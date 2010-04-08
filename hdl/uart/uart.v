module uart #(
  // UART parameters
  parameter BYTESIZE = 8,              // transfer size in bits
  parameter PARITY   = "NONE",         // parity type "EVEN", "ODD", "NONE"
  parameter STOPSIZE = 1,              // number of stop bits
  parameter N_BIT    = 1,              // clock cycles per bit
  parameter N_LOG    = $clog2(N_BIT),  // size of boudrate generator counter
  // Avalon parameters
  parameter AAW = 1,     // address width
  parameter ADW = 32,    // data width
  parameter ABW = ADW/8  // byte enable width
)(
  // system signals
  input                clk,  // clock
  input                rst,  // reset (asynchronous)
  // Avalon MM interface
  input                avalon_read,
  input                avalon_write,
  input      [AAW-1:0] avalon_address,
  input      [ABW-1:0] avalon_byteenable,
  input      [ADW-1:0] avalon_writedata,
  output     [ADW-1:0] avalon_readdata,
  output               avalon_waitrequest,
  // receiver status
  output               status_irq,  // interrupt
  output               status_err,  // error
  // UART
  input                uart_rxd,  // receive
  output reg           uart_txd   // transmit
);

// Avalon signals
wire avalon_write_transfer;
wire avalon_read_transfer;

// UART signals
reg [N_LOG-1:0] txd_baud_cnt,    rxd_pulse_cnt;
wire            txd_shift_pulse, rxd_shift_pulse;
reg             txd_shift_run,   rxd_shift_run;
reg       [3:0] txd_shift_cnt,   rxd_shift_cnt;
reg   [8+1-1:0] txd_shift_reg,   rxd_shift_reg;

//////////////////////////////////////////////////////////////////////////////
// Avalon logic
//////////////////////////////////////////////////////////////////////////////

// avalon transfer status
assign avalon_waitrequest = txd_shift_run;
assign avalon_write_transfer = avalon_write & ~avalon_waitrequest;
assign avalon_read_transfer  = avalon_read  & ~avalon_waitrequest;

assign avalon_readdata = {ADW{1'b0}};

//////////////////////////////////////////////////////////////////////////////
// UART transmitter
//////////////////////////////////////////////////////////////////////////////

// baudrate generator from clock (it counts down to 0 generating a baud pulse)
always @ (posedge clk, posedge rst)
if (rst) txd_baud_cnt <= N_BIT-1;
else     txd_baud_cnt <= txd_shift_pulse ? N_BIT-1 : txd_baud_cnt - txd_shift_run;

// enable signal for shifting logic
assign txd_shift_pulse = ~|txd_baud_cnt;

// bit counter
always @ (posedge clk, posedge rst)
if (rst)                      txd_shift_cnt <= 0;
else begin
  if (avalon_write_transfer)  txd_shift_cnt <= BYTESIZE + (PARITY!="NONE") + STOPSIZE;
  else if (txd_shift_pulse)   txd_shift_cnt <= txd_shift_cnt - 1;
end

// shift status
always @ (posedge clk, posedge rst)
if (rst)                      txd_shift_run <= 1'b0;
else begin
  if (avalon_write_transfer)  txd_shift_run <= 1'b1;
  else if (txd_shift_pulse)   txd_shift_run <= txd_shift_cnt > 'd0;
end

// shift register
always @ (posedge clk)
begin
  if (avalon_write_transfer)  txd_shift_reg <= avalon_writedata[7:0];
  else if (txd_shift_pulse)   txd_shift_reg <= {1'b1, txd_shift_reg[7:1]};
end

// output register
always @ (posedge clk, posedge rst)
if (rst)                      uart_txd <= 1'b1;
else begin
  if (avalon_write_transfer)  uart_txd <= 1'b0;
  else if (txd_shift_pulse)   uart_txd <= txd_shift_reg[0];
end

//////////////////////////////////////////////////////////////////////////////
// UART receiver
//////////////////////////////////////////////////////////////////////////////

endmodule

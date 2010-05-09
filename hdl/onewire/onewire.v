module onewire #(
  // UART parameters
  parameter N_BIT    = 2,              // clock cycles per bit
  parameter N_LOG    = $clog2(N_BIT),  // size of boudrate generator counter
  // Avalon parameters
  parameter ADW = 32,    // data width
)(
  // system signals
  input                clk,  // clock
  input                rst,  // reset (asynchronous)
  // Avalon MM interface
  input                avalon_read,
  input                avalon_write,
  input      [ADW-1:0] avalon_writedata,
  output     [ADW-1:0] avalon_readdata,
  output               avalon_waitrequest,
  output               avalon_interrupt,
  // onewire
  inout                onewire,
);

// Avalon signals
wire avalon_trn_w;
wire avalon_trn_r;

// onewire signals
reg o_od;   // overdrive
reg o_rst;  // reset
reg o_dtx;  // data bit transmit
reg o_drx;  // data bit receive
reg o_stx;  // status transmit
reg o_srx;  // status receive

//////////////////////////////////////////////////////////////////////////////
// Avalon logic
//////////////////////////////////////////////////////////////////////////////

// Avalon transfer status
assign avalon_waitrequest = txd_run & ~avalon_read;
assign avalon_trn_w = avalon_write & ~avalon_waitrequest;
assign avalon_trn_r = avalon_read  & ~avalon_waitrequest;

// Avalon read data
assign avalon_readdata = {26'd0, o_srx, o_stx, o_drx, o_dtx, o_rst, o_od};

// Avalon interrupt
assign avalon_interrupt = o_srx | o_stx;

//////////////////////////////////////////////////////////////////////////////
// UART transmitter
//////////////////////////////////////////////////////////////////////////////

// overdrive
always @ (posedge clk, posedge rst)
if (rst)                        o_od  <= 1'b0;     
else if (avalon_trn_w)          o_od  <= avalon_writedata[0]; 

// reset
always @ (posedge clk, posedge rst)
if (rst)                        o_rst <= 1'b0;
else begin
  if (avalon_trn_w)             o_rst <= avalon_writedata[0];
  else if ((cnt == 'd1) & pls)  o_rst <= 1'b0;
end

// transmit data
always @ (posedge clk, posedge rst)
if (rst)                        o_dtx <= 1'b0;
else begin
  if (avalon_trn_w)             o_dtx <= avalon_writedata[0];
  else if ((cnt == 'd1) & pls)  o_dtx <= 1'b0;
end

// avalon run status
always @ (posedge clk, posedge rst)
if (rst)                        o_run <= 1'b0;
else begin
  if (avalon_trn_w)             o_run <= 1'b1;
  else if ((cnt == 'd0) & pls)  o_run <= 1'b0;
end

// clock divider
always @ (posedge clk, posedge rst)
if (rst)                        o_div <= 0;
else                            o_div <= ;

// 

// state counter
always @ (posedge clk, posedge rst)
if (rst)             cnt <= 0;
else begin
  if (avalon_trn_w)  cnt <=  11;
  else if (cyc)      cnt <= cnt - 1;
end

// transmit status
always @ (posedge clk, posedge rst)
if (rst)             stx <= 1'b0;
else begin
  if (avalon_trn_w)  stx <= 1'b1;
  else if (txd_ena)  stx <= (cnt == 'd0);
end

// receive status
always @ (posedge clk, posedge rst)
if (rst)             srx <= 1'b0;
else begin
  if (avalon_trn_w)  srx <= 1'b1;
  else if (txd_ena)  srx <= (cnt == 'd0);
end

// output register
always @ (posedge clk, posedge rst)
if (rst)             uart_txd <= 1'b1;
else begin
  if (avalon_trn_w)  uart_txd <= 1'b0;
  else if (txd_ena)  uart_txd <= txd_dat[0];
end

endmodule

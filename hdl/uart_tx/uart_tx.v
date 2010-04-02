module uart_tx #(
  parameter AAW = 1,     // address width
  parameter ADW = 32,    // data width
  parameter ABW = ADW/8  // byte enable width
)(
  // system signals
  input                clk,  // clock
  input                rst,  // reset (asynchronous)
  // Avalon MM interface
  input                avalon_read,         //
  input                avalon_write,        //
  input      [AAW-1:0] avalon_address,      //
  input      [ABW-1:0] avalon_byteenable,   //
  input      [ADW-1:0] avalon_writedata,    //
  output     [ADW-1:0] avalon_readdata,     //
  output               avalon_waitrequest,  //
  // UART
//  input                uart_rx,  // receive
  output reg           uart_tx  // transmit
);

wire avalon_transfer;

wire          pulse;
wire          shift_pulse;
reg           shift_run;
reg     [3:0] shift_cnt;
reg [8+1-1:0] shift_reg;

// avalon transfer status
assign avalon_waitrequest = shift_run;
assign avalon_transfer = (avalon_read | avalon_write) & ~avalon_waitrequest;

assign avalon_readdata = {ADW{1'b0}};

// enable signal for shifting logic
assign pulse = 1'b1;
assign shift_pulse = shift_run & pulse;

// bit counter
always @ (posedge clk, negedge rst)
if (rst)                 shift_cnt <= 0;
else begin
  if (avalon_transfer)   shift_cnt <= 'd8;
  else if (shift_pulse)  shift_cnt <= shift_cnt - 1;
end

// shift status
always @ (posedge clk, negedge rst)
if (rst)                 shift_run <= 1'b0;
else begin                                
  if (avalon_transfer)   shift_run <= 1'b1;        
  else if (shift_pulse)  shift_run <= (shift_cnt > 'd0);
end

// shift register
always @ (posedge clk)
begin                                
  if (avalon_transfer)   shift_reg <= avalon_writedata[7:0];        
  else if (shift_pulse)  shift_reg <= {1'b1, shift_reg[7:1]};
end

// output register
always @ (posedge clk, posedge rst)
if (rst)                 uart_tx <= 1'b1;                                
else begin                                
  if (avalon_transfer)   uart_tx <= 1'b0;        
  else if (shift_pulse)  uart_tx <= shift_reg[0];
end

endmodule

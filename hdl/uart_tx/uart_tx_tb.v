`timescale 1ns / 1ps

module uart_tx_tb;

// uart_tx width local parameter
localparam AAW = 1;      // address width
localparam ADW = 32;     // data width
localparam ABW = ADW/8;  // byte enable width

// system_signals
reg            clk;  // clock
reg            rst;  // reset (asynchronous)
// Avalon MM interface
reg            avalon_read;         //
reg            avalon_write;        //
reg  [AAW-1:0] avalon_address;      //
reg  [ABW-1:0] avalon_byteenable;   //
reg  [ADW-1:0] avalon_writedata;    //
wire [ADW-1:0] avalon_readdata;     //
wire           avalon_waitrequest;  //
// UART
wire           uart_tx;

// request for a dumpfile
initial begin
  $dumpfile("uart_tx.vcd");
  $dumpvars(0, uart_tx_tb);
end

// clock generation
initial    clk = 1'b1;
always #10 clk = ~clk;

// test signal generation
initial begin
  // initially the uart_tx is under reset end disabled
  rst = 1'b1;
  // Avalon MM interface is idle
  avalon_read = 1'b0;
  avalon_write = 1'b0;
  repeat (2) @(posedge clk);
  // remove reset
  rst = 1'b0;
  repeat (2) @(posedge clk);
  // perform Avalon MM fundamental writes
  avalon_read       = 1'b0;
  avalon_write      = 1'b1;
  avalon_address    = {AAW{1'b0}};
  avalon_byteenable = 4'b1111;
  avalon_writedata  = {24'h00_00_00, 8'ha5};
  repeat (30) @(posedge clk);
  $finish(); 
end

// instantiate uart_tx RTL
uart_tx #(
  .AAW   (AAW),
  .ADW   (ADW)
) uart_tx_i (
  // system
  .clk  (clk),
  .rst  (rst),
  // Avalon
  .avalon_read         (avalon_read),
  .avalon_write        (avalon_write),
  .avalon_address      (avalon_address),
  .avalon_byteenable   (avalon_byteenable),
  .avalon_writedata    (avalon_writedata),
  .avalon_readdata     (avalon_readdata),
  .avalon_waitrequest  (avalon_waitrequest),
  // UART
  .uart_tx             (uart_tx)
);

endmodule

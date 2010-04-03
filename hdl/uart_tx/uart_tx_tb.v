`timescale 1ns / 1ps

module uart_tx_tb;

// system clock parameters
//localparam FRQ = 24_000_000;  // 24MHz // realistic option                                                                                                            
localparam FRQ =  1_000_000;  //  1MHz // option for faster simulation
localparam real CP = 1000000000/FRQ;  // clock period

// Avalon MM parameters
localparam AAW = 1;      // address width
localparam ADW = 32;     // data width
localparam ABW = ADW/8;  // byte enable width

// UART parameters
localparam BAUDRATE = 9600;

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
// Avalon MM local signals
wire           avalon_transfer;
reg  [ADW-1:0] data;
// UART
//wire           uart_rx;
wire           uart_tx;

// request for a dumpfile
initial begin
  $dumpfile("uart_tx.vcd");
  $dumpvars(0, uart_tx_tb);
end

// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// test signal generation
initial begin
  // initially the uart_tx is under reset end disabled
  rst = 1'b1;
  // Avalon MM interface is idle
  avalon_read  = 1'b0;
  avalon_write = 1'b0;
  repeat (2) @(posedge clk);
  // remove reset
  rst = 1'b0;
  repeat (2) @(posedge clk);
  // perform Avalon MM fundamental writes
  avalon_cycle (1, 0, 4'hf, "H", data);
  avalon_cycle (1, 0, 4'hf, "e", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "o", data);
  avalon_cycle (1, 0, 4'hf, ",", data);
  repeat (20) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, " ", data);
  repeat (1) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, "W", data);
  avalon_cycle (1, 0, 4'hf, "o", data);
  avalon_cycle (1, 0, 4'hf, "r", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "d", data);
  avalon_cycle (1, 0, 4'hf, "!", data);
  repeat (20) @(posedge clk);
  $finish(); 
end

// avalon transfer cycle generation task
task avalon_cycle (
  input            r_w,  // 0-read or 1-write cycle
  input  [AAW-1:0] adr,
  input  [ABW-1:0] ben,
  input  [ADW-1:0] wdt,
  output [ADW-1:0] rdt
);
begin
  $write ("Avalon MM cycle: T_start=%10tns, %s transfer address=%08x byteenable=%04b writedata=%08x - ",
                            $time/1000.0, r_w?"write":"read ", adr, ben,           wdt              );
  // start an Avalon cycle
  avalon_read       <= ~r_w;
  avalon_write      <=  r_w;
  avalon_address    <=  adr;
  avalon_byteenable <=  ben;
  avalon_writedata  <=  wdt;
  // wait for waitrequest to be retracted
  @ (posedge clk); while (~avalon_transfer) @ (posedge clk);
  // end Avalon cycle
  avalon_read       <= 1'b0;
  avalon_write      <= 1'b0;
  // read data
  rdt = avalon_readdata;
  $write ("readdata=%08x, T_stop=%10tns\n",
           rdt,           $time/1000.0  );
end
endtask

// avalon cycle transfer cycle end status
assign avalon_transfer = (avalon_read | avalon_write) & ~avalon_waitrequest;

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
  //.uart_rx             (uart_rx),
  .uart_tx             (uart_tx)
);

endmodule

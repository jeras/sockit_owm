`timescale 1ns / 1ps

module onewire_tb;

// system clock parameters
localparam real FRQ = 24_000_000;     // 24MHz // realistic option
localparam real CP  = 1000000000/FRQ;  // clock period
localparam      DVN = FRQ/6000;        // 

// Avalon MM parameters
localparam AAW = 1;      // address width
localparam ADW = 32;     // data width
localparam ABW = ADW/8;  // byte enable width

// system_signals
reg            clk;  // clock
reg            rst;  // reset (asynchronous)
// Avalon MM interface
reg            avalon_read;
reg            avalon_write;
reg  [AAW-1:0] avalon_address;
reg  [ABW-1:0] avalon_byteenable;
reg  [ADW-1:0] avalon_writedata;
wire [ADW-1:0] avalon_readdata;
wire           avalon_waitrequest;
wire           avalon_interrupt;

// Avalon MM local signals
wire           avalon_transfer;
reg  [ADW-1:0] data;

// onewire
wire           onewire;

// request for a dumpfile
initial begin
  $dumpfile("onewire.vcd");
  $dumpvars(0, onewire_tb);
end

//////////////////////////////////////////////////////////////////////////////
// clock and reset
//////////////////////////////////////////////////////////////////////////////

// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// reset generation
initial begin
  rst = 1'b1;
  repeat (2) @(posedge clk);
  rst = 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
// Avalon write and read transfers
//////////////////////////////////////////////////////////////////////////////

initial begin
  // Avalon MM interface is idle
  avalon_read  = 1'b0;
  avalon_write = 1'b0;

  // long delay to skip presence pulse
  repeat (1000) @(posedge clk);

  // generate a reset pulse
  avalon_cycle (1, 0, 4'hf, 32'b00_000010, data);
  // wait for the reset to finish
  data = 32'd0;
  while (!(data & 32'h10))
  avalon_cycle (0, 0, 4'hf, 32'hxxxx_xxxx, data);
  // write a sequence
  avalon_cycle (1, 0, 4'hf, 32'b00_000000, data);

  // wait a few cycles and finish
  repeat (1000) @(posedge clk);
  $finish(); 
end

//////////////////////////////////////////////////////////////////////////////
// Avalon transfer cycle generation task
//////////////////////////////////////////////////////////////////////////////

task automatic avalon_cycle (
  input            r_w,  // 0-read or 1-write cycle
  input  [AAW-1:0] adr,
  input  [ABW-1:0] ben,
  input  [ADW-1:0] wdt,
  output [ADW-1:0] rdt
);
begin
  $display ("Avalon MM cycle start: T=%10tns, %s address=%08x byteenable=%04b writedata=%08x", $time/1000.0, r_w?"write":"read ", adr, ben, wdt);
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
  $display ("Avalon MM cycle end  : T=%10tns, readdata=%08x", $time/1000.0, rdt);
end
endtask

// avalon cycle transfer cycle end status
assign avalon_transfer = (avalon_read | avalon_write) & ~avalon_waitrequest;

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

onewire #(
  .DVN    (5)
) onewire_master (
  // system
  .clk  (clk),
  .rst  (rst),
  // Avalon
  .avalon_read         (avalon_read),
  .avalon_write        (avalon_write),
  .avalon_writedata    (avalon_writedata),
  .avalon_readdata     (avalon_readdata),
  .avalon_waitrequest  (avalon_waitrequest),
  .avalon_interrupt    (avalon_interrupt),
  // UART
  .onewire             (onewire)
);

// onewire pullup
pullup onewire_pullup (onewire);

//////////////////////////////////////////////////////////////////////////////
// Verilog onewire slave model
//////////////////////////////////////////////////////////////////////////////

onewire_slave_model #(
) onewire_slave (
  .onewire  (onewire)
);

endmodule

`timescale 1ns / 1ps

module avalon_ram_tb;

// system clock parameters                                                                                                                                              
localparam real FRQ = 24_000_000;     // clock frequency 24MHz
localparam real CP = 1000000000/FRQ;  // clock period

// Avalon MM parameters
localparam ADW = 32;               // data width
localparam ABW = ADW/8;            // byte enable width
localparam ASZ = 1024;             // address space size in bytes
localparam AAW = $clog2(ASZ/ABW);  // address width

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
// Avalon MM local signals
wire           avalon_transfer;
reg  [ADW-1:0] data;

// request for a dumpfile
initial begin
  $dumpfile("avalon_ram.vcd");
  $dumpvars(0, avalon_ram_tb);
end


// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// test signal generation
initial begin
  // initially the avalon_ram is under reset end disabled
  rst = 1'b1;
  // Avalon MM interface is idle
  avalon_read  = 1'b0;
  avalon_write = 1'b0;
  repeat (2) @(posedge clk);
  // remove reset
  rst = 1'b0;
  repeat (2) @(posedge clk);
  //  8bit write all, read all bytes
  avalon_cycle (1,  0, 4'b0001, 32'hxxxxxx67, data);
  avalon_cycle (1,  0, 4'b0010, 32'hxxxx45xx, data);
  avalon_cycle (1,  0, 4'b0100, 32'hxx23xxxx, data);
  avalon_cycle (1,  0, 4'b1000, 32'h01xxxxxx, data);
  avalon_cycle (0,  0, 4'b0001, 32'hxxxxxxxx, data);
  avalon_cycle (0,  0, 4'b0010, 32'hxxxxxxxx, data);
  avalon_cycle (0,  0, 4'b0100, 32'hxxxxxxxx, data);
  avalon_cycle (0,  0, 4'b1000, 32'hxxxxxxxx, data);
  repeat (1) @(posedge clk);
  //  8bit write, read byte interleave
  avalon_cycle (1,  4, 4'b0001, 32'h89abcdef, data);
  avalon_cycle (0,  4, 4'b0001, 32'h00000000, data);
  avalon_cycle (1,  4, 4'b0010, 32'h89abcdef, data);
  avalon_cycle (0,  4, 4'b0010, 32'h00000000, data);
  avalon_cycle (1,  4, 4'b0100, 32'h89abcdef, data);
  avalon_cycle (0,  4, 4'b0100, 32'h00000000, data);
  avalon_cycle (1,  4, 4'b1000, 32'h89abcdef, data);
  avalon_cycle (0,  4, 4'b1000, 32'h00000000, data);
  repeat (4) @(posedge clk);
  // 16bit write all, read all
  avalon_cycle (1,  8, 4'b0011, 32'hxxxxba98, data);
  avalon_cycle (1,  8, 4'b1100, 32'hfedcxxxx, data);
  avalon_cycle (0,  8, 4'b0011, 32'hxxxxxxxx, data);
  avalon_cycle (0,  8, 4'b1100, 32'hxxxxxxxx, data);
  repeat (1) @(posedge clk);
  // 16bit write, read interleave
  avalon_cycle (1, 12, 4'b0011, 32'hxxxx3210, data);
  avalon_cycle (0, 12, 4'b0011, 32'hxxxxxxxx, data);
  avalon_cycle (1, 12, 4'b1100, 32'h7654xxxx, data);
  avalon_cycle (0, 12, 4'b1100, 32'hxxxxxxxx, data);
  avalon_cycle (1,  8, 4'b1100, 32'hfedcxxxx, data);
  avalon_cycle (0,  8, 4'b0011, 32'hxxxxxxxx, data);
  repeat (4) @(posedge clk);
  // 32bit write, read
  avalon_cycle (1, 60, 4'b1111, 32'hdeadbeef, data);
  avalon_cycle (0, 60, 4'b1111, 32'hxxxxxxxx, data);
  repeat (2) @(posedge clk);
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

// instantiate avalon_ram RTL
avalon_ram #(
  .ADW   (ADW),
  .ASZ   (ASZ)
) avalon_ram_i (
  // system
  .clk  (clk),
  .rst  (rst),
  // Avalon
  .read         (avalon_read),
  .write        (avalon_write),
  .address      (avalon_address),
  .byteenable   (avalon_byteenable),
  .writedata    (avalon_writedata),
  .readdata     (avalon_readdata),
  .waitrequest  (avalon_waitrequest)
);

endmodule

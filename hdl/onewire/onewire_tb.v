//////////////////////////////////////////////////////////////////////////////                                                                                          
//                                                                          //
//  Minimalistic 1-wire (onewire) master with Avalon MM bus interface       //
//  testbench                                                               //
//                                                                          //
//  Copyright (C) 2010  Iztok Jeras                                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  This RTL is free hardware: you can redistribute it and/or modify        //
//  it under the terms of the GNU Lesser General Public License             //
//  as published by the Free Software Foundation, either                    //
//  version 3 of the License, or (at your option) any later version.        //
//                                                                          //
//  This RTL is distributed in the hope that it will be useful,             //
//  but WITHOUT ANY WARRANTY; without even the implied warranty of          //
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           //
//  GNU General Public License for more details.                            //
//                                                                          //
//  You should have received a copy of the GNU General Public License       //
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module onewire_tb;

// system clock parameters
localparam real FRQ =  4_000_000;      // 24MHz // realistic option
localparam real CP  = 1000000000/FRQ;  // clock period
localparam      CDR = 7500/CP;         // divider number

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
wire           owr;     // bidirectional
wire           owr_i;   // input into master
wire           owr_oe;  // output enable from master

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
  #1000_000;

  // generate a reset pulse
  avalon_cycle (1, 0, 4'hf, 32'b00000010, data);
  avalon_pulling (8, 0);
  // write '0'
  avalon_cycle (1, 0, 4'hf, 32'b00000000, data);
  avalon_pulling (8, 0);
  // write '1'
  avalon_cycle (1, 0, 4'hf, 32'b00000100, data);
  avalon_pulling (8, 0);

  // switch to overdrive mode

  // generate a reset pulse
  avalon_cycle (1, 0, 4'hf, 32'b00000011, data);
  avalon_pulling (8, 0);
  // write '0'
  avalon_cycle (1, 0, 4'hf, 32'b00000001, data);
  avalon_pulling (8, 0);
  // write '1'
  avalon_cycle (1, 0, 4'hf, 32'b00000101, data);
  avalon_pulling (8, 0);
  // wait a few cycles and finish
  repeat (10) @(posedge clk);
  $finish(); 
end

// wait for the onewire cycle completion
task avalon_pulling (input integer d, n);
begin
  data = 32'd0;
  while (!(data & 32'h10)) begin
    repeat (d) @ (posedge clk);
    avalon_cycle (0, 0, 4'hf, 32'hxxxx_xxxx, data);
  end
end endtask

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

assign avalon_waitrequest = 1'b0;

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

sockit_owm #(
  .CDR    (CDR)
) onewire_master (
  // system
  .clk  (clk),
  .rst  (rst),
  // Avalon
  .avalon_read         (avalon_read),
  .avalon_write        (avalon_write),
  .avalon_writedata    (avalon_writedata),
  .avalon_readdata     (avalon_readdata),
  .avalon_interrupt    (avalon_interrupt),
  // onewire
  .owr_oe              (owr_oe),
  .owr_i               (owr_i)
);

// onewire
pullup onewire_pullup (owr);
assign owr   = owr_oe ? 1'b0 : 1'bz;
assign owr_i = owr;

//////////////////////////////////////////////////////////////////////////////
// Verilog onewire slave model
//////////////////////////////////////////////////////////////////////////////

onewire_slave_model #(
) onewire_slave (
  .owr  (owr)
);

endmodule

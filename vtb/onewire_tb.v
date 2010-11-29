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

localparam DEBUG = 1'b0;

// system clock parameters
localparam real FRQ   = 2_000_000;      // 2MHz
localparam real CP    = 1*(10**9)/FRQ;  // clock period in ns

localparam      MTP_N = 7500;           // divider number normal mode
localparam      MTP_O = 1000;           // divider number overdrive mode

localparam      CDR_N = MTP_N / CP;     // divider number normal mode
localparam      CDR_O = MTP_O / CP;     // divider number overdrive mode

// onewire parameters
localparam OWN = 3;      // number of ports

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
wire [OWN-1:0] owr;     // bidirectional
wire [OWN-1:0] owr_p;   // output power enable from master
wire [OWN-1:0] owr_e;   // output pull down enable from master
wire [OWN-1:0] owr_i;   // input into master

// slave conviguration
reg  [OWN-1:0] slave_ena;    // slave enable (connect/disconnect from wire)
reg  [OWN-1:0] slave_ovd;    // overdrive mode enable
reg  [OWN-1:0] slave_dat_r;  // read  data
wire [OWN-1:0] slave_dat_w;  // write data

// timing check variable
real           t_trn;     // transfer cycle time

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

  // initial values for onewire slaves
  slave_ena   = 3'b111;
  slave_dat_r = 3'b000;

  // long delay to skip presence pulse
  #1000_000;

  // test normal mode
  slave_ovd = 3'b000;

  // generate a reset pulse
  avalon_cycle (1, 0, 4'hf, 32'b00000010, data);
  avalon_pulling (8);
  // write '0'
  avalon_cycle (1, 0, 4'hf, 32'b00000000, data);
  avalon_pulling (8);
  // write '1'
  avalon_cycle (1, 0, 4'hf, 32'b00000001, data);
  avalon_pulling (8);

  // test overdrive mode
  slave_ovd = 3'b111;

  // generate a reset pulse
  avalon_cycle (1, 0, 4'hf, 32'b00000110, data);
  avalon_pulling (8);
  // write '0'
  avalon_cycle (1, 0, 4'hf, 32'b00000100, data);
  avalon_pulling (8);
  // write '1'
  avalon_cycle (1, 0, 4'hf, 32'b00000101, data);
  avalon_pulling (8);

  // test power supply

  // generate a delay pulse with power supply enabled
  avalon_cycle (1, 0, 4'hf, 32'h00010003, data);
  avalon_pulling (8);

  // test breaking a delay sequence with an idle transfer

  // generate a delay pulse and break it, before it finishes
  repeat (10) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, 32'h00000003, data);
  repeat (10) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, 32'h00000007, data);

  // wait a few cycles and finish
  repeat (10) @(posedge clk);
  $finish(); 
end

// wait for the onewire cycle completion
task avalon_pulling (input integer d);
  real t_tmp;
begin
  // remember the start time
  t_tmp = $time;
  // pool till owr_trn ends
  data = 32'h02;
  while (data & 32'h02) begin
    repeat (d) @ (posedge clk);
    avalon_cycle (0, 0, 4'hf, 32'hxxxx_xxxx, data);
  end
  // set the transfer length time in us
  t_trn = ($time - t_tmp) / 1000;
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
  if (DEBUG) $display ("Avalon MM cycle start: T=%10tns, %s address=%08x byteenable=%04b writedata=%08x", $time/1000.0, r_w?"write":"read ", adr, ben, wdt);
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
  if (DEBUG) $display ("Avalon MM cycle end  : T=%10tns, readdata=%08x", $time/1000.0, rdt);
end
endtask

// avalon cycle transfer cycle end status
assign avalon_transfer = (avalon_read | avalon_write) & ~avalon_waitrequest;

assign avalon_waitrequest = 1'b0;

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

sockit_owm #(
  .OWN            (OWN),
  .CDR_N          (CDR_N),
  .CDR_O          (CDR_O)
) onewire_master (
  // system
  .clk            (clk),
  .rst            (rst),
  // Avalon
  .bus_read       (avalon_read),
  .bus_write      (avalon_write),
  .bus_writedata  (avalon_writedata),
  .bus_readdata   (avalon_readdata),
  .bus_interrupt  (avalon_interrupt),
  // onewire
  .onewire_p      (owr_p),
  .onewire_e      (owr_e),
  .onewire_i      (owr_i)
);

// onewire
pullup onewire_pullup [OWN-1:0] (owr);

genvar i;
generate for (i=0; i<OWN; i=i+1) begin : owr_loop
  assign owr   [i] = owr_e [i] | owr_p ? owr_p [i] : 1'bz;
  assign owr_i [i] = owr   [i];
end endgenerate

//////////////////////////////////////////////////////////////////////////////
// Verilog onewire slave model
//////////////////////////////////////////////////////////////////////////////

// fast slave device
onewire_slave_model #(
  .TS     (15 + 0.1)
) onewire_slave_min (
  // configuration
  .ena    (slave_ena  [0]),
  .ovd    (slave_ovd  [0]),
  .dat_r  (slave_dat_r[0]),
  .dat_w  (slave_dat_w[0]),
  // 1-wire signal
  .owr    (owr[0])
);

// typical slave device
onewire_slave_model #(
  .TS     (30)
) onewire_slave_typ (
  // configuration
  .ena    (slave_ena  [1]),
  .ovd    (slave_ovd  [1]),
  .dat_r  (slave_dat_r[1]),
  .dat_w  (slave_dat_w[1]),
  // 1-wire signal
  .owr    (owr[1])
);

onewire_slave_model #(
  .TS     (60 - 0.1)
) onewire_slave_max (
  // configuration
  .ena    (slave_ena  [2]),
  .ovd    (slave_ovd  [2]),
  .dat_r  (slave_dat_r[2]),
  .dat_w  (slave_dat_w[2]),
  // 1-wire signal
  .owr    (owr[2])
);

endmodule

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
localparam real FRQ   = 6_000_000;      // 6MHz
localparam real CP    = (10.0**9)/FRQ;  // clock period in ns

// fixed onewire parameters
localparam BDW   = 32;              // bus data width
localparam OWN   = 2*3;             // number of wires

`ifdef PRESET_50_10
localparam OVD_E = 1'b1;   // overdrive functionality enable
localparam BTP_N = "5.0";  // normal    mode
localparam BTP_O = "1.0";  // overdrive mode
`elsif PRESET_60_05
localparam OVD_E = 1'b1;   // overdrive functionality enable
localparam BTP_N = "6.0";  // normal    mode
localparam BTP_O = "0.5";  // overdrive mode
`else // PRESET_75
localparam OVD_E = 1'b0;   // overdrive functionality enable
localparam BTP_N = "7.5";  // normal    mode
localparam BTP_O = "1.0";  // overdrive mode
`endif

// clock dividers for normal and overdrive mode
// NOTE! must be round integer values
`ifdef PRESET_60_05
// there is no way to cast a real value into an integer
localparam integer CDR_N = 45;
localparam integer CDR_O =  4;
`else
localparam integer CDR_N = ((BTP_N == "5.0") ?  5.0 : 7.5 ) * FRQ / 1_000_000;
localparam integer CDR_O = ((BTP_O == "1.0") ?  1.0 : 0.67) * FRQ / 1_000_000;
`endif

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
reg            slave_ena;    // slave enable (connect/disconnect from wire)
reg      [3:0] slave_sel;    // 1-wire slave select
reg            slave_ovd;    // overdrive mode enable
reg            slave_dat_r;  // read  data
wire [OWN-1:0] slave_dat_w;  // write data

// error checking
integer        error;
integer        n;

// loop indexes
integer        i;  // slave timing
integer        j;  // overdrive option

//////////////////////////////////////////////////////////////////////////////
// configuration printout and waveforms
//////////////////////////////////////////////////////////////////////////////

// request for a dumpfile
initial begin
  $dumpfile("onewire.vcd");
  $dumpvars(0, onewire_tb);
end

// print configuration
initial begin
  $display ("NOTE: Config: OVD_E=%0b, CDR_N=%0d, CDR_O=%0d, BTP_N=%f, BTP_O=%f",
                           OVD_E,     CDR_N,     CDR_O, CDR_N*CP/1000, CDR_O*CP/1000);
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
  // reset error counter
  error = 0;

  // Avalon MM interface is idle
  avalon_read  = 1'b0;
  avalon_write = 1'b0;

  // long delay to skip presence pulse
  slave_ena = 1'b0;
  #1000_000;

  // test with slaves with different timing (each slave one one of the wires)
  for (i=0; i<3; i=i+1) begin

    // test reset and data cycles
    for (j=0; j<(OVD_E?2:1); j=j+1) begin

      // select onewire slave (a different set of slaves for overdrive mode)
      slave_sel = i + 3*j;

      // select normal/overdrive mode
      if (j==0)  slave_ovd = 1'b0;  // normal    mode
      if (j==1)  slave_ovd = 1'b1;  // overdrive mode
 
      // testbench status message 
      $display("NOTE: Loop: speed=%s, ovd=%b, BTP=\"%s\")", (i==0) ? "min" : (i==2) ? "max" : "typ", slave_ovd, slave_ovd ? BTP_O : BTP_N);

      // generate a reset pulse
      slave_ena   = 1'b0;
      slave_dat_r = 1'b1;
      avalon_cycle (1, 0, 4'hf, {slave_sel, 5'b00000, slave_ovd, 2'b10}, data);
      avalon_pulling (8, n);
      // expect no response
      if (data[0] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong presence detect responce ('1' expected)", $time);
     end

      // generate a reset pulse
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_cycle (1, 0, 4'hf, {slave_sel, 5'b00000, slave_ovd, 2'b10}, data);
      avalon_pulling (8, n);
      // expect presence response
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong presence detect response ('0' expected)", $time);
     end

      // write '0'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_cycle (1, 0, 4'hf, {slave_sel, 5'b00000, slave_ovd, 2'b00}, data);
      avalon_pulling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '0'", $time);
      end
      // check if '0' was read from the slave
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '0'", $time);
      end

      // write '1', read '1'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b1;
      avalon_cycle (1, 0, 4'hf, {slave_sel, 5'b00000, slave_ovd, 2'b01}, data);
      avalon_pulling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '1', read '1'", $time);
      end
      // check if '1' was read from the slave
      if (data[0] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '1', read '1'", $time);
      end

      // write '1', read '0'
      slave_ena   = 1'b1;
      slave_dat_r = 1'b0;
      avalon_cycle (1, 0, 4'hf, {slave_sel, 5'b00000, slave_ovd, 2'b01}, data);
      avalon_pulling (8, n);
      // check if '0' was written into the slave
      if (slave_dat_w[slave_sel] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong write data for write '1', read '0'", $time);
      end
      // check if '0' was read from the slave
      if (data[0] !== 1'b0) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong read  data for write '1', read '0'", $time);
      end

      // generate a delay/zero pulse with power supply enabled
      avalon_cycle (1, 0, 4'hf, {16'h01<<slave_sel, 4'h0, slave_sel, 5'b00000, slave_ovd, 2'b11}, data);
      avalon_pulling (8, n);
      // check if power is present
      if ((data[0] !== 1'b1) & ~slave_ovd) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong presence detect response (power expected)", $time);
      end
      if (owr_p[slave_sel] !== 1'b1) begin
        error = error+1;
        $display("ERROR: (t=%0t)  Wrong line power state", $time);
      end

    end  // j

  end  // i

  // test power supply

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
task avalon_pulling (
  input  integer dly,
  output integer n
); begin
  // set cycle counter to zero
  n = 0;
  // pool till owr_trn ends
  data = 32'h02;
  while (data & 32'h02) begin
    repeat (dly) @ (posedge clk);
    avalon_cycle (0, 0, 4'hf, 32'hxxxx_xxxx, data);
    n = n + 1;
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
  .BDW            (BDW  ),
  .OWN            (OWN  ),
  .OVD_E          (OVD_E),
  .BTP_N          (BTP_N),
  .BTP_O          (BTP_O),
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

// pullup
pullup onewire_pullup [OWN-1:0] (owr);

// tristate buffers
bufif1 onewire_buffer [OWN-1:0] (owr, owr_p, owr_e | owr_p);

// read back
assign owr_i = owr;

//////////////////////////////////////////////////////////////////////////////
// Verilog onewire slave models for normal mode
//////////////////////////////////////////////////////////////////////////////

// fast slave device
onewire_slave_model #(
  .TS     (15 + 0.1)
) onewire_slave_n_min (
  // configuration
  .ena    (slave_ena     ),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[0]),
  // 1-wire signal
  .owr    (owr[0])
);

// typical slave device
onewire_slave_model #(
  .TS     (30)
) onewire_slave_n_typ (
  // configuration
  .ena    (slave_ena     ),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[1]),
  // 1-wire signal
  .owr    (owr[1])
);

onewire_slave_model #(
  .TS     (60 - 0.1)
) onewire_slave_n_max (
  // configuration
  .ena    (slave_ena     ),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[2]),
  // 1-wire signal
  .owr    (owr[2])
);

//////////////////////////////////////////////////////////////////////////////
// Verilog onewire slave models for overdrive mode
//////////////////////////////////////////////////////////////////////////////

// fast slave device
onewire_slave_model #(
  .TS     (16)
) onewire_slave_o_min (
  // configuration
  .ena    (slave_ena     ),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[0+3]),
  // 1-wire signal
  .owr    (owr[0+3])
);

// typical slave device
onewire_slave_model #(
  .TS     (30)
) onewire_slave_o_typ (
  // configuration
  .ena    (slave_ena     ),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[1+3]),
  // 1-wire signal
  .owr    (owr[1+3])
);

onewire_slave_model #(
  .TS     (47)
) onewire_slave_o_max (
  // configuration
  .ena    (slave_ena     ),
  .ovd    (slave_ovd     ),
  .dat_r  (slave_dat_r   ),
  .dat_w  (slave_dat_w[2+3]),
  // 1-wire signal
  .owr    (owr[2+3])
);

endmodule

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Minimalistic SPI (3 wire) interface with Zbus interface                 //
//                                                                          //
//  Copyright (C) 2008  Iztok Jeras                                         //
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

//////////////////////////////////////////////////////////////////////////////
// this file contains the system bus interface and static registers         //
//////////////////////////////////////////////////////////////////////////////

module spi #(
  // system bus parameters
  parameter DW = 32,         // data bus width
  parameter SW = DW/8,       // select signal width or bus width in bytes
  parameter AW = 32,         // address bus width
  // SPI slave select paramaters
  parameter SSW = 8,         // slave select register width
  // SPI interface configuration parameters
  parameter CFG_bit   =  0,  // select bit mode instead of byte mode by default
  parameter CFG_3wr   =  0,  // duplex type (0 - SPI full duplex, 1 - 3WIRE half duplex (MOSI is shared))
  parameter CFG_oen   =  0,  // MOSI output enable after reset
  parameter CFG_dir   =  1,  // shift direction (0 - LSB first, 1 - MSB first)
  parameter CFG_cpol  =  0,  // clock polarity
  parameter CFG_cpha  =  0,  // clock phase
  // SPI shift register parameters
  parameter PAR_sh_rw = 32,  // shift register width (default width is eqal to wishbone bus width)
  parameter PAR_sh_cw =  5,  // shift counter width (logarithm of shift register width)
  // SPI transfer type parameters
  parameter PAR_tu_rw =  8,  // shift transfer unit register width (default granularity is byte)
  parameter PAR_tu_cw =  3,  // shift transfer unit counter width (counts the bits of a transfer unit)
  // SPI transfer control counter register width (defoult up to 4 byte transfers)
  parameter PAR_tc_rw = PAR_sh_cw - PAR_tu_cw,
  // SPI clock divider parameters
  parameter PAR_cd_en =  1,  // clock divider enable (0 - use full system clock, 1 - use divider)
  parameter PAR_cd_ri =  1,  // clock divider register inplement (otherwise the default clock division factor is used)
  parameter PAR_cd_rw =  8,  // clock divider register width
  parameter PAR_cd_ft =  0   // default clock division factor
)(
  // system signals (used by the CPU bus interface)
  input  wire           clk,
  input  wire           rst,
  // zbus input interface
  input  wire           a_write,
  input  wire           a_read,
  input  wire  [AW-1:0] a_address,
  input  wire  [DW-1:0] a_writedata,
  output wire  [DW-1:0] a_readdata,
  output wire           a_waitrequest,
  output wire           a_interrupt,
  // SPI signals (at a higher level should be connected to tristate IO pads)
  // serial clock
  input  wire           sclk_i,  // input (clock loopback)
  output wire           sclk_o,  // output
  output wire           sclk_e,  // output enable
  // serial input output SIO[3:0] or {HOLD_n, WP_n, MISO, MOSI/3wire-bidir}
  input  wire     [3:0] sio_i,   // input (clock loopback)
  output wire     [3:0] sio_o,   // output
  output wire     [3:0] sio_e,   // output enable
  // active low slave select signal
  output wire [SSW-1:0] ss_n
);

//////////////////////////////////////////////////////////////////////////////
// local signals                                                            //
//////////////////////////////////////////////////////////////////////////////

// clock divider signals
reg  [PAR_cd_rw-1:0] div_cnt;  // clock divider counter
reg  [PAR_cd_rw-1:0] reg_div;  // register holding the requested clock division ratio
wire div_byp;
reg  div_clk;                  // register storing the SCLK clock value (additional division by two)

// spi shifter signals
reg  [PAR_sh_rw-1:0] reg_s;    // spi data shift register
reg  reg_i, reg_o;             // spi input-sampling to output-change phase shift registers
wire ser_i, ser_o;             // shifter serial input and output multiplexed signals
wire spi_mi;                   //
wire clk_l;                    // loopback clock

// spi slave select signals
reg  [SSW-1:0] reg_ss;         // active high slave select register

// spi configuration registers (shift direction, clock polarity and phase, 3 wire option)
reg  cfg_bit, cfg_3wr, cfg_oen, cfg_dir, cfg_cpol, cfg_cpha;

// spi shift transfer control registers
reg  [PAR_sh_cw-1:0] cnt_bit;  // counter of shifted bits
reg  [PAR_tu_cw-1:0] ctl_cnt;  // counter of transfered data units (bytes by defoult)
wire                 ctl_run;  // transfer running status


//////////////////////////////////////////////////////////////////////////////
// bus access implementation (generalisation of wishbone bus signals)       //
//////////////////////////////////////////////////////////////////////////////

// output data multiplexer
assign a_readdata = (a_address[3:2] == 2'd0) ? reg_div :
                    (a_address[3:2] == 2'd1) ? {cfg_bit, cfg_3wr, cfg_oen, cfg_dir, cfg_cpol, cfg_cpha} :
                    (a_address[3:2] == 2'd2) ? {reg_ss, ctl_cnt}:
                                               reg_s;

assign a_waitrequest = 1'b0;
assign a_interrupt   = 1'b0;

//////////////////////////////////////////////////////////////////////////////
// clock divider                                                            //
//////////////////////////////////////////////////////////////////////////////

// clock division factor number register
always @(posedge clk, posedge rst)
if (rst)
  reg_div <= PAR_cd_ft;
else if (a_write & (a_address[3:2] == 0) & ~a_waitrequest)
  reg_div <= a_writedata;

// divider bypass bit
assign div_byp = reg_div[7];

// clock counter
always @(posedge clk, posedge rst)
if (rst)
  div_cnt <= 'b0;
else begin
  if (~ctl_run | ~|div_cnt)
    div_cnt <= reg_div;
  else if (ctl_run)
    div_cnt <= div_cnt - 1;
end

// clock output register (divider by 2)
always @(posedge clk)
if (~ctl_run)
  div_clk <= cfg_cpol;
else if (~|div_cnt)
  div_clk <= ~div_clk;

assign div_ena = div_byp ? 1 : ~|div_cnt & (div_clk ^ cfg_cpol);

//////////////////////////////////////////////////////////////////////////////
// configuration registers                                                  //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk, posedge rst)
if (rst) begin
  cfg_bit  <= CFG_bit;
  cfg_3wr  <= CFG_3wr;
  cfg_oen  <= CFG_oen;
  cfg_dir  <= CFG_dir;
  cfg_cpol <= CFG_cpol;
  cfg_cpha <= CFG_cpha;
end else if (a_write & (a_address[3:2] == 1) & ~a_waitrequest) begin
  cfg_bit  <= a_writedata [5     ];
  cfg_3wr  <= a_writedata [ 4    ];
  cfg_oen  <= a_writedata [  3   ];
  cfg_dir  <= a_writedata [   2  ];
  cfg_cpol <= a_writedata [    1 ];
  cfg_cpha <= a_writedata [     0];
end

//////////////////////////////////////////////////////////////////////////////
// control registers (transfer counter and serial output enable)            //
//////////////////////////////////////////////////////////////////////////////

// bit counter
always @(posedge clk, posedge rst)
if (rst)
  cnt_bit <= 0;
else if (ctl_run & div_ena)
  cnt_bit <= cnt_bit + 1;

// transfer control counter
always @(posedge clk, posedge rst)
if (rst)
  ctl_cnt <= 0;
else begin
  // write from the CPU bus has priority
  if (a_write & (a_address[3:2] == 2) & ~a_waitrequest)
    ctl_cnt <= a_writedata;
  // decrement at the end of each transfer unit (byte by default)
  else if (&cnt_bit [PAR_tu_cw-1:0] & div_ena)
    ctl_cnt <= ctl_cnt - 1;
end

// spi transfer run status
assign ctl_run = |ctl_cnt;

//////////////////////////////////////////////////////////////////////////////
// spi slave select                                                         //
//////////////////////////////////////////////////////////////////////////////

always @(posedge clk, posedge rst)
if (rst)
  reg_ss <= 'b0;
else if (a_write & (a_address[3:2] == 2) & ~a_waitrequest)
  reg_ss <= a_writedata [DW-1:8];

assign ss_n = ~reg_ss;

//////////////////////////////////////////////////////////////////////////////
// spi shift register                                                       //
//////////////////////////////////////////////////////////////////////////////

// shift register implementation
always @(posedge clk)
if (a_write & (a_address[3:2] == 3) & ~a_waitrequest) begin
  reg_s <= a_writedata; // TODO add fifo code
end else if (ctl_run & div_ena) begin
  if (cfg_dir)  reg_s <= {reg_s [PAR_sh_rw-2:0], ser_i};
  else          reg_s <= {ser_i, reg_s [PAR_sh_rw-1:1]};
end

// the serial output from the shift register depends on the direction of shifting
assign ser_o  = (cfg_dir) ? reg_s [PAR_sh_rw-1] : reg_s [0];

always @(posedge clk_l)
if ( cfg_cpha)  reg_o <= ser_o;

always @(posedge clk_l)
if (~cfg_cpha)  reg_i <= spi_mi;

// spi clock output pin
assign sclk_o = div_byp ? cfg_cpol ^ (ctl_run & ~clk) : div_clk;

// loop clock
assign clk_l  = sclk_i ^ cfg_cpol;

// the serial input depends on the used protocol (SPI, 3 wire)
assign spi_mi   = cfg_3wr ? sio_i[0] : sio_i[1];

assign ser_i    = ~cfg_cpha ? reg_i : spi_mi;
assign sio_o[0] = ~cfg_cpha ? ser_o : reg_o;
assign sio_e[0] = cfg_oen;

// temporary IO handler

assign sclk_e     = 1'b1;
assign sio_o[3:1] = 3'b11x;
assign sio_e[3:1] = 3'b110;


endmodule

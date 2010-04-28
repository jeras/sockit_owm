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

module spi_tb ();

//////////////////////////////////////////////////////////////////////////////
// local parameters and signals                                             //
//////////////////////////////////////////////////////////////////////////////

localparam DW = 32;
localparam AW = 32;
localparam SW = DW/8;
localparam SSW = 8;

// system signals
reg clk, rst;

// zbus input interface
wire          zms_req;     // transfer request
wire          zms_ack;     // transfer acknowledge
// translated zbus input interface bus
wire [DW-1:0] zms_dat;     // data
wire [AW-1:0] zms_adr;     // address
wire [SW-1:0] zms_sel;     // byte select
wire          zms_wen;     // write enable (0-read or 1-wite)
// zbus output interface
wire          zsm_req;     // transfer request
wire          zsm_ack;     // transfer acknowledge
wire [DW-1:0] zsm_dat;     // data

// SPI signals
wire [SSW-1:0] ss_n;
wire           sclk;
wire           miso;
wire           mosi;
// SPI mosi tristate buffer signals
wire           mosi_i;
wire           mosi_o;
wire           mosi_e;

//////////////////////////////////////////////////////////////////////////////
// testbench                                                                //
//////////////////////////////////////////////////////////////////////////////

initial    clk <= 1'b1;
always  #5 clk <= ~clk;

initial begin
  // request for a dumpfile
  $dumpfile("test.wav");
  $dumpvars(0, spi_tb);
  rst = 1'b1;
  repeat (4) @ (posedge clk);
  #1;
  rst = 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
// avalon tasks                                                             //
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
// spi controller instance                                                  //
//////////////////////////////////////////////////////////////////////////////

spi #(
  // system bus parameters
  .DW   (32),        // data bus width
  .SW   (DW/8),      // select signal width or bus width in bytes
  .AW   (32),        // address bus width
  // SPI slave select paramaters
  .SSW  (8),         // slave select register width
  // SPI interface configuration parameters
  .CFG_dir    ( 1),  // shift direction (0 - LSB first, 1 - MSB first)
  .CFG_cpol   ( 0),  // clock polarity
  .CFG_cpha   ( 0),  // clock phase
  .CFG_3wr    ( 0),  // duplex type (0 - SPI full duplex, 1 - 3WIRE half duplex (MOSI is shared))
  // SPI shift register parameters
  .PAR_sh_rw  (32),  // shift register width (default width is eqal to wishbone bus width)
  .PAR_sh_cw  ( 5),  // shift counter width (logarithm of shift register width)
  // SPI transfer type parameters
  .PAR_tu_rw  ( 8),  // shift transfer unit register width (default granularity is byte)
  .PAR_tu_cw  ( 3),  // shift transfer unit counter width (counts the bits of a transfer unit)
  // SPI clock divider parameters
  .PAR_cd_en  ( 1),  // clock divider enable (0 - use full system clock, 1 - use divider)
  .PAR_cd_ri  ( 1),  // clock divider register inplement (otherwise the default clock division factor is used)
  .PAR_cd_rw  ( 8),  // clock divider register width
  .PAR_cd_ft  ( 0)   // default clock division factor
) spi (
  // system signals (used by the CPU bus interface)
  .clk            (clk),
  .rst            (rst),
  // avalon interface
  .a_write        (a_write      ),
  .a_read         (a_read       ),
  .a_address      (a_address    ),
  .a_writedata    (a_writedata  ),
  .a_readdata     (a_readdata   ),
  .a_waitrequest  (a_waitrequest),
  .a_interrupt    (a_interrupt  ),
  // SPI signals (should be connected to tristate IO pads)
  // serial clock
  .sclk_i         (sclk),
  .sclk_o         (sclk),
  .sclk_e         (sclk_oe),
  // serial input output SIO[3:0] or {HOLD_n, WP_n, MISO, MOSI/3wire-bidir}
  .sio_i          ({hold_n_i, wp_n_i, miso_i, mosi_i}),
  .sio_o          ({hold_n_o, wp_n_o, miso_o, mosi_o}),
  .sio_e          ({hold_n_e, wp_n_e, miso_e, mosi_e}),
  // active low slave select signal
  .ss_n           (ss_n)
);

//////////////////////////////////////////////////////////////////////////////
// SPI tristate buffers                                                     //
//////////////////////////////////////////////////////////////////////////////

// MOSI
assign mosi_i   = mosi;
assign mosi     = mosi_e   ? mosi_o   : 1'bz;
// MISO
assign miso_i   = miso;
assign miso     = miso_e   ? miso_o   : 1'bz;
// WP_n
assign wp_n_i   = wp_n;
assign wp_n     = wp_n_e   ? wp_n_o   : 1'bz;
// HOLD_n
assign hold_n_i = hold_n;
assign hold_n   = hold_n_e ? hold_n_o : 1'bz;

//////////////////////////////////////////////////////////////////////////////
// SPI slave (serial Flash)                                                 //
//////////////////////////////////////////////////////////////////////////////

// loopback for debug purposes
assign miso = ~ss_n[0] ? mosi : 1'bz;

`define Test_s25fl129p00

`ifdef Test_s25fl129p00
// Spansion serial Flash
s25fl129p00 #(
  .mem_file_name ("none")
) Flash (
  .SCK     (sclk),
  .SI      (mosi),
  .CSNeg   (ss_n[0]),
  .HOLDNeg (hold_n),
  .WPNeg   (wp_n),
  .SO      (miso)
);
`endif

`ifdef Test_s25fl032a
// Spansion serial Flash
s25fl032a #(
  .mem_file_name ("none")
) Flash (
  .SCK     (sclk),
  .SI      (mosi),
  .CSNeg   (ss_n[0]),
  .HOLDNeg (1'b1),
  .WNeg    (1'b1),
  .SO      (miso)
);
`endif

`ifdef Test_m25p80
// Numonyx serial Flash
m25p80 
Flash (
  .c         (sclk),
  .data_in   (mosi),
  .s         (ss_n[1]),
  .w         (1'b1),
  .hold      (1'b1),
  .data_out  (miso)
);
defparam Flash.mem_access.initfile = "hdl/bench/numonyx/initM25P80.txt";
`endif

endmodule

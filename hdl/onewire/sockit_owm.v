//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Minimalistic 1-wire (onewire) master with Avalon MM bus interface       //
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


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
// The clock divider parameter is computed with the next formula:           //
//                                                                          //
// CDR = CLK * 7.5us  (example: 40MHz * 7.5us = 300)                        //
//                                                                          //
// If the dividing factor is not a round integer, than the timing of the    //
// controller will be slightly off, and would support only a subset of      //
// 1-wire devices with timing closer to the typical 30us slot. This limits  //
// the system clock to multiples of 133kHz.                                 //
// CLK = CDR * (400/3)kHz = CDR * 133kHz                                    //
//                                                                          //
// If overdrive is needed than the additional restriction is that CDR must  //
// be divisible by 8. This limits the system clock to multiples of 1067kHz. //
// CLK = CDR * (400*8/3)kHz = CDR * 1067kHz                                 //
//                                                                          //
// TODO: if the system clock requirements can not be met, it is possible to //
// recode the state machine to use 6us reference periods, this way a better //
// tolerance to divider ratio error can be achieved.                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

module sockit_owm #(
  // interface parameters
  parameter BDW   =   32,  // bus data width
  parameter OWN   =    1,  // number of 1-wire ports
  // implementation of overdrive enable
  parameter OVD_E =    1,  // overdrive functionality is implemented by default
  // clock divider ratios
  parameter CDR_N =    8,  // normal    mode
  parameter CDR_O =    1,  // overdrive mode
  // master time period
  parameter MTP_N = "7.5", // normal    mode (7.5us, options are "7.5", "5.0" and "6.0")
  parameter MTP_O = "1.0", // overdrive mode (1.0us, options are "1.0",       and "0.5")
  // normal mode timing
  parameter T_RSTH_N = (MTP_N == "7.5") ?  64 : (MTP_N == "5.0") ?  96 : 80,  // reset high
  parameter T_RSTL_N = (MTP_N == "7.5") ?  64 : (MTP_N == "5.0") ?  96 : 80,  // reset low
  parameter T_RSTP_N = (MTP_N == "7.5") ?  10 : (MTP_N == "5.0") ?  15 : 10,  // reset presence pulse
  parameter T_DAT0_N = (MTP_N == "7.5") ?   8 : (MTP_N == "5.0") ?  12 : 10,  // bit 0 low
  parameter T_DAT1_N = (MTP_N == "7.5") ?   1 : (MTP_N == "5.0") ?   1 :  1,  // bit 1 low
  parameter T_BITS_N = (MTP_N == "7.5") ?   2 : (MTP_N == "5.0") ?   3 :  2,  // bit sample
  parameter T_RCVR_N = (MTP_N == "7.5") ?   1 : (MTP_N == "5.0") ?   1 :  1,  // recovery
  parameter T_IDLE_N = (MTP_N == "7.5") ?  64 : (MTP_N == "5.0") ? 104 :  1,  // recovery
  // overdrive mode timing
  parameter T_RSTH_O = (MTP_N == "1.0") ?  48 :  96,  // reset high
  parameter T_RSTL_O = (MTP_N == "1.0") ?  48 :  96,  // reset low
  parameter T_RSTP_O = (MTP_N == "1.0") ?  10 :  15,  // reset presence pulse
  parameter T_DAT0_O = (MTP_N == "1.0") ?   6 :  12,  // bit 0 low
  parameter T_DAT1_O = (MTP_N == "1.0") ?   1 :   2,  // bit 1 low
  parameter T_BITS_O = (MTP_N == "1.0") ?   2 :   3,  // bit sample
  parameter T_RCVR_O = (MTP_N == "1.0") ?   1 :   2,  // recovery
  parameter T_IDLE_O = (MTP_N == "1.0") ?  48 :  96   // recovery
)(
  // system signals
  input            clk,
  input            rst,
  // bus interface
  input            bus_read,
  input            bus_write,
  input  [BDW-1:0] bus_writedata,
  output [BDW-1:0] bus_readdata,
  output           bus_interrupt,
  // onewire
  output [OWN-1:0] onewire_p,   // output power enable
  output [OWN-1:0] onewire_e,   // output pull down enable
  input  [OWN-1:0] onewire_i    // input from bidirectional wire
);

//////////////////////////////////////////////////////////////////////////////
// local parameters
//////////////////////////////////////////////////////////////////////////////

// size of boudrate generator counter (divider for normal mode is largest)
localparam CDW = $clog2(CDR_N);

// size of port select signal
localparam SDW = $clog2(OWN);

// size of cycle timing counter
localparam TDW =       (T_RSTH_O+T_RSTL_O) >       (T_RSTH_N+T_RSTL_N)
               ? $clog2(T_RSTH_O+T_RSTL_O) : $clog2(T_RSTH_N+T_RSTL_N);

//////////////////////////////////////////////////////////////////////////////
// local signals
//////////////////////////////////////////////////////////////////////////////

// clock divider
//generate if (CDR>1) begin : div_declaration
reg  [CDW-1:0] div;
//end endgenerate
wire           pls;

// transfer control
reg            owr_trn;  // transfer status
reg  [TDW-1:0] cnt;      // transfer counter

// port select
//generate if (OWN>1) begin : sel_declaration
reg  [SDW-1:0] owr_sel;
//end endgenerate

// onewire signals
reg  [OWN-1:0] owr_pwr;  // power
reg            owr_ovd;  // overdrive
reg            owr_rst;  // reset
reg            owr_dtx;  // data bit transmit
reg            owr_drx;  // data bit receive

wire           owr_p;    // output
reg            owr_oen;  // output enable
wire           owr_i;    // input

// interrupt signals
reg            irq_etx;  // interrupt enable transmit
reg            irq_erx;  // interrupt enable receive
reg            irq_stx;  // interrupt status transmit
reg            irq_srx;  // interrupt status receive

// timing signals
wire [TDW-1:0] t_idl ;   // idle                 cycle    time
wire [TDW-1:0] t_rst ;   // reset                cycle    time
wire [TDW-1:0] t_bit ;   // data bit transfer    cycle    time
wire [TDW-1:0] t_rstp;   // reset presence pulse sampling time
wire [TDW-1:0] t_rsth;   // reset                release  time
wire [TDW-1:0] t_dat0;   // data bit 0           release  time
wire [TDW-1:0] t_dat1;   // data bit 1           release  time
wire [TDW-1:0] t_bits;   // data bit transfer    sampling time
wire [TDW-1:0] t_zero;   // end of               cycle    time

//////////////////////////////////////////////////////////////////////////////
// cycle timing
//////////////////////////////////////////////////////////////////////////////

// idle time
assign t_idl  = owr_ovd ? T_IDLE_O                       : T_IDLE_N                      ;
// reset cycle time (reset low + reset hight)
assign t_rst  = owr_ovd ? T_RSTL_O + T_RSTH_O            : T_RSTL_N + T_RSTH_N           ;
// data bit transfer cycle time (write 0 + recovery)
assign t_bit  = owr_ovd ? T_DAT0_O +          + T_RCVR_N : T_DAT0_N +            T_RCVR_O;

// reset presence pulse sampling time (reset high - reset presence)
assign t_rstp = owr_ovd ? T_RSTH_O - T_RSTP_O            : T_RSTH_N - T_RSTP_N           ;
// reset      release time (reset high)
assign t_rsth = owr_ovd ? T_RSTH_O                       : T_RSTH_N                      ;

// data bit 0 release time (write bit 0 - write bit 0 + recovery)
assign t_dat0 = owr_ovd ? T_DAT0_O - T_DAT0_O + T_RCVR_O : T_DAT0_N - T_DAT0_N + T_RCVR_N;
// data bit 1 release time (write bit 0 - write bit 1 + recovery)
assign t_dat1 = owr_ovd ? T_DAT0_O - T_DAT1_O + T_RCVR_O : T_DAT0_N - T_DAT1_N + T_RCVR_N;
// data bit transfer sampling time (write bit 0 - write bit 1 + recovery)
assign t_bits = owr_ovd ? T_DAT0_O - T_BITS_O + T_RCVR_O : T_DAT0_N - T_BITS_N + T_RCVR_N;

// end of cycle time
assign t_zero = 'd0;

//////////////////////////////////////////////////////////////////////////////
// clock divider
//////////////////////////////////////////////////////////////////////////////

// clock division ratio depends on overdrive mode status,
generate if ((CDR_N>1) | (CDR_O>1)) begin : div_implementation
  // clock divider
  always @ (posedge clk, posedge rst)
  if (rst)          div <= 'd0;
  else begin
    if (bus_write)  div <= 'd0;
    else            div <= pls ? 'd0 : div + owr_trn;
  end
  // divided clock pulse
  assign pls = (div == (owr_ovd ? CDR_O : CDR_N) - 1);
end else begin
  // clock period is same as the onewire period
  assign pls = 1'b1;
end endgenerate

//////////////////////////////////////////////////////////////////////////////
// bus logic
//////////////////////////////////////////////////////////////////////////////

// bus read data
generate if (OWN>1) begin : sel_readdata
  assign bus_readdata = {{BDW-OWN-16{1'b0}}, owr_pwr, {8-SDW{1'b0}}, owr_sel,
                         irq_erx, irq_etx, irq_srx, irq_stx,
                         owr_i  , owr_ovd, owr_trn, owr_drx};
end else begin
  assign bus_readdata = {irq_erx, irq_etx, irq_srx, irq_stx,
                         owr_i  , owr_ovd, owr_trn, owr_drx};
end endgenerate

generate if (OWN>1) begin : sel_implementation
  // port select
  always @ (posedge clk, posedge rst)
  if (rst)             owr_sel <= {SDW{1'b0}};
  else if (bus_write)  owr_sel <= bus_writedata[8+:SDW];

  // power delivery
  always @ (posedge clk, posedge rst)
  if (rst)             owr_pwr <= {SDW{1'b0}};
  else if (bus_write)  owr_pwr <= bus_writedata[16+:SDW];
end else begin
  always @ (posedge clk, posedge rst)
  if (rst)             owr_pwr <= 1'b0;
  else if (bus_write)  owr_pwr <= bus_writedata[3];
end endgenerate

// bus interrupt
assign bus_interrupt = irq_erx & irq_srx
                     | irq_etx & irq_stx;

// interrupt enable
always @ (posedge clk, posedge rst)
if (rst)             {irq_erx, irq_etx} <= 2'b00;     
else if (bus_write)  {irq_erx, irq_etx} <= bus_writedata[7:6]; 

// transmit status (active after onewire transfer cycle ends)
always @ (posedge clk, posedge rst)
if (rst)                           irq_stx <= 1'b0;
else begin
  if (bus_write)                   irq_stx <= 1'b0;
  else if (pls & (cnt == t_zero))  irq_stx <= 1'b1;
  else if (bus_read)               irq_stx <= 1'b0;
end

// receive status (active after wire sampling point inside the transfer cycle)
always @ (posedge clk, posedge rst)
if (rst)                     irq_srx <= 1'b0;
else begin
  if (bus_write)             irq_srx <= 1'b0;
  else if (pls) begin
    if      (cnt == t_rstp)  irq_srx <=  owr_rst & ~owr_dtx;  // presence detect
    else if (cnt == t_bits)  irq_srx <= ~owr_rst &  owr_dtx;  // read data bit
  end else if (bus_read)     irq_srx <= 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
// onewire state machine
//////////////////////////////////////////////////////////////////////////////

// transmit data, reset, overdrive
generate if (OVD_E) begin : ctrl_writedata
  always @ (posedge clk, posedge rst)
  if (rst)             {owr_ovd, owr_rst, owr_dtx} <= 3'b000;     
  else if (bus_write)  {owr_ovd, owr_rst, owr_dtx} <= bus_writedata[2:0]; 
end else begin
  always @ (posedge clk, posedge rst)
  if (rst)             {owr_ovd, owr_rst, owr_dtx} <= 3'b000;     
  else if (bus_write)  {         owr_rst, owr_dtx} <= bus_writedata[1:0]; 
end endgenerate

// onewire transfer status
always @ (posedge clk, posedge rst)
if (rst)                           owr_trn <= 1'b0;
else begin
  if (bus_write)                   owr_trn <= ~&bus_writedata[2:0];
  else if (pls & (cnt == t_zero))  owr_trn <= 1'b0;
end

// state counter (initial value depends whether the cycle is reset or data)
always @ (posedge clk, posedge rst)
if (rst)          cnt <= 0;
else begin
  if (bus_write)  cnt <= (&bus_writedata[1:0] ? t_idl : bus_writedata[1] ? t_rst : t_bit) - 'd1;
  else if (pls)   cnt <= cnt - 'd1;
end

// receive data (sampling point depends whether the cycle is reset or data)
always @ (posedge clk)
if (pls) begin
  if      ( owr_rst & (cnt == t_rstp))  owr_drx <= owr_i;  // presence detect
  else if (~owr_rst & (cnt == t_bits))  owr_drx <= owr_i;  // read data bit
end

// output register (switch point depends whether the cycle is reset or data)
always @ (posedge clk, posedge rst)
if (rst)                                owr_oen <= 1'b0;
else begin
  if (bus_write)                        owr_oen <= ~&bus_writedata[1:0];
  else if (pls) begin
    if      (owr_rst & (cnt == t_rsth)) owr_oen <= 1'b0;  // reset
    else if (owr_dtx & (cnt == t_dat1)) owr_oen <= 1'b0;  // write 1, read
    else if (          (cnt == t_dat0)) owr_oen <= 1'b0;  // write 0
  end
end

//////////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////////

// only one 1-wire line cn be accessed at the same time
assign onewire_e = owr_oen << owr_sel;
// all 1-wire lines can be powered independently
assign onewire_p = owr_pwr;

// 1-wire line status read multiplexer
assign owr_i = onewire_i [owr_sel];
assign owr_p = onewire_p [owr_sel];

endmodule

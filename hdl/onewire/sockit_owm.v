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
// be divisible by 10. This limits the system clock to multiples of 1.3MHz. //
// CLK = CDR * (4/3)MHz = CDR * 1,33MHz                                     //
//                                                                          //
// TODO: if the system clock requirements can not be met, it is possible to //
// recode the state machine to use 6us reference periods, this way a better //
// tolerance to divider ratio error can be achieved.                        //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

module sockit_owm #(
  parameter CDR = 10,  // clock cycles per bit (7.5us)
  parameter ADW = 32,  // Avalon bus data width
  parameter OWN = 1    // number of 1-wire ports
)(
  // system signals
  input            clk,
  input            rst,
  // Avalon MM interface
  input            avalon_read,
  input            avalon_write,
  input  [ADW-1:0] avalon_writedata,
  output [ADW-1:0] avalon_readdata,
  output           avalon_interrupt,
  // onewire
  output [OWN-1:0] onewire_o,   // output enable (TODO: fixed to 0 for now)
  output [OWN-1:0] onewire_oe,  // output enable
  input  [OWN-1:0] onewire_i    // input from bidirectional wire
);

//////////////////////////////////////////////////////////////////////////////
// local signals
//////////////////////////////////////////////////////////////////////////////

// size of boudrate generator counter
localparam CDW = $clog2(CDR);

// size of port select signal
localparam SDW = $clog2(OWN);

// clock divider
//generate if (CDR>1) begin : div_declaration
reg [CDW-1:0] div;
//end endgenerate
wire          pls;

// state counter
reg           run;
reg     [6:0] cnt;

// port select
//generate if (OWN>1) begin : sel_declaration
reg [SDW-1:0] sel;
//end endgenerate

// onewire signals
reg  owr_ovd;  // overdrive
reg  owr_rst;  // reset
reg  owr_pwr;  // power
reg  owr_dtx;  // data bit transmit
reg  owr_drx;  // data bit receive

wire owr_o;    // output
reg  owr_oe;   // output enable
wire owr_i;    // input

// interrupt signals
reg  irq_etx;  // interrupt enable transmit
reg  irq_erx;  // interrupt enable receive
reg  irq_stx;  // interrupt status transmit
reg  irq_srx;  // interrupt status receive

//////////////////////////////////////////////////////////////////////////////
// Avalon logic
//////////////////////////////////////////////////////////////////////////////

// Avalon read data
generate if (OWN>1) begin : sel_readdata
  assign avalon_readdata = {{ADW-OWN-8{1'b0}}, sel,
                            irq_erx, irq_etx, irq_srx, irq_stx,
                            owr_pwr, owr_ovd, owr_rst, owr_drx};
end else begin
  assign avalon_readdata = {{ADW-8{1'b0}}, 
                            irq_erx, irq_etx, irq_srx, irq_stx,
                            owr_pwr, owr_ovd, owr_rst, owr_drx};
end endgenerate

generate if (OWN>1) begin : sel_implementation
  // port select
  always @ (posedge clk, posedge rst)
  if (rst)                sel <= {SDW{1'b0}};
  else if (avalon_write)  sel <= avalon_writedata[8+:SDW];
end endgenerate

// Avalon interrupt
assign avalon_interrupt = irq_erx & irq_srx
                        | irq_etx & irq_stx;

// interrupt enable
always @ (posedge clk, posedge rst)
if (rst)                {irq_erx, irq_etx} <= 2'b00;     
else if (avalon_write)  {irq_erx, irq_etx} <= avalon_writedata[7:6]; 

// transmit status
always @ (posedge clk, posedge rst)
if (rst)                        irq_stx <= 1'b0;
else begin
  if (avalon_write)             irq_stx <= avalon_writedata[4];
  else if (pls & (cnt == 'd0))  irq_stx <= 1'b1;
  else if (avalon_read)         irq_stx <= 1'b0;
end

// receive status
always @ (posedge clk, posedge rst)
if (rst)                               irq_srx <= 1'b0;
else begin
  if (avalon_write)                    irq_srx <= avalon_writedata[5];
  else if (pls) begin
    if      (owr_rst & (cnt == 'd54))  irq_srx <= 1'b1;
    else if (owr_dtx & (cnt == 'd07))  irq_srx <= 1'b1;
  end else if (avalon_read)            irq_srx <= 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
// clock divider
//////////////////////////////////////////////////////////////////////////////

generate if (CDR>1) begin : div_implementation
  // clock divider
  always @ (posedge clk, posedge rst)
  if (rst)  div <= 'd0;
  else      div <= pls ? 'd0 : div + run;
  // divided clock pulse
  assign pls = (div == (owr_ovd ? CDR/10 : CDR) - 1);
end else begin
  // clock period is same as the onewire period
  assign pls = 1'b1;
end endgenerate

//////////////////////////////////////////////////////////////////////////////
// onewire
//////////////////////////////////////////////////////////////////////////////

// transmit data, reset, overdrive
always @ (posedge clk, posedge rst)
if (rst)                {owr_pwr, owr_ovd, owr_rst, owr_dtx} <= 4'b0000;     
else if (avalon_write)  {owr_pwr, owr_ovd, owr_rst, owr_dtx} <= avalon_writedata[3:0]; 

// avalon run status
always @ (posedge clk, posedge rst)
if (rst)                        run <= 1'b0;
else begin
  if (avalon_write)             run <= 1'b1;
  else if (pls & (cnt == 'd0))  run <= 1'b0;
end

// state counter (initial value depends whether the cycle is reset or data)
always @ (posedge clk, posedge rst)
if (rst)             cnt <= 0;
else begin
  if (avalon_write)  cnt <= avalon_writedata[1] ? 127 : 8;
  else if (pls)      cnt <= cnt - 1;
end

// receive data
always @ (posedge clk)
if (pls) begin
  if      ( owr_rst & (cnt == 'd54))  owr_drx <= owr_i;
  else if (~owr_rst & (cnt == 'd07))  owr_drx <= owr_i;
end

// output register
always @ (posedge clk, posedge rst)
if (rst)                              owr_oe <= 1'b0;
else begin
  if (avalon_write)                   owr_oe <= ~&avalon_writedata[1:0];
  else if (pls) begin
    if      (owr_rst & (cnt == 'd64)) owr_oe <= 1'b0;
    else if (owr_dtx & (cnt == 'd08)) owr_oe <= 1'b0;
    else if (          (cnt == 'd01)) owr_oe <= 1'b0;
  end
end

//////////////////////////////////////////////////////////////////////////////
// Avalon logic
//////////////////////////////////////////////////////////////////////////////

genvar i;
generate for (i=0; i<OWN; i=i+1) begin : sel_multiplexer
  assign onewire_o  [i] = (i == sel) ? owr_pwr          : 1'b0;
  assign onewire_oe [i] = (i == sel) ? owr_pwr | owr_oe : 1'b0;
end endgenerate
assign owr_i = onewire_i [sel];

endmodule

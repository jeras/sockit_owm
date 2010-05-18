//////////////////////////////////////////////////////////////////////////////                                                                                          
//                                                                          //
//  1-wire (owr) slave model                                                //
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
 
`timescale 1us / 1ns

module onewire_slave_model #(
  // identification
  parameter FAMILY_CODE   =  8'h01,
  parameter SERIAL_NUMBER = 48'hba98_7654_3210,
  parameter CRC_CODE      =  8'hff,
  // time slot (min=15, typ=30, max=60)
  parameter TS = 30
)(
  inout wire owr
);

// commands
localparam Read_ROM           = 8'h33;
localparam Search_ROM         = 8'hf0;
localparam Overdrive_Skip_ROM = 8'h3C;

// IO
reg pull;

// status registers
reg [23:0] state;      // chip state in ASCII
reg [23:0] cycle;      // cycle status in ASCII
reg  [7:0] cmd;        // received command
reg        od;         // overdrive mode status
integer    cnt;        // transfer bit counter

// data registers
reg [7:0] drx;
reg [7:0] dtx;

// events
event transfer;
event clock;
event sample;
event reset;

//////////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////////

assign owr = pull ? 1'b0 : 1'bz;

//////////////////////////////////////////////////////////////////////////////
// events inside a cycle
//////////////////////////////////////////////////////////////////////////////

always @ (negedge owr) begin
  fork
    begin : slot_data
      #((od?TS/10:TS)*1)  -> sample;
    end
    begin : slot_reset
      #((od?TS/10:TS)*8)  -> reset;
    end
    begin : slot_reset_all
      #((od?TS/10:TS)*8*8) begin
      od = 1'b0;
      -> reset;
      end
    end
    begin : slot_end
      @ (posedge owr) begin
        disable slot_data;
        disable slot_reset;
        disable slot_reset_all;
      end
    end
  join
end

// // bit transfer
// always @ (negedge owr) begin
// //task trn (); begin
//   -> transfer;
//   cycle <=  dtx[0] ? "OPN" : "PUL";
//   pull  <= ~dtx[0];
//   cnt   <= cnt + 1;
//   fork
//     // transmit
//     begin : trn_tx
//       #(TS*1);
//       pull <= 1'b0;
//     end
//     // receive
//     begin : trn_rx
//       #(TS*1);
//       drx = {owr, drx[7:1]};
//       -> sample;
//     end
//     // reset
//     begin : trn_rst
//       #(TS*16)
//       state <= "RST";
//       cnt   <= 0;
//     end
//     // wait for owr posedge
//     begin : trn_pdg
//       @ (posedge owr)
//       disable trn_rst;
//     end
//   join
//   cycle <= "IDL";
// end
// //endtask

//////////////////////////////////////////////////////////////////////////////
// logic
//////////////////////////////////////////////////////////////////////////////

// power up state
initial begin
  pull  <= 1'b0;
  #1 -> reset;
end

// reset event
always @ (reset) begin
  // IO state
  pull  <= 1'b0;
  dtx   <= 0;
  cnt   <= 0;
  cycle <= "OPN";
  // power-up chip state
  state <= "RST";
  od    <= 1'b0;
  if (~owr) @ (posedge owr);
  // issue presence pulse
  #((od?TS/10:TS)*1);
  state <= "PRS";
  pull  <= 1'b1;
  #((od?TS/10:TS)*4);
  pull  <= 1'b0;
  state <= "IDL";
end

// // reset
// always @ (negedge owr)
// if (state == "RST") begin
//   trn (); 
//   state <= "IDL";
// end

// // bit transfer
// always @ (negedge owr)
// case (state)
//   "IDL": begin
//     state <= "CMD";
//     trn (); 
//   end
//   "CMD": begin
//     trn ();
//     if (cnt == 8)
//     cmd   <= drx;
//     if (cmd == Read_ROM)
//     state <= "DTX";
//     dtx   <= FAMILY_CODE;
//   end
// endcase


endmodule

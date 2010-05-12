`timescale 1us / 1ns

module onewire_slave_model #(
  // identification
  parameter FAMILY_CODE   =  8'h01,
  parameter SERIAL_NUMBER = 48'hba98_7654_3210,
  parameter CRC_CODE      =  8'hff,
  // internal oscilator period (time resistor capacitor)
  parameter TRC = 6
)(
  inout wire onewire
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

assign onewire = pull ? 1'b0 : 1'bz;

//////////////////////////////////////////////////////////////////////////////
// events inside a cycle
//////////////////////////////////////////////////////////////////////////////

integer osc;

// RC oscilator based delay counter
initial forever begin
  @ (negedge onewire);
  fork
    // RC oscilator timer
    begin : oscilator
      forever begin
        osc = #TRC osc+1;
        -> clock;
      end
    end
    // stop counting on wire posedge
    begin
      @ (posedge onewire);
      disable oscilator;
      osc = 0;
    end
  join
end

always @ (clock) begin
  if (osc ==   8-1)  -> sample;
  if (osc == 8*8-1)  -> reset;
end

// // bit transfer
// always @ (negedge onewire) begin
// //task trn (); begin
//   -> transfer;
//   cycle <=  dtx[0] ? "OPN" : "PUL";
//   pull  <= ~dtx[0];
//   cnt   <= cnt + 1;
//   fork
//     // transmit
//     begin : trn_tx
//       #(TRC*1);
//       pull <= 1'b0;
//     end
//     // receive
//     begin : trn_rx
//       #(TRC*1);
//       drx = {onewire, drx[7:1]};
//       -> sample;
//     end
//     // reset
//     begin : trn_rst
//       #(TRC*16)
//       state <= "RST";
//       cnt   <= 0;
//     end
//     // wait for onewire posedge
//     begin : trn_pdg
//       @ (posedge onewire)
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
  if (~onewire) @ (posedge onewire);
  // issue presence pulse
  #(TRC);
  state <= "PRS";
  pull  <= 1'b1;
  #(TRC*8*4);
  pull  <= 1'b0;
  state <= "IDL";
end

// // reset
// always @ (negedge onewire)
// if (state == "RST") begin
//   trn (); 
//   state <= "IDL";
// end

// // bit transfer
// always @ (negedge onewire)
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

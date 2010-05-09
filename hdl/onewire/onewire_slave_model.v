`timescale 1us / 1ns

module onewire_slave_model #(
  // identification
  parameter FAMILY_CODE   =  8'h01,
  parameter SERIAL_NUMBER = 48'hba98_7654_3210,
  parameter CRC_CODE      =  8'hff,
  // internal oscilator period (time resistor capacitor)
  parameter TRC = 15
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

//////////////////////////////////////////////////////////////////////////////
// IO
//////////////////////////////////////////////////////////////////////////////

assign onewire = pull ? 1'b0 : 1'bx;

//////////////////////////////////////////////////////////////////////////////
// tasks
//////////////////////////////////////////////////////////////////////////////

// bit transfer
task trn (input n); begin
  cycle =  dtx[0] ? "OPN" : "PUL";
  pull  = ~dtx[0];
  cnt   = cnt + 1;
  fork
    // transmit
    begin : trn_tx
      #(TRC*n);
      pull = 1'b0;
    end
    // receive
    begin : trn_rx
      #(TRC);
      drx = {onewire, drx[7:1]};
    end
    // reset
    begin : trn_rst
      #(TRC*8)
      state = "RST";
      cnt   = 0;
    end
    // wait for onewire posedge
    begin : trn_pdg
      @ (posedge onewire)
      disable trn_rst;
    end
  join
  cycle = "IDL";
end endtask

//////////////////////////////////////////////////////////////////////////////
// logic
//////////////////////////////////////////////////////////////////////////////

// power up state
initial begin
  // power-up chip state
  pull  = 1'b0;
  state = "RST";
  od    = 1'b0;
  trn (4);
  state = "IDL";
end

// reset
always @ (negedge onewire)
if (state == "RST") begin
  trn (4); 
  state = "IDL";
end

// bit transfer
always @ (negedge onewire)
case (state)
  "IDL": begin
    state = "CMD";
    trn (1); 
  end
  "CMD": begin
    trn (1);
    if (cnt == 8)
    cmd = drx;
    if (cmd == Read_ROM)
    state = "DTX";
    dtx   = FAMILY_CODE;
  end
endcase


endmodule

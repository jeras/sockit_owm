module stopwatch #(
  // timing parameters
  parameter SPN = 1024,         // second period number
  parameter SPL = $clog2(SPN-1) // second period logarithm (counter width)
)(
  // system signals
  input  wire       clk,        // clock
  input  wire       rst,        // reset
  // buttons (should be debuunced outside this module)
  input  wire       b_run,      // run/stop    button
  input  wire       b_clr,      // clear/split button
  // time outputs
  output reg  [6:0] sec_0,      //     seconds
  output reg  [6:0] sec_1,      // ten seconds
  output reg  [6:0] min_0,      //     minutes
  output reg  [6:0] min_1,      // ten minutes
  // screen status and hold status indicators
  output wire       s_run,
  output wire       s_hld
);

// binary coded decimal to 7 segment conversion
function [6:0] seg7 (input [3:0] bcd);
  case (bcd)
    4'h0    : seg7 = 7'h3F;
    4'h1    : seg7 = 7'h06;
    4'h2    : seg7 = 7'h5B;
    4'h3    : seg7 = 7'h4F;
    4'h4    : seg7 = 7'h66;
    4'h5    : seg7 = 7'h6D;
    4'h6    : seg7 = 7'h7D;
    4'h7    : seg7 = 7'h07;
    4'h8    : seg7 = 7'h7F;
    4'h9    : seg7 = 7'h6F;
    default : seg7 = 7'h00;
  endcase
endfunction

//////////////////////////////////////////////////////////////////////////////
// clock divider
//////////////////////////////////////////////////////////////////////////////

reg [SPL-1:0] clk_cnt;
reg           pulse;

always @ (posedge clk, posedge rst)
if (rst)                 clk_cnt <= 'd0;
else begin
  if (clk_cnt == SPN-1)  clk_cnt <= 'd0;
  else                   clk_cnt <= clk_cnt + 'd1;
end

always @ (posedge clk, posedge rst)
if (rst)  pulse   <= 1'b0;
else      pulse   <= ~|clk_cnt;

//////////////////////////////////////////////////////////////////////////////
// stopwatch status
//////////////////////////////////////////////////////////////////////////////

// delayed button signals and detecting posedge pulse
reg  b_run_d;
reg  b_clr_d;
wire b_run_pdg;
wire b_clr_pdg;

always @ (posedge clk, posedge rst)
if (rst) begin
  b_run_d <= 1'b0;
  b_clr_d <= 1'b0;
end else begin
  b_run_d <= b_run;
  b_clr_d <= b_clr;
end

assign b_run_pdg = ~b_run_d & b_run;
assign b_clr_pdg = ~b_clr_d & b_clr;

// stopwatch status
reg  sts_run;   // run     status (0-stop, 1-running)
reg  sts_hld;   // display status (0-realtime, 1-hold)

always @ (posedge clk, posedge rst)
if (rst) begin
  sts_run <= 1'b0;
  sts_hld <= 1'b0;
end else begin
  if (b_run_pdg) sts_run <= ~sts_run;
  if (b_clr_pdg) sts_hld <= ~sts_hld;
end

//////////////////////////////////////////////////////////////////////////////
// stopwatch
//////////////////////////////////////////////////////////////////////////////

// time counters and hold values
reg  [3:0] cnt_sec_0, hld_sec_0;  //     seconds
reg  [3:0] cnt_sec_1, hld_sec_1;  // ten seconds
reg  [3:0] cnt_min_0, hld_min_0;  //     minutes
reg  [3:0] cnt_min_1, hld_min_1;  // ten minutes
// muxed signal for the output
wire [3:0] mux_sec_0;             //     seconds
wire [3:0] mux_sec_1;             // ten seconds
wire [3:0] mux_min_0;             //     minutes
wire [3:0] mux_min_1;             // ten minutes
// bcd counter wrapping
wire wrp_sec_0;                   //     seconds
wire wrp_sec_1;                   // ten seconds
wire wrp_min_0;                   //     minutes
wire wrp_min_1;                   // ten minutes

// wrapping
assign wrp_sec_0 = (cnt_sec_0 == 4'd9);
assign wrp_sec_1 = (cnt_sec_1 == 4'd5);
assign wrp_min_0 = (cnt_min_0 == 4'd9);
assign wrp_min_1 = (cnt_min_1 == 4'd5);

// counter logic
always @ (posedge clk, posedge rst)
if (rst) begin
  cnt_sec_0 <= 4'd0;
  cnt_sec_1 <= 4'd0;
  cnt_min_0 <= 4'd0;
  cnt_min_1 <= 4'd0;
end else begin
  // if stopwatch is running increment the counters
  if (sts_run) begin
    if (          &                         pulse) cnt_sec_0 <= wrp_sec_0 ? 4'd0 : cnt_sec_0 + 4'd1;
    if (          &             wrp_sec_0 & pulse) cnt_sec_1 <= wrp_sec_1 ? 4'd0 : cnt_sec_1 + 4'd1;
    if (          & wrp_sec_1 & wrp_sec_0 & pulse) cnt_min_0 <= wrp_min_0 ? 4'd0 : cnt_min_0 + 4'd1;
    if (wrp_min_0 & wrp_sec_1 & wrp_sec_0 & pulse) cnt_min_1 <= wrp_min_1 ? 4'd0 : cnt_min_1 + 4'd1;
  end else if (~sts_hld & b_clr) begin
    sec_0 <= 4'd0;
    sec_1 <= 4'd0;
    min_0 <= 4'd0;
    min_1 <= 4'd0;
  end
end

// hold value registers
always @ (posedge clk)
if (sts_run & b_clr) begin
  hld_sec_0 <= cnt_sec_0;
  hld_sec_1 <= cnt_sec_1;
  hld_min_0 <= cnt_min_0;
  hld_min_1 <= cnt_min_1;
end

// counter, hold multiplexer
assign mux_sec_0 = (sts_hld) ? hld_sec_0 : cnt_sec_0;
assign mux_sec_1 = (sts_hld) ? hld_sec_1 : cnt_sec_1;
assign mux_min_0 = (sts_hld) ? hld_min_0 : cnt_min_0;
assign mux_min_1 = (sts_hld) ? hld_min_1 : cnt_min_1;

//////////////////////////////////////////////////////////////////////////////
// conversion to 7 segment for display
//////////////////////////////////////////////////////////////////////////////

// display values
always @ (posedge clk, posedge rst)
if (rst) begin
  sec_0 <= 7'h00;
  sec_1 <= 7'h00;
  min_0 <= 7'h00;
  min_1 <= 7'h00;
end else begin
  sec_0 <= seg7(mux_sec_0);
  sec_1 <= seg7(mux_sec_1);
  min_0 <= seg7(mux_min_0);
  min_1 <= seg7(mux_min_1);
end

assign s_run = sts_run;
assign s_hld = sts_hld;

endmodule

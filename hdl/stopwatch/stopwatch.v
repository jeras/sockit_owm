module stopwatch #(
  // timing parameters
  parameter MSPN = 5,           // milisecond clock periods number
  parameter MSPL = $clog2(MSPN) // milisecond clock periods logarithm (counter width)
)(
  // system signals
  input  wire       clk,        // clock
  input  wire       rst,        // reset
  // buttons (should be debuunced outside this module)
  input  wire       b_run,      // run/stop    button
  input  wire       b_clr,      // clear/split button
  // bcd time outputs
  output wire [3:0] t_mil_0,    //     miliseconds
  output wire [3:0] t_mil_1,    // ten miliseconds
  output wire [3:0] t_mil_2,    // 100 miliseconds
  output wire [3:0] t_sec_0,    //     seconds
  output wire [3:0] t_sec_1,    // ten seconds
  output wire [3:0] t_min_0,    //     minutes
  output wire [3:0] t_min_1,    // ten minutes
  // status indicators
  output reg        s_run,      // run     status (0-stop, 1-running)
  output reg        s_hld       // display status (0-realtime, 1-hold)
);

//////////////////////////////////////////////////////////////////////////////
// clock divider, generates a single clock period pulse every second
//////////////////////////////////////////////////////////////////////////////

reg [MSPL-1:0] clk_cnt;
reg            pulse;

always @ (posedge clk, posedge rst)
if (rst)       clk_cnt <= 'd0;
else begin
  if (~s_run)  clk_cnt <= 'd0;
  else         clk_cnt <= (clk_cnt == MSPN-1) ? 'd0 : clk_cnt + 'd1;
end

always @ (posedge clk, posedge rst)
if (rst)  pulse   <= 1'b0;
else      pulse   <= (clk_cnt == MSPN-1);

//////////////////////////////////////////////////////////////////////////////
// stopwatch status
//////////////////////////////////////////////////////////////////////////////

// delayed button signals and detecting posedge pulse
reg  b_run_d;
reg  b_clr_d;
wire b_run_pdg;
wire b_clr_pdg;

// delaying the button status by one clock period
always @ (posedge clk, posedge rst)
if (rst) begin
  b_run_d <= 1'b0;
  b_clr_d <= 1'b0;
end else begin
  b_run_d <= b_run;
  b_clr_d <= b_clr;
end

// detecting Positive eDGes on button signals
assign b_run_pdg = ~b_run_d & b_run;
assign b_clr_pdg = ~b_clr_d & b_clr;

// run and hold status logic
always @ (posedge clk, posedge rst)
if (rst) begin
  s_run <= 1'b0;
  s_hld <= 1'b0;
end else begin
  if (b_run_pdg) s_run <= ~s_run;
  if (b_clr_pdg) s_hld <= ~s_hld & s_run;
end

//////////////////////////////////////////////////////////////////////////////
// stopwatch
//////////////////////////////////////////////////////////////////////////////

// time counters and hold values
reg  [3:0] cnt_mil_0, hld_mil_0;  //     miliseconds
reg  [3:0] cnt_mil_1, hld_mil_1;  // ten miliseconds
reg  [3:0] cnt_mil_2, hld_mil_2;  // 100 miliseconds
reg  [3:0] cnt_sec_0, hld_sec_0;  //     seconds
reg  [3:0] cnt_sec_1, hld_sec_1;  // ten seconds
reg  [3:0] cnt_min_0, hld_min_0;  //     minutes
reg  [3:0] cnt_min_1, hld_min_1;  // ten minutes
// bcd counter wrapping
wire wrp_mil_0;                   //     miliseconds
wire wrp_mil_1;                   // ten miliseconds
wire wrp_mil_2;                   // 100 miliseconds
wire wrp_sec_0;                   //     seconds
wire wrp_sec_1;                   // ten seconds
wire wrp_min_0;                   //     minutes
wire wrp_min_1;                   // ten minutes

// wrapping from the digit max value back to 0
assign wrp_mil_0 =      1'b1 & (cnt_mil_0 == 4'd9);
assign wrp_mil_1 = wrp_mil_0 & (cnt_mil_1 == 4'd9);
assign wrp_mil_2 = wrp_mil_1 & (cnt_mil_2 == 4'd9);
assign wrp_sec_0 = wrp_mil_2 & (cnt_sec_0 == 4'd9);
assign wrp_sec_1 = wrp_sec_0 & (cnt_sec_1 == 4'd5);
assign wrp_min_0 = wrp_sec_1 & (cnt_min_0 == 4'd9);
assign wrp_min_1 = wrp_min_0 & (cnt_min_1 == 4'd5);

// counter logic
always @ (posedge clk, posedge rst)
if (rst) begin
  cnt_mil_0 <= 4'd0;
  cnt_mil_1 <= 4'd0;
  cnt_mil_2 <= 4'd0;
  cnt_sec_0 <= 4'd0;
  cnt_sec_1 <= 4'd0;
  cnt_min_0 <= 4'd0;
  cnt_min_1 <= 4'd0;
end else begin
  // if stopwatch is running increment the counters
  if (s_run) begin
    if (pulse) begin
      if (     1'b1) cnt_mil_0 <= wrp_mil_0 ? 4'd0 : cnt_mil_0 + 4'd1;
      if (wrp_mil_0) cnt_mil_1 <= wrp_mil_1 ? 4'd0 : cnt_mil_1 + 4'd1;
      if (wrp_mil_1) cnt_mil_2 <= wrp_mil_2 ? 4'd0 : cnt_mil_2 + 4'd1;
      if (wrp_mil_2) cnt_sec_0 <= wrp_sec_0 ? 4'd0 : cnt_sec_0 + 4'd1;
      if (wrp_sec_0) cnt_sec_1 <= wrp_sec_1 ? 4'd0 : cnt_sec_1 + 4'd1;
      if (wrp_sec_1) cnt_min_0 <= wrp_min_0 ? 4'd0 : cnt_min_0 + 4'd1;
      if (wrp_min_0) cnt_min_1 <= wrp_min_1 ? 4'd0 : cnt_min_1 + 4'd1;
    end
  // else if stopwatch is not running, not on hold and clear/split button is pressed
  end else if (~s_hld & b_clr) begin
    cnt_mil_0 <= 4'd0;
    cnt_mil_1 <= 4'd0;
    cnt_mil_2 <= 4'd0;
    cnt_sec_0 <= 4'd0;
    cnt_sec_1 <= 4'd0;
    cnt_min_0 <= 4'd0;
    cnt_min_1 <= 4'd0;
  end
end

// hold (split) value registers
always @ (posedge clk)
if (s_run & b_clr) begin
  hld_mil_0 <= cnt_mil_0;
  hld_mil_1 <= cnt_mil_1;
  hld_mil_2 <= cnt_mil_2;
  hld_sec_0 <= cnt_sec_0;
  hld_sec_1 <= cnt_sec_1;
  hld_min_0 <= cnt_min_0;
  hld_min_1 <= cnt_min_1;
end

// multiplexer between the counter and hold value
assign t_mil_0 = (s_hld) ? hld_mil_0 : cnt_mil_0;
assign t_mil_1 = (s_hld) ? hld_mil_1 : cnt_mil_1;
assign t_mil_2 = (s_hld) ? hld_mil_2 : cnt_mil_2;
assign t_sec_0 = (s_hld) ? hld_sec_0 : cnt_sec_0;
assign t_sec_1 = (s_hld) ? hld_sec_1 : cnt_sec_1;
assign t_min_0 = (s_hld) ? hld_min_0 : cnt_min_0;
assign t_min_1 = (s_hld) ? hld_min_1 : cnt_min_1;


endmodule

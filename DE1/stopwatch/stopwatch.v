module stopwatch #(
  // timing parameters
  parameter MSP  = 1023,        // mili second period
  parameter MSPL = $clog2(MSP)  // mili second period logarithm (counter width)
)(
  // system signals
  input  wire       clk,        // clock
  input  wire       rst,        // reset
  // buttons (should be debuunced outside this module)
  input  wire       b_run,      // run/stop    button
  input  wire       b_clr,      // clear/split button
  // time outputs
  output wire [3:0] sec_0       //     seconds
  output wire [3:0] sec_1,      // ten seconds
  output wire [3:0] min_0,      //     minutes
  output wire [3:0] min_1,      // ten minutes
  // screen status and hold status indicators
  output wire       s_run,
  output wire       s_hld
);

// time counters and hold values
reg [3:0] cnt_sec_0, hld_sec_0;  //     seconds
reg [3:0] cnt_sec_1, hld_sec_1;  // ten seconds
reg [3:0] cnt_min_0, hld_min_0;  //     minutes
reg [3:0] cnt_min_1, hld_min_1;  // ten minutes

// stopwatch status
reg       sts_run;   // run     status (0-stop, 1-running)
reg       sts_hld;   // display status (0-realtime, 1-hold)

// status logic
always @ (posedge clk, posedge rst)
if (rst) begin
  sts_run <= 1'b0;
  sts_hld <= 1'b0;
end else begin
  sts_run <= sts_run ^ b_run;
  sts_hld <= sts_hld ^ b_clr;
end

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
    if (pulse                       ) cnt_sec_0 <= (cnt_sec_0 < 4'd10) ? cnt_sec_0+1 : 4'd0;
    if (pulse & (cnt_sec_0 == 4'd10)) cnt_sec_1 <= (cnt_sec_1 <  4'd6) ? cnt_sec_1+1 : 4'd0;
    if (pulse & (cnt_sec_1 ==  4'd6)) cnt_min_0 <= (cnt_min_0 < 4'd10) ? cnt_min_0+1 : 4'd0;
    if (pulse & (cnt_min_0 == 4'd10)) cnt_min_1 <= (cnt_min_1 <  4'd6) ? cnt_min_1+1 : 4'd0;
  end else if (~sts_hld & b_clr)
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

// display values
assign sec_0 = (sts_hld) ? hld_sec_0 : cnt_sec_0;
assign sec_1 = (sts_hld) ? hld_sec_1 : cnt_sec_1;
assign min_0 = (sts_hld) ? hld_min_0 : cnt_min_0;
assign min_1 = (sts_hld) ? hld_min_1 : cnt_min_1;

assign s_run = sts_run;
assign s_hld = sts_hld;

endmodule

`timescale 1ns / 1ps

module stopwatch_tb;

//localparam real FRQ = 24_000_000;        // 24MHz  // realistic optiony
localparam real FRQ = 5000;              // 5000Hz // option for faster simulation
localparam real CP = 1_000_000_000/FRQ;  // clock period

localparam  SPN = FRQ;                   // a     second in clock periods number
localparam MSPN = SPN/1000;              // a milisecond in clock periods number

// Avalon parameters
localparam AAW = 1;      // address width
localparam ADW = 32;     // data width
localparam ABW = ADW/8;  // byte enable width

// list of local signals
reg        clk;       // clock
reg        rst;      // reset (asynchronous)
// buttons (should be debuunced)
reg        b_run;     // run/stop    button
reg        b_clr;     // clear/split button
reg        b_tmp;     // timepoint   button
// bcd time outputs
wire [3:0] t_mil_0;   //     miliseconds
wire [3:0] t_mil_1;   // ten miliseconds
wire [3:0] t_mil_2;   // 100 miliseconds
wire [3:0] t_sec_0;   //     seconds
wire [3:0] t_sec_1;   // ten seconds
wire [3:0] t_min_0;   //     minutes
wire [3:0] t_min_1;   // ten minutes
// screen status and hold status indicators
wire       s_run;     // run status
wire       s_hld;     // hold status
// Avalon interface
reg            avalon_write;
reg            avalon_read;
reg  [ADW-1:0] avalon_writedata;
wire [ADW-1:0] avalon_readdata;
wire           avalon_interrupt;

// request for a dumpfile
initial begin
  $dumpfile("stopwatch.vcd");
  $dumpvars(0, stopwatch_tb);
end

// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// test signal generation
initial begin
  $display ("DEBUG: SPN=%d, MSPN=%d", SPN, MSPN);

  // buttons are initially not active
  b_run = 1'b0;
  b_clr = 1'b0;
  b_tmp = 1'b0;

  // set Avalon bus into an idle status
  avalon_write = 1'b0;
  avalon_read  = 1'b0;

  // reset sequence
  rst = 1'b1;
  repeat (2) @(posedge clk);
  rst <= 1'b0;
  repeat (10) @(posedge clk);

  // start stopwatch and run it for some time 31s
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (SPN*(31)-10) @(posedge clk);
  // push the leap button to hold the time for 13s
  b_clr <= 1'b1;
  repeat (10) @(posedge clk);
  b_clr <= 1'b0;
  repeat (SPN*(13)-10) @(posedge clk);
  // push the leap button to release the time for 7s
  b_clr <= 1'b1;
  repeat (10) @(posedge clk);
  b_clr <= 1'b0;
  repeat (SPN*(7)-10) @(posedge clk);
  // stop stopwatch and wait for 8s
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (SPN*(8)-10) @(posedge clk);
  // clear the stopwatch and wait for 5s
  b_clr <= 1'b1;
  repeat (10) @(posedge clk);
  b_clr <= 1'b0;
  repeat (SPN*(5)-10) @(posedge clk);

  // restart the stopwatch and run for 5s
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (SPN*(5)-10) @(posedge clk);
  // push the timepoint button
  b_tmp <= 1'b1;
  repeat (10) @(posedge clk);
  b_tmp <= 1'b0;
  repeat (10) @(posedge clk);
  // perform an Avalon read (to get timepoint time)
  avalon_read <= 1'b1;
  @(posedge clk);
  avalon_read <= 1'b0;
  repeat (10) @(posedge clk);
  // perform an Avalon read (to get counter time)
  avalon_read <= 1'b1;
  @(posedge clk);
  avalon_read <= 1'b0;
  repeat (10) @(posedge clk);
  // stop, clear stopwatch and wait for 5s
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (10) @(posedge clk);
  b_clr <= 1'b1;
  repeat (10) @(posedge clk);
  b_clr <= 1'b0;
  repeat (SPN*(5)-30) @(posedge clk);

  // restart the stopwatch and run to 13:13
  b_run <= 1'b1;
  repeat (10) @(posedge clk);
  b_run <= 1'b0;
  repeat (SPN*(13*60+13)-10) @(posedge clk);
  $finish(); 
end

// instantiate counter RTL
stopwatch #(
  // timing parameters
  .MSPN     (MSPN)
) stopwatch_i (
  // system signals
  .clk      (clk),
  .rst      (rst),
  // buttons
  .b_run    (b_run),
  .b_clr    (b_clr),
  .b_tmp    (b_tmp),
  // bcd time outputs
  .t_mil_0  (t_mil_0),
  .t_mil_1  (t_mil_1),
  .t_mil_2  (t_mil_2),
  .t_sec_0  (t_sec_0),
  .t_sec_1  (t_sec_1),
  .t_min_0  (t_min_0),
  .t_min_1  (t_min_1),
  // screen status and hold status indicators
  .s_run    (s_run),
  .s_hld    (s_hld),
  // Avalon CPU interface
  .avalon_write      (avalon_write),
  .avalon_read       (avalon_read),
  .avalon_writedata  (avalon_writedata),
  .avalon_readdata   (avalon_readdata),
  .avalon_interrupt  (avalon_interrupt)
);

endmodule

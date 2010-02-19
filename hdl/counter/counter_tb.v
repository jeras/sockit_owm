module counter_tb;

// counter width local parameter
localparam CW = 3;

// list of local signals
reg           rst;  // clock
reg           clk;  // reset (asynchronous)
reg           ena;  // clear (synchronous)
reg           clr;  // enable
wire [CW-1:0] cnt;  // counter
wire          out;  // running status output

// request for a dumpfile
initial begin
  $dumpfile("counter.vcd");
  $dumpvars(0, counter_tb);
end

 // clock generation
initial    clk = 1'b1;
always #10 clk = ~clk;

// test signal generation
initial begin
  // initially the counter is under reset end disabled
  rst = 1'b1;
  clr = 1'b0;
  ena = 1'b0;
  repeat (2) @(posedge clk);
  // remove reset
  rst = 1'b0;
  repeat (2) @(posedge clk);
  // enable counter
  ena = 1'b1;
  repeat (8) @(posedge clk);
  // test the clear functionality
  clr = 1'b1;
  repeat (4) @(posedge clk);
  clr = 1'b0;
  repeat (8) @(posedge clk);
  $finish(); 
end

// instantiate counter RTL
counter #(
  .CW   (CW)
) counter_i (
  .clk  (clk),
  .rst  (rst),
  .ena  (ena),
  .clr  (clr),
  .cnt  (cnt),
  .out  (out)
);

endmodule

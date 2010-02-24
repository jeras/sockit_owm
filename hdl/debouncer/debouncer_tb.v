`timescale 1ns / 1ps

module debouncer_tb;

// counter length (max debounce time / clock period)
localparam CN = 10_000_000 / 20; 

// list of local signals
reg           clk;  // clock
reg           d_i;  // debouncer inptu
wire          d_o;  // debouncer output

integer i;          // loop variable
integer n;          // number of bounces
integer t;          // time
integer seed;       // random seed

// request for a dumpfile
initial begin
  $dumpfile("debouncer.vcd");
  $dumpvars(0, debouncer_tb);
end

// clock generation
initial    clk = 1'b1;
always #10 clk = ~clk;

// initialize random seed
initial seed = 0;

// test signal generation
// keypress timing is asynchronous
initial begin
  // stable OFF before start for 50ms
  d_i = 1'b0;
  # 50_000_000;
  // switch ON random pulses (max 10ms)
  n = 80;
  for (i=0; i<n; i=i+1) begin
    // short pulses
    d_i = 1'b1;
    t = $dist_uniform(seed, 30, 5000);
    # t;
    // folowed by longer pauses
    d_i = 1'b0;
    t = $dist_uniform(seed, 10_000, 200_000);
    # t;
  end
  // stable ON state for 50ms
  d_i = 1'b1;
  # 50_000_000;
  // switch OFF random pulses (max 10ms)
  n = 80;
  for (i=0; i<n; i=i+1) begin
    // short pulses
    d_i = 1'b0;
    t = $dist_uniform(seed, 30, 5000);
    # t;
    // folowed by longer pauses
    d_i = 1'b1;
    t = $dist_uniform(seed, 10_000, 200_000);
    # t;
  end
  // stable OFF state at the end for 50ms
  d_i = 1'b0;
  # 50_000_000;
  // end simulation
  $finish();
end

// instantiate RTL
debouncer #(
  .CN   (CN)
) debouncer_i (
  .clk  (clk),
  .d_i  (d_i),
  .d_o  (d_o)
);

endmodule

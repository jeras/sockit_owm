`timescale 1ns / 1ps

module debouncer_tb;

// number of debounced signals
localparam DW = 2;

// counter length (max debounce time / clock period)
localparam CP= 200;
localparam CN = 10_000_000 / CP; 

// list of local signals
reg           clk;  // clock
reg  [DW-1:0] d_i;  // debouncer inptu
wire [DW-1:0] d_o;  // debouncer output

integer seed;       // random seed

// request for a dumpfile
initial begin
  $dumpfile("debouncer.vcd");
  $dumpvars(0, debouncer_tb);
end

// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// initialize random seed
initial seed = 0;

genvar d;
generate for (d=0; d<DW; d=d+1) begin

  // test signal generation
  // keypress timing is asynchronous
  initial begin
    // stable OFF before start for 50ms
    d_i[d] = 1'b0;
    # 50_000_000;
    // switch ON random pulses (max 10ms)
    bounce (d, 1'b1, 30, 5000, 10_000, 200_000, 80);
    // stable ON state for 50ms
    d_i[d] = 1'b1;
    # 50_000_000;
    // switch OFF random pulses (max 10ms)
    bounce (d, 1'b0, 30, 5000, 10_000, 200_000, 80);
    // stable OFF state at the end for 50ms
    d_i[d] = 1'b0;
    # 50_000_000;
    // end simulation
    $finish();
  end

end endgenerate

task automatic bounce (
  input         d,
  input         val,
  input integer t_pulse_min, t_pulse_max,
  input integer t_pause_min, t_pause_max,
  input integer n
);
  integer cnt, t;
begin
  for (cnt=0; cnt<n; cnt=cnt+1) begin
    // short pulses
    d_i[d] =  val;  t = $dist_uniform(seed, t_pulse_min, t_pulse_max);  #t;
    // folowed by longer pauses
    d_i[d] = ~val;  t = $dist_uniform(seed, t_pause_min, t_pause_max);  #t;
  end
end
endtask

// instantiate RTL DUT
debouncer #(
  .CN   (CN)
) debouncer_i [DW-1:0] (
  .clk  (clk),
  .d_i  (d_i),
  .d_o  (d_o)
);

endmodule

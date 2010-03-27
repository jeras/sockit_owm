module debouncer #(
  parameter CN = 8,         // counter number (sequence length)
  parameter CW = $clog2(CN) // counter width in bits
)(
  input      clk,           // clock
  input      d_i,           // debouncer input
  output reg d_o            // debouncer output
);

reg [CW-1:0] cnt;           // counter
reg          d_r;           // input register

// TODO
initial cnt <= 0;

// prevention of metastability problems
always @ (posedge clk)
d_r <= d_i;

always @ (posedge clk)
if (|cnt)          cnt <= cnt - 1;
else if (d_r^d_o)  cnt <= CN;

always @ (posedge clk)
if (~|cnt) d_o <= d_r;

endmodule

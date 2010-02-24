module debouncer #(
  parameter CN = 8,         // counter number (sequence length)
  parameter CW = $clog2(CN) // counter width in bits
)(
  input      clk,           // clock
  input      d_i,           // debouncer input
  output reg d_o            // debouncer output
);

reg [CW-1:0] cnt;           // counter

initial cnt <= 0;

always @ (posedge clk)
if (d_i)        cnt <= CN;
else if (|cnt)  cnt <= cnt - 1;

always @ (posedge clk)
d_o <= |cnt;

endmodule

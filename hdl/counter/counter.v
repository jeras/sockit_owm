module counter #(
  parameter CW = 8,         // counter bit width
  parameter CR = (1<<CW)-1  // counter reset value
)(
  input               clk,  // clock
  input               rst,  // reset (asynchronous)
  input               clr,  // clear (synchronous)
  input               ena,  // enable
  output reg [CW-1:0] cnt,  // counter
  output wire         out   // running status output
);

always @ (posedge clk, negedge rst)
if (rst)              cnt <= CR;
else if (ena) begin
  if (clr)            cnt <= (1<<CW)-1;
  else if (cnt != 0)  cnt <= cnt - 1;
end

assign out = (cnt != 0);

endmodule

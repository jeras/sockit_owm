module avalon_ram #(
  parameter ADW = 32,              // data width
  parameter ABW = ADW/8,           // byte enable width
  parameter ASZ = 1024,            // memory size
  parameter AAW = $clog2(ASZ/ABW)  // address width
)(
  // system signals
  input            clk,          // clock
  input            rst,          // reset
  // Avalon MM interface
  input            read,
  input            write,
  input  [AAW-1:0] address,
  input  [ABW-1:0] byteenable,
  input  [ADW-1:0] writedata,
  output [ADW-1:0] readdata,
  output           waitrequest
);

wire transfer;

reg [ADW-1:0] mem [0:ASZ-1];
reg [ADW-1:0] data;
reg           data_valid;

//////////////////////////////////////////////////////////////////////////////
// memory implementation
//////////////////////////////////////////////////////////////////////////////

genvar i;

// write access (writedata is written the same clock period write is asserted)
generate for (i=0; i<ABW; i=i+1) begin : byte
  // generate code for for each byte in a word
  always @ (posedge clk)
  if (write & byteenable[i])  mem[address][8*i+:8] <= writedata[8*i+:8];
end endgenerate

// read access (readdata is available one clock period after read is asserted)
always @ (posedge clk)
if (read)  data <= mem[address];

assign readdata = data;

//////////////////////////////////////////////////////////////////////////////
// avalon interface code
//////////////////////////////////////////////////////////////////////////////

// transfer cycle end
assign transfer = (read | write) & ~waitrequest;

always @ (posedge clk)
data_valid <= read & ~data_valid;

// read, write cycle timing
assign waitrequest = ~(write | data_valid);

endmodule

module stream_source #(
  parameter DW = 8,          // data width
  parameter FN = "dat.hex",  // data file name
  parameter DN = 16          // data file length
)(
  output reg          vld,
  output reg [DW-1:0] dat,
  input wire          rdy
);

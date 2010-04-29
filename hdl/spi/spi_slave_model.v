module spi_slave_model #(
  parameter CPOL = 0,
  parameter CPHA = 0
)(
  input  ss_n,
  input  sclk,
  input  mosi,
  output miso
);

reg       bit;
reg [7:0] byte;

always @ (posedge sclk, posedge ss_n)
if (ss_n) bit  <= 1'bx;
else      bit  <= mosi;

always @ (posedge sclk, posedge ss_n)
if (ss_n) byte <= 7'hxx;
else      byte <= {byte[6:1], bit};

assign miso = byte[7];

endmodule

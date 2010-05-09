


module onewire #(
  // UART parameters
  parameter DVN = 2,           // clock cycles per bit
  parameter DVW = $clog2(DVN)  // size of boudrate generator counter
)(
  // system signals
  input         clk,
  input         rst,
  // Avalon MM interface
  input         avalon_read,
  input         avalon_write,
  input  [31:0] avalon_writedata,
  output [31:0] avalon_readdata,
  output        avalon_waitrequest,
  output        avalon_interrupt,
  // onewire
  inout         onewire
);

// Avalon signals
wire avalon_trn_w;
wire avalon_trn_r;

// clock divider
reg [DVW-1:0] div;
wire          pls;

// state counter
reg           run;
reg     [6:0] cnt;

// output driver
reg          pul;

// onewire signals
reg           o_od;   // overdrive
reg           o_rst;  // reset
reg           o_dtx;  // data bit transmit
reg           o_drx;  // data bit receive
reg           o_stx;  // status transmit
reg           o_srx;  // status receive

//////////////////////////////////////////////////////////////////////////////
// Avalon logic
//////////////////////////////////////////////////////////////////////////////

// Avalon transfer status
assign avalon_waitrequest = 1'b0;
assign avalon_trn_w = avalon_write & ~avalon_waitrequest;
assign avalon_trn_r = avalon_read  & ~avalon_waitrequest;

// Avalon read data
assign avalon_readdata = {26'd0, o_srx, o_stx, o_drx, o_dtx, o_rst, o_od};

// Avalon interrupt
assign avalon_interrupt = o_srx | o_stx;

//////////////////////////////////////////////////////////////////////////////
// clock divider
//////////////////////////////////////////////////////////////////////////////

// clock divider
always @ (posedge clk, posedge rst)
if (rst)  div <= 'd0;
else      div <= pls ? 'd0 : div + run;

// divided clock pulse
assign pls = (div == DVN-1);

//////////////////////////////////////////////////////////////////////////////
// onewire
//////////////////////////////////////////////////////////////////////////////

// transmit data, reset, overdrive
always @ (posedge clk, posedge rst)
if (rst)                {o_dtx, o_rst, o_od} <= 3'b000;     
else if (avalon_trn_w)  {o_dtx, o_rst, o_od} <= avalon_writedata[2:0]; 

// avalon run status
always @ (posedge clk, posedge rst)
if (rst)                        run <= 1'b0;
else begin
  if (avalon_trn_w)             run <= 1'b1;
  else if (pls & (cnt == 'd0))  run <= 1'b0;
end

// state counter
always @ (posedge clk, posedge rst)
if (rst)                        cnt <= 0;
else begin
  if (avalon_trn_w)             cnt <= avalon_writedata[1] ? 80 : 11;
  else if (pls)                 cnt <= cnt - 1;
end

// transmit status
always @ (posedge clk, posedge rst)
if (rst)                        o_stx <= 1'b0;
else begin
  if (pls & (cnt == 'd0))       o_stx <= 1'b1;
  else if (avalon_trn_r)        o_stx <= 1'b0;
end

// receive status
always @ (posedge clk, posedge rst)
if (rst)             o_srx <= 1'b0;
else begin
  if (pls & (cnt == 'd9) & (~o_rst &  o_dtx))
                                o_srx <= 1'b1;
  else if (avalon_trn_w)        o_srx <= 1'b0;
end

// receive data
always @ (posedge clk)
if (pls & (cnt == 'd9))  o_drx <= 1'b0;

// output register
always @ (posedge clk, posedge rst)
if (rst)             pul <= 1'b0;
else begin
  if (avalon_trn_w)  pul <= 1'b1;
  else if (pls) begin
    if ( (~o_rst &  o_dtx) & (cnt == 'd10)
       | ( o_rst | ~o_dtx) & (cnt == 'd01) )
                     pul <= 1'b0;
  end
end

// onewire driver
assign onewire = pul ? 1'b0 : 1'bz;

endmodule

//////////////////////////////////////////////////////////////////////////////
// 1-wire (onewire) master with Avalon MM bus interface
//////////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////////
// local signals
//////////////////////////////////////////////////////////////////////////////

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
reg owr_pul;

// onewire signals
reg owr_ovd;  // overdrive
reg owr_rst;  // reset
reg owr_dtx;  // data bit transmit
reg owr_drx;  // data bit receive

// interrupt signals
reg irq_etx;  // interrupt enable transmit
reg irq_erx;  // interrupt enable receive
reg irq_stx;  // interrupt status transmit
reg irq_srx;  // interrupt status receive

//////////////////////////////////////////////////////////////////////////////
// Avalon logic
//////////////////////////////////////////////////////////////////////////////

// Avalon transfer status
assign avalon_waitrequest = 1'b0;
assign avalon_trn_w = avalon_write & ~avalon_waitrequest;
assign avalon_trn_r = avalon_read  & ~avalon_waitrequest;

// Avalon read data
assign avalon_readdata = {24'd0, irq_erx, irq_etx, irq_srx, irq_stx,
                                 owr_drx, owr_dtx, owr_rst, owr_ovd};

// Avalon interrupt
assign avalon_interrupt = irq_etx & irq_srx
                        | irq_erx & irq_stx;

// interrupt enable
always @ (posedge clk, posedge rst)
if (rst)                {irq_erx, irq_etx} <= 2'b00;     
else if (avalon_trn_w)  {irq_erx, irq_etx} <= avalon_writedata[7:6]; 

// transmit status
always @ (posedge clk, posedge rst)
if (rst)                   irq_stx <= 1'b0;
else begin
  if (pls & (cnt == 'd0))  irq_stx <= 1'b1;
  else if (avalon_trn_r)   irq_stx <= 1'b0;
end

// receive status
always @ (posedge clk, posedge rst)
if (rst)                               irq_srx <= 1'b0;
else begin
  if (pls) begin
    if      (owr_rst & (cnt == 'd54))  irq_srx <= 1'b1;
    else if (owr_dtx & (cnt == 'd07))  irq_srx <= 1'b1;
  end else if (avalon_trn_r)           irq_srx <= 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
// clock divider
//////////////////////////////////////////////////////////////////////////////

// clock divider
always @ (posedge clk, posedge rst)
if (rst)  div <= 'd0;
else      div <= pls ? 'd0 : div + run;

// divided clock pulse
assign pls = (div == (owr_ovd ? DVN/10 : DVN) - 1);

//////////////////////////////////////////////////////////////////////////////
// onewire
//////////////////////////////////////////////////////////////////////////////

// transmit data, reset, overdrive
always @ (posedge clk, posedge rst)
if (rst)                {owr_dtx, owr_rst, owr_ovd} <= 3'b000;     
else if (avalon_trn_w)  {owr_dtx, owr_rst, owr_ovd} <= avalon_writedata[2:0]; 

// avalon run status
always @ (posedge clk, posedge rst)
if (rst)                        run <= 1'b0;
else begin
  if (avalon_trn_w)             run <= 1'b1;
  else if (pls & (cnt == 'd0))  run <= 1'b0;
end

// state counter (initial value depends whether the cycle is reset or data)
always @ (posedge clk, posedge rst)
if (rst)             cnt <= 0;
else begin
  if (avalon_trn_w)  cnt <= avalon_writedata[1] ? 127 : 8;
  else if (pls)      cnt <= cnt - 1;
end

// receive data
always @ (posedge clk)
if (pls) begin
  if      (owr_rst & (cnt == 'd54))  owr_drx <= onewire;
  else if (owr_dtx & (cnt == 'd07))  owr_drx <= onewire;
end

// output register
always @ (posedge clk, posedge rst)
if (rst)                              owr_pul <= 1'b0;
else begin
  if (avalon_trn_w)                   owr_pul <= 1'b1;
  else if (pls) begin
    if      (owr_rst & (cnt == 'd64)) owr_pul <= 1'b0;
    else if (owr_dtx & (cnt == 'd08)) owr_pul <= 1'b0;
    else if (          (cnt == 'd01)) owr_pul <= 1'b0;
  end
end

// onewire driver
assign onewire = owr_pul ? 1'b0 : 1'bz;

endmodule

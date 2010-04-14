//////////////////////////////////////////////////////////////////////////////
// Copyright 2010 by Iztok Jeras (based on code by Terasic Technologies Inc.)
//////////////////////////////////////////////////////////////////////////////

module DE1_uart (
// Clock Input
input   [1:0] CLOCK_24,     // 24 MHz
input   [1:0] CLOCK_27,     // 27 MHz
input         CLOCK_50,     // 50 MHz
input         EXT_CLOCK,    // External Clock
// Push Button
input   [3:0] KEY,          // Pushbutton[3:0]
// DPDT Switch
input   [9:0] SW,           // Toggle Switch[9:0]
// 7-SEG Dispaly
output  [6:0] HEX0,         // Seven Segment Digit 0
output  [6:0] HEX1,         // Seven Segment Digit 1
output  [6:0] HEX2,         // Seven Segment Digit 2
output  [6:0] HEX3,         // Seven Segment Digit 3
// LED
output  [7:0] LEDG,         // LED Green[7:0]
output  [9:0] LEDR,         // LED Red[9:0]
// UART
output        UART_TXD,     // UART Transmitter
input         UART_RXD,     // UART Receiver
// SDRAM Interface
inout  [15:0] DRAM_DQ,      // SDRAM Data bus 16 Bits
output [11:0] DRAM_ADDR,    // SDRAM Address bus 12 Bits
output        DRAM_LDQM,    // SDRAM Low-byte Data Mask 
output        DRAM_UDQM,    // SDRAM High-byte Data Mask
output        DRAM_WE_N,    // SDRAM Write Enable
output        DRAM_CAS_N,   // SDRAM Column Address Strobe
output        DRAM_RAS_N,   // SDRAM Row Address Strobe
output        DRAM_CS_N,    // SDRAM Chip Select
output        DRAM_BA_0,    // SDRAM Bank Address 0
output        DRAM_BA_1,    // SDRAM Bank Address 0
output        DRAM_CLK,     // SDRAM Clock
output        DRAM_CKE,     // SDRAM Clock Enable
// Flash Interface
inout   [7:0] FL_DQ,        // FLASH Data bus 8 Bits
output [21:0] FL_ADDR,      // FLASH Address bus 22 Bits
output        FL_WE_N,      // FLASH Write Enable
output        FL_RST_N,     // FLASH Reset
output        FL_OE_N,      // FLASH Output Enable
output        FL_CE_N,      // FLASH Chip Enable
// SRAM Interface
inout  [15:0] SRAM_DQ,      // SRAM Data bus 16 Bits
output [17:0] SRAM_ADDR,    // SRAM Address bus 18 Bits
output        SRAM_UB_N,    // SRAM High-byte Data Mask 
output        SRAM_LB_N,    // SRAM Low-byte Data Mask 
output        SRAM_WE_N,    // SRAM Write Enable
output        SRAM_CE_N,    // SRAM Chip Enable
output        SRAM_OE_N,    // SRAM Output Enable
// SD_Card Interface
inout         SD_DAT,       // SD Card Data
inout         SD_DAT3,      // SD Card Data 3
inout         SD_CMD,       // SD Card Command Signal
output        SD_CLK,       // SD Card Clock
// USB JTAG link
input         TDI,          // CPLD -> FPGA (data in)
input         TCK,          // CPLD -> FPGA (clk)
input         TCS,          // CPLD -> FPGA (CS)
output        TDO,          // FPGA -> CPLD (data out)
// I2C
inout         I2C_SDAT,     // I2C Data
output        I2C_SCLK,     // I2C Clock
// PS2
input         PS2_DAT,      // PS2 Data
input         PS2_CLK,      // PS2 Clock
// VGA
output        VGA_HS,       // VGA H_SYNC
output        VGA_VS,       // VGA V_SYNC
output  [3:0] VGA_R,        // VGA Red[3:0]
output  [3:0] VGA_G,        // VGA Green[3:0]
output  [3:0] VGA_B,        // VGA Blue[3:0]
// Audio CODEC
inout         AUD_ADCLRCK,  // Audio CODEC ADC LR Clock
input         AUD_ADCDAT,   // Audio CODEC ADC Data
inout         AUD_DACLRCK,  // Audio CODEC DAC LR Clock
output        AUD_DACDAT,   // Audio CODEC DAC Data
inout         AUD_BCLK,     // Audio CODEC Bit-Stream Clock
output        AUD_XCK,      // Audio CODEC Chip Clock
// GPIO
inout  [35:0] GPIO_0,       // GPIO Connection 0
inout  [35:0] GPIO_1        // GPIO Connection 1
);

localparam FRQ = 24000000;  // 24MHz
localparam BAUDRATE = 9600;  // UART baudrate
localparam N_BIT = FRQ/BAUDRATE;  // T=f/baudrate

// local clock and reset
wire clk;
wire rst;

// debounced button signals
wire b_reset;
wire b_write;
wire b_read;
// one clock period delayed button signals
reg  b_write_d;
reg  b_read_d;

// avalon signals
wire       avalon_write;
wire       avalon_read;
wire [7:0] avalon_writedata;
wire [7:0] avalon_readdata;

// receiver status
wire       status_interrupt;
wire       status_error;

// display multiplexer
wire [7:0] display;

// All inout port turn to tri-state
assign SD_DAT      = 1'bz;
assign I2C_SDAT    = 1'bz;
assign AUD_ADCLRCK = 1'bz;
assign AUD_DACLRCK = 1'bz;
assign AUD_BCLK    = 1'bz;
assign GPIO_0      = 36'hzzzzzzzzz;
assign GPIO_1      = 36'hzzzzzzzzz;

// system clock and reset
assign clk = CLOCK_24[0];
assign rst = b_reset;

// debouncing of command buttons (buttons are active low)
debouncer #(.CN (FRQ/100)) debouncer_reset (.clk (clk), .d_i (~KEY[0]), .d_o (b_reset));
debouncer #(.CN (FRQ/100)) debouncer_write (.clk (clk), .d_i (~KEY[1]), .d_o (b_write));
debouncer #(.CN (FRQ/100)) debouncer_read  (.clk (clk), .d_i (~KEY[2]), .d_o (b_read ));

// translating command buttons into pulses by delaying the signals
always @ (posedge clk, posedge rst)
if (rst)  {b_write_d, b_read_d} <= 2'b00;
else      {b_write_d, b_read_d} <= {b_write, b_read};

// Avalon interface
assign avalon_write     = b_write & ~b_write_d;
assign avalon_read      = b_read  & ~b_read_d;
assign avalon_writedata = SW[7:0];

// stopwatch RTL instance
uart #(
  .N_BIT  (N_BIT)
) uart_i (
  // system signals
  .clk                 (clk),
  .rst                 (rst),
  // Avalon
  .avalon_read         (avalon_read),
  .avalon_write        (avalon_write),
  .avalon_writedata    (avalon_writedata),
  .avalon_readdata     (avalon_readdata),
  .avalon_waitrequest  (),
  // receiver status
  .status_irq          (status_interrupt),
  .status_err          (status_error),
  // UART
  .uart_rxd            (uart_RxD),
  .uart_txd            (uart_TxD)
);

// binary to 7 segment conversion
function [6:0] seg7 (input [3:0] bin);
  case (bin)
    4'h0    : seg7 = 7'h3F;
    4'h1    : seg7 = 7'h06;
    4'h2    : seg7 = 7'h5B;
    4'h3    : seg7 = 7'h4F;
    4'h4    : seg7 = 7'h66;
    4'h5    : seg7 = 7'h6D;
    4'h6    : seg7 = 7'h7D;
    4'h7    : seg7 = 7'h07;
    4'h8    : seg7 = 7'h7F;
    4'h9    : seg7 = 7'h6F;
    4'ha    : seg7 = 7'b1110111;
    4'hb    : seg7 = 7'b1111100;
    4'hc    : seg7 = 7'b0111001;
    4'hd    : seg7 = 7'b1011110;
    4'he    : seg7 = 7'b1111001;
    4'hf    : seg7 = 7'b1110001;
    default : seg7 = 7'h00;
  endcase
endfunction

// display multiplexer
assign display = SW[9] ? avalon_writedata : avalon_readdata;

// red LED display
assign LEDR = {2'b00, display};

// active low 7 segment outputs
assign HEX0 = ~seg7(avalon_writedata[3:0]);
assign HEX1 = ~seg7(avalon_writedata[7:4]);
assign HEX2 = ~seg7(avalon_readdata[3:0]);
assign HEX3 = ~seg7(avalon_readdata[7:4]);

// active hight green LED status outputs
assign LEDG[2:0] = {status_error, status_interrupt, b_read, b_write, b_reset};

endmodule

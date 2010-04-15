//////////////////////////////////////////////////////////////////////////////
// Copyright 2010 by Iztok Jeras (based on code by Terasic Technologies Inc.)
//////////////////////////////////////////////////////////////////////////////

module DE1_stopwatch (
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

// system clock
wire clk;

// debounced button signals
wire b_rst;
wire b_run;
wire b_clr;

// status LED signals
wire s_run;
wire s_hld;

// time in BCD format
wire [3:0] t_mil_2;
wire [3:0] t_sec_0;
wire [3:0] t_sec_1;
wire [3:0] t_min_0;
wire [3:0] t_min_1;

// All inout port turn to tri-state
assign SD_DAT      = 1'bz;
assign I2C_SDAT    = 1'bz;
assign AUD_ADCLRCK = 1'bz;
assign AUD_DACLRCK = 1'bz;
assign AUD_BCLK    = 1'bz;
assign GPIO_0      = 36'hzzzzzzzzz;
assign GPIO_1      = 36'hzzzzzzzzz;

// set system clock to 24MHz
assign clk = CLOCK_24[0];

// debouncing of command buttons (buttons are active low)
debouncer #(.CN (FRQ/ 50)) debouncer_rst (.clk (clk), .d_i (~KEY[0]), .d_o (b_rst));
debouncer #(.CN (FRQ/100)) debouncer_run (.clk (clk), .d_i (~KEY[1]), .d_o (b_run));
debouncer #(.CN (FRQ/100)) debouncer_clr (.clk (clk), .d_i (~KEY[2]), .d_o (b_clr));

// stopwatch RTL instance
stopwatch #(
  .MSPN     (FRQ/1000)
) stopwatch_i (
  // system signals
  .clk      (clk),
  .rst      (b_rst),
  // buttons (should be debuunced outside this module)
  .b_run    (b_run),
  .b_clr    (b_clr),
  // time outputs
  .t_mil_0  (),
  .t_mil_1  (),
  .t_mil_2  (t_mil_2),
  .t_sec_0  (t_sec_0),
  .t_sec_1  (t_sec_1),
  .t_min_0  (t_min_0),
  .t_min_1  (t_min_1),
  // screen status and hold status indicators
  .s_run    (s_run),
  .s_hld    (s_hld),
  // Avalon CPU interface
  .avalon_write      (1'b0),
  .avalon_read       (1'b0),
  .avalon_writedata  (32'd0),
  .avalon_readdata   (),
  .avalon_interrupt  ()
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

// tenths of a second
assign LEDR = 10'd1 << t_mil_2;

// (seconds and minutes (active low 7 segment outputs)
assign HEX0 = ~seg7(t_sec_0);
assign HEX1 = ~seg7(t_sec_1);
assign HEX2 = ~seg7(t_min_0);
assign HEX3 = ~seg7(t_min_1);

// active hight green LED status outputs
assign LEDG[2:0] = {s_hld, s_run, b_rst};

endmodule

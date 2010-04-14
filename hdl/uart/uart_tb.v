`timescale 1ns / 1ps

module uart_tb;

// system clock parameters
//localparam real FRQ = 24_000_000;  // 24MHz // realistic option
localparam real FRQ =  48000;  //  48kHz // option for faster simulation
localparam real CP = 1000000000/FRQ;  // clock period

// Avalon MM parameters
localparam AAW = 1;      // address width
localparam ADW = 32;     // data width
localparam ABW = ADW/8;  // byte enable width

// UART parameters
localparam      BYTESIZE = 8;                    // oprions are ..., 7, 8, ...
//localparam      PARITY   = "NONE";               // options are "NONE", "EVEN", "ODD"
localparam      PARITY   = "ODD";               // options are "NONE", "EVEN", "ODD"
localparam      STOPSIZE = 1;                    // options are 1,2,...
localparam real BAUDRATE = 9600;                 // realistic baudrate value
localparam      N_BIT =           FRQ/BAUDRATE;  // T=f/baudrate
localparam real T_BIT = 1_000_000_000/BAUDRATE;  // T=1.0s/baudrate

// system_signals
reg            clk;  // clock
reg            rst;  // reset (asynchronous)
// Avalon MM interface
reg            avalon_read;         //
reg            avalon_write;        //
reg  [AAW-1:0] avalon_address;      //
reg  [ABW-1:0] avalon_byteenable;   //
reg  [ADW-1:0] avalon_writedata;    //
wire [ADW-1:0] avalon_readdata;     //
wire           avalon_waitrequest;  //

// UART status
wire           status_irq;
wire           status_err;

// Avalon MM local signals
wire           avalon_transfer;
reg  [ADW-1:0] data;

// UART
wire           uart_RxD;
wire           uart_TxD;

// request for a dumpfile
initial begin
  $dumpfile("uart.vcd");
  $dumpvars(0, uart_tb);
end

//////////////////////////////////////////////////////////////////////////////
// clock and reset
//////////////////////////////////////////////////////////////////////////////

// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// reset generation
initial begin
  rst = 1'b1;
  repeat (2) @(posedge clk);
  rst = 1'b0;
end

//////////////////////////////////////////////////////////////////////////////
// Avalon write and read transfers
//////////////////////////////////////////////////////////////////////////////

initial begin
  // Avalon MM interface is idle
  avalon_read  = 1'b0;
  avalon_write = 1'b0;
  repeat (4) @(posedge clk);

  // perform Avalon MM fundamental writes
  avalon_cycle (1, 0, 4'hf, "H", data);
  avalon_cycle (1, 0, 4'hf, "e", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "o", data);
  avalon_cycle (1, 0, 4'hf, ",", data);
  repeat (20*N_BIT) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, " ", data);
  repeat (1) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, "W", data);
  avalon_cycle (1, 0, 4'hf, "o", data);
  avalon_cycle (1, 0, 4'hf, "r", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "d", data);
  avalon_cycle (1, 0, 4'hf, "!", data);
  repeat (20*N_BIT) @(posedge clk);

  // read from Avalon to clear interrupt and fifo error
  avalon_cycle (0, 0, 4'hf, 'hx, data);

  // send (loop) receive an UART byte, wait for interrupt and read data
  avalon_cycle (1, 0, 4'hf, "T", data);
  @ (posedge clk); while (~status_irq) @ (posedge clk);
  avalon_cycle (0, 0, 4'hf, 'hx, data);
  $display ("DEBUG: Received character \'%s\' expected \'T\'", data[BYTESIZE-1:0]);

  // wait a few cycles and finish
  repeat (4) @(posedge clk);
  $finish(); 
end

//////////////////////////////////////////////////////////////////////////////
// Avalon transfer cycle generation task
//////////////////////////////////////////////////////////////////////////////

task automatic avalon_cycle (
  input            r_w,  // 0-read or 1-write cycle
  input  [AAW-1:0] adr,
  input  [ABW-1:0] ben,
  input  [ADW-1:0] wdt,
  output [ADW-1:0] rdt
);
begin
  $display ("Avalon MM cycle start: T=%10tns, %s address=%08x byteenable=%04b writedata=%08x", $time/1000.0, r_w?"write":"read ", adr, ben, wdt);
  // start an Avalon cycle
  avalon_read       <= ~r_w;
  avalon_write      <=  r_w;
  avalon_address    <=  adr;
  avalon_byteenable <=  ben;
  avalon_writedata  <=  wdt;
  // wait for waitrequest to be retracted
  @ (posedge clk); while (~avalon_transfer) @ (posedge clk);
  // end Avalon cycle
  avalon_read       <= 1'b0;
  avalon_write      <= 1'b0;
  // read data
  rdt = avalon_readdata;
  $display ("Avalon MM cycle end  : T=%10tns, readdata=%08x", $time/1000.0, rdt);
end
endtask

// avalon cycle transfer cycle end status
assign avalon_transfer = (avalon_read | avalon_write) & ~avalon_waitrequest;

//////////////////////////////////////////////////////////////////////////////
// UART monitor (receiver)
//////////////////////////////////////////////////////////////////////////////

event     uart_sample;  // a semple event should be placed in the middle of each bit
integer   uart_cnt;     // bit counter
reg [7:0] uart_dat;     // byte of data

initial begin
  wait (~rst);
  while (1) begin
    @ (negedge uart_TxD) begin
      // wait half of bit time
      #(T_BIT/2);
      // check the start bit
      if (uart_TxD != 1'b0)  $display ("UART: start bit error."); #T_BIT;
      // sample in the middle of each bit
      for (uart_cnt=0; uart_cnt<BYTESIZE; uart_cnt=uart_cnt+1) begin
        -> uart_sample;  uart_dat [uart_cnt] = uart_TxD;  #T_BIT;
      end
      // check parity
      case (PARITY)
        "ODD"  : begin  if (uart_TxD != ~^uart_dat)  $display ("UART: parity error."); #T_BIT;  end
        "EVEN" : begin  if (uart_TxD !=  ^uart_dat)  $display ("UART: parity error."); #T_BIT;  end
        "NONE" : begin                                                                          end
      endcase
      // check the stop bit and display the transferred character
      if (uart_TxD != 1'b1)  $display ("UART: stop bit error.");
      else                   $display ("UART: transferred character \"%s\".", uart_dat);
    end
  end
end

//////////////////////////////////////////////////////////////////////////////
// RTL instance
//////////////////////////////////////////////////////////////////////////////

uart #(
  // UART parameters
  .BYTESIZE (BYTESIZE),
  .PARITY   (PARITY),
  .STOPSIZE (STOPSIZE),
  .N_BIT    (N_BIT),
  // Avalon parameters
  .AAW   (AAW),
  .ADW   (ADW)
) uart_i (
  // system
  .clk  (clk),
  .rst  (rst),
  // Avalon
  .avalon_read         (avalon_read),
  .avalon_write        (avalon_write),
  .avalon_writedata    (avalon_writedata),
  .avalon_readdata     (avalon_readdata),
  .avalon_waitrequest  (avalon_waitrequest),
  // receiver status
  .status_irq          (status_irq),
  .status_err          (status_err),
  // UART
  .uart_rxd            (uart_RxD),
  .uart_txd            (uart_TxD)
);

// UART loopback
assign uart_RxD = uart_TxD;


endmodule

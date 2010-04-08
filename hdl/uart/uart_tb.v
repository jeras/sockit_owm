`timescale 1ns / 1ps

module uart_tb;

// system clock parameters
//localparam real FRQ = 24_000_000;  // 24MHz // realistic option
localparam real FRQ =  1_000_000;  //  1MHz // option for faster simulation
localparam real CP = 1000000000/FRQ;  // clock period

// Avalon MM parameters
localparam AAW = 1;      // address width
localparam ADW = 32;     // data width
localparam ABW = ADW/8;  // byte enable width

// UART parameters
localparam      BYTESIZE = 8;
localparam      PARITY   = "NONE";
localparam      STOPSIZE = 1;
// localparam real BAUDRATE = 9600;  // realistic baudrate value
localparam real BAUDRATE = FRQ;    // baudrate for UART at system clock
localparam real T_BIT = 1_000_000_000.0/BAUDRATE;  // T=1.0s/baudrate

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
// Avalon MM local signals
wire           avalon_transfer;
reg  [ADW-1:0] data;
// UART
//wire           uart_RxD;
wire           uart_TxD;

// request for a dumpfile
initial begin
  $dumpfile("uart.vcd");
  $dumpvars(0, uart_tb);
end


// clock generation
initial        clk = 1'b1;
always #(CP/2) clk = ~clk;

// test signal generation
initial begin
  // initially the uart is under reset end disabled
  rst = 1'b1;
  // Avalon MM interface is idle
  avalon_read  = 1'b0;
  avalon_write = 1'b0;
  repeat (2) @(posedge clk);
  // remove reset
  rst = 1'b0;
  repeat (2) @(posedge clk);
  // perform Avalon MM fundamental writes
  avalon_cycle (1, 0, 4'hf, "H", data);
  avalon_cycle (1, 0, 4'hf, "e", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "o", data);
  avalon_cycle (1, 0, 4'hf, ",", data);
  repeat (20) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, " ", data);
  repeat (1) @(posedge clk);
  avalon_cycle (1, 0, 4'hf, "W", data);
  avalon_cycle (1, 0, 4'hf, "o", data);
  avalon_cycle (1, 0, 4'hf, "r", data);
  avalon_cycle (1, 0, 4'hf, "l", data);
  avalon_cycle (1, 0, 4'hf, "d", data);
  avalon_cycle (1, 0, 4'hf, "!", data);
  repeat (20) @(posedge clk);
  $finish(); 
end


// avalon transfer cycle generation task
task avalon_cycle (
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


// UART monitor (receiver) signals
event     uart_sample;  // a semple event should be placed in the middle of each bit
integer   uart_cnt;     // bit counter
reg [7:0] uart_dat;     // byte of data

// UART monitor (receiver)
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


// instantiate uart RTL
uart #(
  .AAW   (AAW),
  .ADW   (ADW)
) uart_i (
  // system
  .clk  (clk),
  .rst  (rst),
  // Avalon
  .avalon_read         (avalon_read),
  .avalon_write        (avalon_write),
  .avalon_address      (avalon_address),
  .avalon_byteenable   (avalon_byteenable),
  .avalon_writedata    (avalon_writedata),
  .avalon_readdata     (avalon_readdata),
  .avalon_waitrequest  (avalon_waitrequest),
  // receiver status
  .status_irq          (),
  .status_err          (),
  // UART
  .uart_rxd            (uart_RxD),
  .uart_txd            (uart_TxD)
);

endmodule

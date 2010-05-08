REM cmd script for running the uart example

:: cleanup first
erase uart.out
erase uart.vcd

:: compile the verilog sources (testbench and RTL)
iverilog -o uart.out uart_tb.v uart.v
:: run the simulation
vvp uart.out

:: open the waveform and detach it
gtkwave uart.vcd gtkwave.sav &

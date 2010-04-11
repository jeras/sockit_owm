REM cmd script for running the counter example

:: cleanup first
erase counter.out
erase counter.vcd

:: compile the verilog sources (testbench and RTL)
iverilog -o counter.out counter_tb.v counter.v
:: run the simulation
vvp counter.out

:: open the waveform and detach it
gtkwave counter.vcd gtkwave.sav &

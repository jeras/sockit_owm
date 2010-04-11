REM cmd script for running the debouncer example

:: cleanup first
erase debouncer.out
erase debouncer.vcd

:: compile the verilog sources (testbench and RTL)
iverilog -o debouncer.out debouncer_tb.v debouncer.v
:: run the simulation
vvp debouncer.out

:: open the waveform and detach it
gtkwave debouncer.vcd gtkwave.sav &

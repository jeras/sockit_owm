REM cmd script for running the stopwatch example

:: cleanup first
erase stopwatch.out
erase stopwatch.vcd

:: compile the verilog sources (testbench and RTL)
iverilog -o stopwatch.out stopwatch_tb.v stopwatch.v
:: run the simulation
vvp stopwatch.out

:: open the waveform and detach it
gtkwave stopwatch.vcd gtkwave.sav &

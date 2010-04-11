REM cmd script for running the avalon_ram example

:: cleanup first
erase avalon_ram.out
erase avalon_ram.vcd

:: compile the verilog sources (testbench and RTL)
iverilog -o avalon_ram.out avalon_ram_tb.v avalon_ram.v
:: run the simulation
vvp avalon_ram.out

:: open the waveform and detach it
gtkwave avalon_ram.vcd gtkwave.sav &

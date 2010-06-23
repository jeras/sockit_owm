# sockit_avalon_onewire_master_mini
# Iztok Jeras 2010.06.13.18:29:39
# 1-wire (onewire) master

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module sockit_avalon_onewire_master_mini
# | 
set_module_property DESCRIPTION "1-wire (onewire) master"
set_module_property NAME sockit_avalon_onewire_master_mini
set_module_property VERSION 1.2
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Serial"
set_module_property AUTHOR "Iztok Jeras"
set_module_property DISPLAY_NAME "onewire (1-wire)"
set_module_property TOP_LEVEL_HDL_FILE sockit_avalon_onewire_master_mini.v
set_module_property TOP_LEVEL_HDL_MODULE sockit_avalon_onewire_master_mini
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property ELABORATION_CALLBACK elaboration_callback
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file sockit_avalon_onewire_master_mini.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
set description {The clock divider should divide the Avalon port clock to a exactly 7.5us period.}
add_parameter CDR INTEGER 10
set_parameter_property CDR DEFAULT_VALUE 10
set_parameter_property CDR DISPLAY_NAME CDR
set_parameter_property CDR DISPLAY_NAME "Clock divider ratio"
set_parameter_property CDR UNITS None
set_parameter_property CDR ALLOWED_RANGES 1:2048
set_parameter_property CDR DESCRIPTION $description
set_parameter_property CDR DISPLAY_HINT ""
set_parameter_property CDR AFFECTS_GENERATION false
set_parameter_property CDR HDL_PARAMETER true

set description {OWN 1-wire ports are created, each representing its own network. This module can only access one 1-wire slave simultaneously.}
add_parameter OWN INTEGER 100
set_parameter_property OWN DEFAULT_VALUE 1
set_parameter_property OWN ALLOWED_RANGES "1:8"
set_parameter_property OWN DISPLAY_NAME "Nummber of 1-wire channels"
set_parameter_property OWN UNITS None
set_parameter_property OWN DESCRIPTION $description
set_parameter_property OWN DISPLAY_HINT ""
set_parameter_property OWN AFFECTS_GENERATION false
set_parameter_property OWN AFFECTS_ELABORATION true
set_parameter_property OWN HDL_PARAMETER true

add_parameter ADW INTEGER 32
set_parameter_property ADW DEFAULT_VALUE 32
set_parameter_property ADW DISPLAY_NAME ADW
set_parameter_property ADW ENABLED false
set_parameter_property ADW UNITS Bits
set_parameter_property ADW ALLOWED_RANGES 0:32
set_parameter_property ADW DISPLAY_HINT ""
set_parameter_property ADW AFFECTS_GENERATION false
set_parameter_property ADW HDL_PARAMETER true

# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset rst reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point s1
# | 
add_interface s1 avalon end
set_interface_property s1 addressAlignment DYNAMIC
set_interface_property s1 associatedClock clock_reset
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 0
set_interface_property s1 isMemoryDevice false
set_interface_property s1 isNonVolatileStorage false
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 printableDevice false
set_interface_property s1 readLatency 0
set_interface_property s1 readWaitStates 0
set_interface_property s1 readWaitTime 0
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
set_interface_property s1 writeWaitTime 0

set_interface_property s1 ASSOCIATED_CLOCK clock_reset
set_interface_property s1 ENABLED true

add_interface_port s1 avalon_read read Input 1
add_interface_port s1 avalon_write write Input 1
add_interface_port s1 avalon_writedata writedata Input ADW
add_interface_port s1 avalon_readdata readdata Output ADW
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point irq
# | 
add_interface irq interrupt end
set_interface_property irq associatedAddressablePoint s1

set_interface_property irq ASSOCIATED_CLOCK clock_reset
set_interface_property irq ENABLED true

add_interface_port irq avalon_interrupt irq Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit
# | 
add_interface conduit conduit end

set_interface_property conduit ASSOCIATED_CLOCK clock_reset
set_interface_property conduit ENABLED true

add_interface_port conduit owr_oe export Output 1
add_interface_port conduit owr_i export Input 1
# | 
# +-----------------------------------

proc elaboration_callback {} {
    # Add software defines
    set_module_assignment embeddedsw.CMacro.OWN [get_parameter_value OWN]
}
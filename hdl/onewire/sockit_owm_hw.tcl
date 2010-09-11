# sockit_owm
# Iztok Jeras 2010.06.13.18:29:39
# 1-wire (onewire) master

# request TCL package from ACDS 9.1
package require -exact sopc 9.1

# module sockit_owm
set_module_property DESCRIPTION "1-wire (onewire) master"
set_module_property NAME sockit_owm
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Serial"
set_module_property AUTHOR "Iztok Jeras"
set_module_property DISPLAY_NAME "1-wire (onewire)"
set_module_property TOP_LEVEL_HDL_FILE sockit_owm.v
set_module_property TOP_LEVEL_HDL_MODULE sockit_owm
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

set_module_property ELABORATION_CALLBACK elaboration_callback

# RTL files
add_file sockit_owm.v {SYNTHESIS SIMULATION}

# parameters
set description {Disabling overdrive can spare a small amount of logic.}
add_parameter OVD_E BOOLEAN
set_parameter_property OVD_E DEFAULT_VALUE 1
set_parameter_property OVD_E DISPLAY_NAME OVD_E
set_parameter_property OVD_E DISPLAY_NAME "Implementation of overdrive enable"
set_parameter_property OVD_E UNITS None
#set_parameter_property OVD_E ALLOWED_RANGES 0:1
set_parameter_property OVD_E DESCRIPTION $description
set_parameter_property OVD_E DISPLAY_HINT ""
set_parameter_property OVD_E AFFECTS_GENERATION false
set_parameter_property OVD_E HDL_PARAMETER true

set description {The clock divider should divide the Avalon port clock to a exactly 7.5us period.}
add_parameter CDR_N INTEGER 10
set_parameter_property CDR_N DEFAULT_VALUE 8
set_parameter_property CDR_N DISPLAY_NAME CDR_N
set_parameter_property CDR_N DISPLAY_NAME "Clock divider ratio for normal mode"
set_parameter_property CDR_N UNITS None
set_parameter_property CDR_N ALLOWED_RANGES 1:2048
set_parameter_property CDR_N DESCRIPTION $description
set_parameter_property CDR_N DISPLAY_HINT ""
set_parameter_property CDR_N AFFECTS_GENERATION false
set_parameter_property CDR_N HDL_PARAMETER true

set description {The clock divider should divide the Avalon port clock to a exactly 7.5us period.}
add_parameter CDR_O INTEGER 10
set_parameter_property CDR_O DEFAULT_VALUE 1
set_parameter_property CDR_O DISPLAY_NAME CDR_O
set_parameter_property CDR_O DISPLAY_NAME "Clock divider ratio for overdrive mode"
set_parameter_property CDR_O UNITS None
set_parameter_property CDR_O ALLOWED_RANGES 1:2048
set_parameter_property CDR_O DESCRIPTION $description
set_parameter_property CDR_O DISPLAY_HINT ""
set_parameter_property CDR_O AFFECTS_GENERATION false
set_parameter_property CDR_O HDL_PARAMETER true

set description {OWN 1-wire ports are created, each representing its own network. This module can only access one 1-wire slave simultaneously.}
add_parameter OWN INTEGER 100
set_parameter_property OWN DEFAULT_VALUE 1
set_parameter_property OWN ALLOWED_RANGES 1:16
set_parameter_property OWN DISPLAY_NAME "Nummber of 1-wire channels"
set_parameter_property OWN UNITS None
set_parameter_property OWN DESCRIPTION $description
set_parameter_property OWN DISPLAY_HINT ""
set_parameter_property OWN AFFECTS_GENERATION false
set_parameter_property OWN AFFECTS_ELABORATION true
set_parameter_property OWN HDL_PARAMETER true

add_parameter BDW INTEGER 32
set_parameter_property BDW DEFAULT_VALUE 32
set_parameter_property BDW DISPLAY_NAME BDW
set_parameter_property BDW ENABLED false
set_parameter_property BDW UNITS Bits
set_parameter_property BDW ALLOWED_RANGES 0:32
set_parameter_property BDW DISPLAY_HINT ""
set_parameter_property BDW AFFECTS_GENERATION false
set_parameter_property BDW HDL_PARAMETER true

# connection point clock_reset
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset rst reset Input 1

# connection point s1
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

add_interface_port s1 bus_read read Input 1
add_interface_port s1 bus_write write Input 1
add_interface_port s1 bus_writedata writedata Input BDW
add_interface_port s1 bus_readdata readdata Output BDW

# connection point irq
add_interface irq interrupt end
set_interface_property irq associatedClock clock_reset
set_interface_property irq associatedAddressablePoint s1

set_interface_property irq ASSOCIATED_CLOCK clock_reset
set_interface_property irq ENABLED true

add_interface_port irq bus_interrupt irq Output 1

# connection point conduit
add_interface ext conduit end

set_interface_property ext ENABLED true

add_interface_port ext onewire_p export Output 1
add_interface_port ext onewire_e export Output 1
add_interface_port ext onewire_i export Input  1

proc elaboration_callback {} {
  # Add software defines
  set_module_assignment embeddedsw.CMacro.OWN [get_parameter_value OWN]
}

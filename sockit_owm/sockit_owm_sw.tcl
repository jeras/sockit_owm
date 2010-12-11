#
# sockit_owm_sw.tcl
#

# Create a new driver
create_driver sockit_owm_driver

# Association with hardware
set_sw_property hw_class_name sockit_owm

# Driver version
set_sw_property version 1.1

# This driver is proclaimed to be compatible with sockit_owm hardware
# as old as version "1.1". If the hardware component  version number is not
# equal or greater than the min_compatable_hw_version number, the driver 
# source files will not be copied over to the BSP drivers subdirectory
set_sw_property min_compatible_hw_version 1.1

# Interrupt properties: This driver supports both legacy and enhanced
# interrupt APIs, as well as ISR preemption.
set_sw_property isr_preemption_supported true
set_sw_property supported_interrupt_apis "legacy_interrupt_api enhanced_interrupt_api"

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize true

# Location in generated BSP that above sources will be copied into
set_sw_property bsp_subdirectory drivers

#
# Source file listings...
#

# C/C++ source files
add_sw_property       c_source HAL/src/ownet.c
add_sw_property       c_source HAL/src/owtran.c
add_sw_property       c_source HAL/src/owlnk.c
add_sw_property       c_source HAL/src/owses.c
add_sw_property       c_source HAL/src/sockit_owm.c

# Include files
add_sw_property include_source HAL/inc/ownet.h
add_sw_property include_source HAL/inc/sockit_owm.h
add_sw_property include_source inc/sockit_owm_regs.h

# Common files
add_sw_property       c_source HAL/src/owerr.c
add_sw_property       c_source HAL/src/crcutil.c
add_sw_property include_source HAL/inc/findtype.h
add_sw_property       c_source HAL/src/findtype.c

# device files (thermometer)
add_sw_property include_source HAL/inc/temp10.h
add_sw_property       c_source HAL/src/temp10.c
add_sw_property include_source HAL/inc/temp28.h
add_sw_property       c_source HAL/src/temp28.c

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# Driver configuration options
add_sw_setting boolean_define_only public_mk_define polling_driver_enable  SOCKIT_OWM_POLLING    false "Small-footprint (polled mode) driver"
add_sw_setting boolean_define_only public_mk_define hardware_delay_enable  SOCKIT_OWM_HW_DLY     true  "Mili second delay implemented in hardware"
add_sw_setting boolean_define_only public_mk_define error_detection_enable SOCKIT_OWM_ERR_ENABLE true  "Implement error detection support"
add_sw_setting boolean_define_only public_mk_define error_detection_small  SOCKIT_OWM_ERR_SMALL  true  "Reduced memory consumption for error detection"

# Enable application layer code
#add_sw_setting boolean_define_only public_mk_define enable_A SOCKIT_OWM_A false "Enable driver A"

# End of file

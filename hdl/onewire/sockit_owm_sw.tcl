#
# sockit_owm_sw.tcl
#

# Create a new driver
create_driver sockit_owm_driver

# Association with hardware
set_sw_property hw_class_name sockit_owm

# Pre release driver version
set_sw_property version 0.9

# This driver is proclaimed to be compatible with sockit_owm hardware
# as old as version "1.0". If the hardware component  version number is not
# equal or greater than the min_compatable_hw_version number, the driver 
# source files will not be copied over to the BSP drivers subdirectory
set_sw_property min_compatible_hw_version 0.8

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
add_sw_property c_source HAL/src/ownet.c
add_sw_property c_source HAL/src/owtran.c
add_sw_property c_source HAL/src/owlnk.c
add_sw_property c_source HAL/src/owses.c
add_sw_property c_source HAL/src/sockit_owm.c

# Include files
add_sw_property include_source HAL/inc/ownet.h
add_sw_property include_source HAL/inc/sockit_owm.h
add_sw_property include_source inc/sockit_owm_regs.h

# This driver supports HAL & UCOSII BSP (OS) types
add_sw_property supported_bsp_type HAL
add_sw_property supported_bsp_type UCOSII

# Add the following per_driver configuration option to the BSP:
#  o Type of setting (boolean_define_only translates to "either
#    emit a #define if true, or don't if false"). Useful for
#    source code with "#ifdef" style build-options.
#  o Generated file to write to (public_mk_define -> public.mk)
#  o Name of setting for use with bsp command line settings tools
#    (enable_small_driver). This name will be combined with the
#    driver class to form a settings hierarchy to assure unique
#    settings names
#  o '#define' in driver code (and therefore string in generated
#     makefile): "SOCKIT_OWM_SMALL", which means: "emit
#     CPPFLAGS += SOCKIT_OWM_SMALL in generated makefile
#  o Default value (if the user doesn't specify at BSP creation): false
#    (which means: 'do not emit above CPPFLAGS string in generated makefile)
#  o Description text
add_sw_setting boolean_define_only public_mk_define enable_small_driver SOCKIT_OWM_SMALL false "Small-footprint (polled mode) driver"

# Add per-driver configuration option for optional IOCTL functionality in
# UART driver.
#add_sw_setting boolean_define_only public_mk_define enable_A SOCKIT_OWM_A false "Enable driver A"

# End of file

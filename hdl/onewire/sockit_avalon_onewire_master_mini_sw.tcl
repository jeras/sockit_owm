#
# my_uart_sw.tcl
#

# Create a new driver - this name must be different than the 
# hardware component name
create_driver my_uart_driver

# Associate it with some hardware known as "altera_avalon_uart"
set_sw_property hw_class_name altera_avalon_uart

# The version of this driver is "9.11", making it newer 
# than the version 9.1 Altera production driver.  This will associate "my_uart"
# software driver with the altera_avalon_uart hardware, instead of the production
# version 9.1 altera_avalon_uart software driver.
set_sw_property version 9.11

# This driver may be incompatible with versions of hardware less
# than specified below. Updates to hardware and device drivers
# rendering the driver incompatible with older versions of
# hardware are noted with this property assignment.
#
# Multiple-Version compatibility was introduced in version 7.1;
# prior versions are therefore excluded.
#
# This driver is proclaimed to be compatible with altera_avalon_uart hardware
# as old as version "7.1". If the hardware component  version number is not
# equal or greater than the min_compatable_hw_version number, the driver 
# source files will not be copied over to the BSP drivers subdirectory

set_sw_property min_compatible_hw_version 7.1

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
add_sw_property c_source HAL/src/my_uart_fd.c
add_sw_property c_source HAL/src/my_uart_init.c
add_sw_property c_source HAL/src/my_uart_ioctl.c
add_sw_property c_source HAL/src/my_uart_read.c
add_sw_property c_source HAL/src/my_uart_write.c

# Include files - (hw_class_name is used in the auto-generated inclusion in alt_sys_init of
# the altera_avalon_uart.h header file listed below. alt_sys_init.c auto intialization macro
# invocations are also based on hw_class_name, so the altera_avalon_uart.h defines
# ALTERA_AVALON_UART_INIT and ALTERA_AVALON_UART_INSTANCE macros.)
add_sw_property include_source HAL/inc/altera_avalon_uart.h
add_sw_property include_source HAL/inc/my_uart_fd.h
add_sw_property include_source inc/my_uart_regs.h

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
#     makefile): "MY_UART_SMALL", which means: "emit
#     CPPFLAGS += MY_UART_SMALL in generated makefile
#  o Default value (if the user doesn't specify at BSP creation): false
#    (which means: 'do not emit above CPPFLAGS string in generated makefile)
#  o Description text
add_sw_setting boolean_define_only public_mk_define enable_small_driver MY_UART_SMALL false "Small-footprint (polled mode) driver"

# Add per-driver configuration option for optional IOCTL functionality in
# UART driver.
add_sw_setting boolean_define_only public_mk_define enable_ioctl MY_UART_USE_IOCTL false "Enable driver ioctl() support"

# End of file

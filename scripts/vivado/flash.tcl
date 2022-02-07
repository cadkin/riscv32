open_hw_manager
connect_hw_server
current_hw_target
open_hw_target
current_hw_device

set_property PROGRAM.FILE { ${TARGET} } [current_hw_device]
program_hw_devices

close_hw_target
exit

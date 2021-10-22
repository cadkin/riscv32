# This should only be called from another tcl script.
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $CELL
set_property -dict [list CONFIG.Component_Name {$CELL} CONFIG.Write_Width_A {8} CONFIG.Write_Depth_A {16384} CONFIG.Read_Width_A {8} CONFIG.Write_Width_B {8} CONFIG.Read_Width_B {8} CONFIG.Register_PortA_Output_of_Memory_Primitives {false}] [get_ips $CELL]
generate_target {instantiation_template} [get_files $RISCV32/vivado/riscv32.srcs/sources_1/ip/$CELL/$CELL.xci]
update_compile_order -fileset sources_1
generate_target all [get_files  $RISCV32/vivado/riscv32.srcs/sources_1/ip/$CELL/$CELL.xci]
catch { config_ip_cache -export [get_ips -all $CELL] }
export_ip_user_files -of_objects [get_files $RISCV32/vivado/riscv32.srcs/sources_1/ip/$CELL/$CELL.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $RISCV32/vivado/riscv32.srcs/sources_1/ip/$CELL/$CELL.xci]
launch_runs ${CELL}_synth_1 -jobs 4

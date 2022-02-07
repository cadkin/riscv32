create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $CELL -dir $IP_DIR
set_property -dict [list CONFIG.Write_Width_A {8}\
                         CONFIG.Write_Depth_A {16384}\
                         CONFIG.Read_Width_A {8}\
                         CONFIG.Write_Width_B {8}\
                         CONFIG.Read_Width_B {8}\
                         CONFIG.Register_PortA_Output_of_Memory_Primitives {false}] [get_ips $CELL]

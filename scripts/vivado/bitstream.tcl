# !!!! This file should not be run directly. It should only be invoked by the build system.
set_part ${BOARD}

read_ip ${PROJECT_ROOT}/${IP_DIR}/${MEM_CELL_0}/${MEM_CELL_0}.xci
read_ip ${PROJECT_ROOT}/${IP_DIR}/${MEM_CELL_1}/${MEM_CELL_1}.xci
read_ip ${PROJECT_ROOT}/${IP_DIR}/${MEM_CELL_2}/${MEM_CELL_2}.xci
read_ip ${PROJECT_ROOT}/${IP_DIR}/${MEM_CELL_3}/${MEM_CELL_3}.xci
read_ip ${PROJECT_ROOT}/${IP_DIR}/${IMEM_CELL_0}/${IMEM_CELL_0}.xci
read_ip ${PROJECT_ROOT}/${IP_DIR}/${IMEM_CELL_1}/${IMEM_CELL_1}.xci
read_ip ${PROJECT_ROOT}/${IP_DIR}/${IMEM_CELL_2}/${IMEM_CELL_2}.xci
read_ip ${PROJECT_ROOT}/${IP_DIR}/${IMEM_CELL_3}/${IMEM_CELL_3}.xci

set_param general.maxThreads 32

read_verilog -sv { ${SRC} }
read_vhdl { ${VHDL_PKGS} }
read_vhdl { ${VHDL_SRC} }
read_xdc ${PROJECT_ROOT}/${CONSTR_DIR}/${XDC}
synth_design -top ${TOP} -part ${BOARD}

write_checkpoint -force ${SYNTH_CHECKPOINT}
report_timing_summary -file ${RPT_PS_TIME_SUM}
report_power -file ${RPT_PS_POWER}

opt_design
place_design
phys_opt_design
report_timing_summary -file ${RPT_PP_TIME_SUM}
route_design
report_timing_summary -file ${RPT_PR_TIME_SUM}
write_checkpoint -force ${IMPL_CHECKPOINT}

report_timing -sort_by group -max_paths 100 -path_type summary -file ${RPT_PR_PATH_TIME}
report_clock_utilization -file ${RPT_PR_CLOCK_UTIL}
report_utilization -file ${RPT_PR_UTIL}
report_power -file ${RPT_PR_POWER}
report_drc -file ${RPT_IMPL_DRC}

write_verilog -force ${TOP}_glnet.v
write_xdc -no_fixed_only -force ${TOP}_glnet.xdc

write_bitstream -force ${TARGET}
exit

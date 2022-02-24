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
synth_design -top ${TOP} -rtl -name ${TOP}_rtl -part ${BOARD}
start_gui

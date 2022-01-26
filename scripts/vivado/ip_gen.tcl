create_project -part ${BOARD} -in_memory
set IP_DIR ${PROJECT_ROOT}/${IP_DIR}
read_xdc ${PROJECT_ROOT}/${CONSTR_DIR}/${XDC}

set CELL ${MEM_CELL_0}
source ${PROJECT_ROOT}/${MEM_GEN_TCL_PATH}
set CELL ${MEM_CELL_1}
source ${PROJECT_ROOT}/${MEM_GEN_TCL_PATH}
set CELL ${MEM_CELL_2}
source ${PROJECT_ROOT}/${MEM_GEN_TCL_PATH}
set CELL ${MEM_CELL_3}
source ${PROJECT_ROOT}/${MEM_GEN_TCL_PATH}

generate_target all [get_ips]
synth_ip [get_ips]

exit

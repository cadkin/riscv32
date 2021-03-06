# !!!! This file should not be run directly. It should only be invoked by the build system.
create_project -part ${BOARD} -in_memory
set IP_DIR ${PROJECT_ROOT}/${IP_DIR}
read_xdc ${PROJECT_ROOT}/${CONSTR_DIR}/${XDC}

set CELL ${MEM_CELL_0}
source ${MEM_GEN_CELL_TCL}
set CELL ${MEM_CELL_1}
source ${MEM_GEN_CELL_TCL}
set CELL ${MEM_CELL_2}
source ${MEM_GEN_CELL_TCL}
set CELL ${MEM_CELL_3}
source ${MEM_GEN_CELL_TCL}

generate_target all [get_ips]
synth_ip [get_ips]

exit

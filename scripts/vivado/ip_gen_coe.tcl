# !!!! This file should not be run directly. It should only be invoked by the build system.
create_project -part ${BOARD} -in_memory
set IP_DIR ${PROJECT_ROOT}/${IP_DIR}
set COE_DIR ${PROJECT_ROOT}/${COE_DIR}
read_xdc ${PROJECT_ROOT}/${CONSTR_DIR}/${XDC}

set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}0.coe
set CELL ${MEM_CELL_0}
source ${MEM_COE_CELL_TCL}
set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}1.coe
set CELL ${MEM_CELL_1}
source ${MEM_COE_CELL_TCL}
set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}2.coe
set CELL ${MEM_CELL_2}
source ${MEM_COE_CELL_TCL}
set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}3.coe
set CELL ${MEM_CELL_3}
source ${MEM_COE_CELL_TCL}

set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}0.coe
set CELL ${IMEM_CELL_0}
source ${MEM_COE_CELL_TCL}
set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}1.coe
set CELL ${IMEM_CELL_1}
source ${MEM_COE_CELL_TCL}
set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}2.coe
set CELL ${IMEM_CELL_2}
source ${MEM_COE_CELL_TCL}
set COE_FILE ${PROJECT_ROOT}/${COE_DIR}/${coe_basename}3.coe
set CELL ${IMEM_CELL_3}
source ${MEM_COE_CELL_TCL}

generate_target all [get_ips]
synth_ip [get_ips]

exit

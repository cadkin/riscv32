create_project -part ${BOARD} -in_memory
set IP_DIR ${PROJECT_ROOT}/${IP_DIR}
set COE_DIR ${PROJECT_ROOT}/${COE_DIR}
read_xdc ${PROJECT_ROOT}/${CONSTRS_DIR}/${XDC}

set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)0.coe
set CELL $(word 5, $(MEM_CELL_NAMES))
source ../$(MEM_COE_TCL_PATH)
set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)1.coe
set CELL $(word 6, $(MEM_CELL_NAMES))
source ../$(MEM_COE_TCL_PATH)
set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)2.coe
set CELL $(word 7, $(MEM_CELL_NAMES))
source ../$(MEM_COE_TCL_PATH)
set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)3.coe
set CELL $(word 8, $(MEM_CELL_NAMES))
source ../$(MEM_COE_TCL_PATH)

generate_target all [get_ips]
synth_ip [get_ips]

exit

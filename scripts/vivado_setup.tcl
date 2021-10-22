set RISCV32 $::env(RISCV32)

create_project riscv32 $RISCV32/vivado -part xc7a100tcsg324-1

add_files -fileset sources_1 $RISCV32/src
add_files -fileset constrs_1 -norecurse $RISCV32/constr/riscvcore.xdc
update_compile_order -fileset sources_1

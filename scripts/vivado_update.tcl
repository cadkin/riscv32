set RISCV32 $::env(RISCV32)

add_files -fileset sources_1            $RISCV32/src
add_files -fileset sim_1 -norecurse     $RISCV32/tb

update_compile_order

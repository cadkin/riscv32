set RISCV32 $::env(RISCV32)

create_project riscv32 $RISCV32/vivado -part xc7a100tcsg324-1

add_files -fileset sources_1            $RISCV32/src
add_files -fileset sim_1 -norecurse     $RISCV32/tb
add_files -fileset constrs_1 -norecurse $RISCV32/constr/riscvcore.xdc

update_compile_order

# Run options
set_property write_incremental_synth_checkpoint true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE ExploreWithRemap [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE ExtraTimingOpt [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AlternateFlowWithRetiming [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE HigherDelayCost [get_runs impl_1]

# Generate IP
set CELL mem_cell_0
source $RISCV32/scripts/vivado_mem_gen.tcl

set CELL mem_cell_1
source $RISCV32/scripts/vivado_mem_gen.tcl

set CELL mem_cell_2
source $RISCV32/scripts/vivado_mem_gen.tcl

set CELL mem_cell_3
source $RISCV32/scripts/vivado_mem_gen.tcl

set CELL imem_cell_0
source $RISCV32/scripts/vivado_mem_gen.tcl

set CELL imem_cell_1
source $RISCV32/scripts/vivado_mem_gen.tcl

set CELL imem_cell_2
source $RISCV32/scripts/vivado_mem_gen.tcl

set CELL imem_cell_3
source $RISCV32/scripts/vivado_mem_gen.tcl

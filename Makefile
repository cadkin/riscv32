TARGET              := riscv32_fpga.bit
BUILD_DIR           := build
BOARD               := xc7a100tcsg324-1
XDC                 := constr/riscvcore.xdc

VIVADO              := vivado
VIVADO_PATH			:= $(shell which $(VIVADO) 2> /dev/null)
VIVADO_FLAGS        :=
TOP                 := rv_uart_top

MEM_GEN_TCL_PATH    := scripts/vivado/ip_mem_gen_cell.tcl
MEM_COE_TCL_PATH    := scripts/vivado/ip_mem_gen_cell_coe.tcl
MEM_CELL_NAMES		:= mem_cell_0 mem_cell_1 mem_cell_2 mem_cell_3 imem_cell_0 imem_cell_1 imem_cell_2 imem_cell_3
TMP_TCL_PATH        := /tmp/$(shell bash -c 'echo $$RANDOM')-${USER}-vivado.tcl

SYNTH_CHECKPOINT    := synth.checkpoint
IMPL_CHECKPOINT     := impl.checkpoint

RPT_PS_TIME_SUM     := post_synth_timing_summary.rpt
RPT_PS_POWER        := post_synth_power.rpt
RPT_PP_TIME_SUM     := post_place_timing_summary.rpt
RPT_PR_TIME_SUM     := post_route_timing_summary.rpt
RPT_PR_PATH_TIME    := post_route_path_timing.rpt
RPT_PR_CLOCK_UTIL   := post_route_clock_util.rpt
RPT_PR_UTIL         := post_route_utilization.rpt
RPT_PR_POWER        := post_route_power.rpt
RPT_IMPL_DRC        := impl_drc.rpt

VLOG_ANALYSIS       := xvlog
VLOG_ANALYSIS_FLAGS := --sv --relax
VLOG_ANALYSIS_TS    := analysis_timestamp.tmp

ELAB                := xelab
ELAB_FLAGS          := --debug typical --relax
ELAB_LIBRARIES		:= -L blk_mem_gen_v8_4_4
# Defines testbench module to run for sims, can be specified via 'make sim testbench=foobar'.
testbench           := testbench
ELAB_TS             := $(addprefix $(testbench),_elab_timestamp.tmp)

IP_TS               := ip_gen_timestamp.tmp
IP_DIR				:= ip

COE_TS              := coe_timestamp.tmp
COE_DIR             := c
# Basename for loading from coe, expects $(coe_basename)0.coe - $(coe_basename)3.coe to load from $(COE_DIR). Can be modified.
coe_basename        := testUart

SIM                 := xsim
SIM_FLAGS           :=
# This is default, can be specified to be longer if needed via 'make sim sim_time=XXns' or if finite 'make sim sim_time=all'.
sim_time            := 500ns

TB                  := $(shell find tb/ -type f -name '*.sv')
SRC                 := $(shell find src/ -type f -name '*.sv')
VHDL_SRC            := $(shell find src/ -type f -name '*.vhd')
MEM_SRC				:= $(join $(addsuffix /sim/,$(addprefix $(IP_DIR)/,$(MEM_CELL_NAMES))),$(addsuffix .v,$(MEM_CELL_NAMES)))
#SDB                := $(subst tb/,$(VLOG_ANALYSIS_OUT),$(subst src/,$(VLOG_ANALYSIS_OUT),$(SRC:.sv=.sdb)))

SHELL 				:= bash
.SHELLFLAGS			:= -ec
.ONESHELL:
.NOTPARALLEL:

# Func to check if vars are defined.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

all: xilinx_loaded $(BUILD_DIR)/$(TARGET)

xilinx_loaded:
	$(call check_defined, VIVADO_PATH, Xilinx tools not found in path. Did you forget to load them?)

# Runs elaboration for simulation.
$(BUILD_DIR)/$(ELAB_TS): $(BUILD_DIR)/$(VLOG_ANALYSIS_TS)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(PWD)/$(BUILD_DIR)
	$(ELAB) $(ELAB_FLAGS) $(ELAB_LIBRARIES) -top $(testbench) -snapshot $(testbench)_snap
	touch $(ELAB_TS)

# Runs analysis for simulation.
$(BUILD_DIR)/$(VLOG_ANALYSIS_TS): $(IP_DIR)/$(IP_TS) $(SRC) $(TB)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(PWD)/$(BUILD_DIR)
	$(VLOG_ANALYSIS) $(VLOG_ANALYSIS_FLAGS) $(addprefix ../,$(SRC)) $(addprefix ../,$(TB))
	$(VLOG_ANALYSIS) $(addprefix ../,$(MEM_SRC))
	touch $(VLOG_ANALYSIS_TS)

# Generate block ram IP for build. Should only happen once initally.
$(IP_DIR)/$(IP_TS):
	mkdir -p $(PWD)/$(IP_DIR) && cd $(PWD)/$(IP_DIR)
	echo "create_project -part $(BOARD) -in_memory;\
          set IP_DIR $(PWD)/$(IP_DIR);\
          read_xdc ../$(XDC);\
          \
          set CELL $(word 1, $(MEM_CELL_NAMES));\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL $(word 2, $(MEM_CELL_NAMES));\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL $(word 3, $(MEM_CELL_NAMES));\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL $(word 4, $(MEM_CELL_NAMES));\
          source ../$(MEM_GEN_TCL_PATH);\
		  \
          generate_target all [get_ips];\
          synth_ip [get_ips];\
          \
          exit;" > $(TMP_TCL_PATH)
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	touch $(IP_TS)
	rm $(TMP_TCL_PATH)

# Generates the bitstream.
$(BUILD_DIR)/$(TARGET): $(IP_DIR)/$(IP_TS) $(SRC)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(PWD)/$(BUILD_DIR)
	echo "set_part $(BOARD);\
		  \
		  read_ip ../$(IP_DIR)/$(word 1, $(MEM_CELL_NAMES))/$(word 1, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 2, $(MEM_CELL_NAMES))/$(word 2, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 3, $(MEM_CELL_NAMES))/$(word 3, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 4, $(MEM_CELL_NAMES))/$(word 4, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 5, $(MEM_CELL_NAMES))/$(word 5, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 6, $(MEM_CELL_NAMES))/$(word 6, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 7, $(MEM_CELL_NAMES))/$(word 7, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 8, $(MEM_CELL_NAMES))/$(word 8, $(MEM_CELL_NAMES)).xci;\
		  \
		  set_param general.maxThreads 32;\
          \
          read_verilog -sv { $(addprefix ../,$(SRC)) };\
          read_vhdl { $(addprefix ../,$(VHDL_SRC)) };\
          read_xdc ../$(XDC);\
          synth_design -top $(TOP) -part $(BOARD);\
          \
          write_checkpoint -force $(SYNTH_CHECKPOINT);\
          report_timing_summary -file $(RPT_PS_TIME_SUM);\
          report_power -file $(RPT_PS_POWER);\
          \
          opt_design;\
          place_design;\
          phys_opt_design;\
          report_timing_summary -file $(RPT_PP_TIME_SUM);\
          route_design;\
          report_timing_summary -file $(RPT_PR_TIME_SUM);\
          write_checkpoint -force $(IMPL_CHECKPOINT);\
          \
          report_timing -sort_by group -max_paths 100 -path_type summary -file $(RPT_PR_PATH_TIME);\
          report_clock_utilization -file $(RPT_PR_CLOCK_UTIL);\
          report_utilization -file $(RPT_PR_UTIL);\
          report_power -file $(RPT_PR_POWER);\
          report_drc -file $(RPT_IMPL_DRC);\
          \
          write_verilog -force $(TOP)_glnet.v;\
          write_xdc -no_fixed_only -force $(TOP)_glnet.xdc;\
          \
          write_bitstream -force $(TARGET);\
          exit;" > $(TMP_TCL_PATH)
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	rm $(TMP_TCL_PATH)

# Setup block rom with new COE files.
$(IP_DIR)/$(COE_TS): $(IP_DIR)/$(IP_TS)
	mkdir -p $(PWD)/$(IP_DIR) && cd $(PWD)/$(IP_DIR)
	rm -rf ../$(IP_DIR)/$(word 5, $(MEM_CELL_NAMES))
	rm -rf ../$(IP_DIR)/$(word 6, $(MEM_CELL_NAMES))
	rm -rf ../$(IP_DIR)/$(word 7, $(MEM_CELL_NAMES))
	rm -rf ../$(IP_DIR)/$(word 8, $(MEM_CELL_NAMES))
	echo "create_project -part $(BOARD) -in_memory;\
          set IP_DIR $(PWD)/$(IP_DIR);\
          set COE_DIR $(PWD)/$(COE_DIR);\
          read_xdc ../$(XDC);\
		  \
          set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)0.coe;\
          set CELL $(word 5, $(MEM_CELL_NAMES));\
          source ../$(MEM_COE_TCL_PATH);\
          set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)1.coe;\
          set CELL $(word 6, $(MEM_CELL_NAMES));\
          source ../$(MEM_COE_TCL_PATH);\
          set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)2.coe;\
          set CELL $(word 7, $(MEM_CELL_NAMES));\
          source ../$(MEM_COE_TCL_PATH);\
          set COE_FILE $(PWD)/$(COE_DIR)/$(coe_basename)3.coe;\
          set CELL $(word 8, $(MEM_CELL_NAMES));\
          source ../$(MEM_COE_TCL_PATH);\
		  \
          generate_target all [get_ips];\
          synth_ip [get_ips];\
          \
          exit;" > $(TMP_TCL_PATH)
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	#touch $(COE_TS)
	rm $(TMP_TCL_PATH)

# Alias for bitstream generation.
bitstream: xilinx_loaded $(BUILD_DIR)/$(TARGET)

# Alias for reprogramming via COE files.
loadcoe: xilinx_loaded $(IP_DIR)/$(COE_TS)

.PHONY: sim isim rtl_schematic tcl_console flash clean cleanall

# Terminal only sim, make sure your testbench has $print calls in it.
sim: xilinx_loaded $(BUILD_DIR)/$(ELAB_TS)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(PWD)/$(BUILD_DIR)
	echo "log_wave -recursive *; run ${sim_time}; exit" > $(TMP_TCL_PATH)
	$(SIM) $(SIM_FLAGS) --tclbatch $(TMP_TCL_PATH) $(testbench)_snap
	rm $(TMP_TCL_PATH)

# Launches the simulator in interactive graphical mode.
isim: xilinx_loaded $(BUILD_DIR)/$(ELAB_TS)
	$(call check_defined, DISPLAY, Interactive sim requires X11)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(PWD)/$(BUILD_DIR)
	echo "create_wave_config; add_wave /; set_property needs_save false [current_wave_config]" > $(TMP_TCL_PATH)
	$(SIM) --gui $(SIM_FLAGS) --tclbatch $(TMP_TCL_PATH) $(testbench)_snap
	rm $(TMP_TCL_PATH)

# Shows an RTL schematic of the design.
rtl_schematic: xilinx_loaded $(IP_DIR)/$(IP_TS)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(PWD)/$(BUILD_DIR)
	echo "set_part $(BOARD);\
		  \
		  read_ip ../$(IP_DIR)/$(word 1, $(MEM_CELL_NAMES))/$(word 1, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 2, $(MEM_CELL_NAMES))/$(word 2, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 3, $(MEM_CELL_NAMES))/$(word 3, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 4, $(MEM_CELL_NAMES))/$(word 4, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 5, $(MEM_CELL_NAMES))/$(word 5, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 6, $(MEM_CELL_NAMES))/$(word 6, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 7, $(MEM_CELL_NAMES))/$(word 7, $(MEM_CELL_NAMES)).xci;\
          read_ip ../$(IP_DIR)/$(word 8, $(MEM_CELL_NAMES))/$(word 8, $(MEM_CELL_NAMES)).xci;\
		  \
		  set_param general.maxThreads 32;\
          \
		  read_verilog -sv { $(addprefix ../,$(SRC)) };\
		  synth_design -top $(TOP) -rtl -name $(TOP)_rtl -part $(BOARD);\
          start_gui;" > $(TMP_TCL_PATH)
	$(VIVADO) $(VIVADO_FLAGS) -mode tcl -source $(TMP_TCL_PATH)
	rm $(TMP_TCL_PATH)

# Brings up an interactive TCL console.
tcl_console: xilinx_loaded
	$(VIVADO) -mode tcl

# Programs the bitstream.
flash: xilinx_loaded $(BUILD_DIR)/$(TARGET)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(PWD)/$(BUILD_DIR)
	echo "open_hw_manager;\
          connect_hw_server;\
          current_hw_target;\
          open_hw_target;\
          current_hw_device;\
          \
          set_property PROGRAM.FILE {$(TARGET)} [current_hw_device];\
          program_hw_devices;\
          \
          close_hw_target;\
          exit;" > $(TMP_TCL_PATH)
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	rm $(TMP_TCL_PATH)

clean:
	rm -vrf $(BUILD_DIR)

cleanall:
	rm -vrf $(BUILD_DIR) $(IP_DIR)

TARGET              := riscv32_fpga.bit
BUILD_DIR           := build
BOARD               := xc7a100tcsg324-1
XDC                 := constr/riscvcore.xdc

VIVADO              := vivado
VIVADO_FLAGS        :=
TOP                 := rv_uart_top

MEM_GEN_TCL_PATH    := scripts/vivado/ip_mem_gen.tcl
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
VLOG_ANALYSIS_FLAGS := --sv
VLOG_ANALYSIS_TS    := analysis_timestamp.tmp

ELAB                := xelab
ELAB_FLAGS          := --debug typical
# Defines testbench module to run for sims, can be specified via 'make sim testbench=foobar'.
testbench           := testbench
ELAB_TS             := $(addprefix $(testbench),_elab_timestamp.tmp)

IP_TS               := ip_gen_timestamp.tmp

SIM                 := xsim
SIM_FLAGS           :=
# This is default, can be specified to be longer if needed via 'make sim sim_time=XXns' or if finite 'make sim sim_time=all'.
sim_time            := 500ns

TB                  := $(shell find tb/ -type f -name '*.sv')
SRC                 := $(shell find src/ -type f -name '*.sv')
#SDB                := $(subst tb/,$(VLOG_ANALYSIS_OUT),$(subst src/,$(VLOG_ANALYSIS_OUT),$(SRC:.sv=.sdb)))

.ONESHELL:
.SHELLFLAGS += -e

# Func to check if vars are defined.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

all: xilinx_loaded $(BUILD_DIR)/$(TARGET)

xilinx_loaded:
	$(call check_defined, XILINX_VIVADO, Xilinx tools not found in path. Did you forget to load them?)

# Terminal only sim, make sure your testbench has $print calls in it.
sim: $(BUILD_DIR)/$(ELAB_TS)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
	echo "log_wave -recursive *; run ${sim_time}; exit" > $(TMP_TCL_PATH)
	$(SIM) $(SIM_FLAGS) --tclbatch $(TMP_TCL_PATH) $(testbench)_snap
	rm $(TMP_TCL_PATH)

# Launches the simulator in interactive graphical mode.
isim: $(BUILD_DIR)/$(ELAB_TS)
	$(call check_defined, DISPLAY, Interactive sim requires X11)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
	echo "create_wave_config; add_wave /; set_property needs_save false [current_wave_config]" > $(TMP_TCL_PATH)
	$(SIM) --gui $(SIM_FLAGS) --tclbatch $(TMP_TCL_PATH) $(testbench)_snap
	rm $(TMP_TCL_PATH)

# Runs elaboration for simulation.
$(BUILD_DIR)/$(ELAB_TS): $(BUILD_DIR)/$(VLOG_ANALYSIS_TS)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
	$(ELAB) $(ELAB_FLAGS) -top $(testbench) -snapshot $(testbench)_snap
	touch $(ELAB_TS)

# Runs analysis for simulation.
$(BUILD_DIR)/$(VLOG_ANALYSIS_TS): $(SRC) $(TB)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
	$(VLOG_ANALYSIS) $(VLOG_ANALYSIS_FLAGS) $(addprefix ../,$(SRC)) $(addprefix ../,$(TB))
	touch $(VLOG_ANALYSIS_TS)

# Shows an RTL schematic of the design.
rtl_schematic: $(SRC)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
	echo "read_verilog -sv { $(addprefix ../,$(SRC)) }; synth_design -top $(TOP) -rtl -name $(TOP)_rtl -part $(BOARD);\
          start_gui;" > $(TMP_TCL_PATH)
	$(VIVADO) $(VIVADO_FLAGS) -mode tcl -source $(TMP_TCL_PATH)
	rm $(TMP_TCL_PATH)

$(BUILD_DIR)/$(IP_TS):
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
	mkdir -p ip_data
	echo "create_project -part $(BOARD) -in_memory;\
          set IP_DIR ip_data;\
          \
          set CELL mem_cell_0;\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL mem_cell_1;\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL mem_cell_2;\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL mem_cell_3;\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL imem_cell_0;\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL imem_cell_1;\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL imem_cell_2;\
          source ../$(MEM_GEN_TCL_PATH);\
          set CELL imem_cell_3;\
          source ../$(MEM_GEN_TCL_PATH);\
          \
          generate_target all [get_ips];\
          synth_ip [get_ips];\
          exit;" > $(TMP_TCL_PATH)
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	touch $(IP_TS)
	rm $(TMP_TCL_PATH)

# Generates the bitstream.
$(BUILD_DIR)/$(TARGET): $(BUILD_DIR)/$(IP_TS) $(SRC)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
	echo "read_ip ip_data/mem_cell_0/mem_cell_0.xci;\
          read_ip ip_data/mem_cell_1/mem_cell_1.xci;\
          read_ip ip_data/mem_cell_2/mem_cell_2.xci;\
          read_ip ip_data/mem_cell_3/mem_cell_3.xci;\
          read_ip ip_data/imem_cell_0/imem_cell_0.xci;\
          read_ip ip_data/imem_cell_1/imem_cell_1.xci;\
          read_ip ip_data/imem_cell_2/imem_cell_2.xci;\
          read_ip ip_data/imem_cell_3/imem_cell_3.xci;\
          \
          read_verilog -sv { $(addprefix ../,$(SRC)) };\
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

# Programs the bitstream.
flash: $(BUILD_DIR)/$(TARGET)
	mkdir -p $(PWD)/$(BUILD_DIR) && cd $(BUILD_DIR)
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


.PHONY: clean

clean:
	rm -rf build

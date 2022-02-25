include build.config

SHELL               := bash
.SHELLFLAGS         := -ec
.ONESHELL:
.NOTPARALLEL:

# Func to make/chdir.
init = mkdir -p $(PROJECT_ROOT)/$(1) && cd $(PROJECT_ROOT)/$(1)

# Func to check if vars are defined.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

# Func to generate a script by replacing vars.
gen_script = envsubst < $1 > $(TMP_TCL_PATH)

all: xilinx_loaded bitstream

xilinx_loaded:
	$(call check_defined,VIVADO_PATH,Xilinx tools not found in path. Did you forget to load them?)

# Runs elaboration for simulation.
$(BUILD_DIR)/$(ELAB_TS): $(BUILD_DIR)/$(ANALYSIS_TS)
	$(call init,$(BUILD_DIR))
	$(ELAB) $(ELAB_FLAGS) $(ELAB_LIBRARIES) -top $(testbench) -snapshot $(testbench)_snap
	touch $(ELAB_TS)

# Runs analysis for simulation.
$(BUILD_DIR)/$(ANALYSIS_TS): $(IP_DIR)/$(COE_TS) $(SRC) $(TB)
	$(call init,$(BUILD_DIR))
	# No pkgs in verilog yet, uncomment if any are added.
	#$(VLOG_ANALYSIS) $(VLOG_ANALYSIS_FLAGS) $(PKGS)
	$(VLOG_ANALYSIS) $(VLOG_ANALYSIS_FLAGS) $(SRC) $(TB)
	$(VHDL_ANALYSIS) $(VHDL_ANALYSIS_FLAGS) $(VHDL_PKGS)
	$(VHDL_ANALYSIS) $(VHDL_ANALYSIS_FLAGS) $(VHDL_SRC)
	$(VLOG_ANALYSIS) $(MEM_SRC)
	touch $(ANALYSIS_TS)

# Generate block ram IP for build. Should only happen once initally.
# Unused since all IP cores now have some coe file.
#$(IP_DIR)/$(IP_TS):
#	$(call init,$(IP_DIR))
#	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_0)
#	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_1)
#	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_2)
#	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_3)
#	$(call gen_script,$(MEM_GEN_TCL))
#	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
#	touch $(IP_TS)
#	rm $(TMP_TCL_PATH)

# Setup block rom with new COE files.
$(IP_DIR)/$(COE_TS): $(COE_FILES)
	$(call init,$(IP_DIR))
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_0)
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_1)
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_2)
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_3)
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_0)
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_1)
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_2)
	rm -rf $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_3)
	$(call gen_script,$(MEM_COE_TCL))
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	touch $(COE_TS)
	rm $(TMP_TCL_PATH)

# Generates the bitstream.
$(BUILD_DIR)/$(TARGET): $(IP_DIR)/$(COE_TS) $(SRC)
	$(call init,$(BUILD_DIR))
	$(call gen_script,$(BITSTREAM_TCL))
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	rm $(TMP_TCL_PATH)

# Alias for bitstream generation.
bitstream: xilinx_loaded $(BUILD_DIR)/$(TARGET)

# Alias for reprogramming via COE files.
loadcoe: xilinx_loaded $(IP_DIR)/$(COE_TS)

.PHONY: sim isim rtl_schematic tcl_console flash clean cleanall

# Terminal only sim, make sure your testbench has $print calls in it.
sim: xilinx_loaded $(BUILD_DIR)/$(ELAB_TS)
	$(call init,$(BUILD_DIR))
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_0)/$(MEM_CELL_0).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_1)/$(MEM_CELL_1).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_2)/$(MEM_CELL_2).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_3)/$(MEM_CELL_3).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_0)/$(IMEM_CELL_0).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_1)/$(IMEM_CELL_1).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_2)/$(IMEM_CELL_2).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_3)/$(IMEM_CELL_3).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	$(call gen_script,$(SIM_TCL))
	$(SIM) $(SIM_FLAGS) --tclbatch $(TMP_TCL_PATH) $(testbench)_snap
	rm $(TMP_TCL_PATH)

# Launches the simulator in interactive graphical mode.
isim: xilinx_loaded $(BUILD_DIR)/$(ELAB_TS)
	$(call check_defined,DISPLAY,Interactive sim requires X11)
	$(call init,$(BUILD_DIR))
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_0)/$(MEM_CELL_0).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_1)/$(MEM_CELL_1).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_2)/$(MEM_CELL_2).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(MEM_CELL_3)/$(MEM_CELL_3).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_0)/$(IMEM_CELL_0).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_1)/$(IMEM_CELL_1).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_2)/$(IMEM_CELL_2).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	cp $(PROJECT_ROOT)/$(IP_DIR)/$(IMEM_CELL_3)/$(IMEM_CELL_3).mif $(PROJECT_ROOT)/$(BUILD_DIR)/
	$(call gen_script,$(ISIM_TCL))
	$(SIM) --gui $(SIM_FLAGS) --tclbatch $(TMP_TCL_PATH) $(testbench)_snap
	rm $(TMP_TCL_PATH)

# Shows an RTL schematic of the design.
rtl_schematic: xilinx_loaded $(IP_DIR)/$(COE_TS)
	$(call check_defined,DISPLAY,Schematic requires X11)
	$(call init,$(BUILD_DIR))
	$(call gen_script,$(RTL_SCHEME_TCL))
	$(VIVADO) $(VIVADO_FLAGS) -mode tcl -source $(TMP_TCL_PATH)
	rm $(TMP_TCL_PATH)

# Brings up an interactive TCL console.
tcl_console: xilinx_loaded
	$(VIVADO) -mode tcl

# Show the serial console.
serial:
	$(SCREEN) $(SCREEN_FLAGS) $(SCREEN_DEVICE) $(SCREEN_BAUD)

# Programs the bitstream.
flash: xilinx_loaded
	$(call init,$(BUILD_DIR))
	$(call gen_script,$(FLASH_TCL))
	$(VIVADO) $(VIVADO_FLAGS) -mode batch -source $(TMP_TCL_PATH)
	rm $(TMP_TCL_PATH)

clean:
	rm -vrf $(BUILD_DIR)

cleanall:
	rm -vrf $(BUILD_DIR) $(IP_DIR)

module regfile (
    main_bus_if.regfile bus
);

  logic [31:0] regdata[32];  // Array of 32 32-bit registers
  logic        wen;            // Register write enable

  // Enables write to regfile if instruction writes to a register and destination register isn't x0
  assign wen = bus.MEM_WB_regwrite && |bus.MEM_WB_rd;

  // Reads data in register rs1
  assign bus.IF_ID_dout_rs1 = |bus.adr_rs1 ? regdata[bus.adr_rs1] :
                              |bus.adr_photon_rs1 ? regdata[bus.adr_photon_rs1] : 0;

  // Reads data in register rs2
  assign bus.IF_ID_dout_rs2 = |bus.IF_ID_rs2 ? regdata[bus.IF_ID_rs2] : 0;

  // Writes data to register rd in writeback stage
  always_ff @(posedge bus.clk) begin
    if (bus.Rst) regdata[2] <= 1020;
    if (wen && ~bus.mem_hold) regdata[bus.MEM_WB_rd] <= bus.WB_res;
    if (bus.photon_regwrite) regdata[bus.addr_corereg_photon] <= bus.photon_data_out;
  end

// Initializes registers to 0 in simulations
`ifndef SYNTHESIS
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      regdata[i] = 0;
    end
  end
`endif
endmodule : regfile

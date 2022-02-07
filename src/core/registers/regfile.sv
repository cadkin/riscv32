module regfile (
    main_bus_if.regfile bus
);

  logic [31:0] regdata[31:0];  // array of 32 32-bit registers
  logic [31:0] fcsr;  //flowing point control registers
  logic        wen;

  //write enable if regwrite is asserted and read address is not zero
  assign wen = bus.MEM_WB_regwrite && |bus.MEM_WB_rd;

  assign bus.IF_ID_dout_rs1 = |bus.adr_rs1 ? regdata[bus.adr_rs1] :
                              |bus.adr_photon_rs1 ? regdata[bus.adr_photon_rs1] : 0;

  assign bus.IF_ID_dout_rs2 = |bus.IF_ID_rs2 ? regdata[bus.IF_ID_rs2] : 0;

  always_ff @(posedge bus.clk) begin
    if (bus.Rst) regdata[2] <= 1020;
    if (wen && ~bus.mem_hold) regdata[bus.MEM_WB_rd] <= bus.WB_res;
    if (bus.photon_regwrite) regdata[bus.addr_corereg_photon] <= bus.photon_data_out;
  end

`ifndef SYNTHESIS
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      regdata[i] = 0;
    end
  end
`endif
endmodule : regfile

`timescale 1ns / 1ps

module csr (
    main_bus_if bus
);

  logic clk, wea, rst;
  logic [31:0] din, dout;
  logic [11:0] r_addr, w_addr;

  always_comb begin : bus_stuff
    clk = bus.clk;
    rst = bus.Rst;
    wea = bus.EX_CSR_write;
    din = bus.EX_CSR_res;
    r_addr = bus.IF_ID_CSR_addr;
    w_addr = bus.EX_CSR_addr;
    bus.IF_ID_CSR = dout;
  end

  logic [31:0] mstatus, misa, mie, mtvec, mscratch, mepc, mcause, mtval, mip;

  function static logic [31:0] build_mcause();
    begin
      if (bus.ecall) return {1'b1, 31'h3};
      else if (bus.uart_IRQ) return 31;
    end
  endfunction

  always_comb begin
    bus.mtvec = mtvec;
    bus.mepc  = mepc;

    case (r_addr[11:0])
      12'h300: dout = mstatus;
      12'h301: dout = misa;
      12'h304: dout = mie;
      12'h305: dout = mtvec;
      12'h340: dout = mscratch;
      12'h341: dout = mepc;
      12'h342: dout = mcause;
      12'h343: dout = mtval;
      12'h344: dout = mip;
      default: dout = 0;
    endcase
  end

  always_ff @(posedge clk or posedge bus.trigger_trap or posedge rst) begin
    if (rst) begin
      mie <= 0;
      mtvec <= 0;
      mepc <= 0;
      mcause <= 0;
    end else if (bus.trigger_trap) begin
      mepc   <= bus.ID_EX_pres_addr;
      mcause <= build_mcause();
    end else begin
      if (wea) begin
        case (w_addr[11:0])
          12'h300: mstatus <= din;
          12'h301: misa <= din;
          12'h304: mie <= din;
          12'h305: mtvec <= din;
          12'h340: mscratch <= din;
          12'h341: mepc <= din;
          12'h342: mcause <= din;
          12'h343: mtval <= din;
          12'h344: mip <= din;
          default: ;
        endcase
      end
    end
  end
endmodule : csr

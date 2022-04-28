`timescale 1ns / 1ps

module csr (
    main_bus_if bus
);

  logic clk, wea, rst;
  logic [31:0] din, dout;
  logic [11:0] r_addr, w_addr;
  

  // Connects CSR registers to main bus
  always_comb begin : bus_stuff
    clk = bus.clk;
    rst = bus.Rst;
    wea = bus.EX_CSR_write;
    din = bus.EX_CSR_res;
    r_addr = bus.IF_ID_CSR_addr;
    w_addr = bus.EX_CSR_addr;
    bus.IF_ID_CSR = dout;
  end

  // CSR registers
  // Keeps track of and controls the hart’s current operating state
  logic [31:0] mstatus;   // Machine Status Register
  // WARL read-write register reporting the ISA supported by the hart
  logic [31:0] misa;      // Machine ISA Register
  // Contains information on pending interrupts
  logic [31:0] mie;       // Machine Interrupt Register
  // Holds trap vector configuration, consisting of a vector base address (BASE) and a vector mode (MODE).
  logic [31:0] mtvec;     // Machine Trap-Vector Base-Address Register
  // Used to hold a pointer to a M-mode hart-local context space and swapped with a user register upon entry to an M-mode trap handler.
  logic [31:0] mscratch;  // Machine Scratch Register
  // When a trap is taken, mepc is written with the virtual address of the instruction that encountered the exception
  logic [31:0] mepc;      // Machine Exception Program Counter
  // When a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap
  logic [31:0] mcause;    // Machine Cause Register
  // When a trap is taken into M-mode, mtval is either set to zero or written with exception-specific information to assist software in handling the trap
  logic [31:0] mtval;     // Machine Trap Value
  // Contains interrupt enable bits
  logic [31:0] mip;       // Machine Interrupt Register
  
  //logic [31:0] fcsr;           // Floating point control registers
  logic [7:0] fcsr;           // Floating point control registers reduced with our reserved
  logic [2:0] frm_sys;    // Floating point rounding mode system
  // Floating point Accrued Exceptions (fflags)
  logic nv;   //Invalid Operation
  logic dz;   //Divide by Zero
  logic of;   //Overflow
  logic uf;   //Underflow
  logic nx;   //Inexact
  
  // Writes a code to mcause register indicating the event that caused the trap
  function static logic [31:0] build_mcause();
    begin
      // Trap caused by interrupt
      if (bus.ecall) return {1'b1, 31'h3}; // Interrupt bit set, Exception Code 3: Machine software interrupt
      // Trap caused by UART
      else if (bus.uart_IRQ) return 31;    // Exception Code 31: Custom use
    end
  endfunction

  // Reports statuses of CSR registers
  always_comb begin
    bus.mtvec = mtvec;
    bus.mepc  = mepc;
    bus.fcsr = fcsr;
    //fcsr = {24'h0000000,frm_sys,nv,dz,of,uf,nx};
    fcsr = {frm_sys,nv,dz,of,uf,nx};
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
   always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      frm_sys <= 0;
      nv <= 0;
      dz <= 0;
      of <= 0;
      uf <= 0;
      nx <= 0;
     end
     else begin
       frm_sys <= bus.EX_MEM_fcsr[7:5];
       nv <= bus.EX_MEM_fcsr[4];
       dz <= bus.EX_MEM_fcsr[3];
       of <= bus.EX_MEM_fcsr[2];
       uf <= bus.EX_MEM_fcsr[1];
       nx <= bus.EX_MEM_fcsr[0];
     end
    end
  // Write to CSR registers every clock cycle or trap
  always_ff @(posedge clk or posedge bus.trigger_trap or posedge rst) begin
    if (rst) begin
      mie <= 0;
      mtvec <= 0;
      mepc <= 0;
      mcause <= 0;
    // Write current PC to mepc and interrupt cause to mcause when trap triggered
    end else if (bus.trigger_trap) begin
      mepc   <= bus.ID_EX_pres_addr;
      mcause <= build_mcause();
    // Write to CSR registers when no trap has been triggered
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

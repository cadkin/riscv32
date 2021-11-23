`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2021 10:21:37 PM
// Design Name: 
// Module Name: Execute_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
interface main_bus ();
    logic clk, Rst, debug, dbg, prog, mem_hold, uart_IRQ, RAS_rdy;//rx, //addr_dn, addr_up,
    logic[4:0] debug_input;
    logic         PC_En;
    logic         hz;
    logic         branch;
    logic  [31:0]  branoff;
    logic  [31:0]  ID_EX_pres_addr;
    logic  [31:0] ins;
    logic  [4:0]  ID_EX_rd;
    logic         ID_EX_memread,ID_EX_regwrite;
    logic  [4:0]  EX_MEM_rd,MEM_WB_rd,WB_ID_rd;
    logic  [4:0]  ID_EX_rs1,ID_EX_rs2,ID_EX_rs3;
    logic  [31:0] ID_EX_dout_rs1,ID_EX_dout_rs2,ID_EX_dout_rs3,EX_MEM_dout_rs2;
    logic  [31:0] IF_ID_dout_rs1,IF_ID_dout_rs2,IF_ID_dout_rs3;
    logic  [31:0]  IF_ID_pres_addr;
    logic         IF_ID_jalr;
    logic         ID_EX_jal,ID_EX_jalr;
    logic         ID_EX_compare;
    logic  [31:0] EX_MEM_alures,MEM_WB_alures,MEM_WB_memres;
    logic         EX_MEM_comp_res;

    logic [31:0] EX_MEM_pres_addr;
    logic [31:0] MEM_WB_pres_addr;

    logic  [4:0]  EX_MEM_rs1, EX_MEM_rs2;

    logic  [2:0]  ID_EX_alusel,ID_EX_frm,EX_MEM_frm;
    logic  [4:0]  ID_EX_fpusel;
    logic  [4:0]  ID_EX_loadcntrl;
    logic  [2:0]  ID_EX_storecntrl;
    logic  [3:0]  ID_EX_cmpcntrl;
    logic  [4:0]  EX_MEM_loadcntrl;
    logic  [2:0]  EX_MEM_storecntrl;
    logic         ID_EX_alusrc,IF_ID_fpusrc,ID_EX_fpusrc,EX_MEM_fpusrc,MEM_WB_fpusrc,WB_ID_fpusrc;
    logic         EX_MEM_memread,MEM_WB_memread;
    logic         ID_EX_memwrite,EX_MEM_memwrite;
    logic         EX_MEM_regwrite,MEM_WB_regwrite,WB_ID_regwrite;
    logic         ID_EX_lui;
    logic         ID_EX_auipc;
    logic  [31:0] ID_EX_imm;
    logic  [31:0] WB_res,WB_ID_res;
    logic  [4:0]  adr_rs1;//used for debug option
    logic  [4:0]  IF_ID_rs1,IF_ID_rs2,IF_ID_rs3, IF_ID_rd;
    logic         ID_EX_lb,ID_EX_lh,ID_EX_lw,ID_EX_lbu,ID_EX_lhu,ID_EX_sb,ID_EX_sh,ID_EX_sw;
    logic         EX_MEM_lb,EX_MEM_lh,EX_MEM_lw,EX_MEM_lbu,EX_MEM_lhu,EX_MEM_sb,EX_MEM_sh,EX_MEM_sw;
    logic         f_stall; //used for stall the pipe for floating point calculation.
//    logic dbg;
    logic [31:0] uart_dout;
    logic memcon_prog_ena;

    logic IF_ID_jal;

    logic mmio_wea;
    logic [31:0] mmio_dat;
    logic mmio_read;

    logic [31:0] DD_out;

    logic [31:0] mem_din, mem_dout;
    logic [31:0] mem_addr;
    logic [3:0] mem_en;
    logic mem_wea;
    logic mem_rea;

    logic [31:0] imem_dout;
    logic imem_en;
    logic [31:0] imem_addr;
    
    logic comp_sig;
    logic ID_EX_comp_sig;

//    logic push, pop, stack_ena;
//    logic stack_mismatch, stack_full, stack_empty;
//    logic [31:0] stack_din;


    //CSR signals
    logic [11:0] IF_ID_CSR_addr, ID_EX_CSR_addr;
    logic [31:0] IF_ID_CSR, ID_EX_CSR;
    logic [31:0] EX_CSR_res;
    logic [31:0] EX_MEM_CSR, MEM_WB_CSR;
    logic [11:0] EX_CSR_addr;
    logic ID_EX_CSR_write;
    logic EX_CSR_write;
    logic MEM_WB_CSR_write;
    logic ID_EX_CSR_read, EX_MEM_CSR_read, MEM_WB_CSR_read;

    logic [2:0] csrsel;

    logic trap, ecall;
    logic [31:0] mtvec, mepc;

    logic trapping, trigger_trap, trap_ret, trigger_trap_ret;

    logic [31:0] next_addr;


    assign trap = ecall;
	always_ff @(posedge clk) begin
		if (Rst) begin
			trapping <= 0;
			trigger_trap <= 0;
			trigger_trap_ret <= 0;
		end else begin
			if (trap & (~trapping)) begin
				trapping <= 1;
				trigger_trap <= 1;
			end else trigger_trap <= 0;

			if (trap_ret & (trapping)) begin
				trapping <= 0;
				trigger_trap_ret <= 1;
			end else trigger_trap_ret <= 0;
		end
	end



    //photon_core signals
    logic [31:0] photon_ins, photon_data_out;
    logic photon_busy, photon_regwrite;
    logic [4:0] adr_photon_rs1, addr_corereg_photon;

    //modport declarations. These ensure each pipeline stage only sees and has access to the
    //ports and signals that it needs

 /*   //modport for register file
    modport regfile(
        input clk, adr_rs1, adr_photon_rs1, IF_ID_rs1,IF_ID_rs2, IF_ID_rs3, MEM_WB_rd, addr_corereg_photon, Rst,f_stall,
        input WB_res, MEM_WB_regwrite, mem_hold, photon_data_out, photon_regwrite,IF_ID_fpusrc,MEM_WB_fpusrc,
		output IF_ID_dout_rs1, IF_ID_dout_rs2, IF_ID_dout_rs3 
    );

    //modport for decode stage
    modport decode(            
        input clk, Rst, dbg, ins, IF_ID_pres_addr, MEM_WB_rd, WB_res, mem_hold, comp_sig,f_stall,
        input EX_MEM_memread, EX_MEM_regwrite, MEM_WB_regwrite, EX_MEM_alures,
        input EX_MEM_rd, IF_ID_dout_rs1, IF_ID_dout_rs2, IF_ID_dout_rs3,
        input IF_ID_CSR, trap, trigger_trap, RAS_rdy,
        output ID_EX_memread, ID_EX_regwrite,IF_ID_fpusrc,
        output ID_EX_pres_addr, IF_ID_jalr, ID_EX_jalr, branch, IF_ID_jal,
        output IF_ID_rs1, IF_ID_rs2,IF_ID_rs3, IF_ID_rd,
        output ID_EX_dout_rs1, ID_EX_dout_rs2, branoff, hz,
        output ID_EX_rs1, ID_EX_rs2,ID_EX_rs3,ID_EX_rd, ID_EX_alusel,ID_EX_fpusel,ID_EX_frm,
        output ID_EX_storecntrl, ID_EX_loadcntrl, ID_EX_cmpcntrl,
        output ID_EX_auipc, ID_EX_lui, ID_EX_alusrc, ID_EX_fpusrc,
        output ID_EX_memwrite, ID_EX_imm, ID_EX_compare, ID_EX_jal, 
        output IF_ID_CSR_addr, ID_EX_CSR_addr, ID_EX_CSR, ID_EX_CSR_write, csrsel, ID_EX_CSR_read, ecall, ID_EX_comp_sig, 
        output trap_ret
    );
*/
    //modport for execute stage
    modport execute(
        input clk, Rst, dbg, ID_EX_lui, ID_EX_auipc, ID_EX_loadcntrl, mem_hold,f_stall,
        input ID_EX_storecntrl, ID_EX_cmpcntrl,
        output EX_MEM_loadcntrl, EX_MEM_storecntrl,
        input ID_EX_compare, ID_EX_pres_addr, ID_EX_alusel, ID_EX_alusrc,ID_EX_fpusel,ID_EX_fpusrc,ID_EX_frm,
        input ID_EX_memread, ID_EX_memwrite, ID_EX_regwrite, ID_EX_jal,
        input ID_EX_jalr, ID_EX_rs1, ID_EX_rs2, ID_EX_rs3,ID_EX_rd, ID_EX_dout_rs1, ID_EX_dout_rs2, ID_EX_dout_rs3,
        output EX_MEM_dout_rs2, EX_MEM_rs2, EX_MEM_rs1,
        input ID_EX_imm, MEM_WB_regwrite, WB_ID_regwrite,
        output EX_MEM_alures,
        input WB_res, WB_ID_res,
        output EX_MEM_memread, EX_MEM_rd,
        input MEM_WB_rd, WB_ID_rd,
        output EX_MEM_memwrite, EX_MEM_regwrite, EX_MEM_comp_res,EX_MEM_fpusrc,EX_MEM_frm,
        output EX_MEM_pres_addr,
        input ID_EX_CSR_addr, ID_EX_CSR, ID_EX_CSR_write, csrsel, ID_EX_CSR_read,
        output EX_CSR_res, EX_CSR_addr, EX_CSR_write, EX_MEM_CSR, EX_MEM_CSR_read,
        input ID_EX_comp_sig
    );


endinterface

module Execute_sim(

    );
    

  main_bus bus();
  
  logic EX_MEM_memread_sig, EX_MEM_regwrite_sig,EX_MEM_fpusrc;
  logic [31:0] EX_MEM_alures_sig,EX_MEM_fpures_sig;
  logic [4:0]  EX_MEM_rd_sig;
  logic comp_res,f_stall;
  logic [31:0] alures,fpures;
  logic [2:0]  sel;
  logic [31:0] ALUop1,ALUop2,rs2_mod;
  logic [31:0] rs2_mod_final;//new
  
  logic [31:0] CSR_res;
  logic [31:0] CSR_mod; 


assign bus.adr_rs1=bus.IF_ID_rs1;
/*
FPU fut(.a(bus.ID_EX_dout_rs1),
        .b(bus.ID_EX_dout_rs2),
        .c(bus.ID_EX_dout_rs3),
        .rm(frm),
        .fpusel_s(bus.ID_EX_fpusel),
        .fpusel_d(bus.ID_EX_fpusel),
        .g_clk(bus.clk),
        .fp_clk(bus.clk),
        .g_rst(bus.Rst),
        .res(fpures),
        .stall(f_stall)
        ); 
 */
 //Decode u2(bus.decode);
 Execute u3(bus.execute);

 reg clk;
 always begin
    #3 clk = !clk;  
 end
 assign bus.clk = clk;
 initial begin
    bus.ID_EX_fpusrc = 1;
    bus.Rst = 1;
    e.frm = 0;
    
    #15
    bus.Rst = 0;
    #15
    bus.ID_EX_dout_rs1 = 32'h408ccccd;
    bus.ID_EX_dout_rs2 = 32'h400ccccd;
    bus.ID_EX_fpusel = 1;
    #200;
    
    
    
    
 end


endmodule

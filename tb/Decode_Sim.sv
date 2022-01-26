`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2021 10:21:37 PM
// Design Name: 
// Module Name: Decode_Sim
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

interface main_bus_if ();
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

    logic comp_sig;
    logic ID_EX_comp_sig;


    logic [31:0] imem_dout;
    logic imem_en;
    logic [31:0] imem_addr;

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

*/



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



endinterface


    




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








module Decode_Sim();

main_bus_if bus();

logic ID_EX_memread_sig, ID_EX_regwrite_sig;

//fluhed instruction detector
logic flush;

//logic debug;
logic ins_zero;
logic flush_sig;

//logic jal,jalr;
logic [1:0] funct2;
logic [2:0]funct3;
logic [3:0] funct4;
logic [5:0] funct6;
logic [6:0]funct7;
logic [11:0] funct12;

logic IF_ID_jal, IF_ID_compare;
logic jal, compare, jalr_sig;
logic IF_ID_jalr_sig;


//register file
logic [4:0]IF_ID_rd;
logic [31:0]dout_rs1,dout_rs2,dout_rs3,ins;

//control
logic [2:0]IF_ID_alusel, alusel;
logic IF_ID_memwrite,IF_ID_memread,IF_ID_regwrite,IF_ID_alusrc;
logic memwrite, memread, regwrite, alusrc;
logic fmemwrite, fmemread, fregwrite, fpusrc;
logic [2:0]IF_ID_storecntrl;
logic [4:0]IF_ID_loadcntrl;

logic [4:0] IF_ID_rs3,IF_ID_rs2 ,IF_ID_rs1;

//imm gen
logic [31:0]imm;
logic hz_sig;
logic branch_taken_sig;



logic trap_ret;

Decode u2(bus.decode);

logic clk, rst,stall;
logic [31:0] res;
logic [4:0] fpusel;
logic [2:0] frm;

always_comb begin
 bus.clk = clk;
 bus.Rst = rst;
 fpusrc= bus.ID_EX_fpusrc;
 frm= bus.ID_EX_frm;
 ins = bus.ins;
 fpusel = bus.ID_EX_fpusel;
 stall = bus.f_stall;
IF_ID_rs3 = bus.IF_ID_rs3;
IF_ID_rs2 = bus.IF_ID_rs2;
IF_ID_rs1 = bus.IF_ID_rs1;
imm = bus.ID_EX_imm;
IF_ID_loadcntrl = bus.ID_EX_loadcntrl;
IF_ID_storecntrl = bus.ID_EX_storecntrl;
end;
/*
   Control_fp u8(
       .opcode(bus.ins[6:0]),
       .funct3(funct3),
       .funct7(funct7),
       .ins_zero(ins_zero),
       .flush(flush),
       .hazard(hz_sig),
       .rs2(bus.ins[24:20]),
       .rd(bus.ins[11:7]), 
       .fpusel_s(IF_ID_fpusel),
       .memwrite(fmemwrite),
       .memread(fmemread),
       .regwrite(fregwrite),
       .fpusrc(IF_ID_fpusrc),
       .storecntrl(fstorecntrl),
       .loadcntrl(floadcntrl),
       .rm(IF_ID_frm)
    );

*/


always begin
    #3 clk = !clk;  
 end


 initial begin
    rst = 1;
    clk = 1;
    bus.dbg = 0;
    bus.mem_hold =0;
    bus.comp_sig = 0;
    bus.RAS_rdy = 1;
    bus.f_stall =0;
    #15;
    rst = 0;
    #15;

    bus.ins  = 32'h001001D3; // fadd with rd = 0x03 rs1 =0x00 rs2 = 0x01 rm =000
    #15;
    bus.ins  = 32'h28501353; // fmax with rd = 0x06 rs1 =0x00 rs2 = 0x05
    #15;
    bus.ins  = 32'hD0032053; // fcvts.w with rd = 0x00 rs1 =0x06 rm =010
    #15;
    bus.ins  = 32'h003C2187; //fload with rd = 0x03 rs1 = 0x18 imm = 0x003
    #30;
	

end;



endmodule

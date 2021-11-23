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


module Decode_Sim(main_bus bus);

logic IF_ID_lui, lui;
logic ID_EX_memread_sig, ID_EX_regwrite_sig;
//logic[4:0] ID_EX_rd_sig;

//fluhed instruction detector
logic flush;

//logic debug;
logic ins_zero;
logic flush_sig;
logic [31:0]rs1_mod,rs2_mod,rs3_mod;

//logic jal,jalr;
logic [1:0] funct2;
logic [2:0]funct3;
logic [3:0] funct4;
logic [5:0] funct6;
logic [6:0]funct7;
logic [11:0] funct12;
logic [31:0] comp_imm;

logic IF_ID_jal, IF_ID_compare;
logic jal, compare, jalr_sig;
logic IF_ID_jalr_sig;

//hazard detection and compare unit
logic zero1,zero2,zero3,zero4,zeroa,zerob;

//register file
logic [4:0]IF_ID_rd;
logic [31:0]dout_rs1,dout_rs2,dout_rs3;

//control
logic [2:0]IF_ID_alusel, alusel,IF_ID_frm,rm;
logic [4:0] IF_ID_fpusel,fpusel_s;
logic      IF_ID_branch, branch;
logic      IF_ID_memwrite,IF_ID_memread,IF_ID_regwrite,IF_ID_alusrc;
logic memwrite, memread, regwrite, alusrc;
logic fmemwrite, fmemread, fregwrite, fpusrc;
logic [2:0]IF_ID_storecntrl, storecntrl,fstorecntrl;
logic [4:0]IF_ID_loadcntrl, loadcntrl,floadcntrl;
logic [3:0]IF_ID_cmpcntrl;
logic      IF_ID_auipc;
logic [4:0] IF_ID_rs3,IF_ID_rs2 ,IF_ID_rs1;
logic [2:0] csrsel;
logic csrwrite;
logic csrread;
logic [11:0] IF_ID_CSR_addr;

//imm gen
logic [31:0]imm, IF_ID_imm;
logic hz_sig;
logic branch_taken_sig;


//Compressed signals
logic [4:0] c_rd, c_rs1, c_rs2;
logic [1:0] c_funct2;
logic [2:0] c_funct3;
logic [3:0] c_funct4;
logic [5:0] c_funct6;
logic [6:0] c_funct7; 
logic [2:0] c_alusel; 
logic [2:0] c_storecntrl;
logic [4:0] c_loadcntrl;
logic c_branch, c_beq, c_bne, c_memread, c_memwrite, c_regwrite, c_alusrc, c_compare;
logic c_lui, c_jal, c_jalr;
logic [31:0] c_imm;

logic trap_ret;


Decode d(bus);

initial begin

end



endmodule

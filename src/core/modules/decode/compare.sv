`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/18/2018 11:16:13 PM
// Design Name:
// Module Name: compare
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

module compare (
    input logic [4:0] IF_ID_rs1,
    input logic [4:0] IF_ID_rs2,
    input logic [4:0] ID_EX_rd,
    input logic [4:0] EX_MEM_rd,
    input logic [4:0] MEM_WB_rd,
    output logic zero1,
    output logic zero2,
    output logic zeroa,
    output logic zero3,
    output logic zero4,
    output logic zerob
);

  logic [4:0] res1, res2, res3, res4, resa, resb;

  // Detects load and branch hazards for stalling or branch forwarding
  // Checks if destination register matches a source register

  // Detects load and branch hazards with back-to-back instr.
  // Stall required for both
  // Load Example: ld rd -> add rs1/rs2
  // Branch Example: add rd -> beq rs1/rs2
  assign res1  = IF_ID_rs1 - ID_EX_rd;
  assign res2  = IF_ID_rs2 - ID_EX_rd;
  // Detects load/branch and branch hazards with 1 instr. inbetween
  // Stall required for load/branch, branch can be forwarded
  // Load/Branch Example: ld rd -> [1 instr.] -> beq rs1/rs2
  // Branch Example: add rd -> [1 instr.] -> beq rs1/rs2
  assign res3  = IF_ID_rs1 - EX_MEM_rd;
  assign res4  = IF_ID_rs2 - EX_MEM_rd;
  // Detects branch hazards with 2 instr. inbetween
  // Can be forwarded
  // Branch Example: add rd -> [2 instr.] -> beq rs1/rs2
  assign resa  = IF_ID_rs1 - MEM_WB_rd;
  assign resb  = IF_ID_rs2 - MEM_WB_rd;

  // Forwarding disabled when destination register is x0
  assign zero1 = !(|res1) && (|ID_EX_rd);
  assign zero2 = !(|res2) && (|ID_EX_rd);
  assign zero3 = !(|res3) && (|EX_MEM_rd);
  assign zero4 = !(|res4) && (|EX_MEM_rd);
  assign zeroa = !(|resa) && (|MEM_WB_rd);
  assign zerob = !(|resb) && (|MEM_WB_rd);
endmodule

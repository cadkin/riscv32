typedef struct packed {
    logic [6:0] op;
    logic [2:0] func3;

    logic [12:1] imm;
    logic [4:0] rs1;
    logic [4:0] rs2;
} b_type_instr;

function b_type_instr to_b_format(logic [31:0] instr);
    b_type_instr i;

    i.op    = instr[6:0];
    i.func3 = instr[14:12];
    i.imm   = {instr[31], instr[7], instr[30:25], instr[11:8]};
    i.rs1   = instr[19:15];
    i.rs2   = instr[24:20];

    return i;
endfunction;

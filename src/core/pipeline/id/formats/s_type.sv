typedef struct packed {
    logic [6:0] op;
    logic [2:0] func3;

    logic [11:0] imm;
    logic [4:0] rs1;
    logic [4:0] rs2;
} s_type_instr;

function s_type_instr to_s_format(logic [31:0] instr);
    s_type_instr i;

    i.op    = instr[6:0];
    i.func3 = instr[14:12];
    i.imm   = {instr[31:25], instr[11:7]};
    i.rs1   = instr[19:15];
    i.rs2   = instr[24:20];

    return i;
endfunction;

typedef struct packed {
    logic [6:0] op;

    logic [20:1] imm;
    logic [4:0] rd;
} j_type_instr;

function j_type_instr to_j_format(logic [31:0] instr);
    j_type_instr i;

    i.op    = instr[6:0];
    i.imm   = {instr[31], instr[19:12], instr[20], instr[30:21]};
    i.rd    = instr[11:7];

    return i;
endfunction;

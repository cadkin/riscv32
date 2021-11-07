typedef struct packed {
    logic [6:0] op;

    logic [31:12] imm;
    logic [4:0] rd;
} u_type_instr;

function u_type_instr to_u_format(logic [31:0] instr);
    u_type_instr i;

    i.op    = instr[6:0];
    i.imm   = instr[31:12];
    i.rd    = instr[11:7];

    return i;
endfunction;

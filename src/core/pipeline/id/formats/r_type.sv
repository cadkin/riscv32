typedef struct packed {
    logic [6:0] op;
    logic [2:0] func3;
    logic [6:0] func7;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
} r_type_instr;

function r_type_instr to_r_format(logic [31:0] instr);
    r_type_instr i;

    i.op    = instr[6:0];
    i.func3 = instr[14:12];
    i.func7 = instr[31:25];
    i.rs1   = instr[19:15];
    i.rs2   = instr[24:20]
    i.rd    = instr[11:7];

    return i;
endfunction;

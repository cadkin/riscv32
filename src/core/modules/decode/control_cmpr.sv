module control_cmpr (
    input logic [31:0] ins,
    input logic ins_zero,
    input logic flush,
    input logic hazard,
    output logic [4:0] rd,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [1:0] funct2,
    output logic [2:0] funct3,
    output logic [3:0] funct4,
    output logic [5:0] funct6,
    output logic [6:0] funct7,
    output logic [2:0] alusel,
    output logic [2:0] storecntrl,
    output logic [4:0] loadcntrl,
    output logic branch,
    output logic beq,
    output logic bne,
    output logic memread,
    output logic memwrite,
    output logic regwrite,
    output logic alusrc,
    output logic compare,
    output logic lui,
    output logic jal,
    output logic jalr,
    output logic [31:0] imm
);

  // Instruction Classification Signal
  logic stall;

  // Prevents writes to registers if flushing, a hazard is present, or instruction is 0
  assign stall = flush || hazard || ins_zero;

  // Converts register field in instruction to the register number
  function static logic [4:0] RVC_Reg(input logic [2:0] rs);
    case (rs)
      3'b000:  return 8;
      3'b001:  return 9;
      3'b010:  return 10;
      3'b011:  return 11;
      3'b100:  return 12;
      3'b101:  return 13;
      3'b110:  return 14;
      3'b111:  return 15;
      default: return 0;
    endcase
  endfunction

  always_comb begin
    funct2 = ins[6:5];
    funct3 = ins[15:13];
    funct4 = ins[15:12];
    funct6 = ins[15:10];
    rd = 0;
    rs1 = 0;
    rs2 = 0;
    imm = 0;
    alusel = 0;
    storecntrl = 0;
    loadcntrl = 0;
    branch = 0;
    beq = 0;
    bne = 0;
    memread = 0;
    memwrite = 0;
    regwrite = 0;
    alusrc = 0;
    compare = 0;
    lui = 0;
    jal = 0;
    jalr = 0;

    // Decodes control signals from 16-bit instructions
    case (ins[1:0])
      2'b00: begin
        casez (ins[15:13])
          3'b000: begin  // C.ADDI4SPN - Add Immediate Scaled by 4 to SP
            rd = RVC_Reg(ins[4:2]);
            rs1 = 2;
            rs2 = 0;
            imm = {22'h0, ins[10:7], ins[12:11], ins[5], ins[6], 2'b00};
            regwrite = (!stall) && 1'b1;
            alusrc = 1'b1;
            alusel = 3'b000;
          end
          3'b010: begin  // C.LW - Load Word
            rd = RVC_Reg(ins[4:2]);
            rs1 = RVC_Reg(ins[9:7]);
            rs2 = 0;
            imm = {25'h0, ins[5], ins[12:10], ins[6], 2'b00};
            memread = 1'b1;
            regwrite = (!stall) && (1'b1);
            alusel = 3'b000;
            alusrc = 1'b1;
            loadcntrl = 5'b00100;
          end
          3'b1??: begin  // C.SW - Store Word
            rd = 0;
            rs1 = RVC_Reg(ins[9:7]);
            rs2 = RVC_Reg(ins[4:2]);
            imm = {25'h0, ins[5], ins[12:10], ins[6], 2'b00};
            memwrite = (!stall) && 1'b1;
            alusrc = 1'b1;
            alusel = 3'b000;
            storecntrl = 3'b111;
          end
          default: begin
          end
        endcase
      end
      2'b01: begin
        casez (ins[15:13])
          3'b000: begin  // C.NOP - No Operation, C.ADDI - Add Immediate
            rd = ins[11:7];
            rs1 = ins[11:7];
            rs2 = 0;
            imm = ins[12] ? {26'h3ffffff, ins[12], ins[6:2]} : {26'h0, ins[12], ins[6:2]};
            regwrite = (!stall) && 1'b1;
            alusrc = 1'b1;
            alusel = 3'b000;
          end
          3'b001: begin  // C.JAL - Jump and Link
            imm = ins[12] ? {20'hfffff, ins[12], ins[8], ins[10:9], ins[6], ins[7], ins[2], ins[11], ins[5:3], 1'b0} :
                            {20'h0, ins[12], ins[8], ins[10:9], ins[6], ins[7], ins[2], ins[11], ins[5:3], 1'b0};
            rd = 1;
            rs1 = 0;
            rs2 = 0;
            jal = (!flush) && 1'b1;
            regwrite = stall ? 1'b0 : 1'b1;
          end
          3'b010: begin  // C.LI - Load Immediate
            rd = ins[11:7];
            rs1 = 0;
            rs2 = 0;
            imm = ins[12] ? {26'h3ffffff, ins[12], ins[6:2]} : {26'h0, ins[12], ins[6:2]};
            regwrite = (!stall) && 1'b1;
            alusrc = 1;
            alusel = 3'b000;
          end
          3'b011: begin  // C.ADDI16SP - Add Immediate Scaled by 16 to SP, C.LUI - Load Upper Immediate
            if (ins[11:7] == 2) begin
              rd = ins[11:7];
              rs1 = ins[11:7];
              rs2 = 0;
              imm = ins[12] ? {22'h3fffff, ins[12], ins[4:3], ins[5], ins[2], ins[6], 4'h0} :
                              {22'h0, ins[12], ins[4:3], ins[5], ins[2], ins[6], 4'h0};
              regwrite = (!stall) && 1'b1;
              alusrc = 1;
              alusel = 3'b000;
            end else begin
              rd = ins[11:7];
              rs1 = 0;
              rs2 = 0;
              imm = ins[17] ? {14'h3fff, ins[17], ins[6:2], 12'h0} :
                              {14'h0, ins[17], ins[6:2], 12'h0};
              lui = 1'b1;
              alusrc = 1'b1;
              regwrite = stall ? 0 : 1;
            end
          end
          3'b100: begin
            rd = RVC_Reg(ins[9:7]);
            rs1 = RVC_Reg(ins[9:7]);
            rs2 = RVC_Reg(ins[4:2]);
            imm = {26'h0, ins[12], ins[6:2]};
            regwrite = (!stall) && (1'b1);
            case (ins[11:10])
              2'b00: begin  // SRLI - Logical Right Shift by Immediate
                alusrc = 1;
                alusel = 3'b110;
              end
              2'b01: begin  // SRAI - Arithmetic Right Shift by Immediate
                alusrc = 1;
                alusel = 3'b111;
              end
              2'b10: begin  // ANDI - Bitwise AND with Immediate
                alusrc = 1;
                alusel = 3'b010;
                imm = ins[12] ? {26'h3ffffff, ins[12], ins[6:2]} : {26'h0, ins[12], ins[6:2]};
              end
              2'b11: begin
                alusrc = 0;
                case (ins[6:5])
                  2'b00: begin  // C.SUB - Subtraction
                    alusel = 3'b001;
                  end
                  2'b01: alusel = 3'b100;  // C.XOR - Bitwise XOR
                  2'b10: alusel = 3'b011;  // C.OR - Bitwise OR
                  2'b11: alusel = 3'b010;  // C.AND - Bitwise AND
                  default: begin
                  end
                endcase
              end
              default: begin
              end
            endcase
          end
          3'b101: begin  // C.J - Jump
            imm = ins[12] ? {20'hfffff, ins[12], ins[8], ins[10:9], ins[6], ins[7], ins[2], ins[11], ins[5:3], 1'b0} :
                            {20'h0, ins[12], ins[8], ins[10:9], ins[6], ins[7], ins[2], ins[11], ins[5:3], 1'b0};
            jal = (!flush) && 1;
          end
          3'b110: begin  // C.BEQZ - Branch if Equal to Zero
            rs1 = RVC_Reg(ins[9:7]);
            funct3 = 3'b000;
            imm = ins[12] ? {23'h7fffff, ins[12], ins[6:5], ins[2], ins[11:10], ins[4:3], 1'h0} :
                            {23'h0, ins[12], ins[6:5], ins[2], ins[11:10], ins[4:3], 1'h0};
            branch = (!flush) && 1;
            beq = 1;
          end
          3'b111: begin  // C.BNEZ - Branch if Not Equal to Zero
            rs1 = RVC_Reg(ins[9:7]);
            funct3 = 3'b001;
            imm = ins[12] ? {23'h7fffff, ins[12], ins[6:5], ins[2], ins[11:10], ins[4:3], 1'h0} :
                            {23'h0, ins[12], ins[6:5], ins[2], ins[11:10], ins[4:3], 1'h0};
            branch = (!flush) && 1;
            bne = 1;
          end
          default: begin
          end
        endcase
      end
      2'b10: begin
        case (ins[15:13])
          3'b000: begin  // C.SLLI - Logical Left Shift by Immediate
            rd = ins[11:7];
            rs1 = ins[11:7];
            imm = {26'h0, ins[12], ins[6:2]};
            regwrite = (!stall) && 1'b1;
            alusrc = 1;
            alusel = 3'b101;
          end
          3'b001: begin  // C.FLDSP - Load Double FP from SP + off (UNSUPPORTED)
          end
          3'b010: begin  // C.LWSP - Load Word from SP + off
            rd = ins[11:7];
            rs1 = 2;
            imm = {26'h0, ins[12], ins[6:2]};
            memread = 1'b1;
            regwrite = (!stall) && (1'b1);
            alusel = 3'b000;
            alusrc = 1'b1;
            loadcntrl = 5'b00100;
          end
          3'b100: begin
            if (ins[12]) begin
              if (ins[11:7] == 0) begin  // C.EBREAK - Breakpoint

              end else begin
                if (ins[6:2] == 0) begin  // C.JALR - Jump and Link Register
                  rd = 1;
                  rs1 = ins[11:7];
                  jalr = (!flush) && 1;
                  regwrite = stall ? 0 : 1;
                end else begin  // C.ADD - Addition
                  rd = ins[11:7];
                  rs1 = ins[11:7];
                  rs2 = ins[6:2];
                  alusrc = 0;
                  regwrite = (!stall) && 1;
                  alusel = 3'b000;
                end
              end
            end else begin
              if (ins[6:2] == 0) begin  // C.JR - Jump Register
                rs1  = ins[11:7];
                jalr = (!flush) && 1;
              end else begin  // C.MV - Copy Register
                rd = ins[11:7];
                rs2 = ins[6:2];
                regwrite = (!stall) && 1'b1;
                alusel = 3'b000;
                alusrc = 0;
              end
            end
          end
          3'b110: begin  // C.SWSP - Store Word at SP + off
            rs1 = 2;
            rs2 = ins[6:2];
            imm = {24'h0, ins[8:7], ins[12:9], 2'b00};
            memwrite = (!stall) && 1'b1;
            alusrc = 1'b1;
            alusel = 3'b000;
            storecntrl = 3'b111;
          end
          default: begin
          end
        endcase
      end
      default: begin
      end
    endcase
  end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Created by:
//   Jianjun Xu, Tanner Fowler, Cameron Adkins, Dr. Garrett S. Rose
//   University of Tennessee, Knoxville
// 
// Created:
//   October 28, 2021
// 
// Module name: FPU
// Description:
//   Implements the RISC-V FPU block (part of execute pipeline stage)
//   Only contain the RV32F standard extension
// "Mini-RISC-V" implementation of RISC-V architecture developed by UC Berkeley
//
// Inputs:
//   a -- 32-bit input "a"
//   b -- 32-bit input "b"
//   c -- 32-bit input "c" for FMADD/SUB and FNMADD/SUB instructions
//   ID_EX_pres_adr -- present address (program counter) from decoder
//   sel -- ALU select bits from decoder stage
// Output:
//   res -- FLU operation result
//   comp_res -- FLU result of comparison
// 
//////////////////////////////////////////////////////////////////////////////////

module FPU
 (input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [31:0] c,
  input  logic [3:0]  fpusel_s,fpusel_d,
  input  logic g_clk,fp_clk,g_rst, //global clock, floating point logic unit clock, global reset 
  output logic [31:0] res,    
  output logic stall,     //flag for stall the pipeline
  output logic  comp_res);

  logic [31:0] input_a,input_b,input_c; //temp input for fpu
  logic [31:0] output_add,output_mul,output_div,output_f2i,output_i2f,output_f2ui,output_ui2f,output_fsgnj,output_fmv;//temp result for fpu
  logic [31:0] output_class,output_feq,output_fle,output_flt,output_fmax,output_fmin;
  logic enable_add,enable_mul,enable_div,enable_f2i,enable_i2f,enable_f2ui,enable_ui2f;
  logic clk_add,clk_mul,clk_div,clk_f2i,clk_i2f,clk_f2ui,clk_ui2f;
  logic out_stb_add,out_stb_mul,out_stb_div,out_stb_f2i,out_stb_f2ui,out_stb_i2f,out_stb_ui2f;
  logic [3:0]enable_sel;
  logic [1:0] fsign_sel;
  logic stall_flag;

  adder(input_a,input_b,clk_add,enable_add,output_add,out_stb_add);
  divider(input_a,input_b,clk_div,enable_div,output_div,out_stb_div);
  multiplier(input_a,input_b,clk_mul,enable_mul,output_mul,out_stb_mul);
  
  float_to_int(input_a,clk_f2i,enable_f2i,output_f2i,out_stb_f2i);
  float_to_unsig_int(input_a,clk_f2ui,enable_f2ui,output_f2ui,out_stb_f2ui);
  int_to_float(input_a,clk_i2f,enable_i2f,output_i2f,out_stb_i2f);
  unsig_int_to_float(input_a,clk_ui2f,enable_ui2f,output_ui2f,out_stb_i2uf);
  
  fsign_inject(input_a,input_b,fsign_sel,output_fsgnj);
  fmove(input_a,output_fmv);
  
  FClass(input_a,output_class);
  FEQ(input_a,input_b,output_feq);
  FLE(input_a,input_b, output_fle);
  FLT(input_a,input_b,output_flt);
  FMax(input_a,input_b, output_fmax);
  FMin(input_a,input_b, output_fmin);
  
//enable signal for the clock gating all for the active module 
always_comb 
begin
    if(g_rst == 1)begin
	enable_add = 0;
	enable_mul = 0;
	enable_div = 0;
	enable_f2i = 0;
	enable_i2f = 0;
	enable_f2ui = 0;
	enable_ui2f = 0;
    end else begin
	enable_add = 0;
	enable_mul = 0;
	enable_div = 0;
	enable_f2i = 0;
	enable_i2f = 0;
	enable_f2ui = 0;
	enable_ui2f = 0;
	case(enable_sel)
	   4'd1 :  enable_add = 1;
	   4'd2 :  enable_mul = 1;
	   4'd3 :  enable_div = 1;
	   4'd4 :  enable_f2i = 1;
	   4'd5 :  enable_i2f = 1;
	   4'd6 :  enable_f2ui = 1;
	   4'd7 :  enable_ui2f = 1;
	   default: enable_add = 0;
        endcase   
     end
end

//clock gating all for the active module;
assign   clk_add = enable_add ? fp_clk : 0;
assign   clk_mul = enable_mul ? fp_clk : 0;
assign   clk_div = enable_div ? fp_clk : 0;
assign   clk_f2i = enable_f2i ? fp_clk : 0;
assign   clk_i2f = enable_i2f ? fp_clk : 0;
assign   clk_f2ui = enable_f2ui ? fp_clk : 0;
assign   clk_ui2f = enable_ui2f ? fp_clk : 0;
assign 	 stall = stall_flag;


//getting the inputs from the id stage and select the logic to perform
always_ff @(posedge g_clk) 
begin //fpu instuction selction
	if(stall_flag == 0)	//only update the data if the fpu is not in stall
	    begin
		input_a <= a;
		if(fpusel_s == 5'b00001) 
		begin
			input_b <= {~b[31],b[30:0]};
		end else begin
			input_b <= b;
		end
		input_c <= c;
	end;

    case(fpusel_s)
      5'b00000 : begin //fp fadd 
	   enable_sel <= 1;
	end
      5'b00001 : //fp fsub
		enable_sel <= 1;
      5'b00010 : //fp fmul
		enable_sel <= 2;
      5'b00011 : //fp fdiv
		enable_sel <= 3;
      5'b00100 : //fp fsqurt
		enable_sel <= 3;
      5'b00101 : //fp fsgnj.s
		fsign_sel <= 1;
      5'b00110 : //fp fsgnjn
		fsign_sel <= 2;
      5'b00111 : //fp fsgnjx
		fsign_sel <= 3;
      5'b01000 : //fp fmax.s   compare_get_large
		;
      5'b01001 : //fp fmin.s   compare_get_small
		;
      5'b01010 : //fp feq.s    compare_eq
		;
      5'b01011 : //fp flt.s    compare_less_than
		;
      5'b01100 : //fp fle.s    compare_less_equite
		;
      5'b01101 : //fp fmv.x.w  
		;
      5'b01110 : //fp fclass.s
		;
      5'b01111 : //fp fmv.w.x
		;
      5'b10000 : //FMADD.S
		;
      5'b10001 : //FMSUB.S
		;
      5'b10010 : //FNMSUB.S
		;
      5'b10011 : //FNMADD.S 
		;
      5'b10100 : //FCVT.W.S int_to_float
		enable_sel <= 5;
      5'b10101 : //FCVT.WU.S unsign_int_to_float
		enable_sel <= 7;
      5'b10110 : //FCVT.S.W float_to_int
		enable_sel <= 4;
      5'b10111 : //FCVT.S.WU unsign_int_to_float
		enable_sel <= 6;
      default: begin 
		enable_sel <= 0; 
		fsign_sel <= 0;
		end
    endcase
  end

always_ff @(negedge g_clk)
begin
   case(fpusel_s)
      5'b00000 : //fp fadd 
		if(out_stb_add ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_add; 
			enable_sel <= 0;
		end
      5'b00001 : //fp fsub
        if(out_stb_add ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_add; 
			enable_sel <= 0;
		end
      5'b00010 : //fp fmul
		if(out_stb_mul ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_mul; 
			enable_sel <= 0;
		end
      5'b00011 : //fp fdiv
		if(out_stb_div ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_div; 
			enable_sel <= 0;
		end
      5'b00100 : //fp fsqurt
		;
      5'b00101 : //fp fsgnj.s
		res <= output_fsgnj;
      5'b00110 : //fp fsgnjn
		res <= output_fsgnj;
      5'b00111 : //fp fsgnjx
		res <= output_fsgnj;
      5'b01000 : //fp fmax.s   compare_get_large
		res <= output_fmax;
      5'b01001 : //fp fmin.s   compare_get_small
		res <= output_fmin;
      5'b01010 : //fp feq.s    compare_eq
		res <= output_feq;
      5'b01011 : //fp flt.s    compare_less_than
		res <= output_flt;
      5'b01100 : //fp fle.s    compare_less_equite
		res <= output_fle;
      5'b01101 : //fp fmv.x.w  
		res <= output_fmv;
      5'b01110 : //fp fclass.s
		res <= output_class;
      5'b01111 : //fp fmv.w.x
		res <= output_fmv;
      5'b10000 : //FMADD.S
		;
      5'b10001 : //FMSUB.S
		;
      5'b10010 : //FNMSUB.S
		;
      5'b10011 : //FNMADD.S 
		;
      5'b10100 : //FCVT.W.S int_to_float
		if(out_stb_i2f ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_i2f; 
			enable_sel <= 0;
		end
      5'b10101 : //FCVT.WU.S unsign_int_to_float
		if(out_stb_ui2f ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_ui2f; 
			enable_sel <= 0;
		end
      5'b10110 : //FCVT.S.W float_to_int
		if(out_stb_f2i ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_f2i; 
			enable_sel <= 0;
		end
      5'b10111 : //FCVT.S.WU unsign_int_to_float
		if(out_stb_f2ui ==0) stall_flag <= 1;
		else begin stall_flag <= 0; 
			res <= output_f2ui; 
			enable_sel <= 0;
		end
      default: begin stall_flag <= 0; res <= 32'h7fc00000;//output NaN
		end
    endcase
  end
   
endmodule: FPU

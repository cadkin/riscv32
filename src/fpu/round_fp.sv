//IEEE Floating Point to Integer Converter (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12

module rounding(
  input logic [23:0] a_m,
  input logic [9:0] a_e,
  input logic a_s,
  input logic [2:0] frm,sys_rm,
  output logic [31:0] z_m
  output logic [31:0] z_e);

logic [2:0] rm; //rounding mode
logic [27:0] value; 
parameter RNE    = 3'b000, //Round to Nearest, ties to Even
          RTZ	 = 3'b001, //Round towards Zero
	  RDN    = 3'b010, //Round Down (towards neigtaive infin)
          RUP	 = 3'b011, //Round Up (towards positive infin)
	  RMM    = 3'b100, //Round to Nearest, ties to Max Magnitude
          DYN	 = 3'b111; //In instruction's rm field, selects dynamic rounding mode; In Rounding Mode register, Invalid.
assign rm = (sys_rm == 3'b111) ? frm, sys_rm;

always_comb begin
   case (rm)
	RNE:begin
		if (guard && (round_bit | sticky | a_m[0])) begin
          	  z_m <= a_m + 1;
		  if (z_m == 24'hffffff) 
			z_e <= a_e + 1;
		  else 
			z_e <= a_e;
        	end
	end
	RTZ:begin
		z_m <= a_m;
		z_e <= a_e;
	end
	RDN:begin
		if(a_s == 1) begin
		  z_m <= a_m + 1;
		  z_e <= a_e;
		  if (z_m == 24'hffffff) 
			z_e <= a_e + 1;
		  else 
			z_e <= a_e;
        	end
	end
	RUP:begin
		if(a_s == 0) begin
		  z_m <= a_m + 1;
		  z_e <= a_e;
		  if (z_m == 24'hffffff) 
			z_e <= a_e + 1;
		  else 
			z_e <= a_e;
        	end
	end
	RMM:begin
		if (round_bit | sticky | guard) begin
          	  z_m <= a_m + 1;
		  z_e <= a_e;
		  if (z_m == 24'hffffff) 
			z_e <= a_e + 1;
		  else 
			z_e <= a_e;
        	end
	end
	default:  //invaide
   end
end


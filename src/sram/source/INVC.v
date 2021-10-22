//Verilog HDL for "sram_logic", "INVC" "functional"
//Manu Rathore


module INVC ( Y, A );

  input A;
  output Y;

 assign Y = ~A;
endmodule

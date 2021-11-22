`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2021 11:51:19 AM
// Design Name: 
// Module Name: fp_top_sim
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


module fp_top_sim();
  logic [31:0] input_a;
  logic [31:0] input_b;
  logic [31:0] input_c;
  logic [3:0]  fpusel_s,fpusel_d;
  logic g_clk,fp_clk,g_rst; //global clock, floating point logic unit clock, global reset 
  logic [31:0] res;    
  logic stall;     //flag for stall the pipeline
  logic  comp_res;
  FPU   a1(input_a,input_b,input_c,fpusel_s,fpusel_d,g_clk,fp_clk,g_rst,res,stall,comp_res);
   
    always begin
        #3 g_clk = !g_clk;  
        #3 fp_clk = !fp_clk;
      end
		
    initial begin
            g_clk = 0;
            fp_clk = 0;
            g_rst = 1;
            
            #9;
            g_rst = 0;
            
            
            #18;
            fpusel_s <= 0;
            //Addition Testing
            //2 + 1.5
            input_a = 32'h40000000;
            input_b = 32'h3fc00000;
            #150;
            
            //7.46 + 1.5
            input_a = 32'h40eeb852;
            input_b = 32'h3fc00000;
            #150;
            
            //2 + 3.25
            input_a = 32'h40000000;
            input_b = 32'h40500000;
            #150;
            
            //Modified adder for subtraction
            fpusel_s <= 1;
            //2 - 1.5
            input_a = 32'h40000000;
            input_b = 32'h3fc00000;
            #150;
            
            //7.46 - 1.5
            input_a = 32'h40eeb852;
            input_b = 32'h3fc00000;
            #150;
            
            //2 - 3.25
            input_a = 32'h40000000;
            input_b = 32'h40500000;
            #150;
            fpusel_s <= 2;
            // 2.2*4.4
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'h400ccccd;
            
            //wait
            #250;    
                                  
            //3.5*-3
            //set input a
            input_a = 32'h40600000;
            //set input b
            input_b = 32'hc0000000;
      
            //wait
            #250;
            fpusel_s <= 8;
            #50;
            //set input a
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'h400ccccd;
            //set both stable
            #50;
            
            input_b = 32'h40000000;
            input_a = 32'h40a9999a;
            
            #50;
            
            input_a = 32'h40000000;
            input_b = 32'h40a9999a;
            
            #50;
            
            input_a = 32'h40000000;
            input_b = 32'h40200000;
            #50;
                        
            input_a = 32'h40000000;
            input_b = 32'h40000000;
            #50;
      
      end
   
   
endmodule

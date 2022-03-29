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
  logic [2:0]   sys_rm,frm;
  logic [4:0]  fpusel_s,fpusel_d;
  logic fp_enable,g_clk,fp_clk,g_rst; //global clock, floating point logic unit clock, global reset 
  logic [31:0] res;    
  logic stall;     //flag for stall the pipeline

  FPU   a1(input_a,input_b,input_c,frm,sys_rm,fpusel_s,fpusel_d,fp_enable,g_clk,fp_clk,g_rst,res,stall);
   
    always begin
        #5 g_clk = !g_clk;  
        #5 fp_clk = !fp_clk;
      end
		
    initial begin
            fp_enable = 1;
            frm = 3'b111;
            sys_rm = 3'b000;
            g_clk = 0;
            fp_clk = 0;
            g_rst = 1;
            
            #15;

            fpusel_s <= 0;
            fpusel_d <= 0;
            //Addition Testing
            //2 + 1.5
            input_a = 32'h40000000;
            input_b = 32'h3fc00000;
	    input_c = 32'h00000000;
            sys_rm = 3'b000;
	    #50
	    g_rst = 0;
            
            
            
            #500;
            
            //7.46 + 1.5
            input_a = 32'h40eeb852;
            input_b = 32'h3fc00000;
            #500;
            
            //2 + 3.25
            input_a = 32'h40000000;
            input_b = 32'h40500000;
            #500;
            
            //Modified adder for subtraction
            fpusel_s <= 1;
            //2 - 1.5
            input_a = 32'h40000000;
            input_b = 32'h3fc00000;
            #500;
            
            //7.46 - 1.5
            input_a = 32'h40eeb852;
            input_b = 32'h3fc00000;
            #500;
            
            //2 - 3.25
            input_a = 32'h40000000;
            input_b = 32'h40500000;
            #500;
            fpusel_s <= 2;
            // 2.2*4.4
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'h400ccccd;
            
            //wait
            #500;    
                                  
            //3.5*-3
            //set input a
            input_a = 32'h40600000;
            //set input b
            input_b = 32'hc0000000;
      
            //wait
            #250;
            fpusel_s <= 8;
            #500;
            //set input a
            input_a = 32'h408ccccd;
            //set input b
            input_b = 32'h400ccccd;
            //set both stable
            #500;
            
            input_b = 32'h40000000;
            input_a = 32'h40a9999a;
            
            #500;
            
            input_a = 32'h40000000;
            input_b = 32'h40a9999a;
            
            #500;
            
            input_a = 32'h40000000;
            input_b = 32'h40200000;
            #500;
                        
            input_a = 32'h40000000;
            input_b = 32'h40000000;
            #500;
            
            input_a = 32'h42b20000;
            input_b = 32'h40000000;
            fpusel_s <= 4;
            #500;
      end
   
   
endmodule
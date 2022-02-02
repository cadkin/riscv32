`timescale 1ns / 1ps

//IEEE RISC-V Floating Point Classification (Single Precision)
//By Tanner Joseph Fowler 
//2021-11-15

module FClass(
		input logic [31:0] input_a,
        output logic [31:0] output_z
    );
    reg       [23:0] a_m, b_m, z_m;
    reg       [9:0] a_e, b_e, z_e;
    reg       a_s, b_s, z_s;
    
    assign  a_m = input_a[22 : 0];
    assign  a_e = input_a[30 : 23];
    assign  a_s = input_a[31];
    
    always_comb 
    begin
        //-inf
        if(a_s == 1 && a_e == 255 && a_m == 0) begin
            output_z = 0;
        end 
        //+inf
        else if(a_s == 0 && a_e == 255 && a_m==0) begin
            output_z = 7;
        end
        //-0
        else if(a_s == 1 && a_e == 0 && a_m == 0) begin
            output_z = 3;
        end
        //+0
        else if(a_s == 0 && a_e == 0 && a_m[22:0] == 0) begin
            output_z = 4;
        end
        //Sig NaN
        else if(a_e== 255 && a_m[21] ==1) begin
            output_z = 8;
        end
        //quiet NaN
        else if(a_e== 255 && a_m[22] ==1) begin
            output_z = 9;
        end
        //neg normal number
        else if(a_s == 1 && a_e != 0) begin
            output_z = 1;
        end 
        //neg subnormal number
        else if(a_s ==1 && a_e == 0 && a_m != 0) begin
            output_z = 2;
        end  
        //positive subnormal number
        else if(a_s ==0 && a_e == 0 && a_m != 0) begin
            output_z = 5;
        end
        //positive normal number
        else if(a_s == 0 && a_e != 0) begin
            output_z = 6;
        end 
    end
endmodule

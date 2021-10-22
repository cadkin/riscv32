//`timescale 1ns / 1ps 

//module Timer #(
//	parameter clk_rate = 100000000) (
//	input logic clk, rst, start, stop,
//	output logic [17:0] dout
//	);

//	logic [15:0] cnt = 16'h0000;

//	logic ena = 0;
//	logic ovflw = 0;

//	integer ms_counter = 0;
//	integer ms_to = clk_rate / 1000;
//	logic ms_tick = 0;

//	assign dout = {ena, ovflw, cnt};

//	always_ff @(posedge clk) begin
//		if (rst | start) begin
//			ms_counter <= 0; 
//			ms_tick <= 0; 
//			if (rst) ena <= 0;
//			else if (start) ena <= 1; 
//		end
//		else if (stop) begin
//			ena <= 0; 
//		end
//		else if (ena) begin
//			if (ms_counter == ms_to) begin
//				ms_tick <= 1;
//				ms_counter <= 0;
//			end else begin
//				ms_tick <= 0; 
//				ms_counter <= ms_counter + 1; 
//			end
//		end
//	end

//	always_ff @(posedge ms_tick | posedge rst) begin
//		if (rst) begin
//			cnt <= 0;
//			ovflw <= 0;
//		end else begin
//			if (cnt == 16'hffff) ovflw <= 1;
//			cnt <= cnt + 1;
//		end
//	end
//	// always_ff @(posedge clk) begin
//	// 	if (rst | start) begin
//	// 		cnt <= 32'h00000000;
//	// 		ovflw <= 0;
//	// 		if (rst) ena <= 0;
//	// 		else if (start) ena <= 1;
//	// 	end 
//	// 	else if (stop) begin
//	// 		ena <= 0;
//	// 	end 
//	// 	else if (ena) begin
//	// 		if (cnt == 32'hffffffff) begin
//	// 			ovflw <= 1;
//	// 		end
//	// 		cnt <= cnt + 1;
//	// 	end
//	// end


//endmodule : Timer
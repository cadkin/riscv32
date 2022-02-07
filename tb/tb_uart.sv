`timescale 1ns / 1ps
module tb_uart();

logic clk, rst, CS, WR;
logic [2:0] ADD;
logic [7:0] D; 
logic sRX, CTSn, DSRn, RIn, DCDn;
logic sTX, DTRn, RTSn, OUT1n, OUT2n, TXRDYn, RXRDYn; 
logic IRQ, B_CLK; 
logic [7:0] RD; 

always_comb begin
	CTSn = 1;
	DSRn = 1; 
	RIn = 1; 
	DCDn = 1; 
end

always #5 clk=~clk; 


gh_uart_16550 dut(clk, clk, rst, CS, WR, ADD, D, sRX, CTSn, DSRn, RIn, DCDN,
	sTX, DTRn, RTSn, OUT1n, OUT2n, TXRDYn, RXRDYn, IRQ, B_CLK, RD); 

initial begin
	clk = 0;
	rst = 1;
	CS = 0;
	D = 0;
	WR = 0;
	ADD = 0; 
#10
	rst = 0;
	CS = 1;
	WR = 1;
	ADD = 3;
	D = 8'h83;
#10
	ADD = 0;
	D = 54;
#10
	ADD = 1;
	D = 0;
#10
	ADD = 3;
	D = 3;
#10
	ADD = 2;
	D = 1;
#10
	ADD = 1;
	D = 1;
#10 
	WR = 0;
	CS = 0; 
	ADD = 0;
	D = 0; 
#10
	CS = 1;
	WR = 1; 
	D = 8'haa; 
	ADD = 0;
#10
	CS = 0;
	WR = 0;
	D = 0;

end

endmodule 

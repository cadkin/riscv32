`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/06/2019 10:07:43 AM
// Design Name:
// Module Name: tb_rvtop
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



module tb_riscv_top();

logic clk, Rst, rst_n, debug, rx, prog;
logic[ 4:0] debug_input; 
logic tx, clk_out; 
logic [6:0] sev_out;
logic [7:0] an;
logic [15:0] led; 
logic [95:0] key;
logic miso, mosi, cs; 
logic sck;

assign key[95:48]=48'h3cf3cf3cf3cf;
assign key[47:24]=24'h30c30c;
assign key[23:12]=12'hbae;
assign key[11:0]=12'h3cf;
assign rst_n = ~Rst;
riscv_top dut(.*); 

assign sck = dut.spi_sck;

assign miso = mosi;

always #5 clk=!clk; 






realtime t0, t1; 
realtime en_tot, tot;
logic begin_second = 0; 
logic get_second;

logic byte_sent;
logic [7:0] tx_byte; 
int tx_cnt, tx_idx;
enum {idle, reading} tx_rcv;
logic tx_avail;

logic [31:0] cnt0, cnt1;

task delay();
    #320;
endtask

task send_byte(input logic[7:0] rx_char);
byte_sent = 0;
rx = 0; 
delay();//#9000; 
for (int i = 0; i < 8; i++) begin
	rx = rx_char[i];
	delay();//#9000;  
end
rx = 1; 
byte_sent = 1;
endtask

task send_word(input logic [31:0] rx_word); 

send_byte(rx_word[7:0]);
delay();//#9000;
send_byte(rx_word[15:8]); 
delay();//#9000;
send_byte(rx_word[23:16]);
delay();//#9000;
send_byte(rx_word[31:24]);

endtask

always_ff @(posedge dut.u0.B_CLK or posedge Rst) begin
	if (Rst) begin
		tx_cnt <= 0;
		tx_byte <= 0;
		tx_rcv <= idle;  
		tx_idx <= 0;
		tx_avail <= 0;
	end else begin
		if (tx_cnt == 15) begin
			tx_cnt <= 0; 
			if ((tx_rcv == idle) & (tx == 0)) begin
				tx_rcv <= reading;
				tx_idx <= 0; 
				tx_avail <= 0;
			end else if (tx_rcv == reading) begin
				if (tx_idx < 8) begin
					tx_byte[tx_idx] <= tx; 
					tx_idx <= tx_idx + 1;
				end else begin
					tx_idx <= 0;
					tx_avail <= 1;
					tx_rcv <= idle;
				end 
			end else begin
			    tx_avail <= 0;
			end
		end else begin
			tx_cnt <= tx_cnt + 1;
		end
	end
end

always_ff @(posedge dut.clk_50M) begin
	if ((dut.rbus.IF_ID_pres_addr == 32'h14) & (dut.rbus.branch)) begin
		$stop;
	end 
end

int arr_len = 256;

initial begin
    $display("Begin simulaton");
	get_second = 0;
	byte_sent = 0;
    clk = 0;
    Rst = 1; 
    debug = 0;
    rx = 1; 
    prog = 0;
    debug_input = 0; 
    cnt0 = 0;
    cnt1 = 0;
    #10;
    Rst=0;
    
    #9000; 
    send_byte(0); 
    delay();//#9000;
    send_word(arr_len);   
    
        for (int j = 0; j < 4; j++)
    	   @(posedge tx_avail);
    @(posedge tx_avail);
    cnt0[7:0] = tx_byte;
    @(posedge tx_avail);
    cnt0[15:8] = tx_byte;
    @(posedge tx_avail);
    cnt0[23:16] = tx_byte;
    @(posedge tx_avail);
    cnt0[31:24] = tx_byte;
    
    send_byte(1); 
    delay();//#9000;
    send_word(arr_len); 
        for (int j = 0; j < 4; j++)
    	   @(posedge tx_avail);
    //end
    @(posedge tx_avail);
    cnt1[7:0] = tx_byte;
    @(posedge tx_avail);
    cnt1[15:8] = tx_byte;
    @(posedge tx_avail);
    cnt1[23:16] = tx_byte;
    @(posedge tx_avail);
    cnt1[31:24] = tx_byte;
    
    $display("CNT0: %d\nCNT1: %d", cnt0, cnt1); 
    $stop;
    
    

end

endmodule

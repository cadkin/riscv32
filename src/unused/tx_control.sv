`timescale 1ns / 1ps

module tx_control (
//	input logic clk, rst, ena,
//	input logic[31:0] data,
//	output logic tx
main_bus bus
);

logic clk, rst, ena, tx;
logic [31:0] data;

assign clk = bus.clk;
assign rst = bus.Rst;
assign ena = bus.mmio_wea;
assign bus.tx = tx;
assign data = bus.mmio_dat;

integer baud_count = 53;
//integer baud_count = 26;
integer cnt = 0;

logic[7:0] tx_data;
logic fifo_wea, fifo_rea, fifo_empty, fifo_full;
logic en_16_x_baud;
logic tx_wea, tx_pres, tx_half, tx_full; 
logic writeflag; 

uart_tx6 urt(.data_in(tx_data), .en_16_x_baud(en_16_x_baud), .serial_out(tx),
	.buffer_write(tx_wea), .buffer_data_present(tx_pres), 
	.buffer_half_full(tx_half), .buffer_full(tx_full), .buffer_reset(rst),
	.clk(clk));

FIFO_32I8O fifo_out(.CLK(clk), .RST(rst), .WriteEn(fifo_wea), .DataIn(data),
	.ReadEn(fifo_rea), .DataOut(tx_data), .Empty(fifo_empty), 
	.Full(fifo_full));

//assign fifo_wea = ena;


//uart stuff

always_ff @(posedge clk) begin
	if (rst) begin
		tx_wea <= 0;
		fifo_rea <= 0;
		writeflag <= 0;
		fifo_wea <= 0;
		bus.mmio_read <= 0;
	end
	else begin
	   if (ena) begin
	       fifo_wea <= 1;
	       bus.mmio_read <= 1;
	   end
	   else begin
	       fifo_wea <= 0;
	       bus.mmio_read <= 0;
	   end
		if (tx_full == 0) begin
			if (fifo_empty == 0) begin
				if (writeflag == 0) begin
					writeflag <= 1;
					fifo_rea <= 0;
					tx_wea <= 0;
				end
				else if (fifo_rea == 0) begin
					fifo_rea <= 1;
					tx_wea <= 0;
				end
				else begin
					writeflag <= 0;
					fifo_rea <= 0;
					tx_wea <= 1;
				end
			end
			else begin
				writeflag <= 0;
				fifo_rea <= 0;
				tx_wea <= 0;
			end
		end
	end
end


//baud rate stuff
always_ff @(posedge clk) begin
	if (cnt == baud_count) begin
		cnt <= 0;
		en_16_x_baud <= 1;
	end
	else begin
		cnt <= cnt + 1;
		en_16_x_baud <= 0;
	end
end

endmodule

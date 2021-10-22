`timescale 1ns / 1ps 

module Debug_Display (
//main_bus bus
mmio_bus mbus
//input logic clk, rst, mmio_wea, addr_up_in, addr_dn_in,
//input logic [31:0] din,
//output logic [31:0] dout
);

logic 		 clk, rst, mmio_wea;
logic		 addr_up, addr_dn; 
logic [31:0] din, dout;
logic [4:0]  addr;
integer writecount = 0;

Addressable_FIFO u0 (.wea(mmio_wea), .*);
//DB DB_dn (.Key(bus.addr_dn), .Clk(clk), .pulse(addr_dn));
//DB DB_up (.Key(bus.addr_up), .Clk(clk), .pulse(addr_up));
//DB DB_dn (.Key(addr_dn_in), .Clk(clk), .pulse(addr_dn));
//DB DB_up (.Key(addr_up_in), .Clk(clk), .pulse(addr_un));
//assign addr_dn = addr_dn_in;
//assign addr_up = addr_up_in;
//assign addr_dn = bus.addr_dn;
//assign addr_up = bus.addr_up;

always_comb begin : proc_bustransfer
    clk = mbus.clk;
    rst = mbus.Rst; 
    mmio_wea = mbus.disp_wea; 
    din = mbus.disp_dat; 
    mbus.disp_out = dout; 
    addr = mbus.debug_input;
//	clk = bus.clk;
//	rst = bus.Rst; 
//	mmio_wea = bus.mmio_wea; 
//	din = bus.mmio_dat; 
//	// addr_up = bus.addr_up;
//	// addr_dn = bus.addr_dn; 
//	bus.DD_out = dout;
//	addr = bus.debug_input;
end

//always_ff @(posedge clk) begin : proc_DD
//	if(rst) begin
//		addr <= 0;
//		writecount <= 0;
//	end else begin
////	   if (mmio_wea)
////	       writecount <= writecount + 1;
////		if (addr_up) begin
////			addr = addr + 1;
////			if (addr >= writecount)
////			    addr = 0;
////		end else if (addr_dn) begin
////			addr = addr - 1;
////			if ((addr < 0) || (addr >= writecount)) 
////			    addr = (writecount - 1);
////		end 
//	end
//end

endmodule // Debug_Display
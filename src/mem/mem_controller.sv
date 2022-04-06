`timescale 1ns / 1ps

module mem_controller (
    riscv_bus_if rbus,
    mmio_bus_if  mbus
);

  logic clk, rst;
  logic mem_wea, mem_rea;
  logic [3:0] mem_en;
  logic [11:0] mem_addr_lower;
  logic [19:0] mem_addr_upper;
  logic [31:0] mem_din, mem_dout;

  logic [31:0] imem_addr, imem_dout, imem_din;
  logic imem_en;

  logic mmio_region, kernel_region, prog_region, uart_region;
  logic spi_region;
  logic spi_last_cond;
  logic [7:0] spi_last;
  logic [31:0] blkmem_dout, doutb, blkmem_din, blkmem_addr;
  logic uart_last_cond;
  logic [31:0] uart_last_out;

  logic CRAS_region;
  logic RAS_wr, RAS_rd, RAS_mem_rdy;
  logic [31:0] RAS_din, RAS_dout, RAS_addr;

  logic blkmem_wr, blkmem_rd;
  logic [2:0] blkmem_strctrl;
  logic [3:0] blkmem_en;

  logic cnt_region, cnt_last;
  logic [31:0] cnt_last_out;

  logic mem_hold;

  assign mem_hold = 0;

  // Connection to SRAM/BRAM interface
  mem_interface #(
      .USE_SRAM(0)
  ) sharedmem (
      .clk(clk),
      .imem_en(imem_en),
      // blkmem_wr = Write Enable
      // blkmem_rd = Read Enable
      // Can't be in MMIO Region
      .mem_en((blkmem_wr | blkmem_rd) & (~mmio_region)),
      .storecntrl_a(3'b000),
      .storecntrl_b(blkmem_strctrl),
      .imem_addr(imem_addr),
      .imem_din(32'hz),
      .mem_addr(blkmem_addr),
      .mem_din(blkmem_din),
      .imem_wen(4'b0000),
      .mem_wen(blkmem_en),
      .imem_dout(imem_dout),
      .mem_dout(doutb),
      .scan_en(rbus.scan_en),
      .scan_clk(rbus.scan_clk),
      .scan_in(rbus.scan_in),
      .scan_out(rbus.scan_out)
  );

  assign blkmem_dout = doutb;

  // Connects memory controller to core bus
  always_comb begin
    clk = rbus.clk;
    rst = rbus.Rst;
    mem_wea = rbus.mem_wea;
    mem_rea = rbus.mem_rea;
    mem_din = rbus.mem_din;
    rbus.mem_dout = mem_dout;
    // 0x00000___
    mem_addr_lower = rbus.mem_addr[11:0];
    // 0x_____000
    mem_addr_upper = rbus.mem_addr[31:12];
    // Enable writing to data memory if in kernel or prog region
    mem_en = ((kernel_region | prog_region) & mem_wea) ? rbus.mem_en : 4'b0000;
    imem_en = rbus.imem_en;
    imem_addr = rbus.imem_addr;
    imem_din = rbus.imem_din;
    rbus.imem_dout = imem_dout;
    rbus.mem_hold = mem_hold;
    RAS_din = mbus.RAS_mem_din;
    RAS_addr = mbus.RAS_mem_addr;
    RAS_rd = mbus.RAS_mem_rd;
    RAS_wr = mbus.RAS_mem_wr;
    mbus.RAS_mem_dout = RAS_dout;
    mbus.RAS_mem_rdy = RAS_mem_rdy;
  end

  // Data memory regions
  always_comb begin : mem_region
    // MMIO Region = 0xaaaaa000 to 0xaaaaafff
    mmio_region = (mem_addr_upper == 20'haaaaa);
    // Kernel Region = 0x00000000 to 0x3fffffff
    kernel_region = (rbus.mem_addr[31:30] == 2'b00);
    // Prog Region = 0x00010000 to 0x0001ffff
    prog_region = (rbus.mem_addr[31:16] == 16'h0001);
    // UART Region = 0xaaaaa400 to 0xaaaaa408
    uart_region = (mem_addr_upper == 20'haaaaa) &
                  (mem_addr_lower >= 12'h400) &
                  (mem_addr_lower < 12'h408);
    // UART Region = 0xaaaaa500 to 0xaaaaa502
    spi_region = (mem_addr_upper == 20'haaaaa) &
                 (mem_addr_lower >= 12'h500) &
                 (mem_addr_lower < 12'h502);
    // CRAS Region = 0xaaaaa600 to 0xaaaaa61c
    CRAS_region = (mem_addr_upper == 20'haaaaa) &
                  (mem_addr_lower >= 12'h600) &
                  (mem_addr_lower <= 12'h61c);
    // CNT Region = 0xaaaaa700 to 0xaaaaa708
    cnt_region = (mem_addr_upper == 20'haaaaa) &
                 (mem_addr_lower >= 12'h700) &
                 (mem_addr_lower < 12'h708);
  end

  // RAS
  always_comb begin
    RAS_mem_rdy = ~(mem_wea | mem_rea);
    RAS_dout = blkmem_dout;
  end

  always_comb begin
    // Enable UART write or read when data address is in UART region
    mbus.tx_wen = (uart_region) ? mem_wea : 1'b0;
    mbus.rx_ren = uart_region ? mem_rea : 1'b0;
    mbus.uart_din = mem_din[7:0];
    mbus.uart_addr = mem_addr_lower[2:0];

    // Enable debug display write or read when data address is in MMIO Region and 0xaaaaa008
    mbus.disp_wea = (mmio_region & (mem_addr_lower == 12'h008)) ? mem_wea : 1'b0;
    mbus.disp_dat = (mmio_region & (mem_addr_lower == 12'h008)) ? mem_din : 32'h0;

    // Enable SPI write or read when data address is in SPI region
    mbus.spi_rd = spi_region ? mem_rea : 1'b0;
    mbus.spi_wr = spi_region ? mem_wea : 1'b0;
    mbus.spi_din = spi_region ? mem_din[7:0] : 8'h00;
    mbus.spi_ignore_response = spi_region ? mem_din[8] : 1'b0;

    // Enable CRAS write or read when data address is in CRAS region
    mbus.RAS_config_din = CRAS_region ? mem_din : 32'h0;
    mbus.RAS_config_addr = CRAS_region ? mem_addr_lower[4:2] : 3'b000;
    mbus.RAS_config_wr = CRAS_region ? mem_wea : 0;

    // Enable CNT write or read when data address is in CNT region and 0xaaaaa704
    mbus.cnt_zero = (cnt_region & (mem_addr_lower == 12'h704)) ? mem_wea : 0;

    // Output UART, SPI, or BRAM/SRAM read data
    mem_dout = uart_last_cond ? uart_last_out :
               (spi_last_cond ? {24'h0, spi_last} :
                (cnt_last ? cnt_last_out : blkmem_dout));
  end

  // RAS
  always_comb begin
    blkmem_din = RAS_mem_rdy ? RAS_din : mem_din;
    blkmem_addr = RAS_mem_rdy ? RAS_addr : rbus.mem_addr;
    blkmem_en = RAS_mem_rdy ? (RAS_wr ? 4'b1111 : 4'b0000) : mem_en;
    blkmem_wr = RAS_mem_rdy ? RAS_wr : mem_wea;
    blkmem_rd = RAS_mem_rdy ? RAS_rd : mem_rea;
    blkmem_strctrl = RAS_mem_rdy ? (RAS_wr ? 3'b100 : 3'b000) : rbus.storecntrl;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
    end else if (~mem_hold) begin
      // Write or read data from UART
      if (uart_region && (mem_wea | mem_rea)) begin
        uart_last_cond <= 1;
        uart_last_out  <= mbus.uart_dout;
      end else begin
        uart_last_cond <= 0;
      end

      // Write or read data from SPI
      if (spi_region && (mem_wea | mem_rea)) begin
        spi_last_cond <= 1;
        if (mem_addr_lower == 12'h500) spi_last = mbus.spi_dout;
        else spi_last = {5'b0, mbus.spi_buffer_full, mbus.spi_buffer_empty, mbus.spi_data_avail};
      end else spi_last_cond <= 0;

      // Read data from CNT
      if (cnt_region & (mem_rea)) begin
        cnt_last <= 1;
        if (mem_addr_lower == 12'h700) cnt_last_out <= mbus.cnt_dout;
        else cnt_last_out <= {31'h0, mbus.cnt_ovflw};
      end else cnt_last <= 0;
    end
  end
endmodule : mem_controller

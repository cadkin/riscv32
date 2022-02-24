# RISCV32

### Setup
You can setup the repository for development on a NEXYS4 FPGA fairly easily:
1. Download and install [Vivado 2020.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html)
 \- you'll need an account. If you are using one of the lab computers, Vivado should already be available.

2. Clone the repo.
   ```
   $ git clone git@github.com:cadkin/riscv32.git
   ```

3. Load the Xilinx tools. If you installed it on a personal computer, you should be able to load it by sourcing the included `settings64.sh` file. In a default installation:
   ```
   $ source /opt/Xilinx/Vivado/2020.2/settings64.sh
   ```
   On the lab computers:
   ```
   $ module load Vivado/2020.2
   ```
   
4. Run make to generate a bitstream:
   ```
   $ make
   ```
   This will generate all required IP and load the instruction memory with a sample program. The output bitstream will be located at `build/riscv32_fpga.bit`.
   
   Checkout the [wiki](https://github.com/cadkin/riscv32/wiki) for more details and to learn about more options like simulations.

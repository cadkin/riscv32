# RISCV32
---

### Setup
You can setup the repository for development on a NEXYS4 FPGA fairly easily.
1. Download and install [Vivado 2020.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2020-2.html) (You'll need an account).

2. Clone the repo.
```
$ git clone git@github.com:cadkin/riscv32.git
```
or if you don't have SSH keys set up:
```
$ git clone https://github.com/cadkin/riscv32.git
```

3. Export the `RISCV32` environment variable to where you downloaded the repo. For instance:
```
$ export RISCV32=/home/cadkin17/files/riscv32
```

4. Open Vivado and go to `Window->TCL Console`.

5. In the console, run the setup script:
```
source $::env(RISCV32)/scripts/vivado_setup.tcl
```

This will setup a new Vivado project with the sources in the repo and generate the necessary IP blocks. This is a
one-time setup, you can simply launch Vivado and select the RISCV32 project in the future.

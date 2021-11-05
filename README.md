# RISCV32

### Setup
You can setup the repository for development on a NEXYS4 FPGA fairly easily.
1. Download and install [Vivado 2020.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2020-2.html)
 \- you'll need an account. If you are using one of the lab computers, Vivado should already be available by running
`module load Vivado/2020.2` in the shell.

2. Clone the repo.
   ```
   $ git clone git@github.com:cadkin/riscv32.git
   ```

3. Export the `RISCV32` environment variable to where you downloaded the repo. For instance:
   ```
   $ export RISCV32=/home/cadkin17/files/riscv32
   ```

4. Run Vivado in the same terminal and go to `Window->TCL Console`.

5. In the console, run the setup script:
   ```
   source $::env(RISCV32)/scripts/vivado_setup.tcl
   ```

And that's it. This will setup a new Vivado project with the sources in the repo and generate the necessary IP blocks. This is a
one-time setup, you can simply launch Vivado and select the RISCV32 project in the future.

### Updating
If you do a git pull, there's a chance that some files have either moved or been deleted. There is also a TCL script
to perform this update.

1. Export the `RISCV32` environment variable to where you downloaded the repo. For instance:
   ```
   $ export RISCV32=/home/cadkin17/files/riscv32
   ```

2. Run Vivado in the same terminal open up the `riscv32` project. You might get a warning about missing files - this is
   fine.

3. Go to `Window->TCL Console` and source the script:
   ```
   source $::env(RISCV32)/scripts/vivado_setup.tcl
   ```
   This will update the sources fileset with the files in repo.

4. In the sources pane, click on the missing sources tool button and remove any files here from the project.

with import <nixpkgs> {
  crossSystem = {
    config = "riscv32-none-elf";
  };
};

mkShell {
  buildInputs = [ zlib ]; # your dependencies here
}


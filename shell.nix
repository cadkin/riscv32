{ pkgs ? import <nixpkgs> {} }:

let
    #xrt = pkgs.callPackage ./xrt.nix {};

    fhs = pkgs.buildFHSUserEnv {
        name = "xilinx-env";

        multiPkgs = null;

        targetPkgs = pkgs: with pkgs; [
            bash
            coreutils
            #xrt

            xorg.libXext
            xorg.libX11
            xorg.libXrender
            xorg.libXtst
            xorg.libXi
            xorg.libXft
            xorg.libxcb
            xorg.libxcb

            freetype
            fontconfig
            glib
            gtk2
            gtk3

            graphviz
            gcc
            unzip
            nettools

            zlib
            ncurses5
        ];

        runScript = ''
            #!/bin/sh

            source /opt/xilinx/Vivado/2020.2/settings64.sh
            bash
        '';
    };
in fhs.env



{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in rec {
    packages."${system}".default = pkgs.pkgsi686Linux.stdenv.mkDerivation rec {
      name = "blitz";
      src = pkgs.fetchFromGitHub {
          owner = "BlitzOSProject";
          repo = "BlitzOSProject.github.io";
          rev = "3c60e8e4ac2073ba94802712125b429b2b5ffc49";
          hash = "sha256-DJWV0vBdDGPBylapwbFjLZyybse+Nw8DSEpM07arbdU=";
      };
      installPhase = ''
        mkdir -p $out/bin
        cd ${src}/BlitzBin/Ubuntu64
        cp kpl asm lddd blitz diskUtil dumpObj hexdump check endian $out/bin
        chmod +x $out/bin/*
      '';
      preFixup = ''
      cd $out/bin
        for file in ./*
        do
          patchelf \
            --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            $file
        done
      '';
    };
  };
}
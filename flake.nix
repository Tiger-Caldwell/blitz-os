{
  outputs = { self, nixpkgs }:
    let
      derivInfo = pkgs: rec {
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
    in rec {
      packages."x86_64-linux".default =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in pkgs.pkgsi686Linux.stdenv.mkDerivation (derivInfo pkgs);
      packages."i686-linux".default =
        let pkgs = import nixpkgs { system = "i686-linux"; };
        in pkgs.stdenv.mkDerivation (derivInfo pkgs);

      formatter.x86_64-linux =
        (import nixpkgs { system = "x86_64-linux"; }).nixfmt;
    };
}

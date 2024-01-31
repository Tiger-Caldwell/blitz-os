{
  outputs = { self, nixpkgs }:
    let
      derivInfo = nativePkgs: pkgs: rec {
        name = "blitz";
        src = pkgs.fetchFromGitHub {
          owner = "BlitzOSProject";
          repo = "BlitzOSProject.github.io";
          rev = "3c60e8e4ac2073ba94802712125b429b2b5ffc49";
          hash = "sha256-/zzxD4Nt2VJB8n9cM1fGpD7cOCc8JwuewzwipngY6RU=";
          sparseCheckout = [ "BlitzBin/Ubuntu64" ];
        };
        buildInputs = [ pkgs.gcc-unwrapped.lib ];
        nativeBuildInputs = [ nativePkgs.makeWrapper ];
        installPhase = ''
          mkdir -p $out/bin
          cd ${src}/BlitzBin/Ubuntu64
          cp kpl asm lddd blitz diskUtil dumpObj hexdump check endian $out/bin
          chmod +x $out/bin/*
        '';
        preFixup = ''
          for file in $out/bin/*
          do
            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              $file
          done
        '';
        postFixup = ''
          for file in $out/bin/*
          do
            wrapProgram $file --set LD_LIBRARY_PATH "${pkgs.gcc-unwrapped.lib}/lib"
          done
        '';
      };
    in rec {
      packages."x86_64-linux".default =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in pkgs.pkgsi686Linux.stdenv.mkDerivation (derivInfo pkgs pkgs.pkgsi686Linux);
      packages."i686-linux".default =
        let pkgs = import nixpkgs { system = "i686-linux"; };
        in pkgs.stdenv.mkDerivation (derivInfo pkgs pkgs);

      formatter.x86_64-linux =
        (import nixpkgs { system = "x86_64-linux"; }).nixfmt;
    };
}

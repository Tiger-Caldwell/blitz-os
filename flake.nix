{
  outputs = { self, nixpkgs }:
    let
      derivInfo = nativePkgs: pkgs: rec {
        name = "blitz";
        src = ./blitz-bin.tar.gz;
        sourceRoot = ".";
        buildInputs = [ pkgs.gcc-unwrapped.lib ];
        nativeBuildInputs = [ nativePkgs.makeWrapper ];
        installPhase = ''
          mkdir -p $out/bin
          cp kpl asm lddd blitz diskUtil dumpObj hexdump check endian toyfs $out/bin
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

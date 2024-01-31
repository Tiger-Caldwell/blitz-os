{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    blitz = pkgs.stdenv.mkDerivation rec {
        name = "blitz";
        src = pkgs.fetchFromGitHub {
            owner = "BlitzOSProject";
            repo = "BlitzOSProject.github.io";
            rev = "3c60e8e4ac2073ba94802712125b429b2b5ffc49";
            hash = "sha256-DJWV0vBdDGPBylapwbFjLZyybse+Nw8DSEpM07arbdU=";
        };
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            install -m755 -D ${src}/BlitzBin/Ubuntu64/* $out/bin
            rm $out/bin/blitztools.tar $out/bin/index.html
            runHook postInstall
        '';
    };
  in {
    devShells."${system}".default = pkgs.mkShell {
        buildInputs = [ blitz ];
    };
  };
}
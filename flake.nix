{
  description = "qperf";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.permittedInsecurePackages = [
                "openssl-1.1.1w"
            ];
          };
        in
        {
          packages.qperf = pkgs.stdenv.mkDerivation {
            name = "qperf";
            src = self;
            buildInputs= with pkgs; [
                cmake
                openssl_1_1
                perl
                libev
            ];
            dontUseCmakeConfigure=true; # build manually without nix magic
            buildPhase = ''
                cmake -DCMAKE_BUILD_TYPE=Release -S $TMP/source -B $TMP/source/build
                cmake --build $TMP/source/build --target qperf -- -j 10
                mkdir $out
                mkdir $out/bin
                mv $TMP/source/build/qperf $out/bin/
            '';
          };
          packages.default = self.packages.${system}.qperf;
        }
      );
}
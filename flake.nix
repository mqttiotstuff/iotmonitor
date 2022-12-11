{
  description = "Flake for building Iotmonitor";
  # inputs = [ zig git cmake leveldb pandoc ];
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/22.05.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
    zigpkgs.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, zigpkgs, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zig = zigpkgs.packages.${system}."0.10.0";
      in {
        packages.iotmonitor =
          # Notice the reference to nixpkgs here.
          pkgs.stdenv.mkDerivation {
            name = "iotmonitor";
            src = self;
            buildInputs = [
              zig
              pkgs.git
              pkgs.cmake
              pkgs.leveldb
              pkgs.pandoc
            ]; # pkgs.llvmPackages_14.llvm
            configurePhase = ''
              ls
              zig version
            '';

            buildPhase = ''
              make               
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp bin/iotmonitor $out/bin
            '';

          };

        defaultPackage = self.packages.${system}.iotmonitor;
      });

}

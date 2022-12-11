{
  description = "Flake for building Iotmonitor";
  # inputs = [ zig git cmake leveldb pandoc ];
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/22.05.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self,  zig, nixpkgs, flake-utils, }:

    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.iotmonitor =
          # Notice the reference to nixpkgs here.
          pkgs.stdenv.mkDerivation {
            name = "iotmonitor";
            src = self;
            buildInputs =
              [ pkgs.zig pkgs.git pkgs.cmake pkgs.leveldb pkgs.pandoc ];
            configurePhase = ''
              ls
              zig version
            '';

            buildPhase = ''
              make
              zig build -fstage1
            '';

            installPhase = ''
              mkdir -p $out/bin
              mv bin/iotmonitor $out/bin
            '';

          };

        defaultPackage = self.packages.${system}.iotmonitor;
      });

}

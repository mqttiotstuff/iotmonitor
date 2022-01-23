{
  description = "Flake for building Iotmonitor";
  # inputs = [ zig git cmake leveldb pandoc ];
  inputs = { 

      #  nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
      # To have zig 0.9, unstable one, .. 
nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/d9c13cf44ec1b6de95cb1ba83c296611d19a71ae.tar.gz";

 flake-utils.url = "github:numtide/flake-utils";


  };

  outputs = { self, nixpkgs, flake-utils }: 

    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
	packages.iotmonitor = 
        # Notice the reference to nixpkgs here.
        pkgs.stdenv.mkDerivation {
        name = "iotmonitor";
        src = self;
        buildInputs = [ pkgs.zig pkgs.git pkgs.cmake pkgs.leveldb pkgs.pandoc ];
        configurePhase = ''
          ls
          zig version
        '';

        buildPhase = ''
          make
          zig build
        '';

        installPhase = ''
          mkdir -p $out/bin
          mv bin/iotmonitor $out/bin
        '';

      };

      defaultPackage = self.packages.${system}.iotmonitor;
      }
    );
 
}

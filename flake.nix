{
  description = "Flake for building Iotmonitor";
  # inputs = [ zig git cmake leveldb pandoc ];
  inputs = { 

      #  nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
      # To have zig 0.9, unstable one, .. 
nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/d9c13cf44ec1b6de95cb1ba83c296611d19a71ae.tar.gz";


  };

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      stdenv.mkDerivation {
        name = "iotmonitor";
        src = self;
        buildInputs = [ zig git cmake leveldb pandoc ];
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

  };
}

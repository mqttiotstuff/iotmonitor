{
  description = "Flake for building Iotmonitor";
  # inputs = [ zig git cmake leveldb pandoc ];
  inputs = { 
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
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

{
  description = "Flake for building Iotmonitor";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };

    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        systems.follows = "systems";
      };
    };
  };

  outputs = { self, zig, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib legacyPackages;

      platforms = lib.attrNames zig.packages;

      buildablePlatforms =
        lib.filter
          (p: !(lib.systems.elaborate p).isDarwin)
          platforms;

      forAllPlatforms = f:
        lib.genAttrs platforms (system: f legacyPackages.${system});

      forBuildablePlatforms = f:
        lib.genAttrs buildablePlatforms (system: f legacyPackages.${system});

      mkIotmonitor = pkgs:
        pkgs.stdenv.mkDerivation {
          pname = "iotmonitor";
          version = "1.0.0";

          src = self;

          buildInputs = [
            pkgs.leveldb
          ];

          nativeBuildInputs = [
            pkgs.pandoc
            pkgs.zig
            pkgs.git
            pkgs.cmake
          ];

          configurePhase = ''
            runHook preConfigure
            ls
            zig version
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            make
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp bin/iotmonitor $out/bin/
            runHook postInstall
          '';
        };

    in {
      packages = forBuildablePlatforms (pkgs: {
        iotmonitor = mkIotmonitor pkgs;
        default = mkIotmonitor pkgs;
      });

      devShells = forAllPlatforms (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.leveldb
            pkgs.pandoc
            pkgs.zig
            pkgs.git
            pkgs.cmake
          ];
        };
      });
    };
}

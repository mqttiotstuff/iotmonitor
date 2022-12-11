
# Building iotmonitor

as iotmonitor rely on zig this may be complicated to get all the elements in proper version to work on

## Using nix to ease the job

#### Using Nix

Install Nix, [https://nixos.org/download.html](https://nixos.org/download.html)



then, using the following `shell.nix` file, 

```
{ nixpkgs ? <nixpkgs>, iotstuff ? import (fetchTarball
  "https://github.com/mqttiotstuff/nix-iotstuff-repo/archive/9b12720.tar.gz")
  { } }:

iotstuff.pkgs.mkShell rec { buildInputs = [ iotstuff.iotmonitor ]; }
```

run :

```
nix-shell shell.nix
```

or :  (with the shell.nix in the folder)

```
nix-shell
```

#### using nix flake 


build with flake :

     git clone --recursive https://github.com/mqttiotstuff/iotmonitor
     nix build "git+file://$(pwd)?submodules=1" 
        or nix build .?submodules=1


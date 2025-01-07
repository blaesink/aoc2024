{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    systems = [ "x86_64-linux" ];
    perSystem = func:
      nixpkgs.lib.genAttrs systems (system: func nixpkgs.legacyPackages.${system});

  in {
    devShells = perSystem (pkgs: {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [ zig zls ];
      };
    });
    packages = perSystem (pkgs: {
      default = pkgs.callPackage ./package.nix { inherit pkgs; };
    });
  };
}

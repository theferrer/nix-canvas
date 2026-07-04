{
  description = "canvas - a declarative language for composing NixOS / Darwin / Home Manager systems: machines, hardware, capabilities and a pure software resolver, with no built-in knowledge of concrete applications.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nix-darwin, ... }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      canvasLib = import ./lib { inherit lib; };
    in
    {
      lib = canvasLib;

      nixosModules.default = ./modules/nixos.nix;
      homeModules.default = ./modules/home.nix;
      darwinModules.default = ./modules/darwin.nix;

      checks = forAllSystems (
        pkgs:
        import ./tests {
          inherit
            pkgs
            lib
            canvasLib
            nix-darwin
            ;
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt);

      packages = forAllSystems (pkgs: {

        options-doc =
          (pkgs.nixosOptionsDoc {
            options =
              (lib.evalModules {
                modules = [ ./modules/options ];
              }).options.canvas;
          }).optionsCommonMark;
      });

      templates.default = {
        path = ./templates/default;
        description = "A working starter: one host declared as intent, resolved against a tiny inline palette.";
      };

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.nixfmt
            pkgs.nil
            pkgs.statix
            pkgs.deadnix
          ];
        };
      });
    };
}

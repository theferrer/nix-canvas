{
  description = "My machines, composed with canvas";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    canvas.url = "github:theferrer/nix-canvas";
    canvas.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    { nixpkgs, canvas, ... }:
    {
      nixosConfigurations.demo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          canvas.nixosModules.default
          ./palette.nix
          ./host.nix
        ];
      };
    };
}

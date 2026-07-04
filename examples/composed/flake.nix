{
  description = "A host composed from canvas + a palette (the three layers).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    canvas.url = "github:theferrer/nix-canvas";
    canvas.inputs.nixpkgs.follows = "nixpkgs";

    palette.url = "github:theferrer/nix-canvas?dir=examples/palette-full";
    palette.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      canvas,
      palette,
      ...
    }:
    {
      nixosConfigurations.demo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          canvas.nixosModules.default
          palette.nixosModules.default
          ./host.nix
          { nixpkgs.config.allowUnfree = true; }
        ];
      };
    };
}

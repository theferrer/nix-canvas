{
  description = "A complete example canvas palette: catalog, looks, home modules and NixOS glue.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = _: {
    homeModules.default = ./default.nix;
    darwinModules.default = ./default.nix;
    nixosModules.default = {
      imports = [
        ./default.nix
        ./nixos.nix
      ];
    };
  };
}

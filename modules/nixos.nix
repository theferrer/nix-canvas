{ config, lib, ... }:
{
  _class = "nixos";

  imports = [
    ./options
    ./resolver.nix
    ./variants.nix
    ./integrations.nix
  ];

  config = {
    environment.systemPackages = config.canvas.resolved.packages;
    system.nixos.tags = lib.mkIf (config.canvas.machine.label != null) [
      config.canvas.machine.label
    ];
  };
}

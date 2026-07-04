{ config, lib, ... }:
{
  _class = "darwin";

  imports = [
    ./options
    ./resolver.nix
    ./integrations.nix
  ];

  config = {
    environment.systemPackages = config.canvas.resolved.packages;

    system.primaryUser = lib.mkIf (config.canvas.machine.primaryUser != null) (
      lib.mkDefault config.canvas.machine.primaryUser
    );
  };
}

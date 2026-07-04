{ config, lib, ... }:
{
  _class = "homeManager";

  imports = [
    ./options
    ./resolver.nix
  ];

  config = {
    home.packages = config.canvas.resolved.packages;

    warnings = lib.optional (config.canvas.resolved.homeModules != [ ]) (
      "canvas: ${toString (lib.length config.canvas.resolved.homeModules)} resolved home module(s) "
      + "cannot be auto-applied in standalone Home Manager (imports cannot depend on config); "
      + "import the palette's modules directly and gate them on activity (canvasLib.isActive)"
    );
  };
}

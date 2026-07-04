{ lib, ... }:
{
  config.canvas.catalog.capabilities = lib.mapAttrs (_name: cap: {
    description = lib.mkDefault cap.description;
    requiresGraphical = lib.mkDefault cap.requiresGraphical;
  }) (import ../../lib/capabilities.nix);
}

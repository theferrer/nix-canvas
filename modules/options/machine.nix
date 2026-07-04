{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.canvas.machine = {
    primaryUser = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "alice";
      description = "Primary user of this machine (aligned with nix-darwin's system.primaryUser). Consumed by substrates and integrations; null for machines without one (headless/appliance). Required by integrations.home-manager.";
    };

    formFactor = mkOption {
      type = types.enum [
        "laptop"
        "desktop"
        "handheld"
      ];
      example = "laptop";
      description = "Physical form factor. A hardware fact (battery, lid, portability) - software intent belongs in `wants`. No default: a silently misclassified laptop is a footgun.";
    };

    graphical = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Force the graphical fact. For substrates where the session is not
        canvas-managed: standalone Home Manager on a machine whose desktop
        lives outside Nix, and Darwin (Aqua is never canvas-managed). On
        NixOS leave it null and let the resolver derive it from the
        required capabilities.
      '';
    };

    label = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "Hyprland";
      description = "Label of the main configuration (shown as a NixOS boot tag).";
    };
  };
}

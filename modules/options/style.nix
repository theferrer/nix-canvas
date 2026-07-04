{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.canvas.style = mkOption {
    type = types.submodule {
      freeformType = types.attrsOf types.raw;
      options = {
        name = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "synthppuccin";
          description = "Style/theme identifier. Defaulted by the look; override for 'this look, different theme'.";
        };
      };
    };
    default = { };
    description = "Resolved style. Freeform keys let palettes carry variants (dark/light, accent...).";
  };
}

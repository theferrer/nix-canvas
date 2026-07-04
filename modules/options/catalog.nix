{ lib, ... }:
let
  inherit (lib) mkOption types;
  canvasTypes = import ./types.nix { inherit lib; };
in
{
  options.canvas.catalog = {
    schemaVersion = mkOption {
      type = types.int;
      default = 1;
      description = "Catalog schema version a palette targets. Canvas asserts it supports it.";
    };

    capabilities = mkOption {
      type = types.attrsOf canvasTypes.capabilityType;
      default = { };
      example = {
        ocr = {
          description = "Extract text from screen regions.";
          requiresGraphical = true;
        };
      };
      description = ''
        The capability vocabulary. Canvas ships the base vocabulary (see
        lib/capabilities.nix); palettes extend it by defining additional keys.
        Every capability referenced anywhere (wants, use, needsCapabilities)
        must exist here.
      '';
    };

    software = mkOption {
      type = types.attrsOf canvasTypes.softwareType;
      default = { };
      description = "Software inventory (filled by a palette).";
    };

    wants = mkOption {
      type = types.attrsOf canvasTypes.wantType;
      default = { };
      example = {
        development = {
          capabilities = [ "editor" ];
          includes = [ "cli-core" ];
        };
      };
      description = "Wants: intent expressed as capabilities and software, composable via includes.";
    };

    looks = mkOption {
      type = types.attrsOf canvasTypes.lookType;
      default = { };
      description = "Opinionated looks: capability adjudications + style.";
    };
  };
}

{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.canvas = {
    wants = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "desktop"
        "development"
      ];
      description = "Wants (intents of use) this machine asks for. Defined by the palette catalog.";
    };

    look = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "my-hyprland";
      description = "Palette look: an opinionated bundle of capability adjudications and a style.";
    };

    use = mkOption {
      type = types.attrsOf (types.nullOr types.str);
      default = { };
      example = {
        terminal = "kitty";
        screen-locker = null;
      };
      description = ''
        Per-host capability adjudication. `use.<capability> = "app"` picks the
        app AND requires the capability; `use.<capability> = null` opts out of
        a capability a want would otherwise require. Host values override the
        look's adjudications.
      '';
    };

    extra = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "obsidian" ];
      description = "Extra catalog software (by name) on top of what wants/look resolve to.";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "steam" ];
      description = "Software (by name) removed from the resolved set. Excluded nodes neither appear nor conduct dependencies.";
    };
  };
}

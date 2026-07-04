{ config, lib, ... }:
let
  inherit (lib) mkOption types mapAttrs;
in
{
  options.canvas.variants = mkOption {
    type = types.attrsOf types.deferredModule;
    default = { };
    example = lib.literalExpression ''
      {
        i3 = { canvas.use.desktop = "i3"; };
      }
    '';
    description = "Boot-time variants: partial overrides of this configuration, one boot entry each. The attribute name is the variant label. Variants cannot nest.";
  };

  config.specialisation = mapAttrs (_name: module: {
    inheritParentConfig = true;
    configuration = {
      imports = [ module ];
      canvas.variants = lib.mkForce { };
    };
  }) config.canvas.variants;
}

{ lib, ... }:
{
  options.canvas.secrets = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    example = {
      "syncthing/key" = "/run/secrets/syncthing-key";
    };
    description = "Runtime paths satisfying the secret needs declared by the palette catalog (software.<name>.secrets).";
  };
}

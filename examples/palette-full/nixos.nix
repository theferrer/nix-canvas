{
  config,
  lib,
  canvasLib,
  ...
}:
{
  config = lib.mkIf (canvasLib.isActive config "hyprland") {
    programs.hyprland.enable = true;
  };
}

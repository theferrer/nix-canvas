{
  config,
  osConfig ? null,
  lib,
  ...
}:
let
  conf = if osConfig != null then osConfig else config;
  monitors = conf.canvas.hardware.monitors or [ ];
  rule =
    m:
    "monitor=${m.name},${
      if m.resolution == null then
        "preferred"
      else
        m.resolution + lib.optionalString (m.refreshRate != null) "@${toString m.refreshRate}"
    },${if m.position == null then "auto" else m.position},${
      if m.scale == null then "1" else builtins.toJSON m.scale
    }";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings.monitor = map rule monitors;
  };
}

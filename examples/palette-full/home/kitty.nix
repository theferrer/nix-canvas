{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  conf = if osConfig != null then osConfig else config;
  rcPassword = conf.canvas.secrets."kitty/rc-password" or null;
in
{
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.95";
      env = "CANVAS_STYLE=${toString (conf.canvas.style.name or "")}";
    }
    // lib.optionalAttrs (rcPassword != null) {
      allow_remote_control = "password";
      remote_control_password = "@${rcPassword}";
    };
  };
}

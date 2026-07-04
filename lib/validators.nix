{ lib }:
rec {
  softwareActive = conf: conf.canvas.resolved.software or { };

  isActive = conf: name: (softwareActive conf) ? ${name};

  isGraphical = conf: conf.canvas.resolved.graphical or false;

  isWayland = conf: (conf.canvas.resolved.sessionProtocol or null) == "wayland";

  isX11 = conf: (conf.canvas.resolved.sessionProtocol or null) == "x11";

  isFormFactor = conf: list: lib.elem (conf.canvas.machine.formFactor or null) list;

  mkIfActive =
    conf: name: cfg:
    lib.mkIf (isActive conf name) cfg;
}

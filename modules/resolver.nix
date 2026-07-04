{ config, lib, ... }:
let
  canvasLib = import ../lib { inherit lib; };
  inherit (canvasLib) resolve;
  cfg = config.canvas;

  result = resolve {
    inherit (cfg)
      wants
      look
      use
      catalog
      ;
    inherit (cfg) extra exclude secrets;
    graphical = cfg.machine.graphical;
  };
in
{
  config = {
    _module.args.canvasLib = canvasLib;

    canvas.resolved = {
      inherit (result)
        software
        names
        capabilityMap
        requiredCapabilities
        provenance
        graphical
        sessionProtocol
        packages
        homeModules
        secretsProvenance
        ;
    };

    canvas.style.name = lib.mkIf (result.style != null) (lib.mkOverride 1250 result.style);

    assertions = result.assertions ++ [
      {
        assertion = lib.length (lib.filter (g: g.primary) cfg.hardware.gpus) <= 1;
        message = "canvas: at most one GPU can be primary";
      }
      {
        assertion =
          cfg.hardware.gpuStrategy == null
          || (lib.length cfg.hardware.gpus >= 2 && lib.all (g: g.busId != null) cfg.hardware.gpus);
        message = "canvas: hardware.gpuStrategy relates two GPUs; it requires at least two entries in hardware.gpus, each with a busId";
      }
    ];
    inherit (result) warnings;
  };
}

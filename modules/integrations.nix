{
  config,
  options,
  lib,
  canvasLib,
  ...
}:
let
  cfg = config.canvas.integrations.home-manager;
  user = config.canvas.machine.primaryUser;

  hmAvailable = (options.home-manager or { }) ? users;
  resolvedHome = config.canvas.resolved.homeModules;
in
{
  options.canvas.integrations.home-manager = {
    enable = lib.mkEnableOption "wiring canvas.resolved.homeModules into the primary user's Home Manager configuration";
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || hmAvailable;
          message = "canvas: integrations.home-manager.enable requires the home-manager module to be imported";
        }
        {
          assertion = !cfg.enable || user != null;
          message = "canvas: integrations.home-manager.enable requires canvas.machine.primaryUser";
        }
      ];

      warnings = lib.optional (!cfg.enable && resolvedHome != [ ]) (
        "canvas: ${toString (lib.length resolvedHome)} resolved home module(s) are not applied because "
        + "canvas.integrations.home-manager is disabled; enable it (or set the entries' homeModule = null)"
      );
    }
    (lib.optionalAttrs hmAvailable (
      lib.mkIf cfg.enable {
        home-manager.users = lib.listToAttrs (
          lib.optional (user != null) {
            name = user;

            value.imports = resolvedHome ++ [ { _module.args.canvasLib = canvasLib; } ];
          }
        );
      }
    ))
  ];
}

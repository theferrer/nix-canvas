{ pkgs, lib }:
let
  eval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    system = pkgs.stdenv.hostPlatform.system;
    modules = [
      ../modules/nixos.nix
      ../examples/palette-full
      ../examples/palette-full/nixos.nix
      ../examples/composed/host.nix
      { nixpkgs.config.allowUnfree = true; }
    ];
  };
  cfg = eval.config;
  inherit (import ./support.nix { inherit lib; }) failedMessages;
in
{
  testComposedResolvesClean = {
    expr = failedMessages cfg;
    expected = [ ];
  };

  testComposedHostIntentLands = {
    expr = {
      terminal = cfg.canvas.resolved.capabilityMap.terminal;
      graphical = cfg.canvas.resolved.graphical;
      extra = lib.elem "btop" cfg.canvas.resolved.names;
    };
    expected = {
      terminal = "kitty";
      graphical = true;
      extra = true;
    };
  };

  testComposedOptionalSecretProvenance = {
    expr = cfg.canvas.resolved.secretsProvenance."kitty/rc-password";
    expected = [ "optional-for:kitty" ];
  };
}

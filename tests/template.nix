{ pkgs, lib }:
let
  eval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    system = pkgs.stdenv.hostPlatform.system;
    modules = [
      ../modules/nixos.nix
      ../templates/default/palette.nix
      ../templates/default/host.nix
    ];
  };
  cfg = eval.config;
  inherit (import ./support.nix { inherit lib; }) failedMessages;
in
{
  testTemplateAssertionsPass = {
    expr = failedMessages cfg;
    expected = [ ];
  };

  testTemplateResolvedEditor = {
    expr = cfg.canvas.resolved.capabilityMap.editor;
    expected = "helix";
  };

  testTemplateNames = {
    expr = cfg.canvas.resolved.names;
    expected = [
      "fish"
      "git"
      "helix"
      "ripgrep"
    ];
  };
}

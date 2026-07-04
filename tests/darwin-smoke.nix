{
  pkgs,
  lib,
  nix-darwin,
}:
let
  eval = nix-darwin.lib.darwinSystem {
    modules = [
      ../modules/darwin.nix
      ../examples/palette-full
      {
        nixpkgs.hostPlatform = pkgs.stdenv.hostPlatform.system;
        canvas = {
          machine.primaryUser = "tester";

          machine.graphical = true;
          wants = [ "development" ];
          look = "full-wayland";
          use.terminal = "kitty";
        };
        system.stateVersion = 6;
      }
    ];
  };
  cfg = eval.config;
  inherit (import ./support.nix { inherit lib; }) failedMessages;
  pkgNames = map (p: p.pname or p.name) cfg.environment.systemPackages;
in
{
  testDarwinAssertionsPass = {
    expr = failedMessages cfg;
    expected = [ ];
  };

  testDarwinResolvedEditor = {
    expr = cfg.canvas.resolved.capabilityMap.editor;
    expected = "neovim";
  };

  testDarwinResolvedPackagesInstalled = {
    expr = lib.all (n: lib.elem n pkgNames) [
      "neovim"
      "fish"
      "git"
      "ripgrep"
      "btop"
    ];
    expected = true;
  };

  testDarwinGraphicalDeclared = {
    expr = {
      graphical = cfg.canvas.resolved.graphical;
      terminal = cfg.canvas.resolved.capabilityMap.terminal;
    };
    expected = {
      graphical = true;
      terminal = "kitty";
    };
  };

  testDarwinPrimaryUserWired = {
    expr = cfg.system.primaryUser;
    expected = "tester";
  };

  testDarwinNoVariantsOption = {
    expr = eval.options.canvas ? variants;
    expected = false;
  };
}

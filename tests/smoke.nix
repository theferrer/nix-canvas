{ pkgs, lib }:
let
  eval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    system = pkgs.stdenv.hostPlatform.system;
    modules = [
      ../modules/nixos.nix
      ../examples/palette-full
      ../examples/palette-full/nixos.nix
      {
        canvas = {
          machine = {
            primaryUser = "tester";
            formFactor = "laptop";
            label = "Hyprland";
          };
          wants = [
            "desktop"
            "development"
          ];
          look = "full-wayland";
          variants.x11 = {
            canvas.use.desktop = "i3";
          };
        };
        users.users.tester.isNormalUser = true;
        boot.loader.grub.enable = false;
        fileSystems."/" = {
          device = "none";
          fsType = "tmpfs";
        };
        system.stateVersion = "25.05";
      }
    ];
  };

  cfg = eval.config;
  variant = cfg.specialisation.x11.configuration;

  inherit (import ./support.nix { inherit lib; }) failedMessages;
  pkgNames = map (p: p.pname or p.name) cfg.environment.systemPackages;
in
{
  testSmokeAssertionsPass = {
    expr = failedMessages cfg;
    expected = [ ];
  };

  testSmokeResolvedDesktop = {
    expr = cfg.canvas.resolved.capabilityMap.desktop;
    expected = "hyprland";
  };

  testSmokeSessionProtocol = {
    expr = cfg.canvas.resolved.sessionProtocol;
    expected = "wayland";
  };

  testSmokeGraphical = {
    expr = cfg.canvas.resolved.graphical;
    expected = true;
  };

  testSmokeUnmanagedPackageInstalled = {
    expr = lib.elem "ripgrep" pkgNames;
    expected = true;
  };

  testSmokeModuleCarryingPackageInstalled = {
    expr = lib.elem "kitty" pkgNames;
    expected = true;
  };

  testSmokeNixosPaletteModuleGatesOn = {
    expr = cfg.programs.hyprland.enable;
    expected = true;
  };

  testSmokeNixosPaletteModuleGatesOff = {
    expr = variant.programs.hyprland.enable;
    expected = false;
  };

  testSmokeBootTag = {
    expr = cfg.system.nixos.tags;
    expected = [ "Hyprland" ];
  };

  testSmokeVariantSwitchesDesktop = {
    expr = variant.canvas.resolved.capabilityMap.desktop;
    expected = "i3";
  };

  testSmokeVariantProtocol = {
    expr = variant.canvas.resolved.sessionProtocol;
    expected = "x11";
  };

  testSmokeVariantInheritsWants = {
    expr = lib.elem "git" variant.canvas.resolved.names;
    expected = true;
  };

  testSmokeVariantAssertionsPass = {
    expr = failedMessages variant;
    expected = [ ];
  };

  testSmokeVariantsDoNotNest = {
    expr = variant.canvas.variants;
    expected = { };
  };
}

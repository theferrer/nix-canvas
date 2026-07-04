{ lib }:
let
  inherit (lib) mkOption types;
in
rec {
  secretRequirementType = types.submodule {
    options = {
      required = mkOption {
        type = types.bool;
        default = false;
        description = "Whether resolution fails when the host does not provide this secret.";
      };
      description = mkOption {
        type = types.str;
        default = "";
        description = "What the secret is (format, purpose) - shown in the missing-secret error.";
      };
    };
  };

  softwareType = types.submodule {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "The package providing this software (null if purely module-driven).";
      };
      provides = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "terminal" ];
        description = "Capabilities this software implements.";
      };
      needs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "wl-clipboard" ];
        description = "Other software (by catalog name) this one depends on.";
      };
      needsCapabilities = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "notifications" ];
        description = "Capabilities this software depends on; satisfied by whatever app is adjudicated to them.";
      };
      conflicts = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "pulseaudio" ];
        description = "Software this one cannot coexist with. Declared by either side; detected, never auto-resolved.";
      };
      sessionProtocol = mkOption {
        type = types.nullOr (
          types.enum [
            "wayland"
            "x11"
          ]
        );
        default = null;
        description = "For desktop-capability software: the display protocol its session runs on.";
      };
      homeModule = mkOption {
        type = types.nullOr types.raw;
        default = null;
        description = "Optional Home Manager module for this software.";
      };
      secrets = mkOption {
        type = types.attrsOf secretRequirementType;
        default = { };
        example = {
          "syncthing/key" = {
            required = true;
            description = "device key PEM";
          };
        };
        description = "Abstract secret needs. The host provides runtime paths via canvas.secrets; required ones missing fail the build, optional ones simply gate features off.";
      };
      description = mkOption {
        type = types.str;
        default = "";
        description = "Human-readable description.";
      };
    };
  };

  capabilityType = types.submodule {
    options = {
      description = mkOption {
        type = types.str;
        default = "";
        description = "What this capability means.";
      };
      requiresGraphical = mkOption {
        type = types.bool;
        default = false;
        description = "Whether requiring this capability only makes sense on a graphical machine.";
      };
    };
  };

  wantType = types.submodule {
    options = {
      description = mkOption {
        type = types.str;
        default = "";
        description = "What this want is for.";
      };
      capabilities = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [
          "terminal"
          "editor"
        ];
        description = "Capabilities this want requires.";
      };
      software = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "git" ];
        description = "Explicit software this want pulls in.";
      };
      includes = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "cli-core" ];
        description = "Other wants this one composes. Wants are the only grouping mechanism.";
      };
    };
  };

  lookType = types.submodule {
    options = {
      use = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          terminal = "kitty";
          desktop = "hyprland";
        };
        description = "Capability -> app adjudications this look defaults.";
      };
      style = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "synthppuccin";
        description = "Style/theme identifier for this look.";
      };
    };
  };
}

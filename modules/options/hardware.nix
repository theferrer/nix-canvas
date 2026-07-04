{ lib, ... }:
let
  inherit (lib) mkOption types;

  gpuType = types.submodule {
    options = {
      vendor = mkOption {
        type = types.enum [
          "intel"
          "amd"
          "nvidia"
        ];
        description = "GPU vendor.";
      };
      busId = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "PCI:1:0:0";
        description = "PCI bus id, required when a gpuStrategy relates two GPUs (e.g. NVIDIA PRIME).";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this GPU drives the display.";
      };
    };
  };

  monitorType = types.submodule {
    freeformType = types.attrsOf types.raw;
    options = {
      name = mkOption {
        type = types.str;
        example = "eDP-1";
        description = "Output name.";
      };
      resolution = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "2560x1440";
        description = "Resolution, if pinned.";
      };
      refreshRate = mkOption {
        type = types.nullOr types.int;
        default = null;
        example = 144;
        description = "Refresh rate in Hz, if pinned.";
      };
      scale = mkOption {
        type = types.nullOr types.float;
        default = null;
        example = 1.25;
        description = "Output scale factor.";
      };
      position = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "0x0";
        description = "Position in the layout.";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this is the primary monitor.";
      };
    };
  };
in
{
  options.canvas.hardware = {
    cpu = mkOption {
      type = types.nullOr (
        types.enum [
          "intel"
          "amd"
        ]
      );
      default = null;
      description = "CPU vendor.";
    };

    gpus = mkOption {
      type = types.listOf gpuType;
      default = [ ];
      example = lib.literalExpression ''
        [
          { vendor = "intel"; primary = true; }
          { vendor = "nvidia"; busId = "PCI:1:0:0"; }
        ]
      '';
      description = "GPUs in this machine, as facts per device. The relationship between them is `gpuStrategy`.";
    };

    gpuStrategy = mkOption {
      type = types.nullOr (
        types.enum [
          "offload"
          "sync"
          "reverse-offload"
        ]
      );
      default = null;
      description = "Multi-GPU topology (e.g. NVIDIA PRIME). A relationship between two GPUs, not a property of one.";
    };

    monitors = mkOption {
      type = types.listOf monitorType;
      default = [ ];
      description = "Connected monitors. The typed keys are the contract shared by all palettes; freeform keys allow palette extensions.";
    };

    keyboard = {
      layout = mkOption {
        type = types.str;
        default = "us";
        description = "XKB keyboard layout.";
      };
      variant = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "colemak";
        description = "XKB layout variant.";
      };
      options = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "caps:escape" ];
        description = "XKB options.";
      };
    };

  };
}

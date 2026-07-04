{ lib, ... }:
let
  inherit (lib) mkOption types;
  canvasTypes = import ./types.nix { inherit lib; };

  ro =
    type: description:
    mkOption {
      inherit type description;
      readOnly = true;
    };
in
{
  options.canvas.resolved = {
    software = ro (types.attrsOf canvasTypes.softwareType) "Active software set (name -> definition).";
    names = ro (types.listOf types.str) "Sorted names of the active software.";
    capabilityMap = ro (types.attrsOf types.str) "Capability -> adjudicated app.";
    requiredCapabilities = ro (types.listOf types.str) "Capabilities required after wants, use and fixpoint.";
    provenance = ro (types.attrsOf (types.listOf types.str)) "Why each name is active: origins like want:desktop, use:terminal, need-of:toolchain, extra.";
    graphical = ro types.bool "Whether this machine resolves graphical (the 'desktop' capability is required).";
    sessionProtocol = ro (types.nullOr (
      types.enum [
        "wayland"
        "x11"
      ]
    )) "Display protocol of the adjudicated desktop, declared by its catalog entry.";
    packages = ro (types.listOf types.package) "Packages of every active software entry (a homeModule never suppresses the package; package = null delegates installation).";
    homeModules = ro (types.listOf types.raw) "Home Manager modules of active software.";
    secretsProvenance = ro (types.attrsOf (types.listOf types.str)) "Why each referenced secret matters: required-by:<software> / optional-for:<software>. The paths themselves stay in canvas.secrets.";
  };
}

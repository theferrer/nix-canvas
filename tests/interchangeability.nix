{ lib, canvasLib }:
let
  withCaps = c: c // { capabilities = canvasLib.spec.capabilities; };
  minimal = withCaps (import ../examples/palette-minimal/catalog.nix { });
  full = withCaps (import ../examples/palette-full/catalog.nix { });

  wants = [ "development" ];

  rMinimal = canvasLib.resolve {
    catalog = minimal;
    inherit wants;
    look = "minimal";
  };
  rFull = canvasLib.resolve {
    catalog = full;
    inherit wants;
    look = "full-wayland";
  };

  inherit (import ./support.nix { inherit lib; }) clean;
in
{
  testBothPalettesResolveClean = {
    expr = clean rMinimal && clean rFull;
    expected = true;
  };

  testSameCapabilitySurface = {
    expr = builtins.attrNames rMinimal.capabilityMap;
    expected = builtins.attrNames rFull.capabilityMap;
  };

  testDifferentApps = {
    expr = rMinimal.capabilityMap.editor != rFull.capabilityMap.editor;
    expected = true;
  };

  testSharedIntentSoftwarePresentInBoth = {
    expr = lib.elem "git" rMinimal.names && lib.elem "git" rFull.names;
    expected = true;
  };
}

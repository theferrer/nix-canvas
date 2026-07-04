{ lib }:
{
  looks,
  look,
  use,
}:
let
  lookDef = if look == null then { } else (looks.${look} or { });
  lookUse = lookDef.use or { };
  hostUse = lib.filterAttrs (_: v: v != null) use;
in
{
  inherit lookDef lookUse hostUse;
  knownLook = look == null || (looks ? ${look});
  optOuts = lib.attrNames (lib.filterAttrs (_: v: v == null) use);
  effectiveUse = lookUse // hostUse;
}

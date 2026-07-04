{ lib }:
let
  inherit (lib)
    unique
    concatMap
    elem
    concatStringsSep
    foldl'
    ;
in
{
  look,
  extra,
  hostUse,
  knownWants,
  wantSoftwareOf,
  resolvedCaps,
  depsOf,
  definedNames,
  names,
}:
let
  capOrigin = cap: if hostUse ? ${cap} then "use:${cap}" else "look:${toString look}:${cap}";
  provEntries =
    map (x: {
      name = x.app;
      origin = capOrigin x.cap;
    }) resolvedCaps
    ++ concatMap (
      w:
      map (n: {
        name = n;
        origin = "want:${w}";
      }) (wantSoftwareOf w)
    ) knownWants
    ++ map (n: {
      name = n;
      origin = "extra";
    }) extra
    ++ concatMap (
      n:
      map (d: {
        name = d;
        origin = "need-of:${n}";
      }) (depsOf n)
    ) definedNames;
  provenance = foldl' (
    acc: e:
    if elem e.name names then
      acc // { ${e.name} = unique ((acc.${e.name} or [ ]) ++ [ e.origin ]); }
    else
      acc
  ) { } provEntries;
in
{
  inherit provenance;
  whyIs = n: concatStringsSep ", " (provenance.${n} or [ "unknown origin" ]);
}

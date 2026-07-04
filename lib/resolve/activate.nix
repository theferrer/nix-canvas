{ lib }:
let
  inherit (lib)
    unique
    concatMap
    filter
    elem
    genAttrs
    listToAttrs
    attrNames
    ;
  closure = import ../closure.nix { inherit lib; };
in
{
  software,
  extra,
  exclude,
  knownWants,
  wantCaps,
  wantSoftwareOf,
  effectiveUse,
  hostUse,
  optOuts,
}:
let

  isExcluded = n: elem n exclude;
  depsOf = n: if isExcluded n then [ ] else filter (d: !(isExcluded d)) (software.${n}.needs or [ ]);

  appOf = cap: effectiveUse.${cap} or null;
  requiredFrom = caps: filter (c: !(elem c optOuts)) (unique caps);

  activeFromCaps =
    caps:
    let
      capApps = filter (a: a != null && !(isExcluded a)) (map appOf caps);
      wantSw = filter (n: !(isExcluded n)) (concatMap wantSoftwareOf knownWants);
      extraSw = filter (n: !(isExcluded n)) extra;
    in
    closure depsOf (unique (capApps ++ wantSw ++ extraSw));

  capFixpoint =
    caps:
    let
      activeNow = activeFromCaps caps;
      fromSoftware = concatMap (n: software.${n}.needsCapabilities or [ ]) (
        filter (n: software ? ${n}) activeNow
      );
      next = requiredFrom (caps ++ fromSoftware);
    in
    if next == caps then caps else capFixpoint next;

  requiredCapabilities = lib.sort (a: b: a < b) (
    capFixpoint (requiredFrom (wantCaps ++ attrNames hostUse))
  );

  names = lib.sort (a: b: a < b) (activeFromCaps requiredCapabilities);
  definedNames = filter (n: software ? ${n}) names;

  capabilityResolution = map (cap: {
    inherit cap;
    app = appOf cap;
  }) requiredCapabilities;

  adjudicatedCaps = filter (x: x.app != null) capabilityResolution;
  resolvedCaps = filter (x: !(isExcluded x.app)) adjudicatedCaps;
in
{
  inherit
    isExcluded
    depsOf
    requiredCapabilities
    names
    definedNames
    adjudicatedCaps
    resolvedCaps
    ;
  undefinedNames = filter (n: !(software ? ${n})) names;
  active = genAttrs definedNames (n: software.${n});
  missingCaps = filter (x: x.app == null) capabilityResolution;
  capabilityMap = listToAttrs (
    map (x: {
      name = x.cap;
      value = x.app;
    }) resolvedCaps
  );
}

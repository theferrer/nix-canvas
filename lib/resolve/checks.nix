{ lib }:
let
  inherit (lib)
    unique
    concatMap
    filter
    elem
    attrNames
    optional
    concatStringsSep
    ;
  listOr = names: fallback: if names == [ ] then fallback else concatStringsSep ", " names;
in
{
  capabilities,
  software,
  look,
  use,
  extra,
  exclude,
  knownLook,
  lookUse,
  lookNames,
  wantNames,
  unknownWants,
  wantCaps,
  knownWants,
  wantSoftwareOf,
  optOuts,
  isExcluded,
  definedNames,
  undefinedNames,
  requiredCapabilities,
  adjudicatedCaps,
  resolvedCaps,
  missingCaps,
  graphical,
  declaredGraphical,
  whyIs,
  missingRequired,
  deadSecrets,
}:
let

  knownCap = c: capabilities ? ${c};
  referencedCaps = unique (
    wantCaps
    ++ attrNames use
    ++ attrNames lookUse
    ++ concatMap (n: software.${n}.needsCapabilities or [ ]) definedNames
    ++ concatMap (n: software.${n}.provides or [ ]) definedNames
  );
  unknownCaps = filter (c: !(knownCap c)) referencedCaps;

  graphicalViolations = filter (
    c: knownCap c && (capabilities.${c}.requiresGraphical or false) && !graphical
  ) requiredCapabilities;

  selfConflicts = filter (n: elem n (software.${n}.conflicts or [ ])) definedNames;
  undefinedConflicts = concatMap (
    n:
    map (c: {
      needer = n;
      target = c;
    }) (filter (c: !(software ? ${c})) (software.${n}.conflicts or [ ]))
  ) definedNames;
  conflictPairs = unique (
    concatMap (
      n:
      map (c: {
        a = if n < c then n else c;
        b = if n < c then c else n;
      }) (filter (c: c != n && elem c definedNames) (software.${n}.conflicts or [ ]))
    ) definedNames
  );

  unknownExcludes = filter (n: !(software ? ${n})) exclude;
  extraExcluded = filter (n: elem n exclude) extra;
  wantExcluded = concatMap (
    w:
    map (n: {
      inherit w n;
    }) (filter (n: elem n exclude) (wantSoftwareOf w))
  ) knownWants;
  excludedDefaults = filter (x: isExcluded x.app) adjudicatedCaps;
  danglingNeeds = concatMap (
    n:
    map (d: {
      needer = n;
      dep = d;
    }) (filter isExcluded (software.${n}.needs or [ ]))
  ) definedNames;
  softwareNeededCaps = unique (concatMap (n: software.${n}.needsCapabilities or [ ]) definedNames);
  optedOutButNeeded = filter (c: elem c softwareNeededCaps) optOuts;
  deadOptOuts = filter (c: !(elem c wantCaps) && !(elem c softwareNeededCaps)) optOuts;
in
{
  assertions =
    optional (!knownLook) {
      assertion = false;
      message = "canvas: unknown look '${toString look}'; known looks: ${listOr lookNames "none defined by the palette"}";
    }
    ++ map (w: {
      assertion = false;
      message = "canvas: unknown want '${w}'; known wants: ${listOr wantNames "none defined by the palette"}";
    }) unknownWants
    ++ map (c: {
      assertion = false;
      message = "canvas: unknown capability '${c}'; known capabilities: ${listOr (attrNames capabilities) "none"}";
    }) unknownCaps
    ++ map (cap: {
      assertion = software ? ${lookUse.${cap}};
      message = "canvas: look '${toString look}' adjudicates undefined software '${lookUse.${cap}}' to capability '${cap}'";
    }) (attrNames lookUse)
    ++ map (x: {
      assertion = false;
      message = "canvas: capability '${x.cap}' is required but no app is adjudicated to it (set canvas.use.${x.cap} or pick a look that provides it)";
    }) missingCaps
    ++ map (x: {
      assertion = software ? ${x.app};
      message = "canvas: '${x.app}' (adjudicated to capability '${x.cap}') is not defined in the palette catalog";
    }) adjudicatedCaps
    ++ map (x: {
      assertion = !(software ? ${x.app}) || elem x.cap (software.${x.app}.provides or [ ]);
      message = "canvas: '${x.app}' is adjudicated to capability '${x.cap}' but does not declare provides = [ \"${x.cap}\" ]";
    }) resolvedCaps
    ++ map (n: {
      assertion = false;
      message = "canvas: software '${n}' is referenced (${whyIs n}) but is not defined in the palette catalog";
    }) undefinedNames
    ++ map (n: {
      assertion = false;
      message = "canvas: excluded software '${n}' is not defined in the palette catalog";
    }) unknownExcludes
    ++ map (x: {
      assertion = false;
      message = "canvas: '${x.app}' is adjudicated to required capability '${x.cap}' but is excluded; adjudicate a different app instead of excluding this one";
    }) excludedDefaults
    ++ map (n: {
      assertion = false;
      message = "canvas: software '${n}' declares a conflict with itself";
    }) selfConflicts
    ++ map (x: {
      assertion = false;
      message = "canvas: software '${x.needer}' declares a conflict with undefined software '${x.target}'";
    }) undefinedConflicts
    ++ map (p: {
      assertion = false;
      message = "canvas: active software '${p.a}' declares a conflict with active software '${p.b}'";
    }) conflictPairs
    ++ map (c: {
      assertion = false;
      message = "canvas: capability '${c}' requires a graphical session, but this machine resolves headless (${
        if declaredGraphical == false then
          "machine.graphical is declared false"
        else
          "no 'desktop' capability is required"
      })";
    }) graphicalViolations
    ++ map (r: {
      assertion = false;
      message = "canvas: active software '${r.n}' requires secret '${r.secret}'${
        lib.optionalString (r.description != "") " (${r.description})"
      }; declare canvas.secrets.\"${r.secret}\"";
    }) missingRequired;

  warnings =
    map (n: "canvas: '${n}' is listed in extra but also excluded; the exclusion wins") extraExcluded
    ++ map (
      x: "canvas: '${x.n}' (software of want '${x.w}') is excluded; the exclusion wins"
    ) wantExcluded
    ++ map (
      d:
      "canvas: '${d.dep}' was excluded, but active software '${d.needer}' declares needs = [ \"${d.dep}\" ]"
    ) danglingNeeds
    ++ map (
      c: "canvas: capability '${c}' is opted out (use.${c} = null) but active software still needs it"
    ) optedOutButNeeded
    ++ map (
      c: "canvas: use.${c} = null is a dead opt-out; nothing requires capability '${c}'"
    ) deadOptOuts
    ++ map (s: "canvas: secret '${s}' is provided but no active software references it") deadSecrets;
}

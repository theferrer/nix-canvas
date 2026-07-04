{ lib }:
let
  validateContract = import ./contract.nix { inherit lib; };
  checkSecrets = import ./secrets.nix { inherit lib; };
  expandWants = import ./wants.nix { inherit lib; };
  adjudicate = import ./adjudicate.nix { inherit lib; };
  activate = import ./activate.nix { inherit lib; };
  trace = import ./provenance.nix { inherit lib; };
  derive = import ./facts.nix { inherit lib; };
  check = import ./checks.nix { inherit lib; };
  emit = import ./outputs.nix { inherit lib; };
in
{
  catalog,
  wants ? [ ],
  look ? null,
  use ? { },
  extra ? [ ],
  exclude ? [ ],

  secrets ? { },

  graphical ? null,
}:
let
  software = catalog.software or { };
  capabilities = catalog.capabilities or { };

  contract = validateContract {
    inherit catalog;
    args = {
      inherit
        wants
        look
        use
        extra
        exclude
        secrets
        graphical
        ;
    };
  };

  w = expandWants {
    wantDefs = catalog.wants or { };
    inherit wants;
  };

  adj = adjudicate {
    looks = catalog.looks or { };
    inherit look use;
  };

  act = activate {
    inherit software extra exclude;
    inherit (w) knownWants wantCaps wantSoftwareOf;
    inherit (adj) effectiveUse hostUse optOuts;
  };

  prov = trace {
    inherit look extra;
    inherit (adj) hostUse;
    inherit (w) knownWants wantSoftwareOf;
    inherit (act)
      resolvedCaps
      depsOf
      definedNames
      names
      ;
  };

  facts = derive {
    inherit software;
    inherit (adj) lookDef;
    inherit (act) requiredCapabilities capabilityMap;
    declaredGraphical = graphical;
  };

  checks = check {
    inherit
      capabilities
      software
      look
      use
      extra
      exclude
      ;
    inherit (adj) knownLook optOuts lookUse;
    inherit (w)
      unknownWants
      wantCaps
      knownWants
      wantSoftwareOf
      ;
    inherit (act)
      requiredCapabilities
      adjudicatedCaps
      resolvedCaps
      missingCaps
      definedNames
      undefinedNames
      isExcluded
      ;
    inherit (facts) graphical;
    inherit (prov) whyIs;
    inherit (sec) missingRequired deadSecrets;
    declaredGraphical = graphical;
    lookNames = lib.attrNames (catalog.looks or { });
    wantNames = lib.attrNames (catalog.wants or { });
  };

  sec = checkSecrets {
    inherit software;
    inherit (act) definedNames;
    providedSecrets = secrets;
  };

  out = emit {
    inherit software;
    inherit (act) definedNames;
  };
in

if contract.assertions != [ ] then
  {
    software = { };
    names = [ ];
    capabilityMap = { };
    requiredCapabilities = [ ];
    provenance = { };
    graphical = false;
    sessionProtocol = null;
    style = null;
    secretsProvenance = { };
    packages = [ ];
    homeModules = [ ];
    inherit (contract) assertions;
    warnings = [ ];
  }
else
  {
    software = act.active;
    inherit (act) names capabilityMap requiredCapabilities;
    inherit (prov) provenance;
    inherit (facts) graphical sessionProtocol style;
    secretsProvenance = sec.secretsMap;
    inherit (out) packages homeModules;
    inherit (checks) assertions warnings;
  }

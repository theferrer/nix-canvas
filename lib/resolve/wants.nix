{ lib }:
let
  closure = import ../closure.nix { inherit lib; };
in
{ wantDefs, wants }:
let
  includesOf = w: if wantDefs ? ${w} then (wantDefs.${w}.includes or [ ]) else [ ];
  allWants = closure includesOf wants;
  knownWants = lib.filter (w: wantDefs ? ${w}) allWants;
in
{
  inherit knownWants;
  unknownWants = lib.filter (w: !(wantDefs ? ${w})) allWants;
  wantCaps = lib.unique (lib.concatMap (w: wantDefs.${w}.capabilities or [ ]) knownWants);
  wantSoftwareOf = w: wantDefs.${w}.software or [ ];
}

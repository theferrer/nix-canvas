{ lib }:
{ software, definedNames }:
let
  pkgOf = n: software.${n}.package or null;
  homeOf = n: software.${n}.homeModule or null;
in
{
  packages = map pkgOf (lib.filter (n: pkgOf n != null) definedNames);
  homeModules = map homeOf (lib.filter (n: homeOf n != null) definedNames);
}

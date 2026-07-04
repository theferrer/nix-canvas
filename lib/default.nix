{ lib }:
let
  validators = import ./validators.nix { inherit lib; };
in
{
  version = "0.2.0";

  spec.capabilities = import ./capabilities.nix;

  inherit validators;
  closure = import ./closure.nix { inherit lib; };
  resolve = import ./resolve { inherit lib; };

  inherit (validators)
    isActive
    softwareActive
    isGraphical
    isWayland
    isX11
    isFormFactor
    mkIfActive
    ;
}

{ pkgs, ... }:
{
  canvas.catalog = import ./catalog.nix { inherit pkgs; };
}

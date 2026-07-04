{ pkgs }:
let
  src = ../.;
in
{
  statix = pkgs.runCommand "canvas-statix" { } ''
    ${pkgs.statix}/bin/statix check ${src}
    echo ok > $out
  '';

  deadnix = pkgs.runCommand "canvas-deadnix" { } ''
    ${pkgs.deadnix}/bin/deadnix --fail ${src}
    echo ok > $out
  '';

  formatting = pkgs.runCommand "canvas-formatting" { } ''
    ${pkgs.nixfmt}/bin/nixfmt --check $(find ${src} -name '*.nix')
    echo ok > $out
  '';

  core-purity = pkgs.runCommand "canvas-core-purity" { } ''
    if grep -rnE 'mkIf|mkDefault|mkForce|mkOption|types\.|config\.|options\.' \
        ${src}/lib/resolve ${src}/lib/closure.nix ${src}/lib/capabilities.nix \
        | grep -vE ':[0-9]+: *#'; then
      echo "core purity violated: the resolver core must not reference the module system" >&2
      exit 1
    fi
    echo ok > $out
  '';
}

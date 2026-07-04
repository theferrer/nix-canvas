{
  pkgs,
  lib,
  canvasLib,
  nix-darwin,
}:
let
  runSuite =
    name: tests:
    let
      failures = lib.runTests tests;
      render =
        f:
        "FAIL ${f.name}\n  expected: ${builtins.toJSON f.expected}\n  got:      ${builtins.toJSON f.result}";
    in
    if failures == [ ] then
      pkgs.runCommand "canvas-tests-${name}" { } "echo ok > $out"
    else
      pkgs.runCommand "canvas-tests-${name}" { text = lib.concatMapStringsSep "\n" render failures; } ''
        echo "$text"
        exit 1
      '';
in
{
  lib-loads = runSuite "lib-loads" {
    testVersion = {
      expr = canvasLib.version;
      expected = "0.2.0";
    };
  };
  resolve = runSuite "resolve" (import ./resolve.nix { inherit lib canvasLib; });
  lib-surface = runSuite "lib-surface" (import ./lib.nix { inherit canvasLib; });
  modules = runSuite "modules" (import ./modules.nix { inherit lib; });
  interchangeability = runSuite "interchangeability" (
    import ./interchangeability.nix { inherit lib canvasLib; }
  );
}
// import ./lints.nix { inherit pkgs; }
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {

  smoke = runSuite "smoke" (import ./smoke.nix { inherit pkgs lib; });
  template = runSuite "template" (import ./template.nix { inherit pkgs lib; });
  composed = runSuite "composed" (import ./composed.nix { inherit pkgs lib; });
}
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {

  darwin-smoke = runSuite "darwin-smoke" (import ./darwin-smoke.nix { inherit pkgs lib nix-darwin; });
}

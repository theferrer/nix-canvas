{ lib }:
rec {
  failed = r: builtins.filter (a: !a.assertion) r.assertions;

  failedMessages = r: map (a: a.message) (failed r);

  clean = r: failed r == [ ];

  anyMsg = r: sub: lib.any (m: lib.hasInfix sub m) (failedMessages r);

  anyWarn = r: sub: lib.any (m: lib.hasInfix sub m) r.warnings;

  assertionsStub =
    { lib, ... }:
    {
      options.assertions = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
      };
      options.warnings = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
}

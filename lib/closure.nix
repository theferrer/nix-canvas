{ lib }:
depsOf: seed:
let
  step =
    acc:
    let
      next = lib.unique (acc ++ lib.concatMap depsOf acc);
    in
    if next == acc then acc else step next;
in
step (lib.unique seed)

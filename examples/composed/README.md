# Composed example

A host built from the three layers:

- **canvas** — the framework (`nixosModules.default`).
- **palette** — the vocabulary and opinion (here `examples/palette-full`,
  consumed as a flake input).
- **host** — `host.nix`: what this machine is and what it wants.

`flake.nix` wires them; `host.nix` is the only file you write per machine.
It declares intent (`wants`, `look`, `use`, `extra`) and provides one
optional secret path (`canvas.secrets."kitty/rc-password"`), which the
palette's kitty module reads if present.

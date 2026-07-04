# Examples

- **`palette-full/`** — a complete reference palette as a flake: catalog
  (`catalog.nix`), registration (`default.nix`), home modules
  (`home/`, consuming `canvas.hardware.monitors`, the style and a secret)
  and NixOS glue (`nixos.nix`). Copy this shape for a real palette.
- **`palette-minimal/`** — a second, smaller palette. Together with
  `palette-full` it backs the interchangeability test.
- **`composed/`** — a host flake consuming canvas + `palette-full`: the
  three layers (framework, palette, host) wired end to end.

The template (`nix flake init -t github:theferrer/nix-canvas`) is the same
composition inlined into one flake, for starting from scratch.

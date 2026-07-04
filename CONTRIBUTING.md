# Contributing

Three admission criteria keep the project small; most rejected PRs cite one:

1. An option exists only if a consumer branches on it. The resolver or a
   portable palette must read it. This is why there is no `machine.timezone`.
2. Canvas knows no concrete applications. No app names in `modules/` or
   `lib/` outside option examples; app-specific config belongs in a palette.
   CI greps for this.
3. The resolver core stays pure. `lib/resolve/`, `lib/closure.nix` and
   `lib/capabilities.nix` are data to data and reference no module-system
   constructs. Adapter logic lives in `modules/` or `lib/validators.nix`.
   The `core-purity` check enforces it.

Extending the capability vocabulary: base names in `lib/capabilities.nix` are
a compatibility surface. An addition needs a real capability (an abstract
need at least two apps could provide), a kebab-case name and a
`requiresGraphical` flag. A palette can also extend the vocabulary locally.

## Workflow

```bash
nix develop        # statix, deadnix, nixfmt, nil
nix flake check
nix fmt
```

Every behavioral change needs a test: `tests/resolve.nix` (resolver
semantics), `tests/modules.nix` (option contract), `tests/lib.nix` (lib
surface), `tests/smoke.nix` / `tests/darwin-smoke.nix` / `tests/template.nix`
(real NixOS / nix-darwin / template), `tests/interchangeability.nix`
(palette-swap). Shared helpers are in `tests/support.nix`, lints in
`tests/lints.nix`. The catalog schema is declared twice —
`lib/resolve/schema.nix` (pure) and `modules/options/types.nix` (typed) — and
`testSchemaMatchesTypes` fails if they drift; a schema change bumps
`supportedSchema`.

Releases: tag `vX.Y.Z` must equal `lib.version` in `lib/default.nix`, with a
CHANGELOG entry.

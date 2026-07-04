# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions
follow [SemVer](https://semver.org/).

## [0.2.0] - 2026-07-03

Initial public release.

- Typed intent language for hosts: `machine`, `hardware`, `wants`, `look`,
  `use`, `extra`, `exclude`, `secrets`, `variants`.
- Pure resolver (`lib.resolve`) turning intent plus palette catalog into
  `canvas.resolved.*`: active software, capability→app map, derived facts
  (`graphical`, `sessionProtocol`, `style`) and provenance for every name.
- Hexagonal layout enforced by CI: the resolver core is data to data (the
  `core-purity` check), with NixOS / nix-darwin / Home Manager entry modules
  as adapters.
- Input-contract validation: unknown catalog fields, wrong field shapes,
  unsupported schema versions, unknown `exclude` names and incoherent looks
  are errors with messages. A test keeps the pure schema and the typed
  options in sync field for field.
- Delivery is never inferred: every active entry's package installs
  (`homeModule` is config on top; `package = null` delegates), and unconsumed
  home modules warn instead of dropping config silently.
- Capability vocabulary as a typed spec (`catalog.capabilities`, base set in
  `lib/capabilities.nix`, exported as `lib.spec.capabilities`).
- `use.<capability> = null` opt-out with dead-opt-out warnings; opaque
  `exclude`; `needsCapabilities`; `conflicts` detection;
  `catalog.schemaVersion`.
- Boot-time `variants` as NixOS specialisations (`attrsOf deferredModule`);
  absent on Darwin.
- The canvas lib reaches every module as the `canvasLib` argument, so palette
  glue gates without flake-input plumbing.
- Secrets contract: catalog entries declare abstract secret needs
  (required/optional), hosts supply runtime paths via `canvas.secrets`, the
  resolver validates the match for active software, and
  `resolved.secretsProvenance` records why. Names and paths only.
- Home Manager integration (`integrations.home-manager`) injecting resolved
  home modules into `machine.primaryUser`, plus a standalone HM module.
- Example palettes (`examples/`) with real home modules and NixOS glue; a
  starter template; and a test suite (resolver units, option contract, real
  NixOS and nix-darwin smoke, template eval, interchangeability) plus statix,
  deadnix, formatting and core-purity checks.

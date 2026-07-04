# Design decisions

Why things are the way they are, one entry each.

## The metaphor

canvas (structure), palette (vocabulary and opinion), look (appearance).
One naming family across repos, options and docs.

## Pure core, module adapters

The resolver core (`lib/resolve/`, `lib/closure.nix`, `lib/capabilities.nix`)
is data to data: no `mkIf`, no `config`, no option types. Around it:
`modules/resolver.nix` (module-system adapter, sole writer of
`canvas.resolved.*`), `modules/{nixos,darwin,home}.nix` (substrate adapters),
`lib/validators.nix` (palette-author toolkit; reads evaluated configs, so
adapter-side), and palettes (catalog adapters). The `core-purity` flake
check greps the core for module-system constructs and fails on any hit, so a
nixpkgs or nix-darwin change can only break an adapter or a boundary test,
not the core.

## MIT license

The Nix ecosystem is MIT by convention; a framework meant to be extended by
strangers should not make vendoring a legal question.

## The grammar is closed over the catalog

`extra` accepts only catalog names, and undefined references are hard errors.
That is what makes `canvas.resolved` the complete answer to "what did intent
resolve to". Escape hatch: plain `environment.systemPackages` still works
alongside.

## `use` implies requirement; `null` opts out

`use.wallpaper = "swww"` means the host wants a wallpaper, so it also
requires the capability. `use.screen-locker = null` drops one capability
from a want without dropping the want. A dead opt-out (nothing requires it)
warns rather than errors, so a host can keep it while switching looks.

## `exclude` is opaque

An excluded node neither appears nor conducts `needs` edges, so excluding a
metapackage removes its subtree. Excluding the app adjudicated to a required
capability is an assertion, not a silent `capabilityMap` lie; the fix is
adjudicating a different app. Excluding something another active entry
`needs` is a warning, since it can be intentional.

## Looks are `{ use, style }` only

A look once carried wants and groups, which made "where did this software
come from?" ambiguous. Now wants are intent (host) and a look is opinion
(palette): if a look needs software, it adjudicates a capability. Enforced by
the schema.

## Wants are the only grouping mechanism

`groups` were a want without capabilities, so they were removed. Wants
compose via `includes`; `cli-core` is just a want a host can also request
directly.

## The desktop is a capability

There is no `environment.desktop` option. `use.desktop = "hyprland"` runs
through the same adjudication, closure and provenance as any capability, and
`sessionProtocol` on the catalog entry is where Wayland/X11 knowledge lives.
`resolved.graphical` is derived from whether `desktop` is required, with one
exception: where the session is not canvas-managed (standalone Home Manager
on an out-of-Nix desktop, and Darwin's Aqua), `machine.graphical = true`
declares it.

## The core validates its own input

`lib.resolve` asserts the shape of the catalog and the host arguments: an
unknown or wrong-shaped field, a malformed entry, a non-list `wants`, or an
unsupported `schemaVersion` produces a message, not a raw interpreter error.
On a contract failure the resolution short-circuits to an empty result
carrying only the errors, so later phases never touch malformed data. Field
names and shapes live in `lib/resolve/schema.nix`; a test compares them to
the typed options in `modules/options/types.nix` field for field. One
exception: `package` is `any` on the pure path (mock catalogs use
placeholders) and `types.package` on the typed path. Unknown names in `extra`
and `exclude` are hard errors, and the selected look is validated eagerly.

## No `nixosModule` channel

Home Manager takes modules from `config` (its `imports` is an option), so
`resolved.homeModules` is injectable. NixOS `imports` is structural and
cannot depend on `config`, so a `resolved.nixosModules` output would be
unconsumable. Instead a palette imports its NixOS modules unconditionally and
gates each on activity (`examples/palette-full/nixos.nix` is the reference).
The resolver passes the canvas lib to every module as the `canvasLib`
argument. Module structure cannot depend on module args, so at whole-config
position use `lib.mkIf (canvasLib.isActive config "app")`; `mkIfActive` works
under a static key. Never gate a `canvas.*` intent option on
`canvas.resolved.*` — that is the resolver reading its own output
(infinite recursion).

## A `homeModule` never suppresses the package

Every active entry's package installs; a home module is configuration on top.
A palette that wants the module to own installation sets `package = null`.
An earlier rule inferred "managed" from a module's presence, which silently
uninstalled software wherever the home-manager integration was off. Delivery
is never inferred: unconsumed home modules (integration off, or standalone
Home Manager) produce a warning pointing at the mkIfActive pattern.

## No `machine.hostname`

Networking identity is plain NixOS config (`networking.hostName`). A palette
branching per-hostname would be an anti-pattern (host deviations belong in
`use`), so the admission test fails. It once existed as a required option
with no consumer.

## Secrets are a contract, not a mechanism

`software.<name>.secrets` declares abstract needs (required or optional, with
a description); `canvas.secrets.<name>` supplies runtime paths. The resolver
checks the match for active software only: a missing required secret fails
the build with a message; a missing optional one does nothing (the palette
module gates the feature off); a provided secret no active software
references warns. `resolved.secretsProvenance` records why each secret is
needed.

Consumption reads paths from intent, not from `resolved.*`; secrets are
host-declared facts like hardware:

```nix
# NixOS-side glue                      # injected home module
config.canvas.secrets."x/key"          osConfig.canvas.secrets."x/key" or null
# host provider (dotfiles)
canvas.secrets."x/key" = config.sops.secrets."x/key".path;
```

Values are runtime path strings (sops-nix's /run/secrets/..., agenix, etc.),
never material and never Nix path literals (a path literal would copy the
secret into the world-readable store). Canvas sees names and paths; the
encryption mechanism stays in the host, which is what lets a host switch from
sops-nix to something else without the palette changing.

## `machine.role` was split

The old enum mixed form factor (laptop/desktop), intent (server) and
platform (wsl/vm). `formFactor` stayed (palettes branch on it via
`isFormFactor`); server-ness is wants plus no desktop; `virtualisation` was
cut when nothing consumed it.

## GPU strategy is a relationship

PRIME offload/sync is a relationship between two GPUs, not a property of one.
Hence `hardware.gpus` (per-device facts: vendor, busId, primary) plus
`hardware.gpuStrategy` (the topology), asserted coherent: a strategy needs
two devices with busIds.

## Hardware facts are for palettes

`canvas.hardware.*` (gpus, monitors, keyboard, cpu) is the substrate-neutral
fact sheet a portable palette branches on; the example hyprland home module
turns `monitors` into monitor rules. Facts NixOS already models one-to-one
with no palette value-add (bluetooth, sound) were removed to avoid a mirror
option nothing translates. A hardware fact exists only if a palette
plausibly renders it into app config.

## Variants are deferred modules

A variant is a `types.deferredModule` merged over the host inside a NixOS
specialisation, so `mkForce`, `null` and list semantics behave normally. (An
earlier hand-rolled force/flatten/null-strip made setting anything to null
inside a variant impossible.) Variants do not nest: NixOS specialisations do
not nest, and canvas forces the child's `variants` empty. NixOS-only: darwin
has no specialisation, so the option is absent there.

## primaryUser, not sharedModules

`sharedModules` would apply the configuration to every user, which is
multi-user semantics done by accident; that is a v1 non-goal. Only active
software's home modules are injected, so palette home modules need no `mkIf`
gating. `machine.primaryUser` is nullable (a headless appliance has none) and
required where consumed: the home-manager integration asserts it. The name
follows nix-darwin's `system.primaryUser`. Multi-user, when designed, is
`machine.users.<name>` with `primaryUser` as sugar.

## Composition laws

1. Palettes merge by the module system. Two palettes defining the same want
   concatenate their lists; a palette overrides one field of another's entry
   with `mkForce`/`mkDefault`. This is why catalog injection is options-based
   rather than a function argument.
2. The catalog may depend on host facts (`config.canvas.machine`,
   `config.canvas.hardware`) but never on resolver outputs
   (`config.canvas.resolved.*`) — that is infinite recursion.
3. The look sits below the module system, both halves. Adjudications: a
   host-side `use.terminal = lib.mkDefault "foot"` beats the look, because
   look `use` merges outside the module system, below all definitions.
   Injecting look values as ordinary `canvas.use` definitions would lose the
   distinction between a host adjudication (`use:terminal`) and a look one
   (`look:name:terminal`) that provenance depends on. Style: the resolver
   writes the look's `style.name` at `mkOverride 1250`, so any `mkDefault` or
   normal definition beats it too. The trade-off is that priorities cannot
   interleave across the boundary.
4. Variants use ordinary merge semantics. A variant overriding a value the
   host set directly (including `use.<cap> = null` against a host-set
   adjudication) needs `mkForce`. Opt-outs against look adjudications work at
   any priority (law 3).
5. One canvas revision per evaluation. Module exports are path-keyed, so
   importing the same canvas twice deduplicates; two different revisions in
   one eval fail at option declaration. Pin with `follows`.

## Out of scope

Timezone, locale, disks, networking: plain NixOS config next to canvas. They
do not affect resolution and no palette consumes them. Secret material and
its encryption are also out of scope; canvas models only the names-and-paths
contract above. The test for any new option: does the resolver or a portable
palette branch on it?

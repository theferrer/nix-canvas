# canvas starter

Three files, the three layers:

- `flake.nix` wires canvas and the palette into a host.
- `palette.nix` is the palette: the software catalog, wants and looks.
- `host.nix` is the host: what this machine is and what it wants.

```bash
nix flake check
nixos-rebuild build --flake .#demo
```

Why is something installed:

```bash
nix eval .#nixosConfigurations.demo.config.canvas.resolved.provenance
```

## Deviate from the look

In `host.nix`, under `canvas`:

- `use.editor = "nvim";` picks a different app for a capability.
- `use.shell = null;` opts out of a capability the want would require.
- `extra = [ "btop" ];` adds catalog software by name.

## Grow up

`palette.nix` is inline to keep this one flake. When it grows, move it to
its own repo and consume it as a flake input:

```nix
inputs.palette.url = "github:you/your-palette";
inputs.palette.inputs.canvas.follows = "canvas";
# modules = [ canvas.nixosModules.default palette.nixosModules.default ./host.nix ];
```

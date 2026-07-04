{ lib }:
let
  inherit (import ./support.nix { inherit lib; })
    assertionsStub
    failedMessages
    anyMsg
    anyWarn
    ;

  palette = {
    canvas.catalog = import ../examples/palette-full/catalog.nix { };
  };

  baseHost = {
    canvas.machine.primaryUser = "tester";
  };

  eval =
    modules:
    lib.evalModules {
      modules = [
        assertionsStub
        ../modules/options
        ../modules/resolver.nix
        palette
        baseHost
      ]
      ++ modules;
    };

  desktopHost = eval [
    {
      canvas.wants = [
        "desktop"
        "development"
      ];
      canvas.look = "full-wayland";
    }
  ];
in
{
  testModuleResolvesDesktop = {
    expr = desktopHost.config.canvas.resolved.capabilityMap.desktop;
    expected = "hyprland";
  };

  testModuleAssertionsPass = {
    expr = failedMessages desktopHost.config;
    expected = [ ];
  };

  testVocabularyPresent = {
    expr = desktopHost.config.canvas.catalog.capabilities ? screen-locker;
    expected = true;
  };

  testStyleFromLook = {
    expr = desktopHost.config.canvas.style.name;
    expected = "example-dark";
  };

  testStyleHostOverrideWins = {
    expr =
      (eval [
        {
          canvas = {
            wants = [ "development" ];
            look = "full-wayland";
            style.name = "custom";
          };
        }
      ]).config.canvas.style.name;
    expected = "custom";
  };

  testSchemaMatchesTypes =
    let
      canvasTypes = import ../modules/options/types.nix { inherit lib; };
      schema = import ../lib/resolve/schema.nix;
      fieldsOf =
        t: lib.sort (a: b: a < b) (lib.filter (n: n != "_module") (lib.attrNames (t.getSubOptions [ ])));
      keysOf = s: lib.sort (a: b: a < b) (lib.attrNames s);
    in
    {
      expr = {
        software = fieldsOf canvasTypes.softwareType;
        capability = fieldsOf canvasTypes.capabilityType;
        want = fieldsOf canvasTypes.wantType;
        look = fieldsOf canvasTypes.lookType;
        secretRequirement = fieldsOf canvasTypes.secretRequirementType;
      };
      expected = {
        software = keysOf schema.software;
        capability = keysOf schema.capability;
        want = keysOf schema.want;
        look = keysOf schema.look;
        secretRequirement = keysOf schema.secretRequirement;
      };
    };

  testRequiredSecretAssertsModule = {
    expr =
      anyMsg
        (eval [
          {
            canvas = {
              wants = [ "cli-core" ];
              catalog.software.git.secrets."git/signing-key" = {
                required = true;
              };
            };
          }
        ]).config
        "requires secret 'git/signing-key'";
    expected = true;
  };

  testProvidedSecretResolvesModule =
    let
      cfg =
        (eval [
          {
            canvas = {
              wants = [ "cli-core" ];
              catalog.software.git.secrets."git/signing-key" = {
                required = true;
              };
              secrets."git/signing-key" = "/run/secrets/git-signing-key";
            };
          }
        ]).config;
    in
    {
      expr = {
        failures = failedMessages cfg;
        map = cfg.canvas.resolved.secretsProvenance;
      };
      expected = {
        failures = [ ];
        map."git/signing-key" = [ "required-by:git" ];
      };
    };

  testGraphicalDeclaredModule =
    let
      cfg =
        (eval [
          {
            canvas = {
              machine.graphical = true;
              use.terminal = "kitty";
            };
          }
        ]).config;
    in
    {
      expr = {
        graphical = cfg.canvas.resolved.graphical;
        failures = failedMessages cfg;
      };
      expected = {
        graphical = true;
        failures = [ ];
      };
    };

  testUnconsumedHomeModulesWarn = {
    expr =
      anyWarn
        (eval [
          ../modules/integrations.nix
          {
            canvas = {
              wants = [ "cli-core" ];
              catalog.software.git.homeModule = {
                _testMarker = "git-home";
              };
            };
          }
        ]).config
        "not applied";
    expected = true;
  };

  testCanvasLibModuleArg =
    let
      cfg =
        (eval [
          (
            { canvasLib, ... }:
            {
              canvas.style.canvasVersion = canvasLib.version;
            }
          )
        ]).config;
    in
    {
      expr = cfg.canvas.style.canvasVersion;
      expected = "0.2.0";
    };

  testExampleHomeModuleRendersMonitors =
    let
      rendered = import ../examples/palette-full/home/hyprland.nix {
        inherit lib;
        config = { };
        osConfig.canvas.hardware.monitors = [
          {
            name = "eDP-1";
            resolution = "2560x1440";
            refreshRate = 144;
            scale = 1.25;
            position = "0x0";
          }
        ];
      };
    in
    {
      expr = rendered.wayland.windowManager.hyprland.settings.monitor;
      expected = [ "monitor=eDP-1,2560x1440@144,0x0,1.25" ];
    };

  testResolvedIsReadOnly = {
    expr =
      (builtins.tryEval (eval [ { canvas.resolved.names = [ ]; } ]).config.canvas.resolved.names).success;
    expected = false;
  };

  testSchemaVersionMismatchAsserts = {
    expr = anyMsg (eval [ { canvas.catalog.schemaVersion = lib.mkForce 2; } ]).config "schemaVersion";
    expected = true;
  };

  testGpuStrategyRequiresBusIds = {
    expr =
      anyMsg
        (eval [
          {
            canvas.hardware = {
              gpus = [ { vendor = "intel"; } ];
              gpuStrategy = "offload";
            };
          }
        ]).config
        "gpuStrategy";
    expected = true;
  };

  testAtMostOnePrimaryGpu = {
    expr =
      anyMsg
        (eval [
          {
            canvas.hardware.gpus = [
              {
                vendor = "intel";
                primary = true;
              }
              {
                vendor = "nvidia";
                primary = true;
              }
            ];
          }
        ]).config
        "at most one GPU";
    expected = true;
  };

  testHomeManagerIntegrationRequiresModule = {
    expr =
      anyMsg
        (eval [
          ../modules/integrations.nix
          { canvas.integrations.home-manager.enable = true; }
        ]).config
        "requires the home-manager module";
    expected = true;
  };

  testHomeManagerIntegrationWiresHomeModules =
    let
      marker = {
        _testMarker = "git-home";
      };
      hmStub =
        { lib, ... }:
        {
          options.home-manager.users = lib.mkOption {
            type = lib.types.attrsOf lib.types.raw;
            default = { };
          };
        };
      cfg =
        (eval [
          ../modules/integrations.nix
          hmStub
          {
            canvas = {
              wants = [ "cli-core" ];
              catalog.software.git.homeModule = marker;
              integrations.home-manager.enable = true;
            };
          }
        ]).config;
    in
    {
      expr = {

        markerInjected = lib.elem marker cfg.home-manager.users.tester.imports;
        importCount = builtins.length cfg.home-manager.users.tester.imports;
        resolvedHomeModules = cfg.canvas.resolved.homeModules;
        failures = failedMessages cfg;
      };
      expected = {
        markerInjected = true;
        importCount = 2;
        resolvedHomeModules = [ marker ];
        failures = [ ];
      };
    };

  testHomeManagerIntegrationRequiresPrimaryUser = {
    expr =
      anyMsg
        (eval [
          ../modules/integrations.nix
          {
            canvas.machine.primaryUser = lib.mkForce null;
            canvas.integrations.home-manager.enable = true;
          }
        ]).config
        "requires canvas.machine.primaryUser";
    expected = true;
  };

  testStandaloneHomeResolves =
    let
      hmStub =
        { lib, ... }:
        {
          options.home.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
        };
      hmEval = lib.evalModules {
        modules = [
          assertionsStub
          hmStub
          ../modules/home.nix
          palette
          baseHost
          {
            canvas = {
              wants = [ "development" ];
              look = "full-wayland";
            };
          }
        ];
      };
    in
    {
      expr = {
        editor = hmEval.config.canvas.resolved.capabilityMap.editor;
        failures = failedMessages hmEval.config;
      };
      expected = {
        editor = "neovim";
        failures = [ ];
      };
    };
}

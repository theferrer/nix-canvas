{ lib, canvasLib }:
let
  inherit (canvasLib) resolve;

  catalog = {
    schemaVersion = 1;
    capabilities = {
      terminal = {
        description = "";
        requiresGraphical = true;
      };
      editor = {
        description = "";
        requiresGraphical = false;
      };
      shell = {
        description = "";
        requiresGraphical = false;
      };
      desktop = {
        description = "";
        requiresGraphical = true;
      };
      notifications = {
        description = "";
        requiresGraphical = true;
      };
      wallpaper = {
        description = "";
        requiresGraphical = true;
      };
    };
    software = {
      kitty = {
        provides = [ "terminal" ];
      };
      emacs = {
        provides = [ "editor" ];
      };
      nvim = {
        provides = [ "editor" ];
      };
      fish = {
        provides = [ "shell" ];
      };
      hyprland = {
        provides = [ "desktop" ];
        sessionProtocol = "wayland";
      };
      i3 = {
        provides = [ "desktop" ];
        sessionProtocol = "x11";
      };
      mako = {
        provides = [ "notifications" ];
      };
      swww = {
        provides = [ "wallpaper" ];
      };
      grim = {
        needsCapabilities = [ "wallpaper" ];
      };
      git = {
        package = "git-pkg";
        homeModule = {
          _marker = "git-hm";
        };
      };
      curl = { };
      toolchain = {
        needs = [
          "git"
          "curl"
        ];
      };
      meta = {
        needs = [ "toolchain" ];
      };
      cyc-a = {
        needs = [ "cyc-b" ];
      };
      cyc-b = {
        needs = [ "cyc-a" ];
      };
      pipewire = {
        conflicts = [ "pulseaudio" ];
      };
      pulseaudio = {
        conflicts = [ "pipewire" ];
      };
      vault = {
        secrets."vault/token" = {
          required = true;
          description = "API token";
        };
      };
      journal = {
        secrets."journal/key" = { };
      };
      narcissus = {
        conflicts = [ "narcissus" ];
      };
      ghost-hater = {
        conflicts = [ "ghost" ];
      };
    };
    wants = {
      cli = {
        software = [ "git" ];
      };
      development = {
        capabilities = [
          "editor"
          "shell"
        ];
        includes = [ "cli" ];
        software = [ "toolchain" ];
      };
      desktop = {
        capabilities = [
          "desktop"
          "terminal"
          "notifications"
        ];
      };
    };
    looks = {
      wayland = {
        use = {
          desktop = "hyprland";
          terminal = "kitty";
          editor = "nvim";
          shell = "fish";
          notifications = "mako";
          wallpaper = "swww";
        };
        style = "dark";
      };
    };
  };

  run = args: resolve ({ inherit catalog; } // args);
  inherit (import ./support.nix { inherit lib; })
    clean
    failedMessages
    anyMsg
    anyWarn
    ;
in
{

  testWantSoftware = {
    expr = (run { wants = [ "cli" ]; }).names;
    expected = [ "git" ];
  };

  testWantIncludesCompose = {
    expr =
      (run {
        wants = [ "development" ];
        look = "wayland";
      }).names;
    expected = [
      "curl"
      "fish"
      "git"
      "nvim"
      "toolchain"
    ];
  };

  testCapabilityMap = {
    expr =
      (run {
        wants = [ "development" ];
        look = "wayland";
      }).capabilityMap;
    expected = {
      editor = "nvim";
      shell = "fish";
    };
  };

  testCleanResolutionHasNoFailures = {
    expr = clean (run {
      wants = [ "development" ];
      look = "wayland";
    });
    expected = true;
  };

  testHostUseOverridesLook = {
    expr =
      (run {
        wants = [ "development" ];
        look = "wayland";
        use.editor = "emacs";
      }).capabilityMap.editor;
    expected = "emacs";
  };

  testUseImpliesRequire = {
    expr =
      (run {
        wants = [ "cli" ];
        use.editor = "emacs";
      }).capabilityMap;
    expected = {
      editor = "emacs";
    };
  };

  testOptOut =
    let
      r = run {
        wants = [ "desktop" ];
        look = "wayland";
        use.notifications = null;
      };
    in
    {
      expr = clean r && !(lib.elem "mako" r.names) && !(lib.elem "notifications" r.requiredCapabilities);
      expected = true;
    };

  testDeadOptOutWarns = {
    expr = anyWarn (run {
      wants = [ "cli" ];
      use.wallpaper = null;
    }) "dead opt-out";
    expected = true;
  };

  testMissingAdjudicationAsserts = {
    expr = anyMsg (run { wants = [ "desktop" ]; }) "no app is adjudicated";
    expected = true;
  };

  testDoesNotProvideAsserts = {
    expr = anyMsg (run {
      wants = [ "cli" ];
      use.editor = "git";
    }) "does not declare provides";
    expected = true;
  };

  testUnknownWantAsserts = {
    expr = anyMsg (run { wants = [ "nope" ]; }) "unknown want";
    expected = true;
  };

  testUnknownLookAsserts = {
    expr = anyMsg (run { look = "nope"; }) "unknown look";
    expected = true;
  };

  testUnknownCapabilityAsserts = {
    expr = anyMsg (run { use.termnal = "kitty"; }) "unknown capability 'termnal'";
    expected = true;
  };

  testUndefinedSoftwareAsserts = {
    expr = anyMsg (run { extra = [ "ghost" ]; }) "not defined in the palette catalog";
    expected = true;
  };

  testRequiresGraphicalOnHeadlessAsserts = {
    expr = anyMsg (run {
      wants = [ "cli" ];
      use.wallpaper = "swww";
    }) "requires a graphical session";
    expected = true;
  };

  testMalformedEntryAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        software = catalog.software // {
          rogue = "just-a-string";
        };
      };
    }) "software 'rogue' must be an attribute set";
    expected = true;
  };

  testWrongFieldShapeAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        software = catalog.software // {
          bad.needs = "git";
        };
      };
    }) "software 'bad' field 'needs' must be a list of strings";
    expected = true;
  };

  testSchemaVersionMismatchAssertsPure = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        schemaVersion = 999;
      };
    }) "schemaVersion 999";
    expected = true;
  };

  testUnknownCatalogFieldAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        softwares = { };
      };
    }) "catalog declares unknown field 'softwares'";
    expected = true;
  };

  testUnknownSoftwareFieldAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        software = catalog.software // {
          rogue.nixosModule = { };
        };
      };
    }) "software 'rogue' declares unknown field 'nixosModule'";
    expected = true;
  };

  testUnknownWantFieldAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        wants = catalog.wants // {
          cli = catalog.wants.cli // {
            groups = [ ];
          };
        };
      };
    }) "want 'cli' declares unknown field 'groups'";
    expected = true;
  };

  testUnknownLookFieldAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        looks.wayland = catalog.looks.wayland // {
          wants = [ ];
        };
      };
    }) "look 'wayland' declares unknown field 'wants'";
    expected = true;
  };

  testExcludeRemoves = {
    expr =
      (run {
        wants = [ "development" ];
        look = "wayland";
        exclude = [ "toolchain" ];
      }).names;
    expected = [
      "fish"
      "git"
      "nvim"
    ];
  };

  testExcludeIsOpaque =
    let
      r = run {
        extra = [ "meta" ];
        exclude = [ "toolchain" ];
      };
    in
    {
      expr = r.names == [ "meta" ] && anyWarn r "was excluded";
      expected = true;
    };

  testExcludedAdjudicatedAppAsserts = {
    expr = anyMsg (run {
      wants = [ "desktop" ];
      look = "wayland";
      exclude = [ "kitty" ];
    }) "adjudicate a different app";
    expected = true;
  };

  testCapabilityMapOmitsExcluded = {
    expr =
      (run {
        wants = [ "desktop" ];
        look = "wayland";
        exclude = [ "kitty" ];
      }).capabilityMap ? terminal;
    expected = false;
  };

  testUnknownExcludeAsserts = {
    expr = anyMsg (run { exclude = [ "gti" ]; }) "excluded software 'gti' is not defined";
    expected = true;
  };

  testExtraAndExcludedWarns = {
    expr = anyWarn (run {
      extra = [ "git" ];
      exclude = [ "git" ];
    }) "the exclusion wins";
    expected = true;
  };

  testWantSoftwareExcludedWarns = {
    expr = anyWarn (run {
      wants = [ "cli" ];
      exclude = [ "git" ];
    }) "software of want 'cli'";
    expected = true;
  };

  testDeclaredHeadlessMessage = {
    expr = anyMsg (run {
      graphical = false;
      wants = [ "cli" ];
      use.wallpaper = "swww";
    }) "machine.graphical is declared false";
    expected = true;
  };

  testCycleTerminates = {
    expr = (run { extra = [ "cyc-a" ]; }).names;
    expected = [
      "cyc-a"
      "cyc-b"
    ];
  };

  testNeedsCapabilitiesPullsProvider =
    let
      base = run {
        wants = [ "desktop" ];
        look = "wayland";
      };
      withGrim = run {
        wants = [ "desktop" ];
        look = "wayland";
        extra = [ "grim" ];
      };
    in
    {
      expr =
        !(lib.elem "swww" base.names)
        && lib.elem "swww" withGrim.names
        && withGrim.capabilityMap.wallpaper == "swww";
      expected = true;
    };

  testOptedOutButNeededWarns = {
    expr = anyWarn (run {
      wants = [ "desktop" ];
      look = "wayland";
      extra = [ "grim" ];
      use.wallpaper = null;
    }) "still needs it";
    expected = true;
  };

  testConflictsAssert = {
    expr = anyMsg (run {
      extra = [
        "pipewire"
        "pulseaudio"
      ];
    }) "conflict";
    expected = true;
  };

  testConflictReportedOnce = {
    expr = builtins.length (
      builtins.filter (m: lib.hasInfix "declares a conflict with active" m) (
        failedMessages (run {
          extra = [
            "pipewire"
            "pulseaudio"
          ];
        })
      )
    );
    expected = 1;
  };

  testSelfConflictAsserts = {
    expr = anyMsg (run { extra = [ "narcissus" ]; }) "conflict with itself";
    expected = true;
  };

  testConflictWithUndefinedAsserts = {
    expr = anyMsg (run { extra = [ "ghost-hater" ]; }) "conflict with undefined software 'ghost'";
    expected = true;
  };

  testLookAdjudicatesUndefinedAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        looks.wayland = catalog.looks.wayland // {
          use = catalog.looks.wayland.use // {
            editor = "no-such-app";
          };
        };
      };
      wants = [ "cli" ];
      look = "wayland";
    }) "adjudicates undefined software 'no-such-app'";
    expected = true;
  };

  testLookUnknownCapabilityAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        looks.wayland = catalog.looks.wayland // {
          use = catalog.looks.wayland.use // {
            ghostcap = "kitty";
          };
        };
      };
      wants = [ "cli" ];
      look = "wayland";
    }) "unknown capability 'ghostcap'";
    expected = true;
  };

  testUnknownLookListsKnown = {
    expr = anyMsg (run { look = "nope"; }) "known looks: wayland";
    expected = true;
  };

  testGraphicalTrue = {
    expr =
      (run {
        wants = [ "desktop" ];
        look = "wayland";
      }).graphical;
    expected = true;
  };

  testGraphicalFalse = {
    expr = (run { wants = [ "development" ]; }).graphical;
    expected = false;
  };

  testGraphicalDeclared =
    let
      r = run {
        graphical = true;
        wants = [ "cli" ];
        use.wallpaper = "swww";
      };
    in
    {
      expr = clean r && r.graphical;
      expected = true;
    };

  testRequiredCapabilitiesSorted = {
    expr =
      (run {
        wants = [
          "desktop"
          "development"
        ];
        look = "wayland";
      }).requiredCapabilities;
    expected = [
      "desktop"
      "editor"
      "notifications"
      "shell"
      "terminal"
    ];
  };

  testSessionProtocolWayland = {
    expr =
      (run {
        wants = [ "desktop" ];
        look = "wayland";
      }).sessionProtocol;
    expected = "wayland";
  };

  testSessionProtocolX11 = {
    expr =
      (run {
        wants = [ "desktop" ];
        look = "wayland";
        use.desktop = "i3";
      }).sessionProtocol;
    expected = "x11";
  };

  testStyleFromLook = {
    expr =
      (run {
        wants = [ "development" ];
        look = "wayland";
      }).style;
    expected = "dark";
  };

  testProvenanceWant = {
    expr = lib.elem "want:cli" ((run { wants = [ "cli" ]; }).provenance.git or [ ]);
    expected = true;
  };

  testProvenanceNeed = {
    expr = lib.elem "need-of:toolchain" (
      (run {
        wants = [ "development" ];
        look = "wayland";
      }).provenance.curl or [ ]
    );
    expected = true;
  };

  testProvenanceHostUse = {
    expr = lib.elem "use:editor" (
      (run {
        wants = [ "cli" ];
        use.editor = "emacs";
      }).provenance.emacs or [ ]
    );
    expected = true;
  };

  testProvenanceLook = {
    expr = lib.elem "look:wayland:editor" (
      (run {
        wants = [ "development" ];
        look = "wayland";
      }).provenance.nvim or [ ]
    );
    expected = true;
  };

  testProvenanceExtra = {
    expr = lib.elem "extra" ((run { extra = [ "curl" ]; }).provenance.curl or [ ]);
    expected = true;
  };

  testMissingRequiredSecretAsserts = {
    expr = anyMsg (run { extra = [ "vault" ]; }) "requires secret 'vault/token' (API token)";
    expected = true;
  };

  testProvidedRequiredSecretClean = {
    expr = clean (run {
      extra = [ "vault" ];
      secrets."vault/token" = "/run/secrets/vault-token";
    });
    expected = true;
  };

  testOptionalSecretMissingClean = {
    expr = clean (run {
      extra = [ "journal" ];
    });
    expected = true;
  };

  testInactiveSoftwareSecretsIgnored = {
    expr = clean (run {
      wants = [ "cli" ];
    });
    expected = true;
  };

  testDeadSecretWarns = {
    expr = anyWarn (run {
      wants = [ "cli" ];
      secrets.ghost = "/run/secrets/ghost";
    }) "no active software references it";
    expected = true;
  };

  testSecretsMap = {
    expr =
      (run {
        extra = [
          "vault"
          "journal"
        ];
        secrets."vault/token" = "/run/secrets/vault-token";
      }).secretsProvenance;
    expected = {
      "vault/token" = [ "required-by:vault" ];
      "journal/key" = [ "optional-for:journal" ];
    };
  };

  testActiveMalformedShapeGated = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        software = catalog.software // {
          bad.needs = "git";
        };
      };
      extra = [ "bad" ];
    }) "software 'bad' field 'needs' must be a list of strings";
    expected = true;
  };

  testActiveMalformedSecretsGated = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        software = catalog.software // {
          bad.secrets = [ "oops" ];
        };
      };
      extra = [ "bad" ];
    }) "software 'bad' field 'secrets' must be an attribute set";
    expected = true;
  };

  testSessionProtocolEnumPure = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        software = catalog.software // {
          weirdwm.sessionProtocol = "mir";
        };
      };
    }) "field 'sessionProtocol' must be null, \"wayland\" or \"x11\"";
    expected = true;
  };

  testHostArgShapeAsserts = {
    expr = anyMsg (run {
      graphical = "yes";
    }) "resolve argument 'graphical' must be null or a boolean";
    expected = true;
  };

  testHostArgSecretsShapeAsserts = {
    expr = anyMsg (run {
      secrets = [ "vault/token" ];
    }) "resolve argument 'secrets' must be an attribute set of strings";
    expected = true;
  };

  testUnknownSecretRequirementFieldAsserts = {
    expr = anyMsg (resolve {
      catalog = catalog // {
        software = catalog.software // {
          shady.secrets."s".mandatory = true;
        };
      };
    }) "secret requirement of software 'shady' 's' declares unknown field 'mandatory'";
    expected = true;
  };

  testHomeModulesCollected = {
    expr = (run { wants = [ "cli" ]; }).homeModules;
    expected = [ { _marker = "git-hm"; } ];
  };

  testPackageInstallsAlongsideHomeModule = {
    expr = (run { wants = [ "cli" ]; }).packages;
    expected = [ "git-pkg" ];
  };
}

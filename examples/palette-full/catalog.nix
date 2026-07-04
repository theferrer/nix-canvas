{
  pkgs ? null,
}:
let
  pkg = name: if pkgs == null then null else pkgs.${name};
in
{
  schemaVersion = 1;

  software = {
    hyprland = {
      package = pkg "hyprland";
      provides = [ "desktop" ];
      sessionProtocol = "wayland";
      homeModule = ./home/hyprland.nix;
    };
    i3 = {
      package = pkg "i3";
      provides = [ "desktop" ];
      sessionProtocol = "x11";
    };
    kitty = {
      package = pkg "kitty";
      provides = [ "terminal" ];
      homeModule = ./home/kitty.nix;
      secrets."kitty/rc-password".required = false;
    };
    neovim = {
      package = pkg "neovim";
      provides = [ "editor" ];
    };
    fish = {
      package = pkg "fish";
      provides = [ "shell" ];
    };
    firefox = {
      package = pkg "firefox";
      provides = [ "browser" ];
    };
    fuzzel = {
      package = pkg "fuzzel";
      provides = [ "launcher" ];
    };
    mako = {
      package = pkg "mako";
      provides = [ "notifications" ];
    };
    waybar = {
      package = pkg "waybar";
      provides = [ "bar" ];
    };
    grim = {
      package = pkg "grim";
      provides = [ "screenshot" ];

      needsCapabilities = [ "notifications" ];
    };
    swww = {
      package = pkg "swww";
      provides = [ "wallpaper" ];
    };
    git = {
      package = pkg "git";
    };
    ripgrep = {
      package = pkg "ripgrep";
    };
    btop = {
      package = pkg "btop";
    };
  };

  wants = {
    cli-core = {
      description = "Baseline CLI toolbox.";
      software = [
        "git"
        "ripgrep"
        "btop"
      ];
    };
    development = {
      description = "Write and version code.";
      capabilities = [
        "editor"
        "shell"
      ];
      includes = [ "cli-core" ];
    };
    desktop = {
      description = "Daily-driver graphical session.";
      capabilities = [
        "desktop"
        "terminal"
        "launcher"
        "notifications"
        "bar"
        "browser"
      ];
      includes = [ "cli-core" ];
    };
  };

  looks = {
    full-wayland = {
      use = {
        desktop = "hyprland";
        terminal = "kitty";
        editor = "neovim";
        shell = "fish";
        launcher = "fuzzel";
        notifications = "mako";
        bar = "waybar";
        browser = "firefox";
      };
      style = "example-dark";
    };
    full-x11 = {
      use = {
        desktop = "i3";
        terminal = "kitty";
        editor = "neovim";
        shell = "fish";
        launcher = "fuzzel";
        notifications = "mako";
        bar = "waybar";
        browser = "firefox";
      };
      style = "example-light";
    };
  };
}

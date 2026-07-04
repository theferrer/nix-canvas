{
  canvas = {
    machine = {
      primaryUser = "alice";
      formFactor = "laptop";
    };

    wants = [
      "desktop"
      "development"
    ];
    look = "full-wayland";

    use.terminal = "kitty";
    extra = [ "btop" ];

    secrets."kitty/rc-password" = "/run/secrets/kitty-rc";
  };

  users.users.alice.isNormalUser = true;
  boot.loader.systemd-boot.enable = true;
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  system.stateVersion = "26.05";
}

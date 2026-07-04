{
  canvas = {
    machine = {
      primaryUser = "me";
      formFactor = "laptop";
    };
    wants = [ "development" ];
    look = "starter";
  };

  users.users.me = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

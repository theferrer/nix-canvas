{ pkgs, ... }:
{
  canvas.catalog = {
    software = {
      helix = {
        package = pkgs.helix;
        provides = [ "editor" ];
      };
      nvim = {
        package = pkgs.neovim;
        provides = [ "editor" ];
      };
      fish = {
        package = pkgs.fish;
        provides = [ "shell" ];
      };
      git.package = pkgs.git;
      ripgrep.package = pkgs.ripgrep;
      btop.package = pkgs.btop;
    };

    wants = {
      cli-core.software = [
        "git"
        "ripgrep"
      ];
      development = {
        capabilities = [
          "editor"
          "shell"
        ];
        includes = [ "cli-core" ];
      };
    };

    looks.starter = {
      use = {
        editor = "helix";
        shell = "fish";
      };
    };
  };
}

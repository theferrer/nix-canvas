{
  pkgs ? null,
}:
let
  pkg = name: if pkgs == null then null else pkgs.${name};
in
{
  schemaVersion = 1;

  software = {
    foot = {
      package = pkg "foot";
      provides = [ "terminal" ];
    };
    helix = {
      package = pkg "helix";
      provides = [ "editor" ];
    };
    fish = {
      package = pkg "fish";
      provides = [ "shell" ];
    };
    git = {
      package = pkg "git";
    };
  };

  wants = {
    development = {
      description = "Write and version code.";
      capabilities = [
        "editor"
        "shell"
      ];
      software = [ "git" ];
    };
  };

  looks = {
    minimal = {
      use = {
        editor = "helix";
        shell = "fish";
        terminal = "foot";
      };
    };
  };
}

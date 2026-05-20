{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true; # *.nix
  programs.shfmt.enable = true; # shell scripts
  programs.taplo.enable = true; # *.toml

  settings.global.excludes = [
    "*.lock"
    ".sops.yaml"
    "secrets/*"
  ];
}

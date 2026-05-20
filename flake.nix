{
  description = "ir flakies";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Nvf
    nvf.url = "github:notashelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    # JetBrains plugins
    nix-jetbrains-plugins.url = "github:nix-community/nix-jetbrains-plugins";
    nix-jetbrains-plugins.inputs.nixpkgs.follows = "nixpkgs";

    # Formatter
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Pre-commit hooks
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # Prebuilt nix-index database (for `comma` + `nix-locate`)
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      nvf,
      treefmt-nix,
      sops-nix,
      git-hooks,
      nix-index-database,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

      preCommitCheck = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          treefmt = {
            enable = true;
            package = treefmtEval.config.build.wrapper;
          };
          deadnix.enable = true; # find unused nix bindings
          statix.enable = true; # nix antipatterns
          # Avoid accidentally committing huge blobs (binaries, dumps).
          check-added-large-files.enable = true;
          # Block accidental plaintext secrets in commits.
          ripsecrets.enable = true;
          detect-private-keys.enable = true;
        };
      };
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#irnixos'
      nixosConfigurations = {
        irnixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            nvf.nixosModules.default
            sops-nix.nixosModules.sops
            ./nixos/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
          ];
        };
      };

      # home-manager configuration entrypoint
      # Available through 'home-manager --flake .#ir@irnixos'
      homeConfigurations = {
        "ir@irnixos" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            inherit inputs system;
          }; # Pass flake inputs to our config
          # > Our main home-manager configuration file <
          modules = [
            ./home-manager/home.nix
            nix-index-database.homeModules.nix-index
          ];
        };
      };

      # 'nix fmt'
      formatter.${system} = treefmtEval.config.build.wrapper;

      # 'nix flake check'
      checks.${system} = {
        formatting = treefmtEval.config.build.check self;
        pre-commit = preCommitCheck;
      };

      # 'nix develop' — repo-local tools (sops, age, formatters, pre-commit)
      devShells.${system}.default = pkgs.mkShell {
        inherit (preCommitCheck) shellHook;
        packages =
          (preCommitCheck.enabledPackages or [ ])
          ++ (with pkgs; [
            sops
            age
            ssh-to-age
            nixfmt
            treefmtEval.config.build.wrapper
            nh
          ]);
      };
    };
}

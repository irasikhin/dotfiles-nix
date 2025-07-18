{
  description = "NixOS Configuration";

  inputs = {
    # Using unstable for fresher packages, especially for development
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";

    # The magic for Neovim plugins
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    # Create a pkgs instance with our overlays
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        # Add the neovim overlay to pkgs
        inputs.neovim-nightly-overlay.overlays.default
      ];
    };
  in
  {
    nixosConfigurations = {
      irnixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # Pass pkgs with overlay to the system configuration
          { _module.args.pkgs = pkgs; }
          ./nixos/configuration.nix
          inputs.hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
        ];
      };
    };

    homeConfigurations = {
      "irasikhin@irnixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs; # Pass the pkgs with overlay
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}

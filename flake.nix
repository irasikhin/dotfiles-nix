{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    # This pkgs instance is used for home-manager, which receives it directly.
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];
    };
  in
  {
    nixosConfigurations = {
      irnixos = nixpkgs.lib.nixosSystem {
        inherit system;
        # Pass all inputs down to the modules. This is the key.
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          # THE CORRECTED PATH:
          "${inputs.hardware}/lenovo/thinkpad/p14s-amd/gen2"
        ];
      };
    };

    homeConfigurations = {
      "irasikhin@irnixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs; # Home Manager gets the pkgs with the overlay directly. This is correct.
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}

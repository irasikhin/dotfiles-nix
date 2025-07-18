{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The input name is 'hardware', which is what we will use.
    hardware.url = "github:nixos/nixos-hardware";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, hardware, ... }@inputs:
  let
    system = "x86_64-linux";
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
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          # THIS IS THE FIX: Using your original, working method.
          # The argument `hardware` matches the input name now.
          hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
        ];
      };
    };

    homeConfigurations = {
      "irasikhin@irnixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}

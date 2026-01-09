{
  description = "My Nix/NixOS configuration";

  inputs = {
    # The nixpkgs channels
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur={
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable,nur, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [nur.overlays.default];
      };
      # Nest stable channel into default unstable
      overlay-unstable = final: prev: {
        nixpkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
      {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#oli'
    nixosConfigurations = {
      oli = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        # > Our main nixos configuration file <
        modules = [./nixos/configuration.nix
({config,pkgs, ...}: { nixpkgs.overlays = [overlay-unstable]; })];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#oli'
    homeConfigurations = {
      oli = home-manager.lib.homeManagerConfiguration {
        # Home-manager requires 'pkgs' instance
        inherit pkgs;
        extraSpecialArgs = {inherit inputs; unstable=import nixpkgs-unstable {inherit system; config.allowUnfree = true; };};
        # > Our main home-manager configuration file <
        modules = [./home-manager/home.nix ];
      };
    };
  };
}

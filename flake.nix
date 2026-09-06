{
  description = "My Nix/NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      spicetify-nix,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        annie = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/annie/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.annie = ./hosts/annie/home.nix;
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
    };
}

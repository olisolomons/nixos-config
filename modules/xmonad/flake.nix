{
  description = "Standalone pure-Nix XMonad configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hpkgs = pkgs.haskell.packages.ghc912;

      # Define the Haskell environment containing XMonad, contrib, and xmobar
      haskellEnv = hpkgs.ghcWithPackages (
        hp: with hp; [
          xmonad
          xmonad-contrib
          xmobar
          containers
          process
        ]
      );

      # Pure Nix build for the XMonad binary
      xmonadBin = pkgs.stdenv.mkDerivation {
        pname = "xmonad-config";
        version = "0.1.0";
        src = ./.;
        buildInputs = [ haskellEnv ];
        buildPhase = ''
          mkdir -p $out/bin
          ghc -O2 xmonad.hs -o $out/bin/xmonad-x86_64-linux
        '';
        dontInstall = true;
      };
    in
    {
      packages.${system}.default = xmonadBin;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          haskellEnv
          hpkgs.haskell-language-server
          pkgs.cabal-install
          pkgs.xorg-server # Xephyr, for quick iteration
        ];
      };
    };
}

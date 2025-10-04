{
  description = "Nix for ctfhacker";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix?tag=25.07.1";
    pwndbg.url = "github:pwndbg/pwndbg";
    starship-jj.url = "gitlab:lanastara_foss/starship-jj";
    cursor.url = "github:omarcresp/cursor-flake/main";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... } @ inputs:
    let
      lib = nixpkgs.lib;
      username = "user";
      linuxProfile = "default";

      linuxSystem = "x86_64-linux";
      currentSystem = builtins.currentSystem or "";
      darwinSystem =
        if lib.hasSuffix "-darwin" currentSystem then currentSystem else "aarch64-darwin";

      mkPkgs = system:
        import nixpkgs {
          inherit system;
          overlays = [ (import inputs.rust-overlay) ];
          config.allowUnfree = true;
        };

      linuxPkgs = mkPkgs linuxSystem;
    in rec {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          specialArgs = {
            inherit inputs;
            inherit username;
          };

          modules = [
            {
              nixpkgs.overlays = [ (import inputs.rust-overlay) ];
              nixpkgs.config.allowUnfree = true;
            }
            (./profiles/${linuxProfile}/configuration.nix)
          ];
        };
      };

      homeConfigurations =
        let
          mkHome = system: home-manager.lib.homeManagerConfiguration {
            pkgs = mkPkgs system;

            extraSpecialArgs = {
              inherit inputs;
              inherit username;
            };

            modules = [
              (./profiles/${linuxProfile}/home.nix)
            ];
          };

          linuxHome = mkHome linuxSystem;
          darwinHome = mkHome darwinSystem;
        in {
          "${username}" = linuxHome;
          "${username}-macos" = darwinHome;
        };

      devShells.${linuxSystem}.default = linuxPkgs.mkShell {
        buildInputs = homeConfigurations.user.config.home.packages;
      };
    };
}

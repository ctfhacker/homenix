{
  description = "Nix for ctfhacker";

  outputs = { self, nixpkgs, home-manager,  ... } @ inputs: 
  let
    # ---- USER SETTINGS ----
    system = "x86_64-linux";
    username = "user";
    profile = "default";

    # ---- OTHER VARS ----
    pkgs = nixpkgs.legacyPackages.${system} // {
      overlays = [ (import inputs.rust-overlay) ];
      config.allowUnfree = true;
    };
  in rec {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # Default NixOS config
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit username;
        };

        modules = [
          (./. + "/profiles" + ("/" + profile) + "/configuration.nix")
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .'
    homeConfigurations = {
      user = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Pass configuration variables to this configuration
        extraSpecialArgs = { 
          inherit inputs; 
          inherit username;
        };

        modules = [
          (./. + "/profiles" + ("/" + profile) + "/home.nix")
        ];
      };
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = homeConfigurations.user.config.home.packages;
    };
  };

  ## INPUTS ##
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NUR
    # nur.url = "github:nix-community/NUR";

    # Firefox-addons
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust overlay for Rust nightly
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix?tag=25.07.1";
    pwndbg.url = "github:pwndbg/pwndbg";
    starship-jj.url = "gitlab:lanastara_foss/starship-jj";
    cursor.url = "github:omarcresp/cursor-flake/main";
  };
}

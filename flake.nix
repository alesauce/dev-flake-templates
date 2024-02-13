{
  description = "Templates for flake-driven dev environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = nixpkgs.lib.genAttrs supportedSystems;
  in
    {
      pkgs = forEachSupportedSystem (
        localSystem:
          import nixpkgs {inherit localSystem;}
      );

      checks = forEachSupportedSystem (import ./repo-config/checks.nix inputs);

      devShells = forEachSupportedSystem (import ./repo-config/dev-shell.nix inputs);
    }
    // {
      templates = {
        rust-crane = {
          path = ./rust-crane;
          description = "A Rust dev environment using Nix Crane.";
        };
      };
    };
}

{
  description = "A template Flake for building Rust packages using Crane";

  inputs = {
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };

    crane = {
      url = "https://flakehub.com/f/ipetkov/crane/0.15.1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "https://flakehub.com/f/nix-community/fenix/0.1.1694.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-analyzer-src.follows = "";
    };

    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2311.*.tar.gz";
  };

  outputs = {
    nixpkgs,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in {
    pkgs = forAllSystems (localSystem:
      nixpkgs.legacyPackages.${localSystem}
    );
  };
}

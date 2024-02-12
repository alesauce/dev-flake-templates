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

  outputs = { self, nixpkgs, ... } @inputs:
    let
      overlays = [
        (final: prev:
          let
            exec = pkg: "${prev.${pkg}}/bin/${pkg}";
          in
          {
            dvt = prev.writeScriptBin "dvt" ''
              if [ -z $1 ]; then
                echo "no template specified"
                exit 1
              fi

              TEMPLATE=$1

              ${exec "nix"} \
                --experimental-features 'nix-command flakes' \
                flake init \
                --template \
                "github:the-nix-way/dev-templates#''${TEMPLATE}"
            '';
            update = prev.writeScriptBin "update" ''
              for dir in `ls -d */`; do # Iterate through all the templates
                (
                  cd $dir
                  ${exec "nix"} flake update # Update flake.lock
                  ${exec "nix"} flake check  # Make sure things work after the update
                )
              done
            '';
          })
      ];
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      pkgs = forEachSupportedSystem (localSystem:
        import nixpkgs { inherit localSystem overlays; }
      );

      checks = forEachSupportedSystem (import ./repo-config/checks.nix inputs);

      devShells = forEachSupportedSystem (import ./repo-config/dev-shell.nix inputs);

      packages = forEachSupportedSystem ({ pkgs }: rec {
        default = dvt;
        inherit (pkgs) dvt;
      });
    }

    //

    {
      templates = {
        rust-crane = {
          path = ./rust-crane;
          description = "A Rust dev environment using Nix Crane.";
        };
      };
    };
}

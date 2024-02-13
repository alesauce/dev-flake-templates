{self, ...}: system:
with self.pkgs.${system}; {
  default = mkShell {
    nativeBuildInputs = [
      # Nix
      alejandra
      deadnix
      nil
      statix

      # Misc
      pre-commit
    ];

    shellHook = ''
      ${self.checks.${system}.pre-commit-check.shellHook}
    '';
  };
}

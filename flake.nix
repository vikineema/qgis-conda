{
  description = "A flake for QGIS Conda";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    micromamba-shell = {
      url = "github:vikineema/micromamba-shell";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      micromamba-shell,
      ...
    }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = forAllSystems (
        system:
        import nixpkgs {
          localSystem = system;
          #inherit overlays;
          config.allowUnfreePredicate = false;
        }
      );
      pkgsUnstableFor = forAllSystems (
        system:
        import nixpkgs-unstable {
          localSystem = system;
          config.allowUnfreePredicate = false;
        }
      );
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
          pkgs-unstable = pkgsUnstableFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt-tree
              pkgs.pre-commit
              pkgs.shellcheck
              pkgs.yamllint
            ];
            shellHook = ''
              echo "Welcome to the dev shell for your NixOS Config!"

              echo "Running pre-commit checks..."
              pre-commit clean > /dev/null
              pre-commit install --install-hooks > /dev/null
              pre-commit run --all-files || true
              echo "Pre-commit checks complete. Happy coding! 🚀"

              echo "🌈 Your Dev Environment is prepared."
            '';
          };
        }
      );
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
          pkgs-unstable = pkgsUnstableFor.${system};
        in
        {
          default = pkgs.callPackage ./package/qgis-conda.nix {
            micromambaShellPkg = micromamba-shell.packages.${system}.default;
            qgisVersion = "3.44.9";
          };
        }
      );
    };
}

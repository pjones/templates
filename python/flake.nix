{
  description = "Development Environment for Python Projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      each = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          let pkgs = import nixpkgs { inherit system; };
          in f pkgs);

    in
    {
      packages = each (pkgs:
        let
          python = pkgs.python3;
        in
        {
          some-python-module = python.pkgs.buildPythonPackage {
            name = "some-project-name";
            src = pkgs.nix-gitignore.gitignoreSource [ ] ./.;
            format = "pyproject";
            propagatedBuildInputs = with python.pkgs; [
              hatchling
              pandas
            ];
          };

          some-python-app = python.pkgs.toPythonApplication
            self.packages.${pkgs.system}.some-python-module;
        });

      devShells = each (pkgs: {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.basedpyright

            (pkgs.python3.withPackages (pypkgs: with pypkgs; [
              black
            ]))
          ];
        };
      });
    };
}

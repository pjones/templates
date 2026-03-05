{
  description = "Python Notebooks";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      each =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          f pkgs system
        );

    in
    {
      packages = each (
        pkgs: system: {
          dtreeviz = pkgs.callPackage (
            {
              python3Packages,
              fetchPypi,
            }:
            python3Packages.buildPythonPackage rec {
              version = "2.3.2";
              pname = "dtreeviz";
              format = "pyproject";
              src = fetchPypi {
                inherit pname version;
                hash = "sha256-2EE6ATcyNxUPzMt2PkaThPvQVaYnUX1327AZChQD8Fk=";
              };
              build-system = with python3Packages; [
                setuptools
              ];
              dependencies = with python3Packages; [
                colour
                graphviz
                matplotlib
                numpy
                pandas
                scikit-learn
              ];
            }
          ) { };
        }
      );

      devShells = each (
        pkgs: system: {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.basedpyright
              pkgs.graphviz

              (pkgs.python3.withPackages (
                pypkgs: with pypkgs; [
                  biopython
                  black
                  jupyter
                  matplotlib
                  networkx
                  numpy
                  openpyxl
                  pandas
                  reportlab
                  scikit-learn
                  seaborn
                  self.packages.${system}.dtreeviz
                  statsmodels
                  tabulate
                ]
              ))
            ];
          };
        }
      );
    };
}

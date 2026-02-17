{
  description = "Python Notebooks";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
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
      devShells = each (
        pkgs: system: {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.basedpyright

              (pkgs.python3.withPackages (
                pypkgs: with pypkgs; [
                  black
                  jupyter
                  matplotlib
                  networkx
                  numpy
                  openpyxl
                  pandas
                  seaborn
                  scikit-learn
                  tabulate
                ]
              ))
            ];
          };
        }
      );
    };
}

{
  description = "Python and OpenMS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    proteomics.url = "github:pjones/proteomics.nix/openms-3.5";
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

      # Function to generate a set based on supported systems:
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
        pkgs: system:
        let
          proteomics = self.inputs.proteomics.packages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.basedpyright
              pkgs.texliveFull

              (proteomics.python3.withPackages (
                pypkgs: with pypkgs; [
                  black
                  jupyter
                  matplotlib
                  networkx
                  numpy
                  pandas
                  plotly
                  pyopenms
                  pyopenms-viz
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

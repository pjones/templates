{
  description = "Development Environment for OpenMS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    openms.url = "github:pjones/proteomics.nix";
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
          in f pkgs system);
    in
    {
      packages = each (pkgs: system: {
        openms-dev = self.inputs.openms.packages.${system}.openms.override (orig: {
          python3 = pkgs.python3.override {
            packageOverrides = final: prev: {

              # autowrap 0.23 will be used in the next version of OpenMS:
              autowrap = self.inputs.openms.packages.${system}.pyautowrap.overridePythonAttrs (orig: rec {
                version = "0.23.0";
                src = pkgs.fetchPypi {
                  inherit version;
                  pname = orig.pname;
                  hash = "sha256-rs6MBnYcTELB1ukpJQd2FLOJRm8ttUfL29kDfl855Wk=";
                };
                dependencies = [ final.cython_openms ];
              });

              # OpenMS >= 3.5 needs cython 3.1:
              cython_openms = prev.cython_3_1;
            };
          };
        });
      });

      devShells = each (pkgs: system: {
        default = pkgs.mkShell {
          dontFixCmake = 1;

          cmakeFlags =
            self.inputs.openms.packages.${system}.openms.cmakeFlags ++ [
              # Ask CMake to create extra files for clangd:
              "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
              "-DCMAKE_BUILD_TYPE=Debug"
            ];

          QT_PLUGIN_PATH = "${pkgs.kdePackages.qtwayland}/lib/qt-6/plugins/";
          inputsFrom = [ self.packages.${system}.openms-dev ];
          buildInputs = [ pkgs.clang-tools ];
        };
      });
    };
}

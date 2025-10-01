{
  description = "Development Environment for OpenMS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    proteomics.url = "github:pjones/proteomics.nix/openms-3.5";
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
        openms-dev = self.inputs.proteomics.packages.${system}.openms;
      });

      devShells = each (pkgs: system: {
        default = pkgs.mkShell {
          dontFixCmake = 1;

          cmakeFlags =
            self.packages.${system}.openms-dev.cmakeFlags ++ [
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

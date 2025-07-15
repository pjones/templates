{
  description = "Development Environment for OpenMS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    openms.url = "github:pjones/nix-openms/next";
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
      devShells = each (pkgs: {
        default = pkgs.mkShell {
          dontFixCmake = 1;

          cmakeFlags =
            self.inputs.openms.packages.${pkgs.system}.openms.cmakeFlags ++ [
              # Ask CMake to create extra files for clangd:
              "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
              "-DCMAKE_BUILD_TYPE=Debug"
            ];

          QT_PLUGIN_PATH = "${pkgs.kdePackages.qtwayland}/lib/qt-6/plugins/";
          inputsFrom = builtins.attrValues self.inputs.openms.packages.${pkgs.system};
          buildInputs = [ pkgs.clang-tools ];
        };
      });
    };
}

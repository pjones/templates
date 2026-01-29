{
  description = "Development Environment for OpenMS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    proteomics.url = "github:pjones/proteomics.nix/openms-3.6";
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
          openms-dev = self.inputs.proteomics.packages.${system}.openms;
        }
      );

      devShells = each (
        pkgs: system:
        let
          inherit (pkgs) lib;
          gccVer = lib.concatStringsSep "." (lib.take 3 (lib.splitVersion pkgs.libgcc.version));
        in
        {
          default = pkgs.mkShell {
            dontFixCmake = 1;
            CMAKE_CXX_FLAGS_DEBUG = "-g -O0"; # CMake is ignoring -O0 :(

            cmakeFlags = self.packages.${system}.openms-dev.cmakeFlags ++ [
              # Ask CMake to create extra files for clangd:
              (lib.cmakeBool "CMAKE_EXPORT_COMPILE_COMMANDS" true)
              (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Debug")
            ];

            QT_PLUGIN_PATH = "${pkgs.kdePackages.qtwayland}/lib/qt-6/plugins/";
            PYTHON_LIBSTDCXX = "${pkgs.libgcc.lib}/share/gcc-${gccVer}/python";
            inputsFrom = [ self.packages.${system}.openms-dev ];
            buildInputs = [ pkgs.clang-tools ];
          };
        }
      );
    };
}

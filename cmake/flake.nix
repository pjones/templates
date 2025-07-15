{
  description = "Development Environment for CMake Projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
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

          cmakeFlags = [
            # Ask CMake to create extra files for clangd:
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
            "-DCMAKE_BUILD_TYPE=Debug"
          ];

          inputsFrom = [ ];
          buildInputs = [ pkgs.clang-tools ];
        };
      });
    };
}

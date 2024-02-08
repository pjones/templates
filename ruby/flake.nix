{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import nixpkgs { inherit system; });

      # Which version of Ruby are we using?
      ruby = pkgs: pkgs.ruby_3_3;

      # Function to force installation of documentation for the given
      # Ruby Gem:
      withDocs = map (gem: gem.override {
        document = [ "ri" ];
      });

      rubyWithPackages = pkgs:
        (ruby pkgs).withPackages (ps:
          with ps;
          withDocs [
            rubocop
            minitest
          ]);
    in
    {
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              (rubyWithPackages pkgs)
              (ruby pkgs).devdoc
            ];
          };
        });
    };
}

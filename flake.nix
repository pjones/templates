{
  description = "Peter's Nix Flake Templates";

  outputs = { self }: {
    templates.haskell = {
      path = ./haskell;
      description = "A fulling working Haskell project";
    };

    templates.default = self.templates.haskell;
  };
}

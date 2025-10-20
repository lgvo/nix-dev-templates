{
  description = "Nix development project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dev-templates = {
      url = "github:lgvo/nix-dev-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    dev-templates,
    ...
  }:
    dev-templates.lib.mkDevShells {
      config = {
        lang.nix = {
          enable = true;
          lsp = "nil";
          formatter = "nixpkgs-fmt";
        };
      };
    };
}

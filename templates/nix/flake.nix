{
  description = "Nix development project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dev-templates = {
      url = "github:yourname/nix-dev-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    dev-templates,
  }: let
    system = builtins.currentSystem;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = dev-templates.lib.${system}.mkDevShell {
      nix = {
        enable = true;
        lsp = "nil";
        formatter = "nixpkgs-fmt";
      };
    };
  };
}

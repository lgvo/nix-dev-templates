{
  nixpkgs,
  nix-ai-tools,
  systems ? ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"],
}: {config}: let
  mkDevShellForSystem = system: let
    pkgs = nixpkgs.legacyPackages.${system};
    mkDevShell = import ./mk-dev-shell.nix {inherit pkgs nix-ai-tools;};
  in
    mkDevShell config;

  devShells =
    builtins.listToAttrs
    (map (system: {
        name = system;
        value.default = mkDevShellForSystem system;
      })
      systems);
in
  devShells

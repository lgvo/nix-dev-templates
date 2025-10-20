{
  description = "Multi-language development environment templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-ai-tools,
  }: let
    inherit (nixpkgs) lib;
    mkDevShellForSystem = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      import ./lib/mk-dev-shell.nix {
        inherit pkgs nix-ai-tools;
      };

    eachSystemOutputs = flake-utils.lib.eachDefaultSystem (
      system: let
        mkDevShell = mkDevShellForSystem system;
      in {
        # Export the lib for other flakes to use
        lib = {
          inherit mkDevShell;
        };

        # Example dev shells for testing this flake directly
        devShells = {
          default = mkDevShell {
            automation.just.enable = true;

            assistant.opencode.enable = true;

            lang.nix = {
              enable = true;
              formatter = "alejandra";
              withStatix = true;
            };
          };

          python = mkDevShell {
            lang.python.enable = true;
          };

          nix = mkDevShell {
            lang.nix.enable = true;
          };

          # Python with full tooling
          python-full = mkDevShell {
            lang.python = {
              enable = true;
              lsp = true;
              formatter = true;
            };
          };

          # Combined Python + Nix development
          fullstack = mkDevShell {
            lang.python = {
              enable = true;
              lsp = true;
              formatter = true;
            };
            lang.nix = {
              enable = true;
              formatter = "alejandra";
              withStatix = true;
            };
          };
        };
      }
    );
  in
    lib.recursiveUpdate eachSystemOutputs {
      # System-agnostic helper for easy cross-platform flakes
      lib.mkDevShells = import ./lib/mk-dev-shells.nix {
        inherit nixpkgs nix-ai-tools;
      };

      # Templates (not system-specific)
      templates = {
        python = {
          path = ./templates/python;
          description = "Python project with dev environment";
          welcomeText = ''
            # Python Project Template

            Run `direnv allow` to activate the environment.
            Or use `nix develop` to enter the shell manually.
          '';
        };

        nix = {
          path = ./templates/nix;
          description = "Nix development project";
          welcomeText = ''
            # Nix Project Template

            Run `direnv allow` to activate the environment.
          '';
        };
      };

      # Default template
      defaultTemplate = self.templates.nix;
    };
}

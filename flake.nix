{
  description = "Multi-language development environment templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Export the lib for other flakes to use
        lib = {
          mkDevShell = import ./lib/mk-dev-shell.nix { inherit pkgs; };
        };

        # Example dev shells for testing this flake directly
        devShells = {
          python = self.lib.${system}.mkDevShell {
            python.enable = true;
          };
          
          nix = self.lib.${system}.mkDevShell {
            nix.enable = true;
          };
          
          # Python with full tooling
          python-full = self.lib.${system}.mkDevShell {
            python = {
              enable = true;
              lsp = true;
              formatter = true;
            };
          };
          
          # Combined Python + Nix development
          fullstack = self.lib.${system}.mkDevShell {
            python = {
              enable = true;
              lsp = true;
              formatter = true;
            };
            nix = {
              enable = true;
              formatter = "alejandra";
              withStatix = true;
            };
          };
        };
      }
    )) // {
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

{pkgs}: config: let
  inherit (pkgs) lib;

  # Import all language modules
  modules = [
    ./modules/automation
    ./modules/python.nix
    ./modules/nix.nix
  ];

  # Evaluate the module system
  evaluated = lib.evalModules {
    modules =
      modules
      ++ [
        {_module.args = {inherit pkgs;};}
        config
      ];
  };

  cfg = evaluated.config;

  # Collect all packages from enabled languages
  allPackages = lib.flatten [
    [cfg.automation.packages]
    (lib.optionals cfg.python.enable cfg.python.packages)
    (lib.optionals cfg.nix.enable cfg.nix.packages)
  ];

  # Collect all shell hooks
  allShellHooks = lib.concatStringsSep "\n" (
    [cfg.automation.shellHook]
    ++ lib.optionals cfg.python.enable [cfg.python.shellHook]
    ++ lib.optionals cfg.nix.enable [cfg.nix.shellHook]
  );
in
  pkgs.mkShell {
    buildInputs = allPackages;

    shellHook = ''
      ${allShellHooks}

      echo "🚀 Development environment ready!"
      ${lib.optionalString cfg.python.enable "echo \"  ✓ Python ${cfg.python.package.version}\""}
      ${lib.optionalString cfg.nix.enable "echo \"  ✓ Nix tooling\""}
    '';
  }

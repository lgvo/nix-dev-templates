{pkgs}: config: let
  inherit (pkgs) lib;

  # Import all language modules
  modules = [
    ./modules/automation
    ./modules/lang
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
    cfg.lang.packages
    cfg.automation.packages
  ];

  # Collect all shell hooks
  allShellHooks = lib.concatStringsSep "\n" (
    [
      cfg.automation.shellHook
      cfg.lang.shellHook
    ]
  );
in
  pkgs.mkShell {
    buildInputs = allPackages;

    shellHook = ''
      ${allShellHooks}

      echo "🚀 Development environment ready!"
    '';
  }

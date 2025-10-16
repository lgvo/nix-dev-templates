{pkgs, nix-ai-tools}: config: let
  inherit (pkgs) lib;

  # Import all language modules
  modules = [
    ./modules/lang
    ./modules/automation
    ./modules/assistant
  ];

  # Evaluate the module system
  evaluated = lib.evalModules {
    modules =
      modules
      ++ [
        {_module.args = {inherit pkgs nix-ai-tools;};}
        config
      ];
  };

  cfg = evaluated.config;

  # Collect all packages from enabled languages
  allPackages = lib.flatten [
    cfg.lang.packages
    cfg.automation.packages
    cfg.assistant.packages
  ];

  # Collect all shell hooks
  allShellHooks = lib.concatStringsSep "\n" (
    [
      cfg.lang.shellHook
      cfg.automation.shellHook
      cfg.assistant.shellHook
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

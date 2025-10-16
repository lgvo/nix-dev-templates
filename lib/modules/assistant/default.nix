{
  config,
  lib,
  pkgs,
  nix-ai-tools,
  ...
}: let
  cfg = config.assistant;
in {
  imports = [
    ./opencode.nix
  ];

  options.assistant = {
    # Consolidated internal options
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      internal = true;
      readOnly = true;
    };

    shellHook = lib.mkOption {
      type = lib.types.str;
      internal = true;
      readOnly = true;
    };
  };

  config.assistant = {
    packages = lib.flatten [
      (lib.optionals cfg.opencode.enable cfg.opencode.packages)
    ];

    shellHook = lib.concatStringsSep "\n" (
      lib.optionals cfg.opencode.enable [cfg.opencode.shellHook]
    );
  };
}

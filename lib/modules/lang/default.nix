{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.lang;
in {
  imports = [
    ./nix.nix
    ./python.nix
  ];

  options.lang = {
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

  config.lang = {
    packages = lib.flatten [
      (lib.optionals cfg.nix.enable cfg.nix.packages)
      (lib.optionals cfg.python.enable cfg.python.packages)
    ];

    shellHook = lib.concatStringsSep "\n" (
      lib.optionals cfg.nix.enable [cfg.nix.shellHook]
      ++ lib.optionals cfg.python.enable [cfg.python.shellHook]
    );
  };
}

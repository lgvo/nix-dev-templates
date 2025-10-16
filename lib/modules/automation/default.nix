{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.automation;
in {
  imports = [
    ./just.nix
  ];

  options.automation = {
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

  config.automation = {
    packages = lib.flatten [
      (lib.optionals cfg.just.enable cfg.just.packages)
    ];

    shellHook = lib.concatStringsSep "\n" (
      lib.optionals cfg.just.enable [cfg.just.shellHook]
    );
  };
}

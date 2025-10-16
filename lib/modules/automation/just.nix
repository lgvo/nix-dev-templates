{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.automation.just;
in {
  options.automation.just = {
    enable = lib.mkEnableOption "Just task runner";

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to include with just";
    };

    # Internal options (computed)
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

  config.automation.just = lib.mkIf cfg.enable {
    packages = [pkgs.just] ++ cfg.extraPackages;

    shellHook = ''
      echo "  📋 Just task runner"
    '';
  };
}

{
  config,
  lib,
  pkgs,
  nix-ai-tools,
  ...
}: let
  cfg = config.assistant.opencode;
  aiTools = nix-ai-tools.packages.${pkgs.system};
in {
  options.assistant.opencode = {
    enable = lib.mkEnableOption "OpenCode";

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages";
    };

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

  config.assistant.opencode = lib.mkIf cfg.enable {
    packages = [aiTools.opencode] ++ cfg.extraPackages;
    shellHook = "echo \"  • OpenCode\"";
  };
}

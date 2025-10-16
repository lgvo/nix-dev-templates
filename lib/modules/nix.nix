{ config, lib, pkgs, ... }:

let
  cfg = config.nix;
  
in
{
  options.nix = {
    enable = lib.mkEnableOption "Nix development tools";
    
    lsp = lib.mkOption {
      type = lib.types.enum [ "nil" "nixd" "none" ];
      default = "nil";
      description = "Nix language server to use";
    };
    
    formatter = lib.mkOption {
      type = lib.types.enum [ "nixpkgs-fmt" "alejandra" "nixfmt" "none" ];
      default = "nixpkgs-fmt";
      description = "Nix formatter to use";
    };
    
    withStatix = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include statix linter";
    };
    
    withDeadnix = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include deadnix (find dead code)";
    };
    
    withNixTree = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include nix-tree for exploring dependencies";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional Nix-related packages to include";
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
  
  config.nix = lib.mkIf cfg.enable {
    packages = lib.flatten [
      (lib.optional (cfg.lsp == "nil") pkgs.nil)
      (lib.optional (cfg.lsp == "nixd") pkgs.nixd)
      (lib.optional (cfg.formatter == "nixpkgs-fmt") pkgs.nixpkgs-fmt)
      (lib.optional (cfg.formatter == "alejandra") pkgs.alejandra)
      (lib.optional (cfg.formatter == "nixfmt") pkgs.nixfmt-rfc-style)
      (lib.optional cfg.withStatix pkgs.statix)
      (lib.optional cfg.withDeadnix pkgs.deadnix)
      (lib.optional cfg.withNixTree pkgs.nix-tree)
      cfg.extraPackages
    ];
    
    shellHook = ''
      # Nix development environment setup
      ${lib.optionalString (cfg.formatter != "none") ''
        echo "  📝 Nix formatter: ${cfg.formatter}"
      ''}
      ${lib.optionalString (cfg.lsp != "none") ''
        echo "  🔍 Nix LSP: ${cfg.lsp}"
      ''}
    '';
  };
}

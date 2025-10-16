{ config, lib, pkgs, ... }:

let
  cfg = config.python;
  
  # Map version strings to nixpkgs python packages
  pythonVersions = {
    "39" = pkgs.python39;
    "310" = pkgs.python310;
    "311" = pkgs.python311;
    "312" = pkgs.python312;
    "313" = pkgs.python313;
    "latest" = pkgs.python313;
  };
  
in
{
  options.python = {
    enable = lib.mkEnableOption "Python development environment";
    
    version = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "Python version to use (39, 310, 311, 312, 313, or latest)";
      example = "312";
    };
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pythonVersions.${cfg.version};
      defaultText = lib.literalExpression "pythonVersions.\${config.python.version}";
      description = "Python package to use. Override for custom builds.";
    };
    
    withPip = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include pip";
    };
    
    withUv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include uv package manager";
    };
    
    withPoetry = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include Poetry package manager";
    };
    
    lsp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include Python LSP (pyright)";
    };
    
    formatter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include formatters (black, ruff)";
    };
    
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages to include";
      example = lib.literalExpression "[ pkgs.python3Packages.pytest ]";
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
  
  config.python = lib.mkIf cfg.enable {
    packages = lib.flatten [
      cfg.package
      (lib.optional cfg.withUv pkgs.uv)
      (lib.optional cfg.withPoetry pkgs.poetry)
      (lib.optional cfg.lsp pkgs.pyright)
      (lib.optionals cfg.formatter [ pkgs.black pkgs.ruff ])
      cfg.extraPackages
    ];
    
    shellHook = ''
      # Python environment setup
      export PYTHONPATH="$PWD:$PYTHONPATH"
      ${lib.optionalString cfg.withUv ''
        # Configure uv to use local cache
        export UV_CACHE_DIR="$PWD/.uv-cache"
      ''}
    '';
  };
}

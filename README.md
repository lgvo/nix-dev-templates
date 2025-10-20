# Nix Dev Templates

A opinionated collection of composable Nix development environment templates with a module-based configuration system.

## Features

- 🎯 **Module-based configuration** - Declarative `enable = true` style options
- 🔧 **Composable toolchains** - Mix and match languages in one environment
- 📦 **Ready-to-use templates** - Quick project initialization with `nix flake init`
- 🔄 **Version flexibility** - Use latest versions by default, pin when needed
- 🛠️ **Full tooling support** - LSPs, formatters, linters included
- 🤝 **direnv integration** - Automatic environment activation

## Supported Languages

- **Python** - Multiple versions, uv/poetry, pyright LSP, black/ruff formatters
- **Nix** - Multiple LSPs (nil/nixd), formatters (nixpkgs-fmt/alejandra/nixfmt), linters

## Quick Start

### Using Templates

Initialize a new project with a pre-configured template:

```bash
# Python project with basic setup
nix flake init -t github:lgvo/nix-dev-templates#python

# Nix development environment
nix flake init -t github:lgvo/nix-dev-templates#nix
```

After initialization:

```bash
# With direnv (recommended)
direnv allow

# Or manually
nix develop
```

### Using as a Library

#### Simple Cross-Platform (Recommended)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dev-templates = {
      url = "github:lgvo/nix-dev-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, dev-templates, ... }:
    dev-templates.lib.mkDevShells {
      config = {
        lang.python = {
          enable = true;
          version = "312";
          lsp = true;
          formatter = true;
        };
      };
    };
}
```

#### Per-System (Advanced)

For more control over system-specific configurations:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dev-templates = {
      url = "github:lgvo/nix-dev-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, dev-templates, ... }:
    let
      system = "x86_64-linux";  # or "x86_64-darwin", "aarch64-darwin"
    in {
      devShells.${system}.default = dev-templates.lib.${system}.mkDevShell {
        lang.python = {
          enable = true;
          version = "312";
          lsp = true;
          formatter = true;
        };
      };
    };
}
```

## Configuration Options

### Python Module

```nix
lang.python = {
  enable = true;              # Enable Python environment
  version = "latest";         # "39", "310", "311", "312", "313", or "latest"
  withPip = true;            # Include pip (default: true)
  withUv = true;             # Include uv package manager (default: true)
  withPoetry = false;        # Include Poetry (default: false)
  lsp = false;               # Include pyright LSP (default: false)
  formatter = false;         # Include black and ruff (default: false)
  extraPackages = [];        # Additional packages to include
};
```

### Nix Module

```nix
lang.nix = {
  enable = true;                    # Enable Nix development tools
  lsp = "nil";                      # "nil", "nixd", or "none" (default: "nil")
  formatter = "nixpkgs-fmt";        # "nixpkgs-fmt", "alejandra", "nixfmt", or "none"
  withStatix = false;               # Include statix linter (default: false)
  withDeadnix = false;              # Include deadnix (default: false)
  withNixTree = false;              # Include nix-tree (default: false)
  extraPackages = [];               # Additional packages
};
```

## Usage Examples

### Python Web Development

```nix
dev-templates.lib.mkDevShells {
  config = {
    lang.python = {
      enable = true;
      version = "312";
      lsp = true;
      formatter = true;
      withUv = true;
    };
  };
}
```

### Nix Package Development

```nix
dev-templates.lib.mkDevShells {
  config = {
    lang.nix = {
      enable = true;
      lsp = "nil";
      formatter = "alejandra";
      withStatix = true;
      withDeadnix = true;
    };
  };
}
```

### Multi-Language Project

```nix
dev-templates.lib.mkDevShells {
  config = {
    lang.python = {
      enable = true;
      version = "312";
      lsp = true;
    };
    lang.nix = {
      enable = true;
      formatter = "alejandra";
    };
  };
}
```

## Available Templates

| Template | Description | Includes |
|----------|-------------|----------|
| `python` | Basic Python setup | Python, pip, uv |
| `nix` | Nix development | nil LSP, nixpkgs-fmt |

## Project Structure

```
nix-dev-templates/
├── flake.nix           # Main flake with lib exports and templates
├── lib/
│   ├── mkDevShell.nix  # Module evaluator
│   └── modules/
│       ├── python.nix  # Python module configuration
│       └── nix.nix     # Nix module configuration
└── templates/          # Ready-to-use project templates
    ├── python/
    └── nix.nix     # Nix module configuration
```

## Testing Templates Locally

From this repository:

```bash
# Test Python shell
nix develop .#python

# Test Nix shell
nix develop .#nix

# List all available outputs
nix flake show
```

## Development

### Adding a New Language Module

1. Create `lib/modules/your-language.nix`
2. Define options using the NixOS module system
3. Add to `lib/mkDevShell.nix` modules list
4. Update the main `flake.nix` to include test shells
5. Create a template in `templates/your-language/`

### Module Template

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.your-language;
in
{
  options.your-language = {
    enable = lib.mkEnableOption "Your Language development environment";
    # Add more options...
    
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
  
  config.your-language = lib.mkIf cfg.enable {
    packages = [ /* your packages */ ];
    shellHook = ''
      # Your environment setup
    '';
  };
}
```

## Why Use This?

### vs Plain Nix Flakes
- **Declarative configuration** - No need to manually compose `mkShell` calls
- **Reusable across projects** - One source of truth for your dev environments
- **Composable** - Mix languages easily without conflicts

### vs Other Template Collections
- **Module-based** - Familiar NixOS-style configuration
- **Extensible** - Easy to add new languages or customize existing ones
- **Type-safe** - Options are validated by the module system

## Requirements

- Nix with flakes enabled
- (Optional) direnv for automatic environment activation

Enable flakes in `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

## Contributing

Contributions welcome! Please:

1. Follow the existing module structure
2. Add tests for new modules
3. Update documentation
4. Keep templates minimal and focused

## License

MIT

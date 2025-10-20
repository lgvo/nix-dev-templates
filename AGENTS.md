# Agent Guidelines for nix-dev-templates

## Project Goals
- **Composability**: Enable mixing multiple languages/toolchains in one environment without conflicts
- **Simplicity**: Keep modules minimal with declarative `enable = true` style options and sensible defaults
- **Reusability**: Provide a library (`mkDevShell`) for other flakes, not just standalone templates
- **Convention over configuration**: Use latest versions by default, allow pinning when needed
- **Type safety**: Leverage NixOS module system for option validation and documentation

## Build/Test Commands
- Format: `just fmt` or `alejandra .`
- Lint: `just lint` or `statix check .`
- Check flake: `just check` or `nix flake check`
- Verify modules: `just verify-modules` or `nix eval '.#lib' > /dev/null`
- Test shell: `nix develop -c true`
- Show outputs: `nix flake show`

## Code Style
- Language: Nix only (no shell scripts, pure Nix)
- Formatting: Use alejandra formatter (2-space indentation)
- Imports: `{ config, lib, pkgs, ... }:` with inherit statements in let blocks
- Module structure: Follow NixOS module system (options/config pattern)
- Naming: camelCase for options, kebab-case for files
- Options: Use `lib.mkOption`, `lib.mkEnableOption`, mark internal options with `internal = true; readOnly = true;`
- Conditionals: Use `lib.mkIf`, `lib.optional`, `lib.optionals` for package lists
- No comments unless documenting complex logic
- Descriptions: Always provide `description` and optionally `example` for public options

## Project Structure
- Modules in `lib/modules/{category}/{name}.nix` (lang, automation, assistant)
- Each module exports `packages` and `shellHook` as internal options
- Templates in `templates/{name}/` with minimal flake.nix
- Use `builtins.currentSystem` in templates, `flake-utils` in main flake

## Changelog
- Create changelog entries in `changelog/` for significant changes
- Naming: `YYYY-MM-DD-brief-description.md` (e.g., `2025-10-20-add-mkdevshells.md`)
- Structure: Include sections for Added/Changed/Fixed/Removed as applicable
- Content: Document what changed, why, usage examples, migration guides, and backward compatibility notes
- When: Create changelog for new features, breaking changes, or significant refactors

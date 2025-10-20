# Changelog Entry: Add `mkDevShells` for Cross-Platform Development

**Date:** 2025-10-20

## Added

### `lib.mkDevShells` - Cross-Platform Helper Function

Added a new `mkDevShells` function that automatically creates dev shells for all supported architectures without requiring users to handle system detection or use `flake-utils`.

**Location:** `lib/mk-dev-shells.nix`

**Features:**
- ✅ Automatic multi-system support (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin)
- ✅ Zero boilerplate - no need for `builtins.currentSystem` or manual system handling
- ✅ Simplified API with explicit `config` parameter
- ✅ No additional dependencies (doesn't require users to add `flake-utils`)

**Usage:**
```nix
outputs = { nixpkgs, dev-templates, ... }: {
  devShells = dev-templates.lib.mkDevShells {
    config = {
      lang.python.enable = true;
    };
  };
};
```

### AGENTS.md - Guidelines for AI Coding Agents

Added comprehensive guidelines for agentic coding tools including:
- Project goals (composability, simplicity, reusability)
- Build/test/lint commands
- Code style conventions
- Project structure documentation

## Changed

### Dual API Approach

The library now exports two complementary APIs:

1. **Simple (New):** `lib.mkDevShells` - Cross-platform by default
2. **Advanced (Existing):** `lib.${system}.mkDevShell` - Per-system control

Both APIs remain available for different use cases.

### Updated Templates

Both `templates/python` and `templates/nix` now use the simpler `mkDevShells` approach:
- Reduced from ~27 lines to ~24 lines
- No manual system handling required
- Clearer, more declarative structure

### README Documentation

- Added "Simple Cross-Platform" section showing `mkDevShells` usage
- Reorganized "Using as a Library" with both simple and advanced examples
- Updated all usage examples to show `mkDevShells` as the recommended approach
- Fixed module option namespace to consistently use `lang.*` prefix

## Technical Details

**Implementation:**
- Uses `lib.recursiveUpdate` to merge per-system and system-agnostic exports
- Supports customizable system list via `systems` parameter
- Creates `devShells.${system}.default` for all specified systems

**Files Modified:**
- `flake.nix` - Added `lib.mkDevShells` export and refactored structure
- `lib/mk-dev-shells.nix` - New cross-platform helper
- `lib/mk-dev-shell.nix` - Formatted
- `templates/python/flake.nix` - Simplified using `mkDevShells`
- `templates/nix/flake.nix` - Simplified using `mkDevShells`
- `README.md` - Updated documentation and examples

**Statistics:**
- 5 files changed
- 121 insertions
- 87 deletions

## Migration Guide

### For New Projects
Use `mkDevShells` (recommended):
```nix
devShells = dev-templates.lib.mkDevShells {
  config = { lang.python.enable = true; };
};
```

### For Existing Projects
No breaking changes - existing per-system API still works:
```nix
dev-templates.lib.${system}.mkDevShell {
  lang.python.enable = true;
}
```

## Backward Compatibility

✅ **Fully backward compatible** - no breaking changes
- Per-system `lib.${system}.mkDevShell` continues to work
- All existing module options unchanged
- Templates can still use either approach

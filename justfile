# Nix dev templates justfile

# Show all available flake outputs
show:
  nix flake show

# List all dev shells
list-shells:
  @echo "Available shells:"
  @echo "  default      - Nix development"
  @echo "  python       - Python only"
  @echo "  nix          - Nix only"

# Enter a specific dev shell
dev shell="default":
  nix develop ".#{{ shell }}"

# Format all Nix files
fmt:
  alejandra .

# Check Nix files for issues
lint:
  statix check .

# Update flake.lock
update:
  nix flake update

# Check flake for errors without building
check:
  nix flake check

# Clean Nix artifacts
clean:
  rm -rf result result-*

# Test all dev shells
test-shells: && (show)
  @echo "Testing default shell..."
  nix develop -c true
  @echo "✓ default shell works"

# Verify module syntax
verify-modules:
  nix eval '.#lib' > /dev/null && echo "✓ Modules valid"

# Full development setup
setup: update fmt verify-modules
  @echo "✓ Setup complete"

# Help
help:
  @just --list

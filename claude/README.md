# Claude Code Installation Guide: Global vs Local

## Original Global Installation (Standard Method)

The typical way to install Claude Code globally using npm:

```bash
# Standard global installation
npm install -g @anthropic-ai/claude-code

# Complete OAuth setup
claude
```

**Note:** When using Homebrew Node (common on macOS), npm is automatically installed with Node, and global packages install to `/opt/homebrew/lib/node_modules/` on Apple Silicon Macs.

## Migrating to Local Installation

If you already have Claude Code installed globally and want to migrate to local:

```bash
# Start Claude Code
claude

# Use the migrate installer command
/migrate-installer
```

**What `/migrate-installer` does:**
- Creates a local installation in your user directory
- Avoids npm permission issues
- Enables proper auto-updates
- Maintains your existing configuration

## Removing Global Installation

```bash
# Kill any running claude processes first
pkill -f claude

# Then force remove the stuck directory
sudo rm -rf /opt/homebrew/lib/node_modules/@anthropic-ai/claude-code
```

## Verification Commands

```bash
# Check which claude installation is active
which claude

# Verify version
claude --version

# Run health check
claude doctor
```

## Best Practices

1. **Always use user-local installation** to avoid permission issues
2. **Run `/migrate-installer`** if you already have a global installation
3. **Use `sudo rm -rf`** only as a last resort for stuck global installations
4. **Check `claude doctor`** to verify your installation is healthy
5. **Keep your PATH updated** to point to the user installation

## Troubleshooting

- **ENOTEMPTY errors**: Use `sudo rm -rf` to force remove the directory
- **Permission warnings**: Use `/migrate-installer` or set up user npm prefix
- **Command not found**: Check your PATH includes `~/.npm-global/bin`
- **Auto-update failures**: Ensure you're using local installation, not global
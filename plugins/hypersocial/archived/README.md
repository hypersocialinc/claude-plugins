# Archived Components

This directory contains deprecated or superseded plugin components that are preserved for historical reference.

## Contents

### extract-pattern.md
**Status**: Deprecated
**Superseded by**: [pattern-extractor plugin](../../pattern-extractor)
**Archived**: 2026-01-14

The original extract-pattern agent that was part of the hypersocial plugin. This has been extracted into a standalone plugin with enhanced features:

- **Old location**: `plugins/hypersocial/agents/extract-pattern.md`
- **New location**: `plugins/pattern-extractor/` (standalone plugin)
- **Migration**: Install the pattern-extractor plugin from the marketplace

**Why it was moved:**
- Enables independent installation/uninstallation
- Provides better configuration options
- Allows for independent versioning and updates
- Reduces hypersocial plugin complexity
- Follows single-responsibility principle

**To use the new version:**
```bash
# Via marketplace
/plugin → Add Marketplace → hypersocialinc/claude-plugins → pattern-extractor

# Or direct symlink
ln -s /path/to/claude-plugins/plugins/pattern-extractor ~/.claude/plugins/pattern-extractor
```

## Purpose of Archiving

Rather than deleting deprecated components, we archive them to:

1. **Preserve history** - Maintain a record of how the plugin evolved
2. **Reference implementation** - Serve as examples for future development
3. **Backward compatibility** - Allow recovery if needed
4. **Documentation** - Show what changed and why

## Usage Note

⚠️ Components in this directory are **not actively maintained** and should not be used in production. They are kept for reference only.

If you need functionality from an archived component, please use the recommended alternative listed in its deprecation notice.

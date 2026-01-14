# Pattern Extractor Plugin

Extract implementation patterns from GitHub repositories with structured analysis and documentation.

## Overview

The Pattern Extractor plugin helps you discover how features were implemented in existing codebases. It searches GitHub repositories, extracts relevant code snippets, explains implementation approaches, and provides external documentation links.

**Perfect for:**
- Finding how authentication was implemented in previous projects
- Discovering database patterns and best practices
- Learning how integrations (Stripe, Clerk, etc.) were set up
- Comparing different implementation approaches across repos
- Bootstrapping new features based on proven patterns

## Components

### Agent: `extract-pattern`
Autonomous agent that searches GitHub repos and returns structured implementation summaries.

**Features:**
- Multi-repo search across your organization
- Smart code extraction with context
- External documentation integration
- Caching for performance
- Configurable search scope

### Command: `/extract`
Quick command to invoke pattern extraction.

**Usage:**
```bash
/extract clerk authentication
/extract convex mutations with file upload
/extract stripe subscription setup
```

## Installation

### Prerequisites

1. **GitHub CLI (`gh`)** - Required for repo access
   ```bash
   # macOS
   brew install gh

   # Login to GitHub
   gh auth login
   ```

2. **Claude Code** - The pattern-extractor plugin requires Claude Code CLI

### Install Plugin

**Option 1: Symlink (for development)**
```bash
# From your claude-plugins repo
ln -s $PWD/plugins/pattern-extractor ~/.claude/plugins/pattern-extractor
```

**Option 2: Copy (for stable use)**
```bash
# From your claude-plugins repo
cp -r plugins/pattern-extractor ~/.claude/plugins/pattern-extractor
```

**Option 3: Git Clone**
```bash
# Clone directly to plugins directory
git clone <repo-url> ~/.claude/plugins/pattern-extractor
```

### Verify Installation

```bash
# List installed plugins
ls ~/.claude/plugins/

# Should show: pattern-extractor/
```

## Configuration

### Default Settings

By default, the plugin searches the `hypersocialinc` GitHub organization. To customize:

### Option A: Environment Variables

```bash
export GITHUB_ORG="your-org-name"
export PATTERN_SEARCH_LIMIT=100
export PATTERN_CACHE_DIR="/tmp/pattern-cache"
```

Add to your `~/.zshrc` or `~/.bashrc` to persist.

### Option B: Local Config File

Create `.claude/pattern-extractor.local.md` in your project:

```yaml
---
github_org: your-company
max_repos: 100
excluded_repos:
  - deprecated-*
  - archived-*
  - temp-*
---

# Pattern Extractor Config

Additional notes about your organization's patterns...

## Common Repos
- main-app: Primary application
- api-service: Backend API
- mobile-app: React Native app
```

## Usage

### Basic Pattern Extraction

**Using the slash command:**
```
/extract clerk authentication
```

**Directly invoking the agent:**
```
Use the extract-pattern agent to find how we implemented Stripe subscriptions
```

**In conversation:**
```
User: How did we handle file uploads in previous projects?
Claude: [automatically invokes extract-pattern agent]
```

### Advanced Usage

**Search specific repos:**
```
Extract authentication patterns from tapjam and nicosia repos only
```

**Compare implementations:**
```
Extract database migration patterns and compare approaches across all repos
```

**With external context:**
```
Extract Convex real-time subscription patterns and include official Convex docs
```

## Examples

### Example 1: Authentication Pattern

**Input:**
```
/extract clerk authentication with convex
```

**Output:**
```markdown
## Repos with Clerk Auth + Convex
- tapjam (updated 2024-01-10) ⭐ Most complete
- nicosia (updated 2023-12-15)

## Key Code Snippets

**tapjam/middleware.ts:12-24**
```typescript
import { authMiddleware } from "@clerk/nextjs";
export default authMiddleware({
  publicRoutes: ["/", "/api/webhook"],
});
```

**tapjam/convex/users.ts:8-15**
```typescript
export const syncUser = mutation({
  args: { clerkId: v.string(), email: v.string() },
  handler: async (ctx, args) => {
    // Sync Clerk user to Convex
  },
});
```

## Implementation Approach
1. Install @clerk/nextjs and setup ClerkProvider
2. Configure middleware for protected routes
3. Setup webhook to sync users to Convex
4. Use Clerk user ID in Convex mutations

## External Documentation
- Clerk Next.js: https://clerk.com/docs/quickstarts/nextjs
- Convex with Clerk: https://docs.convex.dev/auth/clerk

## Additional Notes
- tapjam uses webhook for real-time sync
- Consider rate limiting on webhook endpoint
```

### Example 2: Database Pattern

**Input:**
```
/extract file upload to convex storage
```

**Output:**
```markdown
## Repos with Convex File Upload
- tapjam (updated 2024-01-10)

## Key Code Snippets

**tapjam/convex/files.ts:20-35**
```typescript
export const generateUploadUrl = mutation({
  handler: async (ctx) => {
    return await ctx.storage.generateUploadUrl();
  },
});

export const saveFile = mutation({
  args: { storageId: v.id("_storage"), name: v.string() },
  handler: async (ctx, args) => {
    const fileId = await ctx.db.insert("files", {
      storageId: args.storageId,
      name: args.name,
      uploadedAt: Date.now(),
    });
    return fileId;
  },
});
```

**tapjam/app/upload/page.tsx:15-30**
```typescript
const handleUpload = async (file: File) => {
  const uploadUrl = await generateUploadUrl();
  const response = await fetch(uploadUrl, {
    method: "POST",
    body: file,
  });
  const { storageId } = await response.json();
  await saveFile({ storageId, name: file.name });
};
```

## Implementation Approach
1. Generate upload URL via mutation
2. Upload file directly to Convex storage
3. Save storage ID reference in database
4. Retrieve file URL when needed

## External Documentation
- Convex File Storage: https://docs.convex.dev/file-storage

## Additional Notes
- Storage IDs are permanent references
- Consider file size limits (100MB default)
- Use getUrl() mutation to retrieve signed URLs
```

### Example 3: Integration Pattern

**Input:**
```
Extract stripe subscription implementation
```

**Output:**
```markdown
## Repos with Stripe Subscriptions
- tapjam (updated 2024-01-10)

## Key Code Snippets

**tapjam/app/api/stripe/webhook/route.ts**
[Webhook handler code...]

**tapjam/convex/subscriptions.ts**
[Subscription mutations...]

## Implementation Approach
[Step-by-step approach...]

## External Documentation
- Stripe Subscriptions: https://stripe.com/docs/billing/subscriptions/overview
- Next.js API Routes: https://nextjs.org/docs/api-routes/introduction

## Additional Notes
- Use Stripe webhook for subscription events
- Store subscription status in Convex
- Handle failed payments gracefully
```

## Best Practices

### When to Use Pattern Extractor

✅ **Good use cases:**
- Starting a new feature similar to existing ones
- Learning how integrations were set up
- Finding best practices in your codebase
- Comparing different implementation approaches
- Discovering undocumented patterns

❌ **Not ideal for:**
- Finding specific bugs (use code search instead)
- Extracting large codebases (too broad)
- Non-code documentation (use regular search)

### Tips for Better Results

1. **Be specific:** "clerk authentication with middleware" > "auth"
2. **Include context:** "convex mutations for file upload" > "file upload"
3. **Mention libraries:** "stripe subscription with webhook" > "subscriptions"
4. **Compare repos:** "compare authentication in tapjam vs nicosia"
5. **Ask for docs:** "include Convex documentation for real-time queries"

## Troubleshooting

### "GitHub CLI not found"

Install GitHub CLI:
```bash
brew install gh
gh auth login
```

### "Cannot access repo"

Check permissions:
```bash
gh repo view your-org/repo-name
```

If access denied, request access from your organization admin.

### "Rate limit exceeded"

GitHub API has rate limits. The plugin uses caching to minimize requests, but if you hit limits:

1. Wait a few minutes
2. Reduce search scope (search specific repos)
3. Use cached results (automatically used when available)

### Agent not found

Verify plugin is installed:
```bash
ls ~/.claude/plugins/pattern-extractor
```

Should show:
```
.claude-plugin/
agents/
commands/
README.md
```

### Cached results are stale

Clear cache:
```bash
rm -rf /tmp/claude-pattern-cache/*
```

Or set a custom cache location:
```bash
export PATTERN_CACHE_DIR="$HOME/.cache/pattern-extractor"
```

## Uninstallation

To remove the plugin:

```bash
rm -rf ~/.claude/plugins/pattern-extractor
```

Configuration files (`.claude/pattern-extractor.local.md`) in your projects will remain but won't affect anything.

## Development

### Plugin Structure

```
pattern-extractor/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── agents/
│   └── extract-pattern.md   # Main extraction agent
├── commands/
│   └── extract.md           # Slash command
└── README.md                # This file
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with symlinked installation
5. Submit a pull request

### Adding New Features

**To add a new agent:**
```bash
# Create agent file
touch agents/validate-pattern.md

# Add agent frontmatter and instructions
```

**To add a new command:**
```bash
# Create command file
touch commands/compare.yaml

# Add command frontmatter and template
```

## Related Plugins

- **ralph**: Autonomous feature development with story-based tracking
- **hypersocial**: HyperSocial tools including SWARM git worktree manager

## Support

For issues, feature requests, or questions:
- GitHub Issues: [hypersocialinc/claude-plugins](https://github.com/hypersocialinc/claude-plugins/issues)
- Documentation: This README and agent files

## License

MIT License - see repository for details

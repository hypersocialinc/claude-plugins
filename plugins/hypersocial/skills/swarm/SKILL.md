---
name: SWARM
description: This skill should be used when the user asks to "create a worktree", "manage worktrees", "switch branches", "parallel development", "srm", "swarm", or mentions git worktrees, branch management, or parallel feature development.
version: 1.0.0
---

# SWARM - Git Worktree Manager

SWARM (`srm`) is a CLI tool for managing git worktrees, enabling parallel feature development without switching branches.

## What Are Git Worktrees?

Git worktrees allow you to have multiple working directories attached to the same repository. Instead of stashing changes or committing incomplete work to switch branches, you can have separate directories for each branch/feature.

## Commands

| Command | Description |
|---------|-------------|
| `srm` | Interactive TUI - select worktree and CD into it |
| `srm new <branch> [--base b]` | Create new worktree from base branch |
| `srm ls` | List all worktrees |
| `srm rm <branch>` | Remove worktree |
| `srm go <branch>` | Print worktree path (used by shell integration) |
| `srm exec <script> [branch]` | Run script from swarm.json in worktree |
| `srm open <branch> [editor]` | Open worktree in editor (default: cursor) |
| `srm setup-shell` | Print shell integration function |

## Shell Integration (Required for CD)

Since a subprocess cannot change the parent shell's directory, you need shell integration for `srm` to automatically CD into worktrees.

Add to `~/.zshrc` or `~/.bashrc`:

```bash
eval "$(srm setup-shell)"
```

This creates a wrapper function that:
1. Runs `srm` normally
2. If `srm` outputs a valid path, CDs into it
3. Otherwise, shows the normal output

## Config File: swarm.json

Create `swarm.json` in your repository root to customize SWARM behavior:

```json
{
  "worktreeDir": "~/.swarm",
  "copyFiles": [".env", ".env.local"],
  "scripts": {
    "setup": "bun install",
    "dev": "bun run dev"
  }
}
```

### Configuration Options

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `worktreeDir` | string | `~/.swarm` | Base directory for worktrees. Worktrees are stored at `{worktreeDir}/{repo-name}/{branch}` |
| `copyFiles` | string[] | `[]` | Files to copy from main repo to new worktrees (e.g., environment files) |
| `scripts.setup` | string | - | Command to run after creating worktree (e.g., install dependencies) |
| `scripts.dev` | string | - | Command to start dev server |
| `scripts.stop` | string | - | Command to stop dev server (for cleanup) |

## Typical Workflow

### 1. Initialize Config

Use `/swarm-init` command in Claude to analyze your repo and generate `swarm.json`.

### 2. Start a Feature

```bash
srm new feature-x --base main
```

This will:
- Create branch `feature-x` from `main`
- Create worktree at `~/.swarm/{repo}/feature-x`
- Copy configured files (e.g., `.env`)
- Run setup script (e.g., `bun install`)
- Auto-CD into the worktree

### 3. Switch Between Features

Run `srm` to open the interactive TUI:
- Navigate with arrow keys or j/k
- Press Enter to select "CD here"
- Your shell changes to that worktree

### 4. Run Dev Server

```bash
srm exec dev
# or in specific worktree
srm exec dev feature-x
```

### 5. Clean Up

```bash
srm rm feature-x
```

## Examples

### Create worktree from main branch
```bash
srm new feature-auth --base main
```

### Create worktree from current HEAD
```bash
srm new hotfix-123
```

### List all worktrees
```bash
srm ls
```

### Open worktree in VS Code
```bash
srm open feature-auth code
```

### Open worktree in Cursor
```bash
srm open feature-auth
```

## Where Worktrees Are Stored

By default, worktrees are stored at:
```
~/.swarm/{repo-name}/{branch-name}/
```

For example, if your repo is `my-app` and you create a worktree for `feature-x`:
```
~/.swarm/my-app/feature-x/
```

You can customize this with the `worktreeDir` option in `swarm.json`.

## Use `/swarm-init` to generate swarm.json automatically.

Run the `/swarm-init` command and Claude will analyze your repository to:
- Detect project type (Next.js, Node, Python, etc.)
- Detect package manager (bun, pnpm, yarn, npm)
- Find environment files to copy
- Generate appropriate setup/dev scripts

---
description: Analyze repo and create swarm.json config for SWARM worktree manager
---

# Initialize SWARM Config

Analyze this repository and create a `swarm.json` configuration file for the SWARM git worktree manager.

## Analysis Steps

### 1. Detect Project Type

Check for these files to determine the project type:
- `package.json` → Node.js/Bun project
- `next.config.js` or `next.config.ts` or `next.config.mjs` → Next.js
- `requirements.txt` or `pyproject.toml` → Python
- `Cargo.toml` → Rust
- `go.mod` → Go

### 2. Detect Package Manager

Check for lockfiles to determine the package manager:
- `bun.lockb` → Use `bun`
- `pnpm-lock.yaml` → Use `pnpm`
- `yarn.lock` → Use `yarn`
- `package-lock.json` → Use `npm`

If no lockfile found, default to `npm` for Node projects.

### 3. Find Environment Files

Check which of these files exist in the repo root:
- `.env`
- `.env.local`
- `.env.development`
- `.env.development.local`

Only include files that actually exist in `copyFiles`.

### 4. Determine Scripts

Read `package.json` to find appropriate scripts:

**For `setup` script:**
- Use the detected package manager's install command
- Examples: `bun install`, `pnpm install`, `yarn`, `npm install`

**For `dev` script:**
- Check if `package.json` has a `dev` script → use `{pm} run dev`
- Otherwise check for `start` script → use `{pm} run start`
- For Next.js: `{pm} run dev`

**For `stop` script (optional):**
- For dev servers: `pkill -f '{pm} run dev'` or similar

### 5. Create swarm.json

Write the config file to the repo root with this structure:

```json
{
  "worktreeDir": "~/.swarm",
  "copyFiles": ["<detected env files>"],
  "scripts": {
    "setup": "<install command>",
    "dev": "<dev command>"
  }
}
```

## Output

After analyzing, write the `swarm.json` file to the repository root and show the user what was created.

## Example Outputs

**For a Bun + Next.js project with .env and .env.local:**
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

**For a pnpm monorepo:**
```json
{
  "worktreeDir": "~/.swarm",
  "copyFiles": [".env"],
  "scripts": {
    "setup": "pnpm install",
    "dev": "pnpm run dev"
  }
}
```

**For a Python project:**
```json
{
  "worktreeDir": "~/.swarm",
  "copyFiles": [".env"],
  "scripts": {
    "setup": "pip install -r requirements.txt",
    "dev": "python main.py"
  }
}
```

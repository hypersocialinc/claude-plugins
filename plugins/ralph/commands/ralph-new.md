---
name: ralph-new
description: Start a new autonomous feature with Ralph
arguments:
  - name: feature-name
    description: Name of the feature (kebab-case)
    required: true
  - name: from
    description: Optional file path to existing spec/PRD
    required: false
    flag: --from
---

# Ralph New Feature

Initialize a new autonomous feature development loop with Ralph.

## Process

### 1. Check for Existing Ralph

Look for `.ralph/` directory in the project root.

If it exists and contains a feature directory:
```
Found active Ralph feature: <name>
Options:
1. Complete it with /ralph-done
2. Abandon it with /ralph-abandon
3. Cancel this command
```

Use AskUserQuestion to get their choice. If they choose complete or abandon, remind them to run that command first.

### 2. Validate Feature Name

Feature name must be:
- Kebab-case (lowercase with hyphens)
- No spaces or special characters
- Example: `auth-system`, `payment-flow`, `user-dashboard`

### 3. Create Git Branch

```bash
git checkout -b ralph/<feature-name>
```

### 4. Create Ralph Directory

```bash
mkdir -p .ralph/<feature-name>
```

### 5. Copy Templates

Copy from plugin templates to `.ralph/<feature-name>/`:
- `prd.json` (empty story list)
- `plan.md` (feature template)
- `progress.txt` (initialized log)
- `board/` directory with `board.html` (visual dashboard)

Create board directory:
```bash
mkdir -p .ralph/<feature-name>/board
cp ${CLAUDE_PLUGIN_ROOT}/templates/board.html .ralph/<feature-name>/board/index.html
```

Replace template variables:
- `{{FEATURE_NAME}}` → feature name
- `{{DATE}}` → current date (YYYY-MM-DD)
- `{{STORY_COUNT}}` → 0 (will be filled by planner)

### 5b. Generate ralph-go.sh Script

Create the terminal execution script:

```bash
cp ${CLAUDE_PLUGIN_ROOT}/templates/ralph-go.sh .ralph/<feature-name>/ralph-go.sh
```

Replace template variables:
- `{{FEATURE_NAME}}` → feature name (kebab-case)
- `{{DATE}}` → current ISO timestamp (YYYY-MM-DDTHH:MM:SSZ)

Make executable:
```bash
chmod +x .ralph/<feature-name>/ralph-go.sh
```

This script enables terminal-based autonomous execution:
- Loops calling `/ralph-next` until complete
- Exit codes for scripting/CI
- Can be backgrounded or redirected

### 6. Handle Existing Spec (if --from flag)

If user provided `--from <file>`:
- Read the file
- Pass its contents to the ralph-planner agent
- Skip the Q&A phase (planner uses the doc instead)

### 7. Launch Ralph Planner

Use the Task tool to launch the `ralph-planner` agent:

```
Task tool:
  subagent_type: "ralph:ralph-planner"
  description: Plan feature and create stories
  prompt: |
    Feature name: <feature-name>
    Working directory: .ralph/<feature-name>

    {{If --from was used:}}
    Existing spec:
    <file contents>
    {{Otherwise:}}
    No existing spec - gather requirements from user.
```

The planner will:
- Ask user questions (or use provided spec)
- Generate `plan.md`
- Generate stories in `prd.json`
- Aim for 8-15 stories, 15-45 min each

### 8. Initialize Progress

After planner completes, update `progress.txt` with story count:
```
# Ralph Progress: <feature-name>
Branch: ralph/<feature-name>
Started: <date>

## Codebase Patterns
<!-- Add reusable patterns here as you discover them -->

---

## Log

=== <date> - Initialized ===
Feature: <feature-name>
Stories: <count from prd.json>
Ready to start.

---
```

### 9. Initial Commit

Add all Ralph files including the generated script:

```bash
git add .ralph/<feature-name>
git commit -m "ralph: init <feature-name>

<summary from plan.md>

Files:
- plan.md: Feature specification
- prd.json: <count> stories
- progress.txt: Work log
- ralph-go.sh: Terminal execution script

Co-Authored-By: Ralph <ralph@hypersocial.com>"
```

### 10. Output Instructions

```
✅ Ralph feature initialized: <feature-name>

Files created:
- .ralph/<feature-name>/plan.md          # Feature specification
- .ralph/<feature-name>/prd.json         # Story definitions
- .ralph/<feature-name>/progress.txt     # Work log
- .ralph/<feature-name>/ralph-go.sh      # Terminal script ⭐

Branch: ralph/<feature-name>
Stories: <count>

Next steps:

1. Review the plan:
   cat .ralph/<feature-name>/plan.md

2. Start development:

   Option A: Terminal Script (Recommended for CI/CD)
   cd .ralph/<feature-name>
   ./ralph-go.sh

   Option B: Autonomous in Claude Code (Recommended for interactive)
   /ralph-go
   → Choose "Autonomous" when prompted

   Option C: One story at a time (Recommended for learning)
   /ralph-next

3. When complete:
   /ralph-done

Happy shipping! 🚀
```

## Error Handling

- If feature name invalid → show error with correct format
- If .ralph/ already exists → prompt for action
- If git operations fail → show error and cleanup
- If planner fails → cleanup .ralph directory

## Important Notes

- Don't start the loop automatically - let user choose their mode
- Make sure ralph-go.sh is executable (chmod +x)
- Include ralph-go.sh in the initial commit
- Commit before suggesting next steps

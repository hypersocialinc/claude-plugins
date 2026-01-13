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
- `claude.md` (workflow instructions)
- `prd.json` (empty story list)
- `plan.md` (feature template)
- `progress.txt` (initialized log)
- `ralph.sh` (bash loop script)

Replace template variables:
- `{{FEATURE_NAME}}` → feature name
- `{{DATE}}` → current date (YYYY-MM-DD)
- `{{STORY_COUNT}}` → 0 (will be filled by planner)

Make ralph.sh executable:
```bash
chmod +x .ralph/<feature-name>/ralph.sh
```

### 6. Handle Existing Spec (if --from flag)

If user provided `--from <file>`:
- Read the file
- Pass its contents to the ralph-planner agent
- Skip the Q&A phase (planner uses the doc instead)

### 7. Launch Ralph Planner

Use the Task tool to launch the `ralph-planner` agent:

```
Task tool:
  subagent_type: ralph-planner
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

```bash
git add .ralph/<feature-name>
git commit -m "ralph: init <feature-name>

<summary from plan.md>

Co-Authored-By: Ralph <ralph@hypersocial.com>"
```

### 10. Output Instructions

```
✅ Ralph feature initialized: <feature-name>

Branch: ralph/<feature-name>
Stories: <count>

Next steps:
1. Review the plan: .ralph/<feature-name>/plan.md
2. Review stories: .ralph/<feature-name>/prd.json
3. Start autonomous loop:

   Option A: Let Claude run it
   /ralph-run

   Option B: Run manually in terminal
   cd <project-path>
   ./.ralph/<feature-name>/ralph.sh 20

   Option C: One story at a time
   /ralph-next

Happy shipping! 🚀
```

## Error Handling

- If feature name invalid → show error with correct format
- If .ralph/ already exists → prompt for action
- If git operations fail → show error and cleanup
- If planner fails → cleanup .ralph directory

## Important Notes

- Don't start the loop automatically - let user choose
- Make sure ralph.sh is executable
- Commit before suggesting next steps

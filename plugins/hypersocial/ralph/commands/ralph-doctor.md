---
name: ralph-doctor
description: Check and repair Ralph project health
args:
  feature:
    type: string
    description: Feature name to check (optional, defaults to current)
    required: false
---

Run a health check on a Ralph feature and fix common issues.

## Tasks

1. **Locate the feature**
   - If `feature` arg provided, check `.ralph/{feature}/`
   - Otherwise, scan `.ralph/` for directories
   - If multiple features found, ask which one to check
   - If no features found, show error and suggest `/ralph-new`

2. **Validate file structure**
   Check that all required files exist:
   - `.ralph/{feature}/plan.md` - Feature specification
   - `.ralph/{feature}/prd.json` - Stories with status
   - `.ralph/{feature}/progress.txt` - Work log

   Note: `claude.md` is no longer used (agent-based architecture).

   Report any missing files.

3. **Validate prd.json structure**
   Check that `prd.json` has:
   - Valid JSON syntax
   - `stories` array
   - Each story has: id, title, steps, passes, dependencies, priority, status
   - Valid status values: "not_started", "in_progress", "completed", "blocked"

   Report any issues found.

4. **Check for stale or blocked stories**
   - Count stories by status
   - Identify stories marked "blocked" and show their blockers
   - Identify stories with "in_progress" status but no recent STARTED timestamp in progress.txt

   These may indicate crashed iterations or forgotten work.

5. **Verify git branch**
   - Check if current branch matches the feature name pattern
   - Warn if on main/master branch (Ralph should work on feature branches)

6. **Check for orphaned files**
   - Look for old `ralph.sh` or `claude.md` files (from old bash-based architecture)
   - Offer to remove them

7. **Report and offer fixes**
   Provide a clear report:
   ```
   🏥 Ralph Doctor Report: {feature}

   ✅ File structure: OK
   ✅ prd.json: Valid (12 stories, 7 complete, 1 blocked, 4 pending)
   ⚠️  Git branch: Currently on 'main' (recommend feature branch)
   ⚠️  Orphaned files: claude.md, ralph.sh (old architecture)

   Issues Found:
   1. Story FEAT-005 blocked: "Waiting for API keys"
   2. Working on main branch - recommend: git checkout -b {feature}
   3. Old architecture files present - can be removed

   Recommended Actions:
   - Resolve blocker for FEAT-005
   - Create feature branch
   - Remove orphaned files
   ```

8. **Auto-fix options**
   Offer to automatically fix issues:
   - Create proper feature branch and switch to it
   - Remove orphaned files from old bash architecture
   - Fix malformed prd.json (if possible)

   Ask user which fixes to apply, then execute them.

9. **Summary**
    End with next steps:
    - If healthy: "✅ Ralph project is healthy! Run /ralph-continue or /ralph-run to resume work."
    - If fixed: "✅ Issues fixed! Run /ralph-doctor again to verify, then /ralph-continue to resume."
    - If issues remain: "⚠️  Manual intervention needed. See report above."

## Example Output

```
🏥 Running Ralph Doctor...

Found feature: hypersketcher-mvp

📋 Checking file structure...
✅ plan.md exists
✅ prd.json exists
✅ progress.txt exists
⚠️  Found orphaned files: claude.md, ralph.sh (old architecture)

🔍 Analyzing prd.json...
✅ Valid JSON structure
📊 Stories: 15 total (8 complete, 1 in_progress, 1 blocked, 5 pending)
⚠️  Blocked story: MVP-009 - "Need design assets for landing page"

🔍 Checking git status...
⚠️  Currently on branch 'main' (recommend feature branch)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issues found: 2

1. Old architecture files present
   - claude.md (no longer used)
   - ralph.sh (replaced by agent orchestration)

2. Working on main branch
   - Ralph should work on feature branches
   - Prevents accidental commits to main

Auto-fixable: Yes

Would you like me to:
1. Remove orphaned files (claude.md, ralph.sh)
2. Create and switch to feature branch 'hypersketcher-mvp'

Apply fixes? (yes/no)
```

## Orphaned File Detection

Ralph now uses agent orchestration (ralph-executor + ralph-story-worker). The old bash-based architecture used:
- `claude.md` - Workflow instructions for bash loop
- `ralph.sh` - Bash script

These files are no longer needed and can be safely removed. The new architecture uses:
- Agents defined in plugin (ralph-executor, ralph-story-worker)
- Commands that spawn agents (/ralph-run, /ralph-continue)
- State persisted in prd.json and progress.txt

## Notes

- This command is safe to run anytime - it only reads and reports by default
- Always ask before making changes (removing files, creating branches, etc.)
- If user says yes to fixes, apply them and re-run the health check to confirm
- The new agent-based architecture is simpler - no bash scripts needed

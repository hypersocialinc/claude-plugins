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
   - `.ralph/{feature}/claude.md` - Workflow instructions
   - `.ralph/{feature}/plan.md` - Feature specification
   - `.ralph/{feature}/prd.json` - Stories with status
   - `.ralph/{feature}/progress.txt` - Work log
   - `.ralph/{feature}/ralph.sh` - Bash loop script

   Report any missing files.

3. **Check ralph.sh version**
   Read the current `ralph.sh` and check if it has the location-agnostic code:
   - Look for "PROJECT_ROOT" variable
   - Look for "cd \"\$PROJECT_ROOT\"" line

   If missing, offer to update it with the latest template from `${CLAUDE_PLUGIN_ROOT}/templates/ralph.sh`

4. **Validate prd.json structure**
   Check that `prd.json` has:
   - Valid JSON syntax
   - `stories` array
   - Each story has: id, title, steps, passes, dependencies, priority, status
   - Valid status values: "not_started", "in_progress", "completed", "blocked"

   Report any issues found.

5. **Check for stale or blocked stories**
   - Count stories by status
   - Identify stories marked "blocked" and show their blockers
   - Identify stories with "in_progress" status but no recent STARTED timestamp

   These may indicate crashed iterations or forgotten work.

6. **Verify git branch**
   - Check if current branch matches the feature name pattern
   - Warn if on main/master branch (Ralph should work on feature branches)

7. **Test script execution**
   Check if `ralph.sh` is executable:
   ```bash
   test -x .ralph/{feature}/ralph.sh
   ```
   If not, offer to fix permissions: `chmod +x .ralph/{feature}/ralph.sh`

8. **Report and offer fixes**
   Provide a clear report:
   ```
   🏥 Ralph Doctor Report: {feature}

   ✅ File structure: OK
   ⚠️  ralph.sh: Outdated (missing location-agnostic code)
   ✅ prd.json: Valid (12 stories, 7 complete, 1 blocked, 4 pending)
   ⚠️  Git branch: Currently on 'main' (recommend feature branch)
   ✅ Permissions: ralph.sh is executable

   Issues Found:
   1. ralph.sh is outdated - should support running from anywhere
   2. Story FEAT-005 blocked: "Waiting for API keys"
   3. Working on main branch - recommend: git checkout -b {feature}

   Recommended Actions:
   - Update ralph.sh to latest version
   - Resolve blocker for FEAT-005
   - Create feature branch
   ```

9. **Auto-fix options**
   Offer to automatically fix issues:
   - Update ralph.sh to latest template
   - Fix file permissions
   - Create proper feature branch and switch to it

   Ask user which fixes to apply, then execute them.

10. **Summary**
    End with next steps:
    - If healthy: "✅ Ralph project is healthy! Run /ralph-continue or /ralph-run to resume work."
    - If fixed: "✅ Issues fixed! Run /ralph-doctor again to verify, then /ralph-continue to resume."
    - If issues remain: "⚠️  Manual intervention needed. See report above."

## Example Output

```
🏥 Running Ralph Doctor...

Found feature: hypersketcher-mvp

📋 Checking file structure...
✅ claude.md exists
✅ plan.md exists
✅ prd.json exists
✅ progress.txt exists
⚠️  ralph.sh exists but is outdated

🔍 Analyzing prd.json...
✅ Valid JSON structure
📊 Stories: 15 total (8 complete, 1 in_progress, 1 blocked, 5 pending)
⚠️  Blocked story: MVP-009 - "Need design assets for landing page"

🔍 Checking git status...
⚠️  Currently on branch 'main' (recommend feature branch)

🔍 Checking permissions...
✅ ralph.sh is executable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issues found: 2

1. ralph.sh is outdated
   - Missing location-agnostic code
   - Can't run from inside .ralph/hypersketcher-mvp/

2. Working on main branch
   - Ralph should work on feature branches
   - Prevents accidental commits to main

Auto-fixable: Yes

Would you like me to:
1. Update ralph.sh to latest version
2. Create and switch to feature branch 'hypersketcher-mvp'

Apply fixes? (yes/no)
```

## Notes

- This command is safe to run anytime - it only reads and reports by default
- Always ask before making changes (updating files, creating branches, etc.)
- Keep a backup of ralph.sh before updating: `.ralph/{feature}/ralph.sh.bak`
- If user says yes to fixes, apply them and re-run the health check to confirm

---
name: ralph-status
description: Check Ralph feature progress
---

# Ralph Status

Show current progress of the active Ralph feature without executing any work.

## Process

### 1. Find Active Feature

Look for `.ralph/` directory with a feature folder.

If not found:
```
No active Ralph feature found.
Run /ralph-new <feature-name> to start one.
```

### 2. Read Files

From `.ralph/<feature>/`:
- `prd.json` - story statuses
- `progress.txt` - last activity
- `plan.md` - feature summary

### 3. Calculate Stats

From `prd.json`:
- Total stories: count of stories array
- Completed: count where `status === "completed"`
- In progress: count where `status === "in_progress"`
- Blocked: count where `status === "blocked"`
- Not started: count where `status === "not_started"`
- Progress percentage: (completed / total) * 100

From `progress.txt`:
- Last completed story: find last `COMPLETED: <id>` entry
- Last activity time: parse timestamp from last entry
- Check for incomplete: `STARTED` without `COMPLETED`

### 4. Display Status

```
Ralph: <feature-name>
Branch: ralph/<feature-name>
Progress: <completed>/<total> stories (<percentage>%)

Status Breakdown:
✅ Completed: <count>
🔄 In Progress: <count>
⚠️  Blocked: <count>
⏸️  Not Started: <count>

Last Activity:
<Last entry from progress.txt - show 3-5 lines>

{{If incomplete story exists:}}
⚠️  Crash detected: Story <id> was started but not completed
Run /ralph-next to resume

{{If any blocked stories:}}
Blocked Stories:
- <id>: <title>
  Blocker: <reason from blockers array>
  Dependencies: <list from dependencies array>

{{If all complete:}}
✅ All stories complete!
Run /ralph-done to archive and create PR.

Next Actions:
{{If not all complete:}}
- /ralph-next - Do next story interactively
- /ralph-run - Start autonomous loop
- /ralph-abandon - Give up on this feature

{{If all complete:}}
- /ralph-done - Archive and create PR
```

### 5. Check if Running

If `.ralph/<feature>/ralph.pid` exists:
```bash
if ps -p $(cat .ralph/<feature>/ralph.pid) > /dev/null 2>&1; then
  echo "🔄 Ralph loop is currently running"
  echo "PID: $(cat .ralph/<feature>/ralph.pid)"
  echo "Monitor: tail -f .ralph/<feature>/output.log"
fi
```

## Example Output

```
Ralph: auth-system
Branch: ralph/auth-system
Progress: 7/12 stories (58%)

Status Breakdown:
✅ Completed: 7
🔄 In Progress: 0
⚠️  Blocked: 1
⏸️  Not Started: 4

Last Activity:
=== 2024-01-15 14:23 ===
COMPLETED: AUTH-007 at 2024-01-15T14:23:45Z
Story: AUTH-007
Title: Add password reset flow
Action: Implemented password reset with email verification
Result: COMPLETED
Commit: a3f8c9d
Next: AUTH-008

Blocked Stories:
- AUTH-011: OAuth integration
  Blocker: Waiting for API keys
  Dependencies: AUTH-010

Next Actions:
- /ralph-next - Do next story (AUTH-008)
- /ralph-run - Start autonomous loop
- /ralph-abandon - Give up on this feature
```

## Error Handling

If files are corrupted or missing:
```
Error: Could not read Ralph files

Missing or corrupted:
- .ralph/<feature>/prd.json
- .ralph/<feature>/progress.txt

Try:
- /ralph-abandon to clean up
- /ralph-new <feature> to start fresh
```

## Important Notes

- This is read-only - doesn't modify any files
- Fast check without executing work
- Good for monitoring autonomous loops
- Shows what /ralph-next would do next

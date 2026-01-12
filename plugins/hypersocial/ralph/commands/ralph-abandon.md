---
name: ralph-abandon
description: Abandon Ralph feature and clean up
---

# Ralph Abandon

Give up on the current Ralph feature and clean up tracking files.

## Process

### 1. Find Active Feature

Look for `.ralph/<feature>/` directory.

If not found:
```
No active Ralph feature found.
Nothing to abandon.
```

### 2. Show Status

Read `.ralph/<feature>/prd.json` for context:
- Feature name
- Total stories
- Completed count
- Progress percentage

```
Ralph feature: <feature-name>
Progress: <completed>/<total> stories (<percentage>%)

Branch: ralph/<feature-name>
```

### 3. Confirm Abandonment

Ask for confirmation:

```
⚠️  Abandon this feature?

This will:
- Delete .ralph/<feature-name>/ directory
- Keep the branch ralph/<feature-name> (you can delete it manually)
- Keep any commits made
- Lose all tracking/progress data

This cannot be undone.

Options:
1. Yes, abandon it
2. No, keep it
```

Use AskUserQuestion.

If "No", exit.

### 4. Stop Running Loop (if exists)

Check if `ralph.sh` is running:

```bash
if [ -f .ralph/<feature>/ralph.pid ]; then
  PID=$(cat .ralph/<feature>/ralph.pid)
  if ps -p $PID > /dev/null 2>&1; then
    kill $PID
    echo "Stopped running Ralph loop (PID: $PID)"
  fi
fi
```

### 5. Delete Ralph Directory

```bash
rm -rf .ralph/<feature>
```

### 6. Output Cleanup Instructions

```
✅ Abandoned Ralph feature: <feature-name>

Cleaned up:
- .ralph/<feature-name>/ (deleted)

Branch ralph/<feature-name> still exists with commits.

To delete the branch:
git branch -D ralph/<feature-name>

To switch back to main:
git checkout main
```

## Error Handling

If directory doesn't exist:
```
Error: .ralph/<feature-name>/ not found

Already abandoned or never existed.
```

If can't delete directory:
```
Error: Failed to delete .ralph/<feature-name>/

Permission error or files in use.
Try manually: rm -rf .ralph/<feature-name>
```

## Important Notes

- This is destructive - can't undo
- Always confirms before deleting
- Stops running loops automatically
- Keeps the git branch (user can delete manually)
- Keeps any commits that were made
- Only deletes the .ralph tracking directory

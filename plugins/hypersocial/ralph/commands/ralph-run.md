---
name: ralph-run
description: Start Ralph autonomous loop (bash wrapper)
arguments:
  - name: max-iterations
    description: Maximum number of stories to complete (default 20)
    required: false
---

# Ralph Run

Start the autonomous Ralph loop that runs until all stories are complete or blocked.

## Process

### 1. Find Active Feature

Look for `.ralph/` directory with a feature folder.

If not found:
```
No active Ralph feature found.
Run /ralph-new <feature-name> first.
```

### 2. Check ralph.sh Exists

Verify `.ralph/<feature>/ralph.sh` exists and is executable.

If not executable:
```bash
chmod +x .ralph/<feature>/ralph.sh
```

### 3. Show Options

Ask user how they want to run it:

```
Ralph autonomous loop for: <feature-name>

How do you want to run it?

A) Let Claude run it in background
   - Runs in background
   - Check progress with /ralph-status
   - View logs: tail -f .ralph/<feature>/output.log

B) I'll run it manually in terminal
   - Full control
   - Watch each iteration
   - Command: ./.ralph/<feature>/ralph.sh <max-iterations>

C) Cancel
```

Use AskUserQuestion with these options.

### 4A. Run in Background (Option A)

If they choose background:

```bash
cd <project-root>
nohup ./.ralph/<feature>/ralph.sh <max-iterations> > .ralph/<feature>/output.log 2>&1 &
echo $! > .ralph/<feature>/ralph.pid
```

Output:
```
🚀 Ralph running in background

PID: <pid>
Log: .ralph/<feature>/output.log
Max iterations: <max-iterations>

Monitor progress:
- tail -f .ralph/<feature>/output.log (live log)
- /ralph-status (check story completion)

Stop it:
- kill $(cat .ralph/<feature>/ralph.pid)
- Or just close terminal

When complete, run /ralph-done to archive and create PR.
```

### 4B. Manual Run (Option B)

If they choose manual:

Output:
```
Run this in your terminal:

cd <absolute-project-path>
./.ralph/<feature>/ralph.sh <max-iterations>

The loop will:
- Execute one story per iteration
- Fresh Claude context each time
- Stop when all stories done or blocked
- Show progress after each story

When complete, run /ralph-done to archive and create PR.
```

### 4C. Cancel (Option C)

Just exit, no action.

## Max Iterations

Default: 20

User can specify:
```
/ralph-run 50
```

This means "do up to 50 stories max" (safety limit).

## Error Handling

If ralph.sh doesn't exist:
```
Error: ralph.sh not found in .ralph/<feature>/

This feature might not be properly initialized.
Try:
1. /ralph-abandon to clean up
2. /ralph-new <feature> to start fresh
```

If can't start background process:
```
Error: Failed to start ralph.sh in background

Try running it manually in terminal:
./.ralph/<feature>/ralph.sh <max-iterations>
```

## Important Notes

- The bash loop calls `claude --dangerously-skip-permissions -p "$(cat claude.md)"`
- Each iteration is a fresh Claude context
- State persists only through files (prd.json, progress.txt)
- Loop stops on `RALPH_COMPLETE` or `RALPH_BLOCKED` signals
- User can monitor with `tail -f .ralph/<feature>/output.log`
- User can stop anytime with Ctrl+C (manual) or kill PID (background)

## Monitoring

Suggest these monitoring commands:

```bash
# Live log
tail -f .ralph/<feature>/output.log

# Check progress
/ralph-status

# Check if still running
ps aux | grep ralph.sh

# Stop it
kill $(cat .ralph/<feature>/ralph.pid)
```

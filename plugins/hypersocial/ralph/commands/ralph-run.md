---
name: ralph-run
description: Start Ralph autonomous loop using agent orchestration
arguments:
  - name: max-iterations
    description: Maximum number of stories to complete (default 20)
    required: false
---

# Ralph Run

Start the autonomous Ralph loop that executes stories sequentially until complete or blocked.

## Process

### 1. Find Active Feature

Look for `.ralph/` directory with a feature folder.

If not found:
```
❌ No active Ralph feature found.
Run /ralph-new <feature-name> first.
```

If multiple features found, list them and ask which to run.

### 2. Parse Max Iterations

Default: 20 stories max

If user provided argument:
```
/ralph-run 50
```
Use 50 as max_iterations.

### 3. Show Confirmation

Before starting, show a confirmation:

```
🚀 Starting Ralph autonomous loop

Feature: <feature-name>
Max iterations: <max-iterations>

Ralph will:
✓ Execute stories one at a time
✓ Fresh context for each story
✓ Review code before every commit
✓ Stop when complete or blocked
✓ Show progress as it works

Continue? (yes/no)
```

Use AskUserQuestion to get confirmation.

If no: Exit gracefully.

### 4. Launch Executor Agent

Use the Task tool to spawn the ralph-executor agent:

```
Task(
  subagent_type: "ralph-executor",
  prompt: "Execute Ralph feature '{feature}' with max {max_iterations} iterations",
  description: "Ralph autonomous loop: {feature}",
  run_in_background: false  // Run in foreground so user sees progress
)
```

The executor agent will:
- Read prd.json for current state
- Pick next story based on priority + dependencies
- Spawn ralph-story-worker agent for that story (fresh context)
- Wait for worker completion
- Update state files
- Repeat until done/blocked/max iterations

### 5. Handle Executor Result

The executor agent will output one of these signals:

**RALPH_COMPLETE:**
```
✅ Ralph Complete!

Feature: {feature}
Stories: {completed}/{total} completed
Commits: {count}

The feature is ready for review.

Next steps:
- Review commits: git log
- Run tests: npm test
- Create PR: /ralph-done
```

**RALPH_BLOCKED:**
```
⚠️  Ralph Blocked

Feature: {feature}
Progress: {completed}/{total} stories

Blocker: {reason from executor}

To continue:
1. Resolve the blocker (check progress.txt for details)
2. Run /ralph-run to resume
```

**RALPH_PAUSED:**
```
⏸️  Ralph Paused

Feature: {feature}
Progress: {completed}/{total} stories
Max iterations ({max_iterations}) reached

Next story: {story_id} - {title}

To continue: /ralph-run
To check status: /ralph-status
```

**RALPH_ERROR:**
```
❌ Ralph Error

Feature: {feature}

Error: {error message}

Check .ralph/{feature}/progress.txt for details.

To fix:
1. Resolve the error
2. Run /ralph-doctor to check health
3. Run /ralph-run to retry
```

### 6. Final Guidance

After executor completes, remind user:

```
Monitoring:
- Check status: /ralph-status
- View progress: cat .ralph/{feature}/progress.txt
- See commits: git log

Troubleshooting:
- Health check: /ralph-doctor
- Help: /ralph-help
```

## Example Usage

```
# Default (20 stories max)
/ralph-run

# Custom limit
/ralph-run 50

# Do just one story (same as /ralph-next)
/ralph-run 1
```

## Max Iterations Safety

The max_iterations parameter is a safety limit to prevent runaway execution:
- **Default 20** - good for most features (8-15 stories)
- **Lower for testing** - Use 5 to test first few stories
- **Higher for large features** - Use 50+ for features with 30+ stories

The loop stops early if:
- All stories completed (RALPH_COMPLETE)
- Story blocked (RALPH_BLOCKED)
- Error encountered (RALPH_ERROR)

## Advantages Over Bash Loop

✅ **No terminal required** - Runs entirely in Claude Code
✅ **Fresh context per story** - Each story worker gets clean context
✅ **Better visibility** - See progress in Claude Code UI
✅ **Crash recovery** - Just re-run /ralph-run
✅ **Cleaner architecture** - Pure agent orchestration

## Background Execution

To run Ralph in the background while you do other work:

```
# NOT IMPLEMENTED YET
# Future: run_in_background: true in Task call
# For now, run in separate Claude Code window
```

## Error Handling

If Task tool fails to spawn executor:
```
❌ Failed to start Ralph executor

This might be a plugin issue.
Try:
1. /ralph-doctor to check health
2. Update plugin: /plugins update hypersocial-plugins
3. Retry: /ralph-run
```

If feature not found:
```
❌ Feature directory not found

Expected: .ralph/{feature}/
Found: [list directories in .ralph/]

Run /ralph-new {feature} to create it.
```

## Important Notes

- Each story gets **fresh context** via Task tool spawning new agent
- State persists in **prd.json** (story status) and **progress.txt** (log)
- Executor orchestrates, **workers implement** - clean separation
- Loop is **crash-safe** - re-running /ralph-run resumes from current state
- Use **TodoWrite** in executor so user sees which story is active
- Executor waits for each worker to complete before spawning next one (**sequential**, not parallel)

## Monitoring Progress

While Ralph runs, you can check progress:
- Watch the executor agent's output in Claude Code
- It will show TodoWrite updates for each story
- Workers will show their implementation progress
- All output visible in the conversation

After completion:
- `/ralph-status` - Summary of completed/remaining stories
- `cat .ralph/{feature}/progress.txt` - Detailed log with patterns learned
- `git log` - See commits made by Ralph

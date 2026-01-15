---
name: ralph-go
description: Start Ralph autonomous loop via terminal script or current session
arguments: []
---

# Ralph Go

Start Ralph autonomous execution with your choice of mode: terminal script or interactive session.

## What This Does

Ralph-go replaces `/ralph-run` with a flexible execution mode that lets you choose:

**Terminal Script Mode:**
- Runs `.ralph/{feature}/ralph-go.sh` in your terminal
- Loops until all stories complete
- Can background, redirect output, integrate with CI/CD
- Pure bash, works outside Claude Code

**Autonomous Session Mode:**
- Runs in Claude Code like the old `/ralph-run`
- Real-time progress visibility in UI
- Executes up to 20 stories (configurable)
- Interactive, can see each story as it happens

## Process

### 1. Find Active Feature

Look for `.ralph/` directory with a feature folder.

If not found:
```
❌ No active Ralph feature found.
Run /ralph-new <feature-name> first.
```

If multiple features found, list them and ask which to run.

### 2. Show Current Status

Read `.ralph/{feature}/prd.json` to show progress:

```
📊 Ralph Status: {feature}

Total stories: {total}
Completed: {completed} ✅
Blocked: {blocked} ⚠️
Pending: {pending} ⏳

Ready to start autonomous execution.
```

### 3. Ask User for Execution Mode

Use AskUserQuestion to present the choice:

```
How would you like to run Ralph?
```

**Option 1: Terminal Script (Recommended for CI/CD)**
```
Runs .ralph/{feature}/ralph-go.sh in terminal

✓ Loops until all stories complete
✓ Can background (ctrl+z, bg)
✓ Works outside Claude Code
✓ Integrate with automation/CI

Default: 20 iterations max
Override: ./ralph-go.sh 50
```

**Option 2: Autonomous (Current Session)**
```
Runs in Claude Code like /ralph-run

✓ Real-time UI progress
✓ See each story as it executes
✓ TodoWrite tracking
✓ Interactive experience

Max iterations: 20 stories
```

### 4. Execute Based on Choice

#### Option 1: Terminal Script

**Step A: Check if script exists**

Look for `.ralph/{feature}/ralph-go.sh`

If NOT found:
```
Script not found. Generating from template...

📝 Creating ralph-go.sh
```

Generate the script (same as `/ralph-new` would):

1. Read template: `${CLAUDE_PLUGIN_ROOT}/templates/ralph-go.sh`
2. Replace variables:
   - `{{FEATURE_NAME}}` → feature name
   - `{{DATE}}` → current ISO timestamp
3. Write to: `.ralph/{feature}/ralph-go.sh`
4. Make executable: `chmod +x .ralph/{feature}/ralph-go.sh`

```
✓ Script generated: .ralph/{feature}/ralph-go.sh
```

**Step B: Run the script**

Execute the script using Bash tool (foreground, stream output):

```bash
cd .ralph/{feature} && ./ralph-go.sh
```

Show output to user in real-time.

**Step C: Handle completion**

After script finishes:

```
✅ Ralph-go script completed

Check results:
- git log              # Review commits
- cat progress.txt     # See detailed log
- /ralph-status        # Summary

If blocked:
- Resolve issue
- Run /ralph-go again (resumes)

If complete:
- /ralph-done to create PR
```

#### Option 2: Autonomous (Current Session)

**Step A: Confirmation**

Show what will happen:

```
🚀 Starting Ralph Autonomous Mode

Feature: {feature}
Max iterations: 20 stories
Estimated time: {estimate based on story count}

Ralph will:
✓ Execute stories sequentially
✓ Fresh context per story
✓ Code review before each commit
✓ Stop when complete or blocked

Continue?
```

Use AskUserQuestion for confirmation (Yes/No).

If No: Exit gracefully.

**Step B: Launch Executor Agent**

Use the Task tool to spawn ralph-executor:

```
Task(
  subagent_type: "ralph:ralph-executor",
  prompt: "Execute Ralph feature '{feature}' with max 20 iterations",
  description: "Ralph autonomous loop: {feature}",
  run_in_background: false
)
```

The executor will:
1. Read prd.json for current state
2. Pick next story (priority + dependencies)
3. Spawn ralph-story-worker (fresh context)
4. Wait for completion
5. Update state files
6. Repeat until done/blocked/max iterations

**Step C: Handle Executor Result**

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
1. Resolve the blocker (check progress.txt)
2. Run /ralph-go to resume
```

**RALPH_PAUSED:**
```
⏸️  Ralph Paused

Feature: {feature}
Progress: {completed}/{total} stories
Max iterations (20) reached

Next story: {story_id} - {title}

To continue: /ralph-go
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
3. Run /ralph-go to retry
```

## When to Use Which Mode

### Terminal Script Mode

**Use when:**
- Running in CI/CD pipeline
- Want to background the execution
- Need to redirect output to logs
- Running on remote server
- Want it to run until complete (100+ stories)

**Example workflows:**
```bash
# Standard execution
cd .ralph/my-feature && ./ralph-go.sh

# Custom max iterations
./ralph-go.sh 20

# Background with log
./ralph-go.sh > ralph.log 2>&1 &

# In tmux/screen for long features
tmux new -s ralph
./ralph-go.sh
# Detach: ctrl+b, d
```

### Autonomous Session Mode

**Use when:**
- Working interactively in Claude Code
- Want to see real-time progress
- Prefer UI-based feedback
- Running medium-sized features (up to 20 stories)
- Want TodoWrite tracking

**Example workflow:**
```
/ralph-go
→ Choose "Autonomous (Current Session)"
→ See stories execute in real-time
→ Get completion notification
```

## Advantages Over /ralph-run

✅ **Flexibility** - Choose terminal or interactive
✅ **CI/CD Ready** - Script works in automation
✅ **One Command** - Replaces /ralph-run with more options
✅ **Clearer** - Name implies "start execution"
✅ **Same Power** - All the features of /ralph-run plus more

## Migration from /ralph-run

If you were using `/ralph-run`:

**Old:**
```
/ralph-run
```

**New:**
```
/ralph-go
→ Choose "Autonomous (Current Session)"
```

Same behavior, same output, just with an initial choice prompt.

## Script Details

The generated `ralph-go.sh` script:

**What it does:**
- Loops calling `/ralph-next` (one story per iteration)
- Checks for RALPH_COMPLETE/RALPH_BLOCKED signals
- Exits appropriately based on result

**Max iterations:**
- Default: 100 (high for "run until complete")
- Override: `./ralph-go.sh 20`

**Exit codes:**
- 0: Success (all complete)
- 1: Error or blocked

**Location:**
- `.ralph/{feature}/ralph-go.sh`
- Generated by `/ralph-new`
- Can be regenerated if deleted

## Example: Full Workflow

### Terminal Script Workflow

```bash
# 1. Create feature
claude /ralph-new my-feature

# 2. Review plan
cat .ralph/my-feature/plan.md

# 3. Run via script
cd .ralph/my-feature
./ralph-go.sh

# 4. (Script runs autonomously...)
# 5. (All stories complete)

# 6. Create PR
claude /ralph-done
```

### Interactive Workflow

```
# 1. Create feature
/ralph-new my-feature

# 2. Review plan
Read .ralph/my-feature/plan.md

# 3. Run autonomous
/ralph-go
→ Choose "Autonomous (Current Session)"

# 4. (Watch stories execute in real-time)
# 5. (All stories complete)

# 6. Create PR
/ralph-done
```

### Hybrid Workflow

```
# 1. Create feature
/ralph-new my-feature

# 2. Validate first 2 stories manually
/ralph-next  # Story 1
/ralph-next  # Story 2

# 3. Go autonomous via script for remaining
/ralph-go
→ Choose "Terminal Script"

# 4. (Script handles remaining stories)
# 5. Create PR
/ralph-done
```

## Important Notes

- **Replaces /ralph-run** - Same autonomous execution, more flexibility
- **Fresh context per story** - Whether script or interactive
- **Same crash recovery** - Can re-run after interruption
- **Same code review gates** - All stories reviewed before commit
- **Script is optional** - Both modes work great

## Troubleshooting

**Script not found:**
- Run `/ralph-go` and choose "Terminal Script"
- It will generate the script automatically

**Claude CLI not found in script:**
- Install: https://docs.anthropic.com/cli
- Or use "Autonomous" mode instead

**Want to stop mid-execution:**
- Terminal script: ctrl+c
- Autonomous mode: Interrupt agent
- Both are crash-safe - re-run to resume

**Script vs Autonomous choice every time:**
- This is intentional - flexibility
- If you know which you want:
  - Terminal: just run `./ralph-go.sh` directly
  - Autonomous: /ralph-next in a loop (or wait for /ralph-go --autonomous flag in future)

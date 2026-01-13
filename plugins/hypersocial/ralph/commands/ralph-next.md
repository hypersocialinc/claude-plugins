---
name: ralph-next
description: Execute one Ralph story interactively
---

# Ralph Next

Execute the next Ralph story interactively. This is the manual mode - complete one story, then stop.

## What This Does

This is equivalent to `/ralph-run 1` - it executes exactly ONE story, then stops.

Use this when you want:
- Manual control over each story
- To validate the plan with first few stories
- To review code after each story
- Step-by-step progress instead of autonomous loop

## Process

### 1. Find Active Feature

Look for `.ralph/` directory with a feature folder.

If not found:
```
❌ No active Ralph feature found.
Run /ralph-new <feature-name> first.
```

If multiple features found, list them and ask which to continue.

### 2. Check Current State

Read `.ralph/{feature}/prd.json` to show progress:

```
📊 Ralph Status: {feature}

Total stories: {total}
Completed: {completed} ✅
In progress: {in_progress} 🔄
Blocked: {blocked} ⚠️
Pending: {pending} ⏳

Next story: {story_id} - {title}
```

### 3. Launch Executor for One Story

Use the Task tool to spawn ralph-executor with max_iterations=1:

```
Task(
  subagent_type: "ralph-executor",
  prompt: "Execute Ralph feature '{feature}' with max 1 iterations",
  description: "Ralph continue: {feature}",
  run_in_background: false
)
```

The executor will:
1. Pick the next story (priority + dependencies)
2. Spawn ralph-story-worker agent (fresh context)
3. Wait for worker to complete the story
4. Return result

### 4. Handle Result

**STORY_COMPLETE:**
```
✅ Story {story_id} Complete

Title: {title}
Commit: {commit_hash}
Patterns learned: {count}

Progress: {completed+1}/{total} stories

Next story: {next_story_id} - {next_story_title}

To continue: /ralph-next
To go autonomous: /ralph-run
To check status: /ralph-status
```

**STORY_BLOCKED:**
```
⚠️  Story {story_id} Blocked

Reason: {blocker_reason}

This story cannot proceed until:
{blocker details from progress.txt}

Options:
1. Resolve the blocker manually
2. Update prd.json to skip this story
3. Run /ralph-status for full context
```

**STORY_ERROR:**
```
❌ Story {story_id} Failed

Error: {error_message}

Check .ralph/{feature}/progress.txt for details.

Options:
1. Fix the error manually
2. Run /ralph-doctor to diagnose
3. Run /ralph-next to retry
```

**ALL_COMPLETE:**
```
✅ All Stories Complete!

Feature: {feature}
Total stories: {total} ✅
Total commits: {count}

The feature is ready for review.

Next steps:
- Review commits: git log
- Run tests: npm test
- Create PR: /ralph-done
```

### 5. Guidance

After each story, remind user of options:

```
What's next?

- Continue: /ralph-next (do next story)
- Go autonomous: /ralph-run (finish all stories)
- Check status: /ralph-status
- Review work: git log
- Test it: npm test
- Done: /ralph-done (create PR)
```

## Example Workflow

```
# Start feature
/ralph-new user-auth

# Do first story manually
/ralph-next
→ Story AUTH-001 complete

# Do second story manually
/ralph-next
→ Story AUTH-002 complete

# Looks good, go autonomous
/ralph-run
→ Completes remaining 10 stories

# Done
/ralph-done
```

## Advantages

✅ **Control** - Review after each story
✅ **Learning** - Understand what Ralph does
✅ **Validation** - Catch plan issues early
✅ **Fresh context** - Each story gets clean slate
✅ **Interruptible** - Stop anytime, resume later

## When to Use This vs /ralph-run

**Use /ralph-next when:**
- First time using Ralph on this project
- Want to validate the plan before going autonomous
- Complex/sensitive feature requiring oversight
- Learning how Ralph works

**Use /ralph-run when:**
- Plan is validated (first 2-3 stories done via /ralph-next)
- Clear, well-defined stories
- Want to walk away and let it work
- Large feature with many stories

## Fresh Context Per Story

Each `/ralph-next` spawns a NEW ralph-story-worker agent with fresh context via the Task tool.

This means:
- Worker doesn't know about previous stories (except via progress.txt patterns)
- No context bloat across stories
- Can run indefinitely without hitting limits
- Same as /ralph-run, just one story at a time

## Interactive Review

After each story, you can:

```bash
# See what changed
git diff HEAD~1

# Review the commit
git show HEAD

# Check if it works
npm run typecheck
npm test

# Read what was learned
tail -20 .ralph/{feature}/progress.txt
```

Then decide: continue, go autonomous, or stop.

## Error Recovery

If a story fails:
1. Read error from progress.txt
2. Fix the issue manually
3. Run /ralph-next to retry
   - Worker will pick up the same story (crash recovery)
   - Fresh context, new attempt

## Important Notes

- **One story at a time** - Executes exactly one, then stops
- **Same architecture as /ralph-run** - Uses executor + worker agents
- **Fresh context** - Each invocation spawns new agent
- **Crash safe** - Re-running picks up where you left off
- **Equivalent to `/ralph-run 1`** - Just a convenience command

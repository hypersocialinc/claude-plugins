---
name: ralph-continue
description: Continue Ralph feature - execute one story interactively
---

# Ralph Continue

Execute the Ralph workflow for one story cycle in the current session (not autonomous bash loop).

## Process

### 1. Find Active Feature

Look for `.ralph/` directory containing a feature folder.

If not found:
```
No active Ralph feature found.
Run /ralph-new <feature-name> to start one.
```

If found multiple (edge case):
```
Found multiple Ralph features:
- feature-a
- feature-b

Which one to continue? (This shouldn't happen - only one should be active)
```

### 2. Read Context Files

Read these files from `.ralph/<feature>/`:

1. **progress.txt**:
   - Read entire file
   - Note Codebase Patterns section
   - Check for incomplete story (STARTED without COMPLETED)
   - Review recent work

2. **prd.json**:
   - Load all stories
   - Check statuses and dependencies

3. **claude.md**:
   - Review workflow instructions
   - Follow the process defined there

### 3. Pick Next Story

Follow the logic from claude.md:

**Check for crash recovery first:**
- Scan progress.txt for `STARTED: <id> at <timestamp>` without matching `COMPLETED: <id>`
- If found → resume that story (crash recovery)

**Otherwise pick next story:**
- Filter: `status === "not_started"` or `status === "in_progress"`
- Filter: All stories in `dependencies` array have `status === "completed"`
- Sort by `priority` ascending
- Pick first one

**If all stories complete:**
```
✅ All stories complete!
Feature: <name>
Stories: <total> / <total>

Run /ralph-done to archive and create PR.
```

**If no story available (all blocked):**
```
⚠️  No stories available - all blocked

Blocked stories:
- <id>: <title> (waiting on <dependency-id>)
- <id>: <title> (blocker: <reason>)

Resolve blockers or run /ralph-abandon to give up.
```

### 4. Execute Story

Show which story you're working on:
```
📝 Working on: <story-id>
Title: <story-title>

Steps:
1. <step 1>
2. <step 2>
...
```

#### 4.1 Log Start
Append to `.ralph/<feature>/progress.txt`:
```
STARTED: <story-id> at <ISO timestamp>
```

#### 4.2 Update Status
In `.ralph/<feature>/prd.json`, update:
```json
{
  "id": "<story-id>",
  "status": "in_progress",
  ...
}
```

#### 4.3 Implement
Follow the story's `steps` array. Implement the changes.

#### 4.4 Verify
- Run typecheck (detect from package.json: `npm run typecheck`, `bun typecheck`, etc.)
- Run tests if they exist
- Verify all items in story's `passes` array

#### 4.5 Review
Launch review agents in parallel using Task tool:
```
Task tool (parallel):
  1. subagent: code-reviewer
  2. subagent: silent-failure-hunter
```

If issues found:
- Fix them
- Re-verify
- Re-review
- Repeat until clean

#### 4.6 Commit Code
```bash
git add <files>
git commit -m "feat(<story-id>): <story-title>

<brief description>

Co-Authored-By: Ralph <ralph@hypersocial.com>"
```

#### 4.7 Update Tracking

**prd.json:**
```json
{
  "id": "<story-id>",
  "status": "completed",
  ...
}
```

**progress.txt:**
Append:
```
=== <date> <time> ===
COMPLETED: <story-id> at <ISO timestamp>
Story: <story-id>
Title: <story-title>
Action: <what was implemented>
Result: COMPLETED
Commit: <commit-hash>
Files: <files changed>
Learnings:
  - <pattern discovered>
  - <gotcha>
Next: <next-story-id or "All complete">

---
```

**If new pattern discovered:**
Add to Codebase Patterns section at top of progress.txt

**If permanent pattern:**
Update project's `CLAUDE.md` with the pattern

#### 4.8 Commit Tracking
```bash
git add .ralph/<feature>/
git commit -m "ralph: complete <story-id>"
```

### 5. Output Next Steps

**If more stories remain:**
```
✅ Story complete: <story-id>

Progress: <completed> / <total> stories

Next story: <next-id> - <next-title>

Options:
- /ralph-continue - Do next story now
- /ralph-run - Start autonomous loop
- /ralph-status - Check progress
```

**If all complete:**
```
✅ All stories complete!
Feature: <name>
Stories: <total> / <total>

Run /ralph-done to archive and create PR.
```

## Error Handling

If implementation fails:
- Don't mark story as completed
- Log blocker in progress.txt
- Update story status to `"blocked"`
- Add blocker to story's `blockers` array
- Show blocker to user

## Important Notes

- This is the interactive, one-story-at-a-time mode
- Context stays in current session (no fresh context)
- For autonomous mode, use /ralph-run instead
- Always follow the workflow in claude.md

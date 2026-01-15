---
name: ralph-board
description: Open Ralph dashboard to monitor feature progress
arguments: []
---

# Ralph Board

Open the visual Kanban dashboard to monitor Ralph feature progress in real-time.

## Process

### 1. Find Active Feature

Look for `.ralph/` directory and find the feature folder inside it.

If no feature found:
```
❌ No active Ralph feature found.

Run /ralph-new <feature-name> to start a new feature.
```

If multiple features exist (shouldn't happen, but handle gracefully):
```
Found multiple features:
- feature-1
- feature-2

Please specify which one or run /ralph-abandon to clean up.
```

### 2. Check Board Exists

Check if `.ralph/<feature>/board/index.html` exists.

If NOT exists:
```bash
mkdir -p .ralph/<feature>/board
cp ${CLAUDE_PLUGIN_ROOT}/templates/board.html .ralph/<feature>/board/index.html
```

Output:
```
✅ Created dashboard for <feature>
```

### 3. Open Board in Browser

Use the `open` command (Mac) or equivalent to launch the board:

```bash
open .ralph/<feature>/board/index.html
```

On Linux, try:
```bash
xdg-open .ralph/<feature>/board/index.html
```

On Windows:
```bash
start .ralph/<feature>/board/index.html
```

### 4. Output Instructions

```
✅ Ralph Dashboard opened: <feature>

Dashboard features:
- 📊 Kanban board with 4 columns (Pending, In Progress, Completed, Blocked)
- 📈 Progress bar and stats
- 📋 Story cards with details
- 📝 Recent activity log
- 🔄 Auto-refreshes every 5 seconds

The dashboard reads from:
- .ralph/<feature>/prd.json (story status)
- .ralph/<feature>/progress.txt (activity log)

Keep this window open while Ralph is running to monitor progress.
```

## Important Notes

- Dashboard is read-only - it displays Ralph's state but doesn't control it
- Auto-refreshes every 5 seconds to show latest progress
- Works for both active and archived features
- Board is a single self-contained HTML file with no external dependencies

## Error Handling

**If board file is corrupted:**
```bash
rm .ralph/<feature>/board/index.html
cp ${CLAUDE_PLUGIN_ROOT}/templates/board.html .ralph/<feature>/board/index.html
```

Output:
```
✅ Regenerated board from template
```

**If browser doesn't open:**
```
Dashboard ready at: .ralph/<feature>/board/index.html

Please open this file manually in your browser.
```

## Use Cases

1. **Monitor active Ralph loop**: Open dashboard while `/ralph-run` is executing
2. **Review completed features**: Open dashboard for archived features to see history
3. **Debugging**: Watch story transitions in real-time
4. **Presentations**: Visual way to show Ralph's progress to team

## Dashboard Features

### Kanban Columns
- **Pending** (yellow): Stories not started yet
- **In Progress** (blue, pulsing): Currently executing story
- **Completed** (green): Finished stories with commits
- **Blocked** (red): Stories waiting for dependencies or human input

### Story Cards Show
- Story ID and title
- Priority number
- Dependency count
- Blocker messages (if blocked)
- Click to see full details (steps, passes, dependencies)

### Progress Section
- Overall completion percentage
- Number of stories in each status
- Progress bar

### Recent Activity
- Latest 10 entries from progress.txt
- Timestamps and commit hashes
- STARTED/COMPLETED/ERROR status
- Patterns learned

### Auto-Refresh
- Updates every 5 seconds
- Countdown timer shown
- Manual refresh button available

---
name: ralph-help
description: Show Ralph documentation and usage guide
---

Please explain the following Ralph documentation to the user. Display the entire guide exactly as written below. Do not respond to the user's current project context or analyze their .ralph directories - just present the help documentation:

---

# Ralph - Autonomous Feature Development

Ralph automates feature development with story-based tracking, review gates, and crash recovery.

## What Ralph Does

- Breaks features into bite-sized stories (15-45 minutes each)
- Executes one story at a time with clear verification criteria
- Reviews code before every commit using specialized agents
- Tracks progress in files that survive crashes
- Learns patterns as it works and updates project CLAUDE.md
- Creates pull requests when complete

## Available Commands

| Command | Description |
|---------|-------------|
| `/ralph-help` | Show this help (you are here) |
| `/ralph-new <name>` | Start new feature, create plan + stories |
| `/ralph-continue` | Execute one story interactively |
| `/ralph-run` | Start autonomous loop (bash) |
| `/ralph-status` | Check progress without doing work |
| `/ralph-doctor` | Health check and repair Ralph projects |
| `/ralph-done` | Complete feature, archive, create PR |
| `/ralph-abandon` | Give up and clean up |

## Basic Workflow

```
/ralph-new feature-name
  ↓
[Planning: asks questions, generates stories]
  ↓
/ralph-run (autonomous) or /ralph-continue (manual)
  ↓
[Executor agent spawns story workers sequentially]
  ↓
[Each worker: implement → verify → review → commit]
  ↓
/ralph-done
  ↓
[Archive + PR to main]
```

## File Structure

Ralph creates `.ralph/<feature>/` in your project:

```
.ralph/
└── auth-system/
    ├── plan.md         # Feature spec
    ├── prd.json        # Stories with status
    └── progress.txt    # Work log + patterns
```

When complete, moves to `.ralph-archive/<feature>/`

## Architecture

Ralph uses **agent orchestration** (not bash scripts):
- **/ralph-run** spawns **ralph-executor** agent
- Executor spawns **ralph-story-worker** agents (one per story)
- Each worker gets **fresh context** via Task tool
- State persists in **prd.json** and **progress.txt**

## Usage Examples

### Interactive Mode (Recommended for learning)
```
/ralph-new user-dashboard
→ Answer questions, review plan

/ralph-continue
→ Does story AUTH-001

/ralph-continue
→ Does story AUTH-002

... repeat until done ...

/ralph-done
→ Creates PR
```

### Autonomous Mode (For production)
```
/ralph-new payment-flow

/ralph-run
→ Executor spawns workers sequentially

... watch progress in Claude Code ...

/ralph-status
→ "7/12 stories complete"

/ralph-done
→ Creates PR
```

### From Existing Spec
```
/ralph-new api-redesign --from docs/api-spec.md
→ Uses your spec instead of asking questions

/ralph-run
→ Executes all stories autonomously
```

## Key Features

### Crash Recovery
If Ralph crashes mid-story, it detects the incomplete story and resumes from where it left off (not skipping it).

### Pattern Learning
As Ralph works, it discovers codebase patterns and adds them to `progress.txt`. Each story can reference previous patterns. Project `CLAUDE.md` gets updated with permanent patterns.

### Review Gates
Before every commit:
- Runs `code-reviewer` agent (bugs, style, logic)
- Runs `silent-failure-hunter` agent (error handling)
- If issues found → fix → re-review → repeat
- Only commits when clean

### Story Dependencies
Stories can depend on other stories. Ralph won't start a story until all its dependencies are complete.

## When to Use Ralph

**Good for:**
- Features with clear requirements
- 8-15 independent stories
- Work that can be verified with typecheck/tests
- Features you want done while you sleep

**Not good for:**
- Exploratory work
- Major refactors without clear criteria
- Security-critical code without review
- Vague requirements

## Tips for Success

1. **Start small** - Try a 3-story feature first to learn the workflow
2. **Good passes criteria** - Be specific: "Button shows modal" not "Button works"
3. **Right-sized stories** - 15-45 minutes each, not 5 min or 2 hours
4. **Watch the first few** - Run `/ralph-continue` manually for first 2-3 stories to validate the plan
5. **Review the PRD** - After `/ralph-new`, check `prd.json` before starting the loop
6. **Health checks** - Run `/ralph-doctor` if something seems off or scripts aren't working

## Troubleshooting

**Something feels broken:**
- Run `/ralph-doctor` to check project health
- It will identify and fix common issues automatically

**Ralph gets stuck on a story:**
- Check `/ralph-status` for blockers
- Review the story's passes criteria (too vague?)
- Manually fix the issue, update prd.json, continue

**Agent errors:**
- Run `/ralph-doctor` to check project health
- Ensures prd.json and progress.txt are valid

**Stories too big:**
- Edit `prd.json` manually, break into smaller stories
- Update dependencies

**Wrong order:**
- Edit `prd.json`, adjust priorities and dependencies
- Ralph picks by priority + dependencies

**Want to make changes mid-feature:**
- Edit `prd.json` directly
- Add/remove/modify stories as needed
- Ralph reads it fresh each iteration

## Story Structure Example

Each story in `prd.json`:

```json
{
  "id": "AUTH-001",
  "title": "Create auth types",
  "steps": [
    "Create types/auth.ts",
    "Add User and Session types",
    "Export from index"
  ],
  "passes": [
    "Types compile without errors",
    "Exports work correctly",
    "typecheck passes"
  ],
  "dependencies": [],
  "priority": 1,
  "status": "not_started",
  "blockers": []
}
```

## Getting Started

```
/ralph-new my-feature
→ Follow the prompts
→ Review the generated plan
→ Choose how to run it

Happy shipping! 🚀
```

## More Information

For additional details, see the Ralph skill documentation by typing `/ralph`.

## Architecture Notes

Ralph uses **agent orchestration** instead of bash scripts:
- Each story runs in a **fresh agent** with clean context
- No context bloat across stories
- Can run indefinitely without limits
- Simpler, more reliable than bash loops

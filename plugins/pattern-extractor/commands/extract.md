---
name: extract
description: Extract implementation patterns from GitHub repositories
usage: /extract <pattern-description>
examples:
  - command: /extract clerk authentication
    description: Find how Clerk auth was implemented
  - command: /extract convex mutations with file upload
    description: Find Convex file upload mutation patterns
  - command: /extract stripe subscription setup
    description: Extract Stripe subscription implementation patterns
---

Use the Task tool to spawn the extract-pattern agent:

```
Task(
  subagent_type: "extract-pattern",
  prompt: "{{user_message}}",
  description: "Extract pattern"
)
```

The agent will search GitHub repositories and return structured findings with code snippets, implementation approaches, and documentation links.

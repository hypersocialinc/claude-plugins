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

Use the Task tool to invoke the extract-pattern agent and search for the requested pattern.

**Task Configuration:**
- subagent_type: `extract-pattern`
- description: "Extract pattern"
- prompt: "{{user_message}}"

The agent will search GitHub repositories and return:
- Repos containing the pattern
- Key code snippets with file paths
- Implementation approach
- External documentation
- Recommendations

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

I'll use the extract-pattern agent to search for the requested implementation pattern across GitHub repositories.

The agent will:
1. Search relevant repositories for the pattern
2. Extract key code snippets with file paths
3. Explain the implementation approach
4. Include relevant external documentation
5. Provide recommendations and gotchas

Invoking extract-pattern agent to find: {{user_message}}

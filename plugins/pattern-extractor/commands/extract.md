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

Immediately use the Task tool to invoke the pattern-extractor:extract-pattern agent with the user's request.

Task(
  subagent_type: "pattern-extractor:extract-pattern",
  prompt: "{{user_message}}",
  description: "Extract pattern from GitHub"
)

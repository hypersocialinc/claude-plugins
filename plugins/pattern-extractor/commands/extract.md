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

# Extract Pattern Command

Extract implementation patterns from GitHub repositories using the pattern-extractor agent.

## Process

### 1. Invoke the Pattern Extractor Agent

Use the Task tool to spawn the extract-pattern agent:

```
Task tool parameters:
  subagent_type: "pattern-extractor:extract-pattern"
  description: "Extract pattern from GitHub"
  prompt: "{{user_message}}"
```

### 2. Wait for Results

The agent will:
- Search GitHub repos for the requested pattern
- Extract key code snippets with file paths
- Explain the implementation approach
- Include relevant external documentation

### 3. Return Findings

After the agent completes, present the structured findings to the user.

## Error Handling

If the agent fails or returns no results:
- Verify `gh` CLI is installed: `gh --version`
- Check GitHub authentication: `gh auth status`
- Try a more specific search term

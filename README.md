# HyperSocial Claude Plugins

A collection of Claude Code plugins, agents, skills, and commands used by HyperSocial.

## Installation

```bash
claude plugins:add hypersocialinc/claude-plugins
```

Or clone manually:
```bash
git clone https://github.com/hypersocialinc/claude-plugins.git ~/.claude/plugins/hypersocial
```

## Contents

### Agents

| Agent | Description |
|-------|-------------|
| `extract-pattern` | Search hypersocialinc GitHub repos to extract implementation patterns |

### Skills

| Skill | Description |
|-------|-------------|
| `swarm` | Git worktree manager for parallel feature development |

### Commands

| Command | Description |
|---------|-------------|
| `/swarm-init` | Analyze repo and generate `swarm.json` config |

## Usage

### Extract Pattern Agent

Automatically triggered when you ask Claude to find how something was implemented in internal repos:

```
"How did we implement Clerk auth in tapjam?"
"Find the Convex file storage pattern from nicosia"
```

### SWARM Skill

Triggered when discussing git worktrees or parallel development:

```
"Help me set up worktrees for this project"
"How do I use srm to manage branches?"
```

### /swarm-init Command

Run directly to generate config:

```
/swarm-init
```

## Structure

```
claude-plugins/
├── plugin.json          # Main manifest
├── agents/
│   └── extract-pattern.md
├── skills/
│   └── swarm/
│       └── SKILL.md
└── commands/
    └── swarm-init.md
```

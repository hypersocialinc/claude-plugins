# HyperSocial Claude Plugins

A marketplace of Claude Code plugins used by HyperSocial.

## Installation

1. Open Claude Code
2. Run `/plugin` and select "Add Marketplace"
3. Enter: `hypersocialinc/claude-plugins`
4. Then install the `hypersocial` plugin from the marketplace

## Available Plugins

### hypersocial

Tools and agents for HyperSocial development workflows.

**Agents:**
| Agent | Description |
|-------|-------------|
| `extract-pattern` | Search hypersocialinc GitHub repos to extract implementation patterns |

**Skills:**
| Skill | Description |
|-------|-------------|
| `swarm` | Git worktree manager for parallel feature development |

**Commands:**
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
├── .claude-plugin/
│   └── marketplace.json     # Marketplace manifest
├── plugins/
│   └── hypersocial/         # Plugin
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── agents/
│       │   └── extract-pattern.md
│       ├── skills/
│       │   └── swarm/
│       │       └── SKILL.md
│       └── commands/
│           └── swarm-init.md
└── README.md
```

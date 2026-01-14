# HyperSocial Claude Plugins

A marketplace of Claude Code plugins used by HyperSocial.

## Installation

### All Plugins (Marketplace)

1. Open Claude Code
2. Run `/plugin` and select "Add Marketplace"
3. Enter: `hypersocialinc/claude-plugins`
4. Select which plugins to install:
   - `pattern-extractor` - Pattern extraction
   - `ralph` - Autonomous development
   - `hypersocial` - SWARM and other tools

### Individual Plugin Installation

You can install plugins individually without the marketplace:

**Pattern Extractor:**
```bash
ln -s /path/to/claude-plugins/plugins/pattern-extractor ~/.claude/plugins/pattern-extractor
```

**Ralph:**
```bash
ln -s /path/to/claude-plugins/plugins/hypersocial/ralph ~/.claude/plugins/ralph
```

**HyperSocial:**
```bash
ln -s /path/to/claude-plugins/plugins/hypersocial ~/.claude/plugins/hypersocial
```

See individual plugin READMEs for detailed setup instructions.

## Available Plugins

### pattern-extractor

Extract implementation patterns from GitHub repositories with structured analysis and documentation.

**Agents:**
| Agent | Description |
|-------|-------------|
| `extract-pattern` | Search GitHub repos to extract implementation patterns |

**Commands:**
| Command | Description |
|---------|-------------|
| `/extract` | Quick pattern extraction command |

**Features:**
- Multi-repo search across your organization
- Structured code snippets with file paths
- External documentation integration
- Configurable search scope
- Performance caching

### ralph

Autonomous feature development with story-based tracking, review gates, and crash recovery.

**Agents:**
| Agent | Description |
|-------|-------------|
| `ralph-planner` | Gather requirements and create feature plan with story breakdown |
| `ralph-executor` | Orchestrate autonomous feature development by spawning story workers |
| `ralph-story-worker` | Execute a single story with fresh context |

**Commands:**
| Command | Description |
|---------|-------------|
| `/ralph-new` | Start a new autonomous feature |
| `/ralph-run` | Start Ralph autonomous loop |
| `/ralph-next` | Execute one story interactively |
| `/ralph-status` | Check feature progress |
| `/ralph-done` | Complete feature and create PR |
| `/ralph-abandon` | Abandon feature and clean up |
| `/ralph-help` | Show Ralph documentation |

### hypersocial

Tools and agents for HyperSocial development workflows.

**Skills:**
| Skill | Description |
|-------|-------------|
| `swarm` | Git worktree manager for parallel feature development |

**Commands:**
| Command | Description |
|---------|-------------|
| `/swarm-init` | Analyze repo and generate `swarm.json` config |

## Usage

### Pattern Extractor

**Using the slash command:**
```
/extract clerk authentication
/extract convex mutations with file upload
/extract stripe subscription setup
```

**Or ask naturally:**
```
"How did we implement Clerk auth in tapjam?"
"Find the Convex file storage pattern from nicosia"
"Extract Stripe subscription patterns and compare approaches"
```

### Ralph (Autonomous Development)

**Start a new feature:**
```
/ralph-new
```

**Run autonomous loop:**
```
/ralph-run
```

**Check progress:**
```
/ralph-status
```

See [Ralph README](plugins/hypersocial/ralph/README.md) for full documentation.

### SWARM Skill

Triggered when discussing git worktrees or parallel development:

```
"Help me set up worktrees for this project"
"How do I use srm to manage branches?"
```

**Initialize swarm config:**
```
/swarm-init
```

## Structure

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json           # Marketplace manifest
├── plugins/
│   ├── pattern-extractor/         # Pattern extraction plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── agents/
│   │   │   └── extract-pattern.md
│   │   ├── commands/
│   │   │   └── extract.yaml
│   │   └── README.md
│   │
│   └── hypersocial/               # HyperSocial tools
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── swarm/
│       │       └── SKILL.md
│       ├── commands/
│       │   └── swarm-init.md
│       │
│       └── ralph/                 # Ralph autonomous development
│           ├── .claude-plugin/
│           │   └── plugin.json
│           ├── agents/
│           │   ├── ralph-planner.md
│           │   ├── ralph-executor.md
│           │   └── ralph-story-worker.md
│           ├── commands/
│           │   ├── ralph-new.md
│           │   ├── ralph-run.md
│           │   └── ...
│           └── README.md
└── README.md
```

#!/bin/bash
set -e

# Ralph autonomous loop
# Usage: ./ralph.sh [max_iterations]
# Can be run from project root OR from inside .ralph/feature-name/

MAX_ITERATIONS=${1:-20}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FEATURE_NAME="$(basename "$(dirname "$SCRIPT_DIR")")"

# Find project root (go up until we find .git or top-level .ralph)
PROJECT_ROOT="$SCRIPT_DIR"
while [[ "$PROJECT_ROOT" != "/" ]]; do
  # Check if we're at project root
  if [[ -d "$PROJECT_ROOT/.git" ]] || [[ -d "$PROJECT_ROOT/.ralph" && "$(basename "$PROJECT_ROOT")" != ".ralph" ]]; then
    break
  fi
  PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done

# Navigate to project root
cd "$PROJECT_ROOT"

echo "🚀 Starting Ralph autonomous loop"
echo "Feature: $FEATURE_NAME"
echo "Project root: $PROJECT_ROOT"
echo "Max iterations: $MAX_ITERATIONS"
echo ""

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "═══════════════════════════════════════"
  echo "  Ralph Iteration $i/$MAX_ITERATIONS"
  echo "═══════════════════════════════════════"
  echo ""

  # Run Claude from project root with the workflow instructions
  OUTPUT=$(claude --dangerously-skip-permissions -p "$(cat "$SCRIPT_DIR/claude.md")" 2>&1 | tee /dev/stderr) || true

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "RALPH_COMPLETE"; then
    echo ""
    echo "✅ Ralph complete! All stories done."
    echo "Run /ralph-done in Claude Code to archive and create PR."
    exit 0
  fi

  # Check for blocker
  if echo "$OUTPUT" | grep -q "RALPH_BLOCKED"; then
    echo ""
    echo "⚠️  Ralph blocked - needs human input"
    BLOCKER=$(echo "$OUTPUT" | grep "RALPH_BLOCKED" | head -1)
    echo "$BLOCKER"
    exit 1
  fi

  echo ""
  echo "Story completed. Waiting 2 seconds before next iteration..."
  sleep 2
  echo ""
done

echo ""
echo "⚠️  Max iterations ($MAX_ITERATIONS) reached"
echo "Run /ralph-status to check progress"
echo "Run ./ralph.sh to continue"
exit 1

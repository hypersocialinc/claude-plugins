#!/bin/bash
set -e

# Ralph autonomous loop
# Usage: ./ralph.sh [max_iterations]

MAX_ITERATIONS=${1:-20}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FEATURE_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting Ralph autonomous loop"
echo "Feature: $(basename "$FEATURE_DIR")"
echo "Max iterations: $MAX_ITERATIONS"
echo ""

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "═══════════════════════════════════════"
  echo "  Ralph Iteration $i/$MAX_ITERATIONS"
  echo "═══════════════════════════════════════"
  echo ""

  # Run Claude with the workflow instructions
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

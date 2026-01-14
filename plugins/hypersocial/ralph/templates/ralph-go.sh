#!/bin/bash
# Ralph Go Script - Autonomous Story Execution
# Feature: {{FEATURE_NAME}}
# Generated: {{DATE}}
#
# This script runs Ralph autonomously until all stories are complete.
# It calls `/ralph-next` repeatedly, checking for completion signals.
#
# Usage:
#   ./ralph-go.sh           # Run with defaults (100 iterations, autonomous)
#   ./ralph-go.sh 50        # Run 50 iterations max (autonomous)
#   ./ralph-go.sh 50 --hit  # Run 50 iterations with human-in-the-loop
#   ./ralph-go.sh --hit     # Run with human-in-the-loop, default iterations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FEATURE_NAME="{{FEATURE_NAME}}"

# Parse arguments
MAX_ITERATIONS=100
HUMAN_IN_LOOP=false

# Process all arguments
for arg in "$@"; do
  case $arg in
    --hit|--human-in-loop)
      HUMAN_IN_LOOP=true
      shift || true
      ;;
    [0-9]*)
      MAX_ITERATIONS=$arg
      shift || true
      ;;
  esac
done

cd "$PROJECT_ROOT"

# Verify claude command exists
if ! command -v claude &> /dev/null; then
  echo "❌ Error: 'claude' command not found"
  echo ""
  echo "The Ralph script requires Claude CLI to be installed."
  echo "Install from: https://docs.anthropic.com/cli"
  echo ""
  echo "Alternatively, use /ralph-go and choose 'Autonomous' mode."
  exit 1
fi

# Show configuration
echo "🚀 Ralph Go: $FEATURE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Max iterations: $MAX_ITERATIONS"
echo "Working directory: $PROJECT_ROOT"
if [ "$HUMAN_IN_LOOP" = true ]; then
  echo "Mode: Human-in-the-loop (permission prompts enabled)"
  echo ""
  echo "⚠️  You will be prompted to approve each tool use."
  echo "    This is useful for reviewing each story as it's completed."
else
  echo "Mode: Autonomous (no permission prompts)"
  echo ""
  echo "🤖 Ralph will run autonomously without prompts."
  echo "    You can walk away and come back to completed work."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Main execution loop
for i in $(seq 1 $MAX_ITERATIONS); do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Iteration $i/$MAX_ITERATIONS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Run one story via /ralph-next
  # Use --dangerously-skip-permissions for true autonomous mode
  set +e
  if [ "$HUMAN_IN_LOOP" = true ]; then
    # With permission prompts (human reviews each action)
    OUTPUT=$(claude /ralph-next 2>&1)
    EXIT_CODE=$?
  else
    # Autonomous mode (no prompts - walk away and come back)
    OUTPUT=$(claude --dangerously-skip-permissions /ralph-next 2>&1)
    EXIT_CODE=$?
  fi
  set -e

  echo "$OUTPUT"
  echo ""

  # Parse executor output for completion signals
  if echo "$OUTPUT" | grep -q "RALPH_COMPLETE"; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 All Stories Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Feature: $FEATURE_NAME"
    echo ""
    echo "Next steps:"
    echo "  1. Review commits: git log"
    echo "  2. Run tests: npm test (or equivalent)"
    echo "  3. Create PR: claude /ralph-done"
    echo ""
    exit 0
  fi

  if echo "$OUTPUT" | grep -q "RALPH_BLOCKED"; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  Story Blocked"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "A story requires human intervention."
    echo ""
    echo "Check details:"
    echo "  cat .ralph/$FEATURE_NAME/progress.txt | head -50"
    echo ""
    echo "After resolving:"
    echo "  ./ralph-go.sh (resumes from blocked story)"
    echo ""
    exit 1
  fi

  if echo "$OUTPUT" | grep -q "RALPH_ERROR"; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Error Encountered"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Check error details:"
    echo "  cat .ralph/$FEATURE_NAME/progress.txt | head -50"
    echo ""
    echo "Diagnose:"
    echo "  claude /ralph-doctor"
    echo ""
    echo "After fixing:"
    echo "  ./ralph-go.sh (retries the failed story)"
    echo ""
    exit 1
  fi

  # Check if command failed but without a recognized signal
  if [ $EXIT_CODE -ne 0 ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Command Failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "The /ralph-next command failed (exit code: $EXIT_CODE)"
    echo ""
    echo "This might indicate:"
    echo "  - Network issue with Claude API"
    echo "  - Claude CLI authentication problem"
    echo "  - Unexpected error in agent"
    echo ""
    echo "Try again:"
    echo "  ./ralph-go.sh"
    echo ""
    exit $EXIT_CODE
  fi

  # Story completed successfully, continue to next
  echo "✓ Story complete, continuing to next..."
  echo ""
  sleep 2
done

# Max iterations reached
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏸️  Max Iterations Reached"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Completed $MAX_ITERATIONS iterations."
echo ""
echo "Check status:"
echo "  claude /ralph-status"
echo ""
echo "To continue:"
echo "  ./ralph-go.sh $MAX_ITERATIONS"
echo ""
echo "Or increase limit:"
echo "  ./ralph-go.sh 200"
echo ""
echo "Or run with human-in-the-loop:"
echo "  ./ralph-go.sh 50 --hit"
echo ""
exit 0

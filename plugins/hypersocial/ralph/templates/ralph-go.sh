#!/bin/bash
# Ralph Go Script - Autonomous Story Execution
# Feature: {{FEATURE_NAME}}
# Generated: {{DATE}}
#
# This script runs Ralph autonomously until all stories are complete.
# It calls `/ralph-next` repeatedly, checking for completion signals.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FEATURE_NAME="{{FEATURE_NAME}}"
MAX_ITERATIONS=${1:-100}

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

echo "🚀 Ralph Go: $FEATURE_NAME"
echo "Max iterations: $MAX_ITERATIONS"
echo "Working directory: $PROJECT_ROOT"
echo ""

# Main execution loop
for i in $(seq 1 $MAX_ITERATIONS); do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Iteration $i/$MAX_ITERATIONS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Run one story via /ralph-next
  # Capture both output and exit code
  set +e
  OUTPUT=$(claude /ralph-next 2>&1)
  EXIT_CODE=$?
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
exit 0

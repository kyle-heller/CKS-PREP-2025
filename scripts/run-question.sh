#!/bin/bash
# CKS Prep 2025 — Question Runner
# Usage: bash scripts/run-question.sh <question-dir-name>
# Example: bash scripts/run-question.sh 01-apparmor-profile

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QUESTIONS_DIR="$REPO_DIR/questions"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <question-name>"
  echo ""
  echo "Available questions:"
  ls -1 "$QUESTIONS_DIR" | sort
  exit 1
fi

QUESTION="$1"
QUESTION_DIR="$QUESTIONS_DIR/$QUESTION"

if [ ! -d "$QUESTION_DIR" ]; then
  echo "ERROR: Question directory not found: $QUESTION_DIR"
  echo ""
  echo "Available questions:"
  ls -1 "$QUESTIONS_DIR" | sort
  exit 1
fi

# Run lab setup
if [ -f "$QUESTION_DIR/LabSetUp.bash" ]; then
  echo "========================================="
  echo "  Setting up lab environment..."
  echo "========================================="
  chmod +x "$QUESTION_DIR/LabSetUp.bash"
  bash "$QUESTION_DIR/LabSetUp.bash"
  echo ""
  echo "  Lab setup complete."
  echo "========================================="
  echo ""
fi

# Display the question
if [ -f "$QUESTION_DIR/Questions.bash" ]; then
  echo "========================================="
  echo "  QUESTION"
  echo "========================================="
  cat "$QUESTION_DIR/Questions.bash"
  echo ""
  echo "========================================="
fi

echo ""
echo "When you're ready to check your answer:"
echo "  bash $QUESTION_DIR/Verify.bash"
echo ""
echo "When you want to see the solution:"
echo "  cat $QUESTION_DIR/SolutionNotes.bash"

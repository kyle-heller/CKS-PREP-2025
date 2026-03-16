#!/bin/bash
# CKS Prep 2025 — Run all lab setups
# Useful for pre-loading all scenarios at once.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QUESTIONS_DIR="$REPO_DIR/questions"

for q in $(ls -1 "$QUESTIONS_DIR" | sort); do
  if [ -f "$QUESTIONS_DIR/$q/LabSetUp.bash" ]; then
    echo "=== Setting up: $q ==="
    bash "$QUESTIONS_DIR/$q/LabSetUp.bash" || echo "  WARNING: Setup failed for $q"
    echo ""
  fi
done

echo "All labs set up."

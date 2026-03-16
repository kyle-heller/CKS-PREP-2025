#!/bin/bash
# CKS-PREP-2025 Test Runner
# Run LabSetUp and/or Verify scripts for Test 1 or Test 2 questions
# and report a summary.
#
# Usage:
#   bash scripts/test-all.sh              # Run setup + verify for all Q01-Q16
#   bash scripts/test-all.sh --test2      # Run setup + verify for all Q17-Q32
#   bash scripts/test-all.sh --setup-only # Only run LabSetUp scripts
#   bash scripts/test-all.sh --verify-only # Only run Verify scripts
#   bash scripts/test-all.sh --test2 --verify-only  # Combine flags

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QUESTIONS_DIR="$REPO_DIR/questions"

# Parse flags
SETUP=true
VERIFY=true
TEST2=false
for arg in "$@"; do
  case "$arg" in
    --setup-only)  VERIFY=false ;;
    --verify-only) SETUP=false ;;
    --test2)       TEST2=true ;;
  esac
done

# Select question range based on test
if $TEST2; then
  Q_MIN=17; Q_MAX=32
  LABEL="Q17-Q32 (Test 2)"
  API_SERVER_QUESTIONS="26"
else
  Q_MIN=1; Q_MAX=16
  LABEL="Q01-Q16 (Test 1)"
  API_SERVER_QUESTIONS="04 07"
fi

QUESTIONS=()
for q in $(ls -1 "$QUESTIONS_DIR" | sort); do
  NUM=$(echo "$q" | grep -oE '^[0-9]+' || true)
  if [ -n "$NUM" ] && [ "$NUM" -ge "$Q_MIN" ] && [ "$NUM" -le "$Q_MAX" ]; then
    QUESTIONS+=("$q")
  fi
done

# Counters
SETUP_OK=0
SETUP_FAIL=0
VERIFY_PASS=0
VERIFY_FAIL=0
VERIFY_ERROR=0
TOTAL=${#QUESTIONS[@]}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== CKS-PREP-2025 Test Runner ===${NC}"
echo "Questions: $TOTAL ($LABEL)"
echo ""

# Results arrays for summary
declare -a SETUP_RESULTS
declare -a VERIFY_RESULTS

wait_for_apiserver() {
  printf "  Waiting for API server... "
  local i=0
  while ! kubectl get nodes &>/dev/null 2>&1; do
    sleep 2
    ((i++))
    if [ $i -gt 60 ]; then
      echo -e "${RED}timeout (120s)${NC}"
      return 1
    fi
  done
  echo -e "${GREEN}ready${NC}"
  sleep 3
}

for q in "${QUESTIONS[@]}"; do
  NUM=$(echo "$q" | grep -oE '^[0-9]+')
  PRETTY=$(echo "$q" | sed 's/^[0-9]*-//' | tr '-' ' ')

  # --- LabSetUp ---
  if $SETUP; then
    if [ -f "$QUESTIONS_DIR/$q/LabSetUp.bash" ]; then
      printf "Setting up Q%s (%s)... " "$NUM" "$PRETTY"
      OUTPUT=$(bash "$QUESTIONS_DIR/$q/LabSetUp.bash" 2>&1)
      EXIT_CODE=$?
      if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}done${NC}"
        SETUP_RESULTS+=("Q${NUM}: OK")
        ((SETUP_OK++))
      else
        echo -e "${RED}FAILED (exit $EXIT_CODE)${NC}"
        echo "  $OUTPUT" | tail -3
        SETUP_RESULTS+=("Q${NUM}: SETUP_FAIL")
        ((SETUP_FAIL++))
      fi
      # Wait for API server after setups that modify its manifest
      if echo "$API_SERVER_QUESTIONS" | grep -qw "$NUM"; then
        wait_for_apiserver
      fi
    fi
  fi

  # --- Verify ---
  if $VERIFY; then
    if [ -f "$QUESTIONS_DIR/$q/Verify.bash" ]; then
      printf "Verifying Q%s (%s)... " "$NUM" "$PRETTY"
      OUTPUT=$(bash "$QUESTIONS_DIR/$q/Verify.bash" 2>&1)
      EXIT_CODE=$?

      # Distinguish between FAIL (expected pre-solve) and ERROR (script bug)
      if [ $EXIT_CODE -eq 0 ]; then
        if echo "$OUTPUT" | grep -q "ALL CHECKS PASSED"; then
          echo -e "${GREEN}PASS${NC}"
          VERIFY_RESULTS+=("Q${NUM}: PASS")
          ((VERIFY_PASS++))
        elif echo "$OUTPUT" | grep -q "FAIL"; then
          echo -e "${YELLOW}FAIL${NC} (expected before solving)"
          VERIFY_RESULTS+=("Q${NUM}: FAIL")
          ((VERIFY_FAIL++))
        else
          echo -e "${YELLOW}FAIL${NC} (expected before solving)"
          VERIFY_RESULTS+=("Q${NUM}: FAIL")
          ((VERIFY_FAIL++))
        fi
      elif [ $EXIT_CODE -eq 1 ]; then
        # Exit 1 can be a normal FAIL (checks failed) or a script error
        if echo "$OUTPUT" | grep -q "\[FAIL\]\|\[PASS\]"; then
          echo -e "${YELLOW}FAIL${NC} (expected before solving)"
          VERIFY_RESULTS+=("Q${NUM}: FAIL")
          ((VERIFY_FAIL++))
        else
          echo -e "${RED}ERROR${NC} (script problem)"
          echo "  $(echo "$OUTPUT" | tail -2)"
          VERIFY_RESULTS+=("Q${NUM}: ERROR")
          ((VERIFY_ERROR++))
        fi
      else
        echo -e "${RED}ERROR${NC} (exit $EXIT_CODE)"
        echo "  $(echo "$OUTPUT" | tail -2)"
        VERIFY_RESULTS+=("Q${NUM}: ERROR")
        ((VERIFY_ERROR++))
      fi
    fi
  fi
done

# --- Summary ---
echo ""
echo -e "${CYAN}=== Summary ===${NC}"
echo "$TOTAL questions tested"
echo ""

if $SETUP; then
  echo -e "Setup:  ${GREEN}$SETUP_OK ok${NC}, ${RED}$SETUP_FAIL failed${NC}"
fi

if $VERIFY; then
  echo -e "Verify: ${GREEN}$VERIFY_PASS pass${NC}, ${YELLOW}$VERIFY_FAIL fail${NC} (expected pre-solve), ${RED}$VERIFY_ERROR errors${NC} (bugs)"
  if [ $VERIFY_ERROR -gt 0 ]; then
    echo ""
    echo -e "${RED}Errors found — these verify scripts have bugs:${NC}"
    for r in "${VERIFY_RESULTS[@]}"; do
      if echo "$r" | grep -q "ERROR"; then
        echo "  $r"
      fi
    done
  fi
fi

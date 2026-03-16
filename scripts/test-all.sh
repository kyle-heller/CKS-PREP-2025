#!/bin/bash
# CKS-PREP-2025 Test Runner
# Run LabSetUp and/or Verify scripts for Test 1 questions (Q01-Q16)
# and report a summary.
#
# Usage:
#   bash scripts/test-all.sh              # Run setup + verify for all Q01-Q16
#   bash scripts/test-all.sh --setup-only # Only run LabSetUp scripts
#   bash scripts/test-all.sh --verify-only # Only run Verify scripts

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QUESTIONS_DIR="$REPO_DIR/questions"

# Parse flags
SETUP=true
VERIFY=true
case "${1:-}" in
  --setup-only)  VERIFY=false ;;
  --verify-only) SETUP=false ;;
esac

# Only test Test 1 questions (01-16)
QUESTIONS=()
for q in $(ls -1 "$QUESTIONS_DIR" | sort); do
  NUM=$(echo "$q" | grep -oE '^[0-9]+' || true)
  if [ -n "$NUM" ] && [ "$NUM" -ge 1 ] && [ "$NUM" -le 16 ]; then
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
echo "Questions: $TOTAL (Q01-Q16)"
echo ""

# Results arrays for summary
declare -a SETUP_RESULTS
declare -a VERIFY_RESULTS

# Questions whose LabSetUp modifies the API server manifest and causes a restart.
# After these, we must wait for the API server to come back before continuing.
API_SERVER_QUESTIONS="04 07"

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

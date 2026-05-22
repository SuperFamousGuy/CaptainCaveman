#!/usr/bin/env bash
# Bisection script to find which test creates unwanted files/state.
#
# Usage:
#   ./find-polluter.sh <pollution_check> <search_dir> [name_glob]
#
# Examples:
#   ./find-polluter.sh '.git'   src                 '*.test.ts'
#   ./find-polluter.sh logs/    tests               '*_spec.rb'
#   ./find-polluter.sh tmp/x    .                   '*.spec.js'
#
# Backward-compat usage (deprecated):
#   ./find-polluter.sh <pollution_check> <test_pattern>
#   — where <test_pattern> is interpreted as a name glob and the search
#   root defaults to '.'. Useful if you previously called with patterns
#   like 'src/**/*.test.ts' (note: `**` is NOT a portable find token; use
#   the new 3-argument form instead).

set -e

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <pollution_check> <search_dir> [name_glob]" >&2
  echo "       $0 <pollution_check> <name_glob>           (legacy 2-arg form)" >&2
  exit 1
fi

POLLUTION_CHECK="$1"

if [ $# -eq 3 ]; then
  SEARCH_DIR="$2"
  NAME_GLOB="$3"
else
  SEARCH_DIR="."
  NAME_GLOB="$2"
fi

if [ ! -d "$SEARCH_DIR" ]; then
  echo "Error: search directory '$SEARCH_DIR' not found." >&2
  exit 1
fi

echo "🔍 Searching for test that creates: $POLLUTION_CHECK"
echo "Search dir: $SEARCH_DIR"
echo "Name glob:  $NAME_GLOB"
echo ""

# Use -name (a portable glob match against the file basename) instead of
# -path (which treats * as not crossing / and doesn't understand `**`).
# Use null-delimited output + mapfile to handle filenames with spaces/special chars.
mapfile -d '' TEST_FILES < <(find "$SEARCH_DIR" -type f -name "$NAME_GLOB" -print0 | sort -z)
TOTAL=${#TEST_FILES[@]}

if [ "$TOTAL" -eq 0 ]; then
  echo "Error: no files matched $NAME_GLOB under $SEARCH_DIR" >&2
  exit 1
fi

echo "Found $TOTAL test files"
echo ""

COUNT=0
for TEST_FILE in "${TEST_FILES[@]}"; do
  COUNT=$((COUNT + 1))

  # Skip if pollution already exists
  if [ -e "$POLLUTION_CHECK" ]; then
    echo "⚠️  Pollution already exists before test $COUNT/$TOTAL"
    echo "   Skipping: $TEST_FILE"
    continue
  fi

  echo "[$COUNT/$TOTAL] Testing: $TEST_FILE"

  # Run the test. Replace `npm test` with your project's runner if needed.
  npm test "$TEST_FILE" > /dev/null 2>&1 || true

  # Check if pollution appeared
  if [ -e "$POLLUTION_CHECK" ]; then
    echo ""
    echo "🎯 FOUND POLLUTER!"
    echo "   Test: $TEST_FILE"
    echo "   Created: $POLLUTION_CHECK"
    echo ""
    echo "Pollution details:"
    ls -la "$POLLUTION_CHECK"
    echo ""
    echo "To investigate:"
    echo "  npm test $TEST_FILE    # Run just this test"
    echo "  cat $TEST_FILE         # Review test code"
    exit 1
  fi
done

echo ""
echo "✅ No polluter found - all tests clean!"
exit 0

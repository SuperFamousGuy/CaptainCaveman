#!/usr/bin/env bash
# Bisection script to find which test creates unwanted files/state.
#
# Usage:
#   ./find-polluter.sh <pollution_check> <search_dir> [name_glob] [test_runner]
#
# Arguments:
#   pollution_check  Path/file to check for after each test (e.g. '.git', 'tmp/x')
#   search_dir       Directory to search for test files (e.g. 'src', 'tests', '.')
#   name_glob        Filename glob for test files (default: '*.test.*')
#   test_runner      Command used to run a single test file (e.g. 'pytest', 'npm test')
#                    Auto-detected from project files if not provided.
#                    Override via TEST_RUNNER env var.
#
# Examples:
#   ./find-polluter.sh '.git'   src                 '*.test.ts'
#   ./find-polluter.sh logs/    tests               '*_spec.rb'   'bundle exec rspec'
#   ./find-polluter.sh tmp/x    .                   '*.spec.js'
#   TEST_RUNNER='yarn test' ./find-polluter.sh tmp/x . '*.test.js'
#
# Backward-compat usage (deprecated):
#   ./find-polluter.sh <pollution_check> <test_pattern>
#   — where <test_pattern> is interpreted as a name glob and the search
#   root defaults to '.'. Useful if you previously called with patterns
#   like 'src/**/*.test.ts' (note: `**` is NOT a portable find token; use
#   the new 3-argument form instead).

set -e

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
  echo "Usage: $0 <pollution_check> <search_dir> [name_glob] [test_runner]" >&2
  echo "       $0 <pollution_check> <name_glob>              (legacy 2-arg form)" >&2
  exit 1
fi

POLLUTION_CHECK="$1"

if [ $# -ge 3 ] && [ -d "$2" ]; then
  # 3- or 4-arg form: <pollution_check> <search_dir> [name_glob] [test_runner]
  SEARCH_DIR="$2"
  NAME_GLOB="${3:-*.test.*}"
  TEST_RUNNER="${4:-${TEST_RUNNER:-}}"
else
  # Legacy 2-arg form: <pollution_check> <name_glob>
  SEARCH_DIR="."
  NAME_GLOB="$2"
  TEST_RUNNER="${TEST_RUNNER:-}"
fi

# Detect test runner from project files if not already set via arg or env var.
# Each runner must accept a single test-file path as its last argument.
if [ -z "$TEST_RUNNER" ]; then
  if [ -f package.json ];                                     then TEST_RUNNER="npm test"
  elif [ -f pyproject.toml ] || [ -f requirements.txt ] \
       || [ -f setup.py ];                                    then TEST_RUNNER="pytest"
  elif [ -f Gemfile ];                                        then TEST_RUNNER="bundle exec rspec"
  elif [ -f composer.json ];                                  then TEST_RUNNER="vendor/bin/phpunit"
  elif [ -f pom.xml ];                                        then TEST_RUNNER="mvn test"
  elif ls build.gradle* >/dev/null 2>&1;                      then TEST_RUNNER="./gradlew test"
  elif [ -f Cargo.toml ];                                     then TEST_RUNNER="cargo test"
  elif [ -f go.mod ];                                         then TEST_RUNNER="go test ./..."
  else
    echo "Warning: could not detect test runner. Set TEST_RUNNER env var or pass as 4th arg." >&2
    TEST_RUNNER="npm test"
  fi
  echo "Detected test runner: $TEST_RUNNER"
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
# Newline-delimited collection via while-read — compatible with Bash 3.2+ and
# BSD/GNU tools (mapfile and sort -z require Bash 4+ / GNU sort).
# Handles filenames with spaces; filenames with literal newlines are not supported
# (vanishingly rare for test files).
TEST_FILES_ARR=()
while IFS= read -r f; do
  [[ -n "$f" ]] && TEST_FILES_ARR+=("$f")
done < <(find "$SEARCH_DIR" -type f -name "$NAME_GLOB" | sort)
TOTAL=${#TEST_FILES_ARR[@]}

if [ "$TOTAL" -eq 0 ]; then
  echo "Error: no files matched $NAME_GLOB under $SEARCH_DIR" >&2
  exit 1
fi

echo "Found $TOTAL test files"
echo ""

COUNT=0
for TEST_FILE in "${TEST_FILES_ARR[@]}"; do
  COUNT=$((COUNT + 1))

  # Skip if pollution already exists
  if [ -e "$POLLUTION_CHECK" ]; then
    echo "⚠️  Pollution already exists before test $COUNT/$TOTAL"
    echo "   Skipping: $TEST_FILE"
    continue
  fi

  echo "[$COUNT/$TOTAL] Testing: $TEST_FILE"

  # Run the test using the detected/configured runner.
  $TEST_RUNNER "$TEST_FILE" > /dev/null 2>&1 || true

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
    echo "  $TEST_RUNNER $TEST_FILE    # Run just this test"
    echo "  cat $TEST_FILE             # Review test code"
    exit 1
  fi
done

echo ""
echo "✅ No polluter found - all tests clean!"
exit 0

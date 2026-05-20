#!/usr/bin/env bash
set -e

REPO="SuperFamousGuy/CaptainCaveman"
BRANCH="${BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API_URL="https://api.github.com/repos/${REPO}"
TARGET=".github/copilot-instructions.md"
SKILLS_PREFIX=".github/skills/"
BEGIN_MARKER="<!-- BEGIN CAPTAINCAVEMAN -->"
END_MARKER="<!-- END CAPTAINCAVEMAN -->"

mkdir -p "$(dirname "$TARGET")"

TMP=$(mktemp)
trap 'rm -f "$TMP" "$TARGET.new" 2>/dev/null || true' EXIT

# --- Part 1: Install/update copilot-instructions.md ---
echo "Fetching CaptainCaveman instructions..."
curl -fsSL "${BASE_URL}/.github/copilot-instructions.md" -o "$TMP"

if [ ! -f "$TARGET" ]; then
  {
    printf '%s\n' "$BEGIN_MARKER"
    cat "$TMP"
    printf '%s\n' "$END_MARKER"
  } > "$TARGET"
  echo "Installed instructions to $TARGET"
else
  HAS_BEGIN=$(grep -cF "$BEGIN_MARKER" "$TARGET" || true)
  HAS_END=$(grep -cF "$END_MARKER" "$TARGET" || true)

  if [ "$HAS_BEGIN" -eq 1 ] && [ "$HAS_END" -eq 1 ]; then
    awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" -v content_file="$TMP" '
      $0 == begin {
        print
        while ((getline line < content_file) > 0) print line
        in_block = 1
        next
      }
      $0 == end {
        in_block = 0
        print
        next
      }
      !in_block { print }
    ' "$TARGET" > "$TARGET.new"
    mv "$TARGET.new" "$TARGET"
    echo "Updated CaptainCaveman block in $TARGET (other content preserved)."
  elif [ "$HAS_BEGIN" -eq 0 ] && [ "$HAS_END" -eq 0 ]; then
    {
      cat "$TARGET"
      tail -c1 "$TARGET" | od -An -c | grep -q '\\n' || printf '\n'
      printf '\n%s\n' "$BEGIN_MARKER"
      cat "$TMP"
      printf '%s\n' "$END_MARKER"
    } > "$TARGET.new"
    mv "$TARGET.new" "$TARGET"
    echo "Appended CaptainCaveman block to existing $TARGET (existing content preserved)."
  else
    echo "Error: $TARGET has an unbalanced CaptainCaveman marker pair." >&2
    echo "  BEGIN markers: $HAS_BEGIN, END markers: $HAS_END" >&2
    echo "Fix the file manually and re-run." >&2
    exit 1
  fi
fi

# --- Part 2: Install agent skills under .github/skills/ ---
echo
echo "Fetching skill list..."
TREE_JSON=$(curl -fsSL "${API_URL}/git/trees/${BRANCH}?recursive=1")

if ! command -v python3 >/dev/null 2>&1; then
  echo "Warning: python3 not found. Skipping skill install. Instructions file is still in place." >&2
  exit 0
fi

PATHS=$(printf '%s' "$TREE_JSON" | python3 -c "
import sys, json
tree = json.load(sys.stdin)
for item in tree.get('tree', []):
    if item['type'] == 'blob' and item['path'].startswith('$SKILLS_PREFIX'):
        print(item['path'])
")

if [ -z "$PATHS" ]; then
  echo "No agent skills found in the repo. Done."
  exit 0
fi

SKILL_COUNT=$(printf '%s\n' "$PATHS" | awk -F/ '{print $3}' | sort -u | wc -l | tr -d ' ')
FILE_COUNT=$(printf '%s\n' "$PATHS" | wc -l | tr -d ' ')
echo "Installing $SKILL_COUNT agent skills ($FILE_COUNT files)..."

while IFS= read -r path; do
  [ -z "$path" ] && continue
  mkdir -p "$(dirname "$path")"
  curl -fsSL "${BASE_URL}/${path}" -o "$path"
done <<EOF
$PATHS
EOF

echo "Done."
echo "Open Copilot Chat in this workspace — Caveman is now active and agent skills are available."

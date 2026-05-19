#!/usr/bin/env bash
set -e

REPO="SuperFamousGuy/CaptainCaveman"
BRANCH="${BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
TARGET=".github/copilot-instructions.md"
BEGIN_MARKER="<!-- BEGIN CAPTAINCAVEMAN -->"
END_MARKER="<!-- END CAPTAINCAVEMAN -->"

mkdir -p "$(dirname "$TARGET")"

TMP=$(mktemp)
trap 'rm -f "$TMP" "$TARGET.new" 2>/dev/null || true' EXIT

echo "Fetching CaptainCaveman instructions..."
curl -fsSL "${BASE_URL}/.github/copilot-instructions.md" -o "$TMP"

if [ ! -f "$TARGET" ]; then
  # Fresh install
  {
    printf '%s\n' "$BEGIN_MARKER"
    cat "$TMP"
    printf '%s\n' "$END_MARKER"
  } > "$TARGET"
  echo "Installed to $TARGET"
  echo "Open Copilot Chat in this workspace — Caveman now active."
  exit 0
fi

HAS_BEGIN=$(grep -cF "$BEGIN_MARKER" "$TARGET" || true)
HAS_END=$(grep -cF "$END_MARKER" "$TARGET" || true)

if [ "$HAS_BEGIN" -eq 1 ] && [ "$HAS_END" -eq 1 ]; then
  # Update existing managed block in place
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
  # Append to existing unmanaged file
  {
    cat "$TARGET"
    # Guarantee a blank line before the block
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
  echo "Fix the file manually (either remove both markers or restore the pair) and re-run." >&2
  exit 1
fi

echo "Open Copilot Chat in this workspace — Caveman now active."

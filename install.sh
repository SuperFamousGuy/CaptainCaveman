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

# All `.prompt.md` files the very first (PR #2) installer dropped under
# `.github/prompts/`. Later iterations replaced this with copilot-instructions.md
# + .github/skills/, but old files linger on workspaces that installed during
# that brief window.
LEGACY_PROMPT_FILES=(
  ".github/prompts/caveman.prompt.md"
  ".github/prompts/caveman-commit.prompt.md"
  ".github/prompts/caveman-compress.prompt.md"
  ".github/prompts/caveman-help.prompt.md"
  ".github/prompts/caveman-review.prompt.md"
  ".github/prompts/cavecrew.prompt.md"
  ".github/prompts/cavecrew-builder.prompt.md"
  ".github/prompts/cavecrew-investigator.prompt.md"
  ".github/prompts/cavecrew-reviewer.prompt.md"
)

mkdir -p "$(dirname "$TARGET")"

TMP=$(mktemp)
trap 'rm -f "$TMP" "$TARGET.new" 2>/dev/null || true' EXIT

# --- Step 0: Clean up legacy CaptainCaveman artifacts ---
# Removes `.github/prompts/*.prompt.md` files from the original (PR #2) install,
# and (later) rewrites any pre-marker monolithic copilot-instructions.md as part
# of Part 1.
REMOVED_LEGACY=0
for f in "${LEGACY_PROMPT_FILES[@]}"; do
  if [ -f "$f" ]; then
    rm -f "$f"
    echo "Removed legacy file: $f"
    REMOVED_LEGACY=$((REMOVED_LEGACY + 1))
  fi
done
if [ "$REMOVED_LEGACY" -gt 0 ] && [ -d .github/prompts ] && [ -z "$(ls -A .github/prompts 2>/dev/null)" ]; then
  rmdir .github/prompts
  echo "Removed now-empty .github/prompts/ directory"
fi
if [ "$REMOVED_LEGACY" -gt 0 ]; then
  echo "Cleaned up $REMOVED_LEGACY legacy file(s) from an earlier CaptainCaveman install."
  echo
fi

# Detect a pre-marker monolithic CaptainCaveman install (file exists, no
# markers, but H1 is CaptainCaveman). Earlier installer versions used a plain
# `curl -o` and didn't add markers — re-running today would append a duplicate
# block. Treat these as fully-managed legacy files and wipe-and-replace.
is_legacy_monolithic_install() {
  [ -f "$TARGET" ] || return 1
  # First non-blank line must be the CaptainCaveman H1
  local first_line
  first_line=$(awk 'NF{print; exit}' "$TARGET")
  case "$first_line" in
    "# CaptainCaveman"*) return 0 ;;
    *) return 1 ;;
  esac
}

# --- Part 1: Install/update copilot-instructions.md ---
echo "Fetching CaptainCaveman instructions..."
curl -fsSL "${BASE_URL}/.github/copilot-instructions.md" -o "$TMP"

write_fresh_block() {
  {
    printf '%s\n' "$BEGIN_MARKER"
    cat "$TMP"
    printf '%s\n' "$END_MARKER"
  } > "$TARGET"
}

if [ ! -f "$TARGET" ]; then
  # Fresh install
  write_fresh_block
  echo "Installed instructions to $TARGET"
else
  HAS_BEGIN=$(grep -cF "$BEGIN_MARKER" "$TARGET" || true)
  HAS_END=$(grep -cF "$END_MARKER" "$TARGET" || true)

  if [ "$HAS_BEGIN" -eq 1 ] && [ "$HAS_END" -eq 1 ]; then
    # Standard managed-block update
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
    if is_legacy_monolithic_install; then
      # Pre-marker (PR #3 / PR #5 era) CaptainCaveman install — fully-managed
      # file with no markers. Wipe and replace with the current marker-wrapped
      # block so users get the dispatcher + skill references.
      write_fresh_block
      echo "Detected legacy pre-marker CaptainCaveman install in $TARGET — replaced with the current Superpowered version."
    else
      # Genuine user-authored file with no CaptainCaveman content yet. Append
      # the block after preserving everything that's already there.
      {
        cat "$TARGET"
        tail -c1 "$TARGET" | od -An -c | grep -q '\\n' || printf '\n'
        printf '\n%s\n' "$BEGIN_MARKER"
        cat "$TMP"
        printf '%s\n' "$END_MARKER"
      } > "$TARGET.new"
      mv "$TARGET.new" "$TARGET"
      echo "Appended CaptainCaveman block to existing $TARGET (existing content preserved)."
    fi
  else
    echo "Error: $TARGET has an unbalanced CaptainCaveman marker pair." >&2
    echo "  BEGIN markers: $HAS_BEGIN, END markers: $HAS_END" >&2
    echo "Fix the file manually and re-run." >&2
    exit 1
  fi
fi

# --- Part 2: Install agent skills under .github/skills/ (best-effort) ---
# Part 2 must never break Part 1. If anything goes wrong (no python3, API
# rate-limit, network blip, partial download), warn and exit 0 — the
# instructions file is already in place.
echo
echo "Fetching skill list..."

if ! command -v python3 >/dev/null 2>&1; then
  echo "Note: python3 not found. Skipping agent-skill install (instructions file already in place)." >&2
  exit 0
fi

set +e
TREE_JSON=$(curl -fsSL "${API_URL}/git/trees/${BRANCH}?recursive=1")
TREE_RC=$?
set -e
if [ "$TREE_RC" -ne 0 ] || [ -z "$TREE_JSON" ]; then
  echo "Warning: failed to list repo tree via GitHub API (rate-limit or network). Skipping agent-skill install." >&2
  exit 0
fi

PATHS=$(printf '%s' "$TREE_JSON" | python3 -c "
import sys, json
try:
    tree = json.load(sys.stdin)
except Exception:
    sys.exit(1)
for item in tree.get('tree', []):
    if item.get('type') == 'blob' and item.get('path', '').startswith('$SKILLS_PREFIX'):
        print(item['path'])
" 2>/dev/null) || {
  echo "Warning: could not parse the GitHub API tree response. Skipping agent-skill install." >&2
  exit 0
}

if [ -z "$PATHS" ]; then
  echo "No agent skills found in the repo. Done."
  exit 0
fi

SKILL_COUNT=$(printf '%s\n' "$PATHS" | awk -F/ 'NF>=3{print $3}' | sort -u | wc -l | tr -d ' ')
FILE_COUNT=$(printf '%s\n' "$PATHS" | wc -l | tr -d ' ')
echo "Installing $SKILL_COUNT agent skills ($FILE_COUNT files)..."

FAILED=0
while IFS= read -r path; do
  [ -z "$path" ] && continue
  mkdir -p "$(dirname "$path")"
  if ! curl -fsSL "${BASE_URL}/${path}" -o "$path"; then
    echo "  Warning: failed to download $path" >&2
    FAILED=$((FAILED + 1))
  fi
done <<EOF
$PATHS
EOF

if [ "$FAILED" -gt 0 ]; then
  echo "Skill install completed with $FAILED file(s) failed. Re-run the installer to retry." >&2
else
  echo "Skill install complete."
fi

echo "Open Copilot Chat in this workspace — Caveman is now active and agent skills are available."

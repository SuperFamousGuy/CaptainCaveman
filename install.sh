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

# Install mode for skill files under .github/skills/:
#   preserve (default) — never overwrite an existing file; new files install normally.
#   upgrade  (UPGRADE=1) — overwrite every file with the upstream version.
# copilot-instructions.md uses marker-delimited block management (Part 1) and is
# always non-destructive to user content outside the markers, so this flag does
# not affect it.
case "${UPGRADE:-}" in
  1|true|TRUE|yes) INSTALL_MODE="upgrade" ;;
  *)               INSTALL_MODE="preserve" ;;
esac

# ── Visual helpers ─────────────────────────────────────────────────────────
# Colour and spinners activate only when stdout is a real terminal and
# NO_COLOR is unset. Everything degrades to plain text in CI / piped output.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD='\033[1m'  DIM='\033[2m'     RESET='\033[0m'
  GREEN='\033[32m' YELLOW='\033[33m' RED='\033[31m'
  CYAN='\033[36m'  BLUE='\033[34m'
  INTERACTIVE=true
else
  BOLD='' DIM='' RESET='' GREEN='' YELLOW='' RED='' CYAN='' BLUE=''
  INTERACTIVE=false
fi

CHK="${GREEN}✓${RESET}"
WRN="${YELLOW}⚠${RESET}"
BAD="${RED}✗${RESET}"

section() { printf "\n${BOLD}${BLUE}▸ %s${RESET}\n" "$1"; }
ok()      { printf "  ${CHK} %s\n" "$1"; }
skip()    { printf "  ${DIM}─ %s${RESET}\n" "$1"; }
warn_msg(){ printf "  ${WRN} %s\n" "$1" >&2; }
die()     { printf "\n  ${BAD} %s\n\n" "$1" >&2; exit 1; }

# ── Spinner ────────────────────────────────────────────────────────────────
SPIN_PID=''
_FRAMES='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

_spin_loop() {
  local label="$1" i=0
  while true; do
    printf "\r  ${CYAN}%s${RESET} %s   " "${_FRAMES:$(( i % 10 )):1}" "$label"
    sleep 0.1
    i=$(( i + 1 ))
  done
}

spin_start() {
  if [ "$INTERACTIVE" = true ]; then
    _spin_loop "$1" &
    SPIN_PID=$!
  else
    printf "  %s..." "$1"
  fi
}

spin_stop() {
  if [ -n "$SPIN_PID" ]; then
    kill "$SPIN_PID" 2>/dev/null || true
    wait "$SPIN_PID" 2>/dev/null || true
    SPIN_PID=''
    [ "$INTERACTIVE" = true ] && printf "\r\033[K"
  fi
}

# ── Progress bar ───────────────────────────────────────────────────────────
# Usage: progress CURRENT TOTAL LABEL
progress() {
  [ "$INTERACTIVE" != true ] && return
  local cur=$1 tot=$2 label="${3:-}" w=32 filled bar='' i=0
  filled=$(( cur * w / tot ))
  while [ $i -lt $filled ]; do bar="${bar}█"; i=$(( i + 1 )); done
  while [ $i -lt $w ];      do bar="${bar}░"; i=$(( i + 1 )); done
  printf "\r  ${DIM}[${RESET}${GREEN}%s${RESET}${DIM}]${RESET}  %s/%s  %s" \
         "$bar" "$cur" "$tot" "$label"
}

# ── Banners ────────────────────────────────────────────────────────────────
print_header() {
  printf "\n"
  printf "${BOLD}  ┌─────────────────────────────────┐${RESET}\n"
  printf "${BOLD}  │    CaptainCaveman  Installer    │${RESET}\n"
  printf "${BOLD}  └─────────────────────────────────┘${RESET}\n"
}

print_footer() {
  printf "\n"
  printf "${BOLD}${GREEN}  ┌────────────────────────────────────────────┐${RESET}\n"
  printf "${BOLD}${GREEN}  │  ✓  Caveman active. Superpowers loaded.   │${RESET}\n"
  printf "${BOLD}${GREEN}  │     Open Copilot Chat to begin.           │${RESET}\n"
  printf "${BOLD}${GREEN}  └────────────────────────────────────────────┘${RESET}\n"
  printf "\n"
}

# ── Startup ────────────────────────────────────────────────────────────────
print_header
mkdir -p "$(dirname "$TARGET")"

TMP=$(mktemp)
trap 'spin_stop; rm -f "$TMP" "$TARGET.new" 2>/dev/null || true' EXIT INT TERM

# ── Step 0: Clean up legacy CaptainCaveman artifacts ──────────────────────
# Removes `.github/prompts/*.prompt.md` files from the original (PR #2) install,
# and (later) rewrites any pre-marker monolithic copilot-instructions.md as part
# of Part 1.
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

section "Cleanup"
REMOVED_LEGACY=0
for f in "${LEGACY_PROMPT_FILES[@]}"; do
  if [ -f "$f" ]; then
    rm -f "$f"
    ok "Removed legacy file: $f"
    REMOVED_LEGACY=$(( REMOVED_LEGACY + 1 ))
  fi
done
if [ "$REMOVED_LEGACY" -gt 0 ] && [ -d .github/prompts ] \
   && [ -z "$(ls -A .github/prompts 2>/dev/null)" ]; then
  rmdir .github/prompts
  ok "Removed now-empty .github/prompts/"
fi
if [ "$REMOVED_LEGACY" -eq 0 ]; then
  skip "No legacy files found"
fi

# ── Part 1: Install/update copilot-instructions.md ────────────────────────
# Detect a pre-marker monolithic CaptainCaveman install (file exists, no
# markers, but H1 is CaptainCaveman). Earlier installer versions used a plain
# `curl -o` and didn't add markers — re-running today would append a duplicate
# block. Treat these as fully-managed legacy files and wipe-and-replace.
is_legacy_monolithic_install() {
  [ -f "$TARGET" ] || return 1
  local first_line
  first_line=$(awk 'NF{print; exit}' "$TARGET")
  case "$first_line" in
    "# CaptainCaveman"*) return 0 ;;
    *) return 1 ;;
  esac
}

section "Instructions"
spin_start "Fetching copilot-instructions.md"
curl -fsSL "${BASE_URL}/.github/copilot-instructions.md" -o "$TMP"
spin_stop

write_fresh_block() {
  {
    printf '%s\n' "$BEGIN_MARKER"
    cat "$TMP"
    printf '%s\n' "$END_MARKER"
  } > "$TARGET"
}

if [ ! -f "$TARGET" ]; then
  write_fresh_block
  ok "Installed → $TARGET"
else
  HAS_BEGIN=$(grep -cF "$BEGIN_MARKER" "$TARGET" || true)
  HAS_END=$(grep -cF   "$END_MARKER"   "$TARGET" || true)

  if [ "$HAS_BEGIN" -eq 1 ] && [ "$HAS_END" -eq 1 ]; then
    awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" -v cf="$TMP" '
      $0 == begin { print; while ((getline l < cf) > 0) print l; in_b=1; next }
      $0 == end   { in_b=0; print; next }
      !in_b       { print }
    ' "$TARGET" > "$TARGET.new"
    mv "$TARGET.new" "$TARGET"
    ok "Updated block in $TARGET  ${DIM}(other content preserved)${RESET}"
  elif [ "$HAS_BEGIN" -eq 0 ] && [ "$HAS_END" -eq 0 ]; then
    if is_legacy_monolithic_install; then
      write_fresh_block
      ok "Replaced legacy pre-marker install in $TARGET"
    else
      {
        cat "$TARGET"
        tail -c1 "$TARGET" | od -An -c | grep -q '\\n' || printf '\n'
        printf '\n%s\n' "$BEGIN_MARKER"
        cat "$TMP"
        printf '%s\n' "$END_MARKER"
      } > "$TARGET.new"
      mv "$TARGET.new" "$TARGET"
      ok "Appended block to $TARGET  ${DIM}(existing content preserved)${RESET}"
    fi
  else
    die "$TARGET has unbalanced markers (BEGIN=$HAS_BEGIN END=$HAS_END). Fix manually and re-run."
  fi
fi

# ── Part 2: Install agent skills under .github/skills/ ────────────────────
# Best-effort: never abort Part 1's work. Warn and exit 0 on any failure.
section "Skills"

if ! command -v python3 >/dev/null 2>&1; then
  warn_msg "python3 not found — skipping skill install (instructions file already in place)"
  print_footer
  exit 0
fi

spin_start "Resolving file list"
set +e
TREE_JSON=$(curl -fsSL "${API_URL}/git/trees/${BRANCH}?recursive=1")
TREE_RC=$?
set -e
spin_stop

if [ "$TREE_RC" -ne 0 ] || [ -z "$TREE_JSON" ]; then
  warn_msg "GitHub API unreachable — skipping skill install (instructions file already in place)"
  print_footer
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
  warn_msg "Could not parse GitHub API response — skipping skill install"
  print_footer
  exit 0
}

if [ -z "$PATHS" ]; then
  warn_msg "No skill files found in repo"
  print_footer
  exit 0
fi

SKILL_COUNT=$(printf '%s\n' "$PATHS" | awk -F/ 'NF>=3{print $3}' | sort -u | wc -l | tr -d ' ')
FILE_COUNT=$(printf '%s\n'  "$PATHS" | wc -l | tr -d ' ')
if [ "$INSTALL_MODE" = "upgrade" ]; then
  ok "$SKILL_COUNT skills  ·  $FILE_COUNT files  ${DIM}(upgrade mode — overwriting)${RESET}"
else
  ok "$SKILL_COUNT skills  ·  $FILE_COUNT files  ${DIM}(preserve mode — UPGRADE=1 to overwrite)${RESET}"
fi
printf "\n"

DONE=0
INSTALLED=0
KEPT=0
FAILED=0
FAIL_LIST=""
DOWNLOADED_PATHS=""
while IFS= read -r fpath; do
  [ -z "$fpath" ] && continue
  mkdir -p "$(dirname "$fpath")"
  DONE=$(( DONE + 1 ))

  # Preserve mode: keep any file that already exists. The user may have
  # customised the skill — overwriting silently would produce a destructive
  # diff in their next install PR. Use UPGRADE=1 to opt into overwriting.
  if [ -f "$fpath" ] && [ "$INSTALL_MODE" = "preserve" ]; then
    KEPT=$(( KEPT + 1 ))
    progress "$DONE" "$FILE_COUNT" "kept existing"
    continue
  fi

  progress "$DONE" "$FILE_COUNT" "downloading"
  if ! curl -fsSL "${BASE_URL}/${fpath}" -o "$fpath" 2>/dev/null; then
    FAILED=$(( FAILED + 1 ))
    FAIL_LIST="${FAIL_LIST}      • ${fpath}\n"
  else
    INSTALLED=$(( INSTALLED + 1 ))
    DOWNLOADED_PATHS="${DOWNLOADED_PATHS}${fpath}
"
  fi
done <<EOF
$PATHS
EOF

[ "$INTERACTIVE" = true ] && printf "\n"

# Restore executable bit on shell scripts we actually wrote (curl -o strips
# it). Skip files we preserved — those are the user's version, leave alone.
CHMOD_COUNT=0
while IFS= read -r sh_path; do
  [ -z "$sh_path" ] && continue
  if [ -f "$sh_path" ]; then
    chmod +x "$sh_path"
    CHMOD_COUNT=$(( CHMOD_COUNT + 1 ))
  fi
done < <(printf '%s\n' "$DOWNLOADED_PATHS" | grep -E '\.sh$' || true)
[ "$CHMOD_COUNT" -gt 0 ] && ok "Set +x on $CHMOD_COUNT shell script(s)"

# Summary
if [ "$FAILED" -gt 0 ]; then
  warn_msg "$FAILED file(s) failed to download — re-run to retry:"
  printf "%b" "$FAIL_LIST" >&2
fi

if [ "$INSTALL_MODE" = "upgrade" ]; then
  [ "$INSTALLED" -gt 0 ] && ok "Upgraded $INSTALLED file(s)"
elif [ "$INSTALLED" -gt 0 ] && [ "$KEPT" -gt 0 ]; then
  ok "Installed $INSTALLED new  ${DIM}·  kept $KEPT existing (UPGRADE=1 to overwrite)${RESET}"
elif [ "$INSTALLED" -gt 0 ]; then
  ok "Installed $INSTALLED file(s)"
elif [ "$KEPT" -gt 0 ]; then
  ok "All $KEPT file(s) already present  ${DIM}(UPGRADE=1 to overwrite)${RESET}"
fi

print_footer

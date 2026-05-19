#!/usr/bin/env bash
set -e

REPO="SuperFamousGuy/CaptainCaveman"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
TARGET=".github/prompts"

mkdir -p "$TARGET"

SKILLS=(
  "cavecrew-builder.prompt.md"
  "cavecrew-investigator.prompt.md"
  "cavecrew-reviewer.prompt.md"
)

for skill in "${SKILLS[@]}"; do
  echo "Installing $skill..."
  curl -fsSL "${BASE_URL}/.github/prompts/${skill}" -o "${TARGET}/${skill}"
done

echo "Done. Skills installed to ${TARGET}/"

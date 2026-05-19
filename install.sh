#!/usr/bin/env bash
set -e

REPO="SuperFamousGuy/CaptainCaveman"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
TARGET=".github"

mkdir -p "$TARGET"

echo "Installing CaptainCaveman skills..."
curl -fsSL "${BASE_URL}/.github/copilot-instructions.md" -o "${TARGET}/copilot-instructions.md"

echo "Done. Skills installed to ${TARGET}/copilot-instructions.md"
echo "Open Copilot Chat in this workspace — skills auto-activate based on intent."

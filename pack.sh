#!/usr/bin/env bash
# Stage all changes and pack them into claude-setup.zip (next to this script),
# staging the zip too, so the next commit contains both the change and an
# up-to-date zip. The zip unpacks into a claude-setup/ folder and never
# contains itself (see .gitattributes).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP="$REPO_DIR/claude-setup.zip"

git -C "$REPO_DIR" add -A
git -C "$REPO_DIR" archive --format=zip --prefix=claude-setup/ -o "$ZIP" "$(git -C "$REPO_DIR" write-tree)"
git -C "$REPO_DIR" add "$ZIP"
echo "Created and staged $ZIP — commit to save it"

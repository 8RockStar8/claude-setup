#!/usr/bin/env bash
# Pack the committed setup into claude-setup.zip (next to this script) to share
# it or push it to another repo. The zip unpacks into a claude-setup/ folder.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP="$REPO_DIR/claude-setup.zip"

if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
  echo "Note: uncommitted changes are not in the zip. Commit them first."
fi

git -C "$REPO_DIR" archive --format=zip --prefix=claude-setup/ -o "$ZIP" HEAD
echo "Created $ZIP ($(git -C "$REPO_DIR" log -1 --format='%h %s'))"

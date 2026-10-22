#!/usr/bin/env bash
# One-command Claude Code setup: skills, plugins, MCP servers, agents,
# slash commands, settings and global CLAUDE.md. Safe to run again any time.
#
#   claude-setup             install what's missing and apply config files
#   claude-setup --update    also reinstall template skills (latest versions)
#   claude-setup --no-pull   don't git pull this repo first

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
BACKUP_DIR="$CLAUDE_DIR/backups/claude-setup"

UPDATE=0
PULL=1
for arg in "$@"; do
  case "$arg" in
    --update) UPDATE=1 ;;
    --no-pull) PULL=0 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg (see --help)"; exit 1 ;;
  esac
done

FAILED=()
step() { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
skip() { printf '  \033[2m· %s\033[0m\n' "$1"; }
fail() { printf '  \033[31m✘ %s\033[0m\n' "$1"; FAILED+=("$1"); }

# Run a command quietly; show the tail of its output only if it fails.
run() {
  local label="$1" out; shift
  if out="$("$@" </dev/null 2>&1)"; then ok "$label"
  else fail "$label"; printf '%s\n' "$out" | tail -5 | sed 's/^/      /'; fi
}

# Entries of a list file, without comments and blank lines.
list() {
  [ -f "$REPO_DIR/$1" ] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$REPO_DIR/$1"
}

backup() {
  [ -e "$1" ] || return 0
  mkdir -p "$BACKUP_DIR"
  cp -R "$1" "$BACKUP_DIR/$(basename "$1").$(date +%Y%m%d-%H%M%S)"
}

# --- Update this repo, then restart with the new version ---------------------
if [ "$PULL" = 1 ] && [ -z "${CLAUDE_SETUP_PULLED:-}" ] \
   && git -C "$REPO_DIR" remote get-url origin >/dev/null 2>&1; then
  step "Updating setup repo"
  if git -C "$REPO_DIR" pull --ff-only --quiet; then ok "up to date"
  else printf '  \033[33m! git pull failed, using local copy\033[0m\n'; fi
  CLAUDE_SETUP_PULLED=1 exec bash "$REPO_DIR/setup.sh" "$@"
fi

# --- Requirements ------------------------------------------------------------
step "Requirements"
missing=0
for cmd in claude git node npx; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd"; else fail "$cmd not found"; missing=1; fi
done
if [ "$missing" = 1 ]; then
  echo
  echo "Install the missing tools first:"
  echo "  Claude Code: https://claude.com/claude-code"
  echo "  Node.js (includes npx): https://nodejs.org"
  exit 1
fi

# --- Config files: CLAUDE.md, custom skills, agents, commands, settings ------
step "Config files"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands"

if cmp -s "$REPO_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; then
  skip "CLAUDE.md (unchanged)"
else
  backup "$CLAUDE_DIR/CLAUDE.md"
  cp "$REPO_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" && ok "CLAUDE.md" || fail "CLAUDE.md"
fi

for kind in skills agents commands; do
  for src in "$REPO_DIR/config/$kind"/*; do
    [ -e "$src" ] || continue
    name="$(basename "$src")"
    dest="$CLAUDE_DIR/$kind/$name"
    if diff -rq "$src" "$dest" >/dev/null 2>&1; then skip "$kind/$name (unchanged)"; continue; fi
    rm -rf "$dest" && cp -R "$src" "$dest" && ok "$kind/$name" || fail "$kind/$name"
  done
done

if [ -f "$REPO_DIR/config/settings.json" ]; then
  settings_backup="$BACKUP_DIR/settings.json.$(date +%Y%m%d-%H%M%S)"
  [ -f "$CLAUDE_DIR/settings.json" ] && mkdir -p "$BACKUP_DIR" && cp "$CLAUDE_DIR/settings.json" "$settings_backup"
  if result="$(node "$REPO_DIR/lib/merge-settings.js" "$REPO_DIR/config/settings.json" "$CLAUDE_DIR/settings.json" 2>&1)"; then
    if [ "$result" = "changed" ]; then ok "settings.json (merged)"; else skip "settings.json (unchanged)"; rm -f "$settings_backup"; fi
  else
    fail "settings.json: $result"; rm -f "$settings_backup"
  fi
fi

# --- Skills from claude-code-templates ---------------------------------------
step "Skills (claude-code-templates)"
to_install=()
while read -r id; do
  name="${id##*/}"
  if [ "$UPDATE" = 0 ] && [ -f "$CLAUDE_DIR/skills/$name/SKILL.md" ]; then skip "$name"
  else to_install+=("$id"); fi
done < <(list skills.txt)

if [ "${#to_install[@]}" -gt 0 ]; then
  ids="$(IFS=,; echo "${to_install[*]}")"
  echo "  Installing ${#to_install[@]} skill(s)..."
  (cd "$HOME" && npx -y claude-code-templates@latest --directory "$HOME" --yes --skill "$ids" </dev/null)
  # The installer can exit 0 even when some skills fail (e.g. GitHub rate limit),
  # so check each skill on disk.
  for id in "${to_install[@]}"; do
    if [ -f "$CLAUDE_DIR/skills/${id##*/}/SKILL.md" ]; then ok "${id##*/}"
    else fail "skill $id (GitHub rate limit? run claude-setup again later)"; fi
  done
fi

# --- Plugins -----------------------------------------------------------------
step "Plugins"
known_marketplaces="$(claude plugin marketplace list </dev/null 2>/dev/null)"
while read -r source; do
  if grep -qF "$source" <<<"$known_marketplaces"; then skip "marketplace $source"
  else run "marketplace $source" claude plugin marketplace add "$source"; fi
done < <(list marketplaces.txt)

installed_plugins="$(claude plugin list </dev/null 2>/dev/null)"
while read -r plugin; do
  if grep -qF "$plugin" <<<"$installed_plugins"; then skip "$plugin"
  else run "$plugin" claude plugin install --scope user "$plugin"; fi
done < <(list plugins.txt)

# --- MCP servers -------------------------------------------------------------
step "MCP servers"
if [ -f "$REPO_DIR/mcp.json" ]; then
  while IFS=$'\t' read -r name config; do
    [ -n "$name" ] || continue
    if [ "$config" = "MISSING_ENV" ]; then fail "$name: set its env vars (see mcp.json) and run again"; continue; fi
    if claude mcp get "$name" </dev/null >/dev/null 2>&1; then skip "$name"
    else run "$name" claude mcp add-json --scope user "$name" "$config"; fi
  done < <(node "$REPO_DIR/lib/mcp-servers.js" "$REPO_DIR/mcp.json")
fi

# --- Shell command -----------------------------------------------------------
step "Shell command"
alias_line="alias claude-setup='bash \"$REPO_DIR/setup.sh\"'"
case "${SHELL:-}" in *zsh) touch "$HOME/.zshrc" ;; esac
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || continue
  if grep -qF "alias claude-setup=" "$rc"; then skip "claude-setup in $(basename "$rc")"
  else printf '\n# Claude Code one-command setup\n%s\n' "$alias_line" >>"$rc" && ok "added claude-setup to $(basename "$rc")"; fi
done

# --- Summary -----------------------------------------------------------------
step "Summary"
echo "  Not scriptable — connect these in your claude.ai account if you use them:"
echo "  claude.ai connectors (Claude Docs, GitHub, Slack, ...) and claude.ai plugins."
if [ "${#FAILED[@]}" -eq 0 ]; then
  ok "Done. Restart Claude Code (and open a new terminal) to load everything."
else
  printf '\n  \033[31m%s item(s) failed:\033[0m\n' "${#FAILED[@]}"
  for f in "${FAILED[@]}"; do printf '    - %s\n' "$f"; done
  exit 1
fi

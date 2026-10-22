---
name: claude-setup
description: Run or maintain Gagik's one-command Claude Code setup (the ~/claude-setup repo and the `claude-setup` shell command). Use when the user asks to set up Claude on this machine, or asks to add/remove anything global — a skill, agent, slash command, MCP server, plugin, setting or global CLAUDE.md rule — so it is also recorded in the setup repo.
---

# claude-setup

`~/claude-setup` is a git repo that reproduces this Claude Code setup on any PC with one command: `claude-setup` (a shell alias for `bash ~/claude-setup/setup.sh`). The repo is the source of truth; `setup.sh` applies it to `~/.claude` and is safe to re-run.

## Running it

- `claude-setup` — pull the repo, install anything missing, apply config files.
- `claude-setup --update` — also reinstall template skills to their latest versions.
- `claude-setup --no-pull` — apply the local copy without pulling.

It doesn't log in to Claude and can't add claude.ai account connectors/plugins; those come with the user's claude.ai account.

## Repo layout

| What | Where in `~/claude-setup` |
|---|---|
| Skills from claude-code-templates (`npx claude-code-templates --skill X`) | `skills.txt` — one `category/name` per line |
| Custom skills | `config/skills/<name>/SKILL.md` (+ files) |
| Agents (subagents) | `config/agents/<name>.md` |
| Slash commands | `config/commands/<name>.md` |
| Plugin marketplaces | `marketplaces.txt` — `owner/repo`, URL or path |
| Plugins | `plugins.txt` — `plugin@marketplace` |
| MCP servers (user scope) | `mcp.json` → `mcpServers` (same shape as `.mcp.json`) |
| Settings | `config/settings.json` — deep-merged into `~/.claude/settings.json` |
| Global instructions | `config/CLAUDE.md` — copied to `~/.claude/CLAUDE.md` |

## Adding something global (do this every time)

When the user asks to add or change anything global, keep the repo in sync — the command stays the same, only its contents grow:

1. **Record it in the repo** at the path in the table above. Edit the repo copy (`config/CLAUDE.md`, `config/skills/...`), never only `~/.claude/...`, or the next run overwrites it.
   - MCP secrets: never write real keys in `mcp.json`. Use `"${ENV_VAR}"` placeholders and tell the user which env var to export before running setup.
   - Settings: put only portable settings in `config/settings.json` — no machine paths, no secrets.
2. **Apply it**: `bash ~/claude-setup/setup.sh --no-pull`. Check the output shows it installed (✔) or skipped as already present (·), with no ✘.
3. **Commit and push** the repo using the `git-commit` skill style, e.g. `Feat: add senior-devops skill`, `Feat: add sentry mcp server`, `Chore: enable dark theme`. Push if `origin` is set; if not, say the change is only local.

## Removing something

`setup.sh` only adds. To remove: delete the entry from the repo, uninstall it here too (`rm -rf ~/.claude/skills/<name>`, `claude plugin uninstall <plugin>`, `claude mcp remove --scope user <name>`, ...), then commit (`Chore: remove X`) and push. Tell the user other PCs keep the old item until removed there.

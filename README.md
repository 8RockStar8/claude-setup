# claude-setup

My Claude Code setup — skills, plugins, MCP servers, agents, slash commands, settings and global `CLAUDE.md` — installed on any PC with one command.

## New PC

Requirements: [Claude Code](https://claude.com/claude-code), [Node.js](https://nodejs.org), git. On Windows, use WSL or Git Bash.

```bash
git clone https://github.com/8RockStar8/claude-setup.git ~/claude-setup && bash ~/claude-setup/setup.sh
```

The repo is public, so no GitHub login is needed to install. Then open a new terminal and restart Claude Code. From now on just run:

```bash
claude-setup
```

## Commands

| Command | What it does |
|---|---|
| `claude-setup` | Pull the latest version of this repo, install what's missing, apply config |
| `claude-setup --update` | Same, plus reinstall template skills to their latest versions |
| `claude-setup --no-pull` | Apply the local copy without pulling |

It's safe to run any time: installed things are skipped, and `CLAUDE.md` / `settings.json` are backed up to `~/.claude/backups/claude-setup/` before they change.

## What's inside

| File | Contents |
|---|---|
| `skills.txt` | Skills from [claude-code-templates](https://aitmpl.com) |
| `config/skills/` | My own skills (`git-commit`, `claude-setup`) |
| `config/agents/` | Subagents |
| `config/commands/` | Slash commands |
| `marketplaces.txt`, `plugins.txt` | Plugin marketplaces and plugins |
| `mcp.json` | MCP servers (user scope). Secrets as `${ENV_VAR}` — export them before running |
| `config/settings.json` | Settings merged into `~/.claude/settings.json` |
| `config/CLAUDE.md` | Global instructions, copied to `~/.claude/CLAUDE.md` |

## Not covered

- Logging in to Claude Code (`claude` → `/login`).
- claude.ai account connectors and plugins (Claude Docs, GitHub, Slack, ...) — connect them in claude.ai settings.
- If template skills fail with a GitHub rate limit, run `claude-setup` again later.

## Adding things

Ask Claude to add a skill, agent, MCP server, plugin or setting "globally". It records it here, applies it, commits and pushes (see `config/skills/claude-setup/SKILL.md`). On other PCs, run `claude-setup` to get it.

Pushing needs GitHub access. To push from a PC that installed over HTTPS, add its SSH key to GitHub, then:

```bash
git -C ~/claude-setup remote set-url origin git@github.com:8RockStar8/claude-setup.git
```

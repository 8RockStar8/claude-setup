# Global instructions

## "You are done" → commit and push

When I say **"You are done"** (in any project, any wording of case/punctuation), that is my standing approval to commit all changes and push to the **current branch**. Do it without asking again, following the `git-commit` skill (`~/.claude/skills/git-commit/SKILL.md`) for the workflow and message style.

If the commit or push fails (hooks, conflicts, rejected push), stop and tell me — don't force-push. If there is nothing to commit, just say so.

## Commit message style

Every commit (not only "You are done") uses: `Type: short imperative description` — e.g. `Feat: add login form`, `Validate: login form`, `Refactor: modal component`, `Fix: ...`, `Bug: ...`. Full type list and rules are in the `git-commit` skill.

## Global setup lives in ~/claude-setup

My whole Claude Code setup (skills, agents, slash commands, MCP servers, plugins, settings, this file) is kept in the `~/claude-setup` repo and installed on any PC with one command: `claude-setup`.

Whenever I ask to add, change or remove anything global, also record it in `~/claude-setup`, apply it, commit, rebuild `~/claude-setup/claude-setup.zip` and push that repo (if the push fails, the updated zip is enough) — follow the `claude-setup` skill. This is my standing approval for those commits and pushes. Edit this file at `~/claude-setup/config/CLAUDE.md`, not `~/.claude/CLAUDE.md` (setup copies it over).

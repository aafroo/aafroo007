#!/bin/bash
# SessionStart hook for Claude Code cloud sessions.
# Each cloud container starts with an empty ~/.claude, so this restores the
# web-dev toolchain declared for this repo:
#   - superpowers@claude-plugins-official   (obra/superpowers)
#   - frontend-design@claude-plugins-official (anthropics, frontend-design)
#   - gstack (garrytan/gstack) in ~/.claude/skills/gstack
# Idempotent: anything already installed is left alone.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

LOG="${TMPDIR:-/tmp}/claude-session-start.log"
: > "$LOG"
status=()

# --- Claude Code plugins (official Anthropic marketplace) -------------------
MARKETPLACE="claude-plugins-official"
if ! claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE"; then
  claude plugin marketplace add anthropics/claude-plugins-official >>"$LOG" 2>&1 || true
fi
installed="$(claude plugin list 2>/dev/null || true)"
for plugin in superpowers frontend-design; do
  if grep -q "$plugin@$MARKETPLACE" <<<"$installed"; then
    status+=("$plugin: ok")
  # User scope: installing at project scope would rewrite the committed
  # .claude/settings.json (which already enables the plugin) on every session.
  elif claude plugin install "$plugin@$MARKETPLACE" -s user >>"$LOG" 2>&1; then
    status+=("$plugin: installed")
  else
    status+=("$plugin: FAILED (see $LOG)")
  fi
done

# --- gstack (official install: clone to ~/.claude/skills/gstack + ./setup) --
GSTACK_DIR="$HOME/.claude/skills/gstack"
if [ -x "$GSTACK_DIR/browse/dist/browse" ]; then
  status+=("gstack: ok")
else
  if [ ! -d "$GSTACK_DIR/.git" ]; then
    rm -rf "$GSTACK_DIR"
    git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git "$GSTACK_DIR" >>"$LOG" 2>&1 || true
  fi
  if [ -x "$GSTACK_DIR/setup" ] && (cd "$GSTACK_DIR" && ./setup --team </dev/null) >>"$LOG" 2>&1; then
    status+=("gstack: installed")
  else
    status+=("gstack: FAILED (see $LOG)")
  fi
fi

summary="$(printf '%s; ' "${status[@]}")"
echo "Web-dev toolchain: ${summary%; }"

# Plugins installed by this hook load only from the next session. Until then,
# point Claude at their skill files so the workflow in CLAUDE.md still works.
if grep -qE '(superpowers|frontend-design): installed' <<<"$summary"; then
  echo "Plugins installed during this session are not registered as Skills yet."
  echo "Until the next session, Read the SKILL.md files directly from:"
  echo "  $HOME/.claude/plugins/cache/$MARKETPLACE/<plugin>/<version>/skills/<skill>/SKILL.md"
fi

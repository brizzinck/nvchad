#!/usr/bin/env bash
# agentdash-hook — append one agent lifecycle event (Claude Code / Codex hooks JSON on
# stdin) to the agentdash event log. Never blocks the agent: always exit 0.
#   AGENTDASH_AGENT   "claude" | "codex" | ... (set in the hook command)
#   TMUX_PANE         inherited from the agent's pane, used to jump back to it
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agentdash"
mkdir -p "$STATE_DIR" 2>/dev/null
jq -c --arg agent "${AGENTDASH_AGENT:-unknown}" --arg pane "${TMUX_PANE:-}" \
  '. + {ts: now, agent: $agent, tmux_pane: $pane}' 2>/dev/null \
  >> "$STATE_DIR/events.jsonl"
exit 0

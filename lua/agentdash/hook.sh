#!/usr/bin/env bash
# agentdash-hook — append one agent lifecycle event (Claude Code / Codex hooks JSON on
# stdin) to the agentdash event log. Never blocks the agent: always exit 0.
#   AGENTDASH_AGENT   "claude" | "codex" | ... (set in the hook command)
#   TMUX_PANE         inherited from the agent's pane, used to jump back to it
# The payload is slimmed to what store.lua reads (tool_response / full tool_input / huge
# prompts made the log grow to hundreds of MB, and every nvim polls + decodes it), appends
# are serialized with flock so concurrent hooks can't interleave, and the log is rotated.
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agentdash"
LOG="$STATE_DIR/events.jsonl"
MAX_BYTES=$((5 * 1024 * 1024))
mkdir -p "$STATE_DIR" 2>/dev/null

line=$(jq -c --arg agent "${AGENTDASH_AGENT:-unknown}" --arg pane "${TMUX_PANE:-}" '
  def cut($n): if type == "string" then .[0:$n] else . end;
  del(.tool_response)
  | (if .tool_input then .tool_input |= (if type == "object"
      then {file_path, path, pattern, command: (.command | cut(200)), description: (.description | cut(200))} | with_entries(select(.value != null))
      else null end) else . end)
  | (if .prompt then .prompt |= cut(2000) else . end)
  | (if .user_input then .user_input |= cut(2000) else . end)
  | (if .last_assistant_message then .last_assistant_message |= cut(2000) else . end)
  | . + {ts: now, agent: $agent, tmux_pane: $pane}' 2>/dev/null)
[ -n "$line" ] || exit 0

{
  flock 9
  if [ "$(stat -c %s "$LOG" 2>/dev/null || echo 0)" -gt "$MAX_BYTES" ]; then
    mv -f "$LOG" "$LOG.1"
  fi
  printf '%s\n' "$line" >> "$LOG"
} 9>>"$STATE_DIR/.lock"
exit 0

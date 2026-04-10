#!/bin/bash

# ==============================================================================
# chat-pick.sh — fzf picker for llm chat logs
# ==============================================================================

export LOG_DIR="$HOME/.llm"
export CHAT_HISTORY_PREVIEW="${CHAT_HISTORY_PREVIEW:-10}"
export CHAT_SH="/home/ed/code/projects/llm-localchat.sh"

# shellcheck source=/dev/null
[ -f "$CHAT_SH" ] && source "$CHAT_SH"

# Helper functions for the UI
_render_jsonl() {
  local jsonl_file="$1"
  [ -f "$jsonl_file" ] || return 1
  jq -r 'if .role == "user" then "\n[you]\n" + .content else "\n[gemma]\n" + .content end' "$jsonl_file"
}

_render_last_n() {
  local jsonl_file="$1"
  local n="$2"
  [ -f "$jsonl_file" ] || return 1
  tail -n "$n" "$jsonl_file" | jq -r 'if .role == "user" then "\n[you]\n" + .content else "\n[gemma]\n" + .content end'
}

_build_list() {
  for meta in "$LOG_DIR"/*.meta; do
    [ -f "$meta" ] || continue
    local title created last_used last_used_epoch
    title=$(grep '^title=' "$meta" | cut -d= -f2-)
    created=$(grep '^created=' "$meta" | cut -d= -f2-)
    last_used=$(grep '^last_used=' "$meta" | cut -d= -f2-)
    [ -z "$last_used" ] && last_used="$created"
    last_used_epoch=$(date -d "$last_used" +%s 2>/dev/null || echo 0)
    printf "%s\t%s\t%s\t%s\n" "$last_used_epoch" "$title" "$created" "$last_used"
  done | sort -rn | cut -f2-
}

_tui_repl() {
  local topic="$1"
  local log_file="${LOG_DIR}/$(_sanitise "$topic").jsonl"
  clear
  echo "════════════════════════════════════════════════════"
  echo "  chat: $topic"
  echo "  ctrl+c or type 'quit' to exit"
  echo "════════════════════════════════════════════════════"
  if [ -f "$log_file" ]; then
    _render_last_n "$log_file" "$CHAT_HISTORY_PREVIEW"
    echo "════════════════════════════════════════════════════"
  fi
  # repl loop
  while true; do
    echo "[YOU] (Ctrl+D to send, 'quit' to exit):"

    # Read everything until EOF (Ctrl+D)
    user_input=$(cat)

    # Check for exit commands on a single line
    if [[ "$user_input" == "quit" || "$user_input" == "exit" ]]; then
      echo "bye"
      break
    fi

    [[ -z "$user_input" ]] && continue

    _send "$topic" "$user_input"
  done
}

_open_nvim() {
  local topic="$1"
  local log_file="${LOG_DIR}/$(_sanitise "$topic").jsonl"
  local tmp_file="/tmp/llm-chat-${topic// /_}.md"
  {
    echo "# $topic"
    echo ""
    _render_jsonl "$log_file"
  } >"$tmp_file"
  nvim "+normal G" "$tmp_file" </dev/tty
}

_fzf_preview() {
  local topic="$1"
  local log_file="${LOG_DIR}/$(_sanitise "$topic").jsonl"
  local meta_file="${LOG_DIR}/$(_sanitise "$topic").meta"

  # Basic Metadata
  local model=$(grep '^model=' "$meta_file" | cut -d= -f2-)
  local turns=$(wc -l <"$log_file" 2>/dev/null || echo 0)

  echo "════════════════════════════════════════"
  echo "  $topic ($model)"
  echo "  turns: $turns"
  echo "════════════════════════════════════════"
  _render_jsonl "$log_file"
}

export -f _fzf_preview _render_jsonl _sanitise _open_nvim _render_last_n

chat_pick() {
  local list=$(_build_list)
  [[ -z "$list" ]] && echo "no chats yet" && return

  # We REMOVE the --bind for ctrl-p here so it doesn't double-fire.
  mapfile -t out < <(echo "$list" | fzf \
    --ansi \
    --delimiter $'\t' \
    --with-nth="1,2,3" \
    --prompt="  chat > " \
    --header="enter: repl  |  ctrl-p: nvim  |  ctrl-o: send single message" \
    --header-first \
    --preview-window="right:50%:wrap:follow" \
    --preview='_fzf_preview "{1}"' \
    --expect="enter,ctrl-p,ctrl-o")

  local key="${out[0]}"
  local selection="${out[1]}"
  [[ -z "$selection" ]] && return

  # Extract the topic from the selection line
  local topic=$(echo "$selection" | cut -f1)

  # This is much more stable than nesting processes inside fzf.
  case "$key" in
  ctrl-p)
    _open_nvim "$topic"
    ;;
  ctrl-o)
    read -rp "chat [$topic] > " message
    if [ -n "$message" ]; then
      _send "$topic" "$message"
    fi
    ;;
  enter | "") # "" handles the case where someone just hits enter and fzf returns nothing for the key
    _tui_repl "$topic"
    ;;
  esac
}

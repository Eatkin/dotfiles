#!/bin/bash

# ==============================================================================
# chat.sh — local ollama chat manager
# ==============================================================================
# usage:
#   source chat.sh
#   chat --new                        create a new chat (prompts for title)
#   chat --id <topic> "<message>"     send a message to an existing chat
#   chat --list                       list all chats (plain, no fzf yet)
# ==============================================================================

LOG_DIR="$HOME/.llm"
MODEL="${OLLAMA_MODEL:-gemma4:e2b}"
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"

# ------------------------------------------------------------------------------
# internal utils
# ------------------------------------------------------------------------------

_setup_dir() {
  mkdir -p "$LOG_DIR"
}

_sanitise() {
  echo "$1" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]_-'
}

_log_path() {
  echo "${LOG_DIR}/$(_sanitise "$1").jsonl"
}

_meta_path() {
  echo "${LOG_DIR}/$(_sanitise "$1").meta"
}

# ------------------------------------------------------------------------------
# new chat
# ------------------------------------------------------------------------------

_new_chat() {
  read -rp "chat title: " title

  if [ -z "$title" ]; then
    echo "error: title cannot be empty" >&2
    return 1
  fi

  local log_file meta_file
  log_file=$(_log_path "$title")
  meta_file=$(_meta_path "$title")

  if [ -f "$log_file" ]; then
    read -rp "chat '${title}' already exists, overwrite? (y/N): " confirm
    [[ ! "$confirm" =~ ^[Yy]$ ]] && echo "aborted" && return 1
    rm "$log_file" "$meta_file" 2>/dev/null
  fi

  # write meta file (for fzf later)
  echo "title=${title}" >"$meta_file"
  echo "created=$(date -Iseconds)" >>"$meta_file"
  echo "model=${MODEL}" >>"$meta_file"

  # touch the jsonl file
  touch "$log_file"

  echo "created: $log_file"
}

# ------------------------------------------------------------------------------
# send message
# ------------------------------------------------------------------------------

_send() {
  local topic="$1"
  local user_message="$2"

  local log_file
  log_file=$(_log_path "$topic")

  if [ ! -f "$log_file" ]; then
    echo "error: no chat found for '${topic}'" >&2
    return 1
  fi

  # Append user message safely
  jq -cn --arg content "$user_message" '{"role":"user","content":$content}' >>"$log_file"

  # Build request payload directly from the log file
  # This is more efficient than loading it into a bash variable first
  local payload
  payload=$(jq -s --arg model "$MODEL" \
    '{"model": $model, "messages": ., "stream": false}' "$log_file")

  echo "thinking..." >&2

  # Call ollama
  local raw_response
  raw_response=$(curl -sf "${OLLAMA_URL}/api/chat" \
    -H "Content-Type: application/json" \
    -d "$payload")

  if [ $? -ne 0 ] || [ -z "$raw_response" ]; then
    echo "error: ollama request failed" >&2
    # Rollback last line
    sed -i '$d' "$log_file"
    return 1
  fi

  echo ""
  echo "[ROBOT]"
  echo ""
  # Extract and Save Assistant response in ONE jq hit
  # This ensures the version saved to disk is perfectly escaped JSON
  local assistant_entry
  assistant_entry=$(echo "$raw_response" | jq -c '{role: .message.role, content: .message.content}')

  if [ -z "$assistant_entry" ] || [ "$assistant_entry" == "null" ]; then
    echo "error: could not parse assistant response" >&2
    return 1
  fi

  echo "$assistant_entry" >>"$log_file"

  # Update meta
  local meta_file
  meta_file=$(_meta_path "$topic")
  if [ -f "$meta_file" ]; then
    # Efficient in-place update
    sed -i '/^last_used=/d' "$meta_file"
    echo "last_used=$(date -Iseconds)" >>"$meta_file"
  fi

  # Print for the user (using -r to make it readable in terminal)
  echo ""
  echo "$assistant_entry" | jq -r '.content'
  echo ""
}

export -f _send

# ------------------------------------------------------------------------------
# list chats
# ------------------------------------------------------------------------------

_list_chats() {
  local found=0
  for meta in "$LOG_DIR"/*.meta; do
    [ -f "$meta" ] || continue
    found=1
    local title created
    title=$(grep '^title=' "$meta" | cut -d= -f2-)
    created=$(grep '^created=' "$meta" | cut -d= -f2-)
    local turns=0
    local log_file
    log_file=$(_log_path "$title")
    [ -f "$log_file" ] && turns=$(wc -l <"$log_file")
    printf "  %-30s  %s  (%s turns)\n" "$title" "$created" "$turns"
  done
  [ $found -eq 0 ] && echo "no chats yet — run: chat --new"
}

# ------------------------------------------------------------------------------
# main entrypoint
# ------------------------------------------------------------------------------

chat() {
  _setup_dir

  case "$1" in
  --new)
    _new_chat
    ;;
  --list)
    _list_chats
    ;;
  --id)
    if [ -z "$2" ] || [ -z "$3" ]; then
      echo "usage: chat --id <topic> \"<message>\"" >&2
      return 1
    fi
    _send "$2" "$3"
    ;;
  *)
    echo "usage:"
    echo "  chat --new                       create a new chat"
    echo "  chat --id <topic> \"<message>\"    send a message"
    echo "  chat --list                      list all chats"
    ;;
  esac
}

# ------------------------------------------------------------------------------
# init
# ------------------------------------------------------------------------------

_setup_dir

if ! command -v ollama &>/dev/null; then
  echo "warning: ollama not found in PATH" >&2
fi

if ! command -v jq &>/dev/null; then
  echo "warning: jq not found — install with: sudo apt install jq" >&2
fi

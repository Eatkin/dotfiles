_yt_token() {
  local config=~/.config/youtube
  local client_secret="$config/client_secret.json"
  local refresh_token_file="$config/refresh_token"

  [[ ! -f "$client_secret" ]] && {
    echo "missing $client_secret" >&2
    return 1
  }
  [[ ! -f "$refresh_token_file" ]] && {
    echo "missing $refresh_token_file - run youtube-auth" >&2
    return 1
  }

  local client_id client_secret_val refresh_token
  client_id=$(jq -r '.installed.client_id' "$client_secret")
  client_secret_val=$(jq -r '.installed.client_secret' "$client_secret")
  refresh_token=$(cat "$refresh_token_file")

  curl -sf -X POST "https://oauth2.googleapis.com/token" \
    -d "client_id=${client_id}&client_secret=${client_secret_val}&refresh_token=${refresh_token}&grant_type=refresh_token" |
    jq -r '.access_token'
}

ytsync() {
  local token config=~/.config/youtube
  local subs_file="$config/subs.json"

  token=$(_yt_token) || return 1

  echo "fetching subscriptions..."

  local all_items='[]'
  local page_token=""

  while true; do
    local url="https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&mine=true&maxResults=50"
    [[ -n "$page_token" ]] && url="${url}&pageToken=${page_token}"

    local data
    data=$(curl -sf -H "Authorization: Bearer ${token}" "$url") || {
      echo "api request failed"
      return 1
    }

    all_items=$(echo "$all_items $data" | jq -s '
      .[0] + [.[1].items[] | {
        channel_id: .snippet.resourceId.channelId,
        name: .snippet.title
      }]
    ')

    page_token=$(echo "$data" | jq -r '.nextPageToken // empty')
    [[ -z "$page_token" ]] && break
  done

  echo "$all_items" >"$subs_file"
  echo "saved $(echo "$all_items" | jq 'length') subscriptions to $subs_file"
}

_yt_parse_rss() {
  # called via xargs -P, args: channel_id channel_name
  local channel_id="$1" channel_name="$2"
  local url="https://www.youtube.com/feeds/videos.xml?channel_id=${channel_id}"

  local xml
  xml=$(curl -sf "$url") || return 0 # silently skip dead channels

  python3 - <<EOF
import xml.etree.ElementTree as ET
import json, sys

ns = {
  'atom': 'http://www.w3.org/2005/Atom',
  'yt':   'http://www.youtube.com/xml/schemas/2015',
  'media':'http://search.yahoo.com/mrss/',
}

try:
  root = ET.fromstring("""${xml//\"/\\\"}""")
except ET.ParseError:
  sys.exit(0)

entries = root.findall('atom:entry', ns)[:5]
for e in entries:
  title     = e.findtext('atom:title', '', ns)
  video_id  = e.findtext('yt:videoId', '', ns)
  published = e.findtext('atom:published', '', ns)
  url       = f"https://www.youtube.com/watch?v={video_id}"
  print(json.dumps({
    "channel": "${channel_name}",
    "title":   title,
    "url":     url,
    "published": published,
  }))
EOF
}

export -f _yt_parse_rss

ytfetch() {
  local config=~/.config/youtube
  local subs_file="$config/subs.json"
  local cache_file="$config/feed_cache.json"

  [[ ! -f "$subs_file" ]] && {
    echo "no subs cache"
    return 1
  }

  echo "fetching RSS feeds..."

  local results
  results=$(jq -r '.[] | "\(.channel_id)|\(.name)"' "$subs_file" |
    xargs -P 20 -d$'\n' -I {} bash -c '
      IFS="|" read -r id name <<< "{}"
      _yt_parse_rss "$id" "$name"
    ')

  echo "$results" | jq -s 'sort_by(.published) | reverse' >"$cache_file"
  echo "cached $(jq 'length' "$cache_file") videos to $cache_file"
}

export -f _yt_parse_rss
export -f ytfetch

_gen_list() {
  local cache_file="$HOME/.config/youtube/feed_cache.json"
  jq -r '.[] | "\(.published[:10])\t\(.channel)\t\(.title)\t\(.url)"' "$cache_file"
}
export -f _gen_list

ytfeed() {
  local cache_file="$HOME/.config/youtube/feed_cache.json"

local selected=$(_gen_list |
    fzf --ansi \
      --header "CTRL+j/k / arrow keys: Move | CTRL+R: Reload feed | CTRL-U/D: Scroll Preview | ENTER: Play | ESC: Quit" \
      --delimiter $'\t' \
      --with-nth 1..3 \
      --preview 'echo -e "Date: {1}\nChannel: {2}\nTitle: {3}\n\nURL: {4}"' \
      --bind "ctrl-r:reload(bash -c 'ytfetch > /dev/null 2>&1 && _gen_list')" \
      --bind "ctrl-u:half-page-up" \
      --bind "ctrl-d:half-page-down" \
      --bind "q:abort" \
      --bind "ctrl-j:down" \
      --bind "ctrl-k:up")

  if [[ -n "$selected" ]]; then
    # Grab the 4th tab-separated field (the URL)
    local url=$(echo "$selected" | cut -f4)
    echo "Playing: $url"
    mpv-yt "$url"
  fi
}

mpv-yt() {
  [[ -z "$1" ]] && {
    echo "usage: mpv-yt <url>"
    return 1
  }
  mpv --ytdl-format="bestvideo[height<=1080]+bestaudio/best" "$1"
}

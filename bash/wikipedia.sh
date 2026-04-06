wikifeatured() {
  local date data title extract page_url

  date=$(date +%Y/%m/%d)
  data=$(curl -sf -A "wikitoday/1.0" "https://api.wikimedia.org/feed/v1/wikipedia/en/featured/${date}") || {
    echo "couldn't fetch featured article"
    return 1
  }

  title=$(echo "$data" | jq -r '.tfa.normalizedtitle')
  extract=$(echo "$data" | jq -r '.tfa.extract' | fold -sw 80 | head -n 6)
  page_url=$(echo "$data" | jq -r '.tfa.content_urls.desktop.page')

  echo
  echo -e "\033[1;33m📖 today's featured article\033[0m"
  echo -e "\033[1;37m${title}\033[0m"
  echo "────────────────────────────────────────"
  echo "$extract"
  echo
  echo -e "\033[2m${page_url}\033[0m"
  echo
}

wikiinteresting() {
  local date data article_title extract page_url

  # random date in the last year
  date=$(date -d "$(shuf -i 1-365 -n 1) days ago" +%Y/%m/%d)

  data=$(curl -sf -A "wikiinteresting/1.0" \
    "https://wikimedia.org/api/rest_v1/metrics/pageviews/top/en.wikipedia.org/all-access/${date}") || {
    echo "couldn't fetch top articles"
    return 1
  }

  # pick random from top 50, skip Main_Page and special pages
  article_title=$(echo "$data" | jq -r --argjson idx "$(shuf -i 0-49 -n 1)" '
    .items[0].articles
    | map(select(.article | test("^(Main_Page|Special:|Wikipedia:|Portal:)") | not))
    | .[$idx].article
  ')

  [[ -z "$article_title" || "$article_title" == "null" ]] && {
    echo "couldn't pick an article, try again"
    return 1
  }

  # fetch the extract
  data=$(curl -sf -A "wikiinteresting/1.0" \
    "https://en.wikipedia.org/api/rest_v1/page/summary/${article_title}") || {
    echo "couldn't fetch article"
    return 1
  }

  local title extract page_url
  title=$(echo "$data" | jq -r '.titles.normalized')
  extract=$(echo "$data" | jq -r '.extract' | fold -sw 80 | head -n 5)
  page_url=$(echo "$data" | jq -r '.content_urls.desktop.page')

  echo
  echo -e "\033[1;36m🎲 interesting article\033[0m"
  echo -e "\033[1;37m${title}\033[0m"
  echo "────────────────────────────────────────"
  echo "$extract"
  echo
  echo -e "\033[2m${page_url}\033[0m"
  echo
}

wikitoday() {
  local month day data event article title extract page_url year

  month=$(date +%m)
  day=$(date +%d)

  data=$(curl -sf -A "wikitoday/1.0" \
    "https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/selected/${month}/${day}") || {
    echo "couldn't fetch on this day"
    return 1
  }

  # pick a random selected event
  local count idx
  count=$(echo "$data" | jq '.selected | length')
  idx=$(shuf -i 0-$((count - 1)) -n 1)

  event=$(echo "$data" | jq --argjson i "$idx" '.selected[$i]')
  year=$(echo "$event" | jq -r '.year')
  text=$(echo "$event" | jq -r '.text')

  # grab the first linked article that has an extract
  article=$(echo "$event" | jq -r '.pages[] | select(.extract != null and .extract != "") | select(.namespace.id == 0)' | jq -rs '.[0]')

  title=$(echo "$article" | jq -r '.titles.normalized')
  extract=$(echo "$article" | jq -r '.extract' | fold -sw 80 | head -n 5)
  page_url=$(echo "$article" | jq -r '.content_urls.desktop.page')

  echo
  echo -e "\033[1;33m📅 on this day\033[0m"
  echo -e "\033[2m${year}\033[0m \033[1;37m${text}\033[0m" | fold -sw 80
  echo "────────────────────────────────────────"
  echo "$extract"
  echo
  echo -e "\033[2m${page_url}\033[0m"
  echo
}

#!/usr/bin/env zsh
set -euo pipefail

# Executes one Notion API request with bounded retry/backoff for transient failures.
# Example: notion_api_request "GET" "https://api.notion.com/v1/blocks/$id/children" "$token"
notion_api_request() {
  local method="$1"
  local url="$2"
  local token="$3"
  local data="${4-}"
  local max_attempts=3
  local attempt=1
  local response=""
  local curl_exit=0

  while [[ "$attempt" -le "$max_attempts" ]]; do
    if [[ -n "$data" ]]; then
      set +e
      response="$(curl -sS -X "$method" "$url" \
        -H "Authorization: Bearer $token" \
        -H "Notion-Version: 2022-06-28" \
        -H "Content-Type: application/json" \
        --data "$data")"
      curl_exit=$?
      set -e
    else
      set +e
      response="$(curl -sS -X "$method" "$url" \
        -H "Authorization: Bearer $token" \
        -H "Notion-Version: 2022-06-28")"
      curl_exit=$?
      set -e
    fi

    if [[ "$curl_exit" -eq 0 ]]; then
      if printf '%s' "$response" | jq -e '.object == "error" and (.code == "rate_limited" or .code == "service_unavailable" or .code == "internal_server_error")' >/dev/null 2>&1; then
        if [[ "$attempt" -lt "$max_attempts" ]]; then
          sleep "$attempt"
          attempt=$((attempt + 1))
          continue
        fi
      fi
      echo "$response"
      return 0
    fi

    if [[ "$attempt" -lt "$max_attempts" ]]; then
      sleep "$attempt"
      attempt=$((attempt + 1))
      continue
    fi

    echo "Error: Notion API request failed after $max_attempts attempts: $method $url" >&2
    return 1
  done
}

# Queries a database and follows pagination until all results are aggregated.
# Example: notion_query_all "$database_id" "$token" "$filter_payload"
notion_query_all() {
  local database_id="$1"
  local token="$2"
  local filter_payload="$3"
  local cursor=""
  local all='[]'
  local response page_results has_more

  while true; do
    local payload="$filter_payload"
    if [[ -n "$cursor" ]]; then
      payload="$(printf '%s' "$filter_payload" | jq -c --arg cursor "$cursor" '. + {start_cursor: $cursor}')"
    fi
    response="$(notion_api_request "POST" "https://api.notion.com/v1/databases/$database_id/query" "$token" "$payload")" || return 1
    if printf '%s' "$response" | jq -e '.object == "error"' >/dev/null; then
      echo "$response"
      return 0
    fi
    page_results="$(printf '%s' "$response" | jq '.results')"
    all="$(jq -n --argjson a "$all" --argjson b "$page_results" '$a + $b')"
    has_more="$(printf '%s' "$response" | jq -r '.has_more // false')"
    if [[ "$has_more" != "true" ]]; then
      break
    fi
    cursor="$(printf '%s' "$response" | jq -r '.next_cursor // empty')"
    if [[ -z "$cursor" ]]; then
      break
    fi
  done

  jq -n --argjson results "$all" '{results: $results}'
}

# Fetches all child block IDs across paginated children responses.
# Example: notion_fetch_all_children_ids "$page_id" "$token"
notion_fetch_all_children_ids() {
  local page_id="$1"
  local token="$2"
  local cursor=""
  local ids=()
  local response has_more

  while true; do
    local url="https://api.notion.com/v1/blocks/$page_id/children"
    if [[ -n "$cursor" ]]; then
      url="$url?start_cursor=$cursor"
    fi
    response="$(notion_api_request "GET" "$url" "$token")" || return 1
    if printf '%s' "$response" | jq -e '.object == "error"' >/dev/null; then
      echo "$response"
      return 0
    fi
    local page_ids
    page_ids="$(printf '%s' "$response" | jq -r '.results[].id')"
    if [[ -n "$page_ids" ]]; then
      ids+=("${(@f)page_ids}")
    fi
    has_more="$(printf '%s' "$response" | jq -r '.has_more // false')"
    if [[ "$has_more" != "true" ]]; then
      break
    fi
    cursor="$(printf '%s' "$response" | jq -r '.next_cursor // empty')"
    if [[ -z "$cursor" ]]; then
      break
    fi
  done

  printf "%s\n" "${ids[@]-}"
}

# Fetches all full child blocks across paginated children responses.
# Example: notion_fetch_all_children_blocks "$page_id" "$token"
notion_fetch_all_children_blocks() {
  local page_id="$1"
  local token="$2"
  local cursor=""
  local all='[]'
  local response page_results has_more

  while true; do
    local url="https://api.notion.com/v1/blocks/$page_id/children"
    if [[ -n "$cursor" ]]; then
      url="$url?start_cursor=$cursor"
    fi
    response="$(notion_api_request "GET" "$url" "$token")" || return 1
    if printf '%s' "$response" | jq -e '.object == "error"' >/dev/null; then
      echo "$response"
      return 0
    fi
    page_results="$(printf '%s' "$response" | jq '.results')"
    all="$(jq -n --argjson a "$all" --argjson b "$page_results" '$a + $b')"
    has_more="$(printf '%s' "$response" | jq -r '.has_more // false')"
    if [[ "$has_more" != "true" ]]; then
      break
    fi
    cursor="$(printf '%s' "$response" | jq -r '.next_cursor // empty')"
    if [[ -z "$cursor" ]]; then
      break
    fi
  done

  jq -n --argjson results "$all" '{results: $results}'
}

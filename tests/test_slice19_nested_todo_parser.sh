#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARSER="$ROOT_DIR/lib/notion_parser.py"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  local got="$1"
  local expected="$2"
  if [[ "$got" != "$expected" ]]; then
    fail "expected: $expected"$'\n'"got: $got"
  fi
}

[[ -f "$PARSER" ]] || fail "missing parser: $PARSER"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
input_md="$tmp_dir/nested-todos.md"

cat > "$input_md" <<'EOF'
### [toggle] task: feature implementation (1)

  - [ ] build out the following features:

    - [ ] spotlight

    - [ ] tabs

      - [ ] implement full page browser

    - [ ] tab management

### [toggle] misc (0)

  - [ ] learn basics of swift
EOF

json_out="$(python3 "$PARSER" "$input_md")"

heading_count="$(printf '%s' "$json_out" | jq '[.[] | select(.type == "heading_3")] | length')"
assert_eq "$heading_count" "2"

first_heading_child_count="$(printf '%s' "$json_out" | jq '.[0].heading_3.children | length')"
assert_eq "$first_heading_child_count" "1"

root_todo_text="$(printf '%s' "$json_out" | jq -r '.[0].heading_3.children[0].to_do.rich_text[0].text.content')"
assert_eq "$root_todo_text" "build out the following features:"

nested_todo_count="$(printf '%s' "$json_out" | jq '.[0].heading_3.children[0].to_do.children | length')"
assert_eq "$nested_todo_count" "3"

deep_todo_text="$(printf '%s' "$json_out" | jq -r '.[0].heading_3.children[0].to_do.children[1].to_do.children[0].to_do.rich_text[0].text.content')"
assert_eq "$deep_todo_text" "implement full page browser"

second_heading_todo_text="$(printf '%s' "$json_out" | jq -r '.[1].heading_3.children[0].to_do.rich_text[0].text.content')"
assert_eq "$second_heading_todo_text" "learn basics of swift"

echo "PASS: slice 19 nested todo parser"

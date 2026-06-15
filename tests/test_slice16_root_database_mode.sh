#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT_DIR/bin/ns"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "expected output to contain '$needle', got: $haystack"
  fi
}

assert_exit_code() {
  local got="$1"
  local expected="$2"
  if [[ "$got" -ne "$expected" ]]; then
    fail "expected exit code $expected, got $got"
  fi
}

[[ -x "$CLI" ]] || fail "missing executable: $CLI"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
notes_root="$tmp_dir/notes"
mkdir -p "$notes_root"

"$CLI" init --database-id db_tasks --notes-root "$notes_root" >/dev/null
printf -- "- [ ] inbox\n- [x] done\n" > "$notes_root/Tasks.md"

set +e
upload_out="$(cd "$notes_root" && "$CLI" upload --dry-run "Tasks.md" 2>&1)"
code=$?
set -e
assert_exit_code "$code" 0
assert_contains "$upload_out" "relation_page_id: <none>"
assert_contains "$upload_out" "action: query exact title; update if found else create"

set +e
download_out="$(cd "$notes_root" && "$CLI" download --dry-run "Tasks.md" 2>&1)"
code=$?
set -e
assert_exit_code "$code" 0
assert_contains "$download_out" "relation_property: <none>"
assert_contains "$download_out" "action: query exact title; overwrite local file if single match"

set +e
status_out="$(cd "$notes_root" && "$CLI" status "Tasks.md" 2>&1)"
code=$?
set -e
assert_exit_code "$code" 0
assert_contains "$status_out" "  Relation Page: <none>"
assert_contains "$status_out" "  Upload Intent: query exact title; update if found else create"
assert_contains "$status_out" "\"property\": \"Name\""
assert_contains "$status_out" "\"equals\": \"Tasks\""

echo "PASS: slice 16 root database mode"

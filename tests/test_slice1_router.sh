#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT_DIR/bin/notion"

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

if [[ ! -x "$CLI" ]]; then
  fail "missing executable: $CLI"
fi

# help with no args
set +e
out="$($CLI 2>&1)"
code=$?
set -e
assert_exit_code "$code" 1
assert_contains "$out" "Usage: notion <command>"

# explicit help
set +e
out="$($CLI help 2>&1)"
code=$?
set -e
assert_exit_code "$code" 0
assert_contains "$out" "Commands:"
assert_contains "$out" "upload"
assert_contains "$out" "download"

# unknown command
set +e
out="$($CLI frob 2>&1)"
code=$?
set -e
assert_exit_code "$code" 1
assert_contains "$out" "Unknown command: frob"

# dispatch smoke tests
for cmd in init link upload download; do
  set +e
  out="$($CLI "$cmd" --help 2>&1)"
  code=$?
  set -e
  assert_exit_code "$code" 0
  assert_contains "$out" "Usage: notion $cmd"
done

echo "PASS: slice 1 router contract"

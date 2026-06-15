#!/usr/bin/env zsh
set -euo pipefail

# Returns success when target file path is inside notes_root (supports canonical path fallback).
# Example: notion_ensure_path_inside_notes_root "$file_path" "$notes_root"
notion_ensure_path_inside_notes_root() {
  local target_path="$1"
  local notes_root="$2"

  local abs_target="${target_path:a}"
  local abs_notes_root="${notes_root:A}"

  if [[ "$abs_target" == "$abs_notes_root"/* ]]; then
    return 0
  fi

  local target_dir target_base
  target_dir="${abs_target%/*}"
  target_base="${abs_target##*/}"

  local canonical_notes_root canonical_target_dir canonical_target
  canonical_notes_root="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$abs_notes_root")"
  canonical_target_dir="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$target_dir")"
  canonical_target="$canonical_target_dir/$target_base"

  [[ "$canonical_target" == "$canonical_notes_root"/* ]]
}

# Returns file path relative to notes_root (supports canonical path fallback).
# Example: rel_path="$(notion_relative_path_under_notes_root "$file_path" "$notes_root")"
notion_relative_path_under_notes_root() {
  local target_path="$1"
  local notes_root="$2"

  local abs_target="${target_path:a}"
  local abs_notes_root="${notes_root:A}"

  if [[ "$abs_target" == "$abs_notes_root"/* ]]; then
    echo "${abs_target#$abs_notes_root/}"
    return 0
  fi

  local target_dir target_base
  target_dir="${abs_target%/*}"
  target_base="${abs_target##*/}"

  local canonical_notes_root canonical_target_dir canonical_target
  canonical_notes_root="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$abs_notes_root")"
  canonical_target_dir="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$target_dir")"
  canonical_target="$canonical_target_dir/$target_base"

  if [[ "$canonical_target" == "$canonical_notes_root"/* ]]; then
    echo "${canonical_target#$canonical_notes_root/}"
    return 0
  fi

  return 1
}

# Returns first-level directory segment for a file under notes_root.
# Example: seg="$(notion_first_segment_for_file "$file_path" "$notes_root")"
notion_first_segment_for_file() {
  local target_path="$1"
  local notes_root="$2"
  local rel

  rel="$(notion_relative_path_under_notes_root "$target_path" "$notes_root")" || return 1
  echo "${rel%%/*}"
}

# Returns success when a relative path points to a file directly under notes_root.
# Example: notion_is_root_level_relative_path "Tasks.md"
notion_is_root_level_relative_path() {
  local relative_path="$1"
  [[ "$relative_path" != */* ]]
}

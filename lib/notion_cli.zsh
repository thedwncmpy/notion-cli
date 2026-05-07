#!/usr/bin/env zsh
set -euo pipefail

notion_usage() {
  cat <<'USAGE'
Usage: notion <command> [options]

Commands:
  init       Initialize notion project config
  link       Map a first-level subdirectory to a Notion relation page id
  upload     Upload a markdown file to Notion
  download   Download a markdown file from Notion
  help       Show this help
USAGE
}

notion_init_usage() {
  echo "Usage: notion init --database-id <id> --notes-root <path> [--force]"
}

notion_link_usage() {
  echo "Usage: notion link <subdir> <relation_page_id> [--force]"
}

notion_upload_usage() {
  echo "Usage: notion upload <file.md>"
}

notion_download_usage() {
  echo "Usage: notion download <file.md>"
}

notion_cmd_init() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    notion_init_usage
    return 0
  fi

  echo "Error: 'notion init' is not implemented yet in this slice."
  echo "Run: notion init --help"
  return 1
}

notion_cmd_link() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    notion_link_usage
    return 0
  fi

  echo "Error: 'notion link' is not implemented yet in this slice."
  echo "Run: notion link --help"
  return 1
}

notion_cmd_upload() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    notion_upload_usage
    return 0
  fi

  echo "Error: 'notion upload' is not implemented yet in this slice."
  echo "Run: notion upload --help"
  return 1
}

notion_cmd_download() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    notion_download_usage
    return 0
  fi

  echo "Error: 'notion download' is not implemented yet in this slice."
  echo "Run: notion download --help"
  return 1
}

notion_main() {
  local cmd="${1:-}"
  if [[ -z "$cmd" ]]; then
    notion_usage
    return 1
  fi
  shift || true

  case "$cmd" in
    help|-h|--help)
      notion_usage
      ;;
    init)
      notion_cmd_init "$@"
      ;;
    link)
      notion_cmd_link "$@"
      ;;
    upload)
      notion_cmd_upload "$@"
      ;;
    download)
      notion_cmd_download "$@"
      ;;
    *)
      echo "Unknown command: $cmd"
      echo
      notion_usage
      return 1
      ;;
  esac
}

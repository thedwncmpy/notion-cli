# Slice 7: Roundtrip and Contract Test Harness

## Scope
Add a vertical-slice test harness that validates upload/download contract behavior and roundtrip expectations without requiring live Notion calls.

## What changed
- Added a new test: `tests/test_slice7_roundtrip_contract.sh`.
- Added shared parser-path helper in CLI: `notion_parser_path`.
- Updated both `notion_cmd_upload` and `notion_cmd_download` to use the shared parser-path helper.
- Fixed download relative-path derivation to avoid first-level mapping errors caused by mixed path representations (`/var/...` vs `/private/var/...`).

## Why this was needed
- Slice 7 requires a stable harness for contract-level behavior across upload/download.
- The new harness exposed a real bug where download could resolve the first segment as a filename instead of the mapped top-level directory.
- Centralizing parser-path resolution reduces drift risk between upload and download behavior.

## Test coverage added
`tests/test_slice7_roundtrip_contract.sh` validates:
- Upload success through parser/API contract stubs.
- Download overwrites existing local markdown when unique remote match exists.
- Download creates a missing local markdown file when unique remote match exists.

## Regression status
- `tests/test_slice7_roundtrip_contract.sh`: PASS
- `tests/test_slice4_credentials.sh`: PASS
- `tests/test_slice5_upload.sh`: PASS
- `tests/test_slice6_download.sh`: PASS
- `zsh -n lib/notion_cli.zsh`: PASS

## Related issue
- GitHub issue: #8

# Slice 2 Summary: Add Project Config Lifecycle (`init`)

Date: 2026-05-07
Issue: https://github.com/thedwncmpy/notion-cli/issues/3

## Delivered
- Implemented `notion init --database-id <id> --notes-root <path> [--force]`.
- Added strict flag validation for required arguments.
- Added config lifecycle behavior:
  - create new config when missing
  - fail on existing config without `--force`
  - overwrite existing config with `--force`
- Persisted config at `<notes_root>/.notion-cli/config.json`.

## Files Changed
- `lib/notion_cli.zsh`
- `tests/test_slice2_init.sh`

## Behavior Confirmed
- Missing `--database-id` fails non-zero with clear error.
- Missing `--notes-root` fails non-zero with clear error.
- First successful `init` creates `.notion-cli/config.json`.
- Re-running without `--force` fails and preserves existing config.
- Re-running with `--force` overwrites config.
- `notion init --help` exits zero.

## Test Evidence
- `./tests/test_slice1_router.sh` passes.
- `./tests/test_slice2_init.sh` passes.

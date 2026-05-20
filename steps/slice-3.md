# Slice 3 Summary: Add Relation Mapping Workflow (`link`)

Date: 2026-05-14
Issue: https://github.com/thedwncmpy/notion-cli/issues/4

## Delivered
- Implemented `notion link <subdir> <relation_page_id> [--force]`.
- Added project config discovery (searching upwards for `.notion-cli/config.json`).
- Added mapping lifecycle behavior:
  - Validate that the target subdirectory exists relative to `notes_root`.
  - Prevent re-mapping an existing directory without `--force`.
  - Update `mappings` object in `config.json` using `jq`.
- Preserved `notion link --help` behavior.

## Files Changed
- `lib/notion_cli.zsh`: Added `find_config` and implemented `notion_cmd_link`.
- `tests/test_slice3_link.sh`: New test suite for link workflow.

## Behavior Confirmed
- Running `notion link` without arguments fails with usage.
- Linking a non-existent directory fails with a clear error.
- Successfully linking a valid directory updates `config.json`.
- Overwriting an existing mapping requires `--force`.
- Fails with a clear error if run outside of a project (no config found).

## Test Evidence
- `./tests/test_slice1_router.sh` passes.
- `./tests/test_slice2_init.sh` passes.
- `./tests/test_slice3_link.sh` passes.

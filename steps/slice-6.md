# Slice 6 Summary: Ship Download Vertical Slice With Overwrite + Create Behavior

Date: 2026-05-20
Issue: (fill after creation)

## Goal
Implement `notion download <file.md>` with strict guardrails and remote-to-local sync behavior.

## Required Behavior
- Require `.md` input path.
- Require target path inside configured `notes_root`.
- Resolve relation from first-level segment and require mapping.
- Query by exact title + mapped relation.
- If local file exists and unique remote page exists: overwrite local file.
- If local file missing and unique remote page exists: create local file (including parent dirs).
- If no remote match: fail non-zero.
- If multiple matches: fail non-zero with ambiguity guidance.

## Files Involved
- `lib/notion_cli.zsh`
- `lib/notion_parser.py` (reverse conversion path)
- `tests/test_slice6_download.sh`

## Test Reference
- `./tests/test_slice6_download.sh`

## Notes
- This is a scaffold summary. Update with final implementation details and commit hash when slice 6 is complete.

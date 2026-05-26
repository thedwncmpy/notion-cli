# Notion CLI Roadmap: Next Changes and Features

Date: 2026-05-26

## Current Status

The MVP slices 1-8 are mostly implemented, with working router/init/link/credential flow/upload/download/homebrew scaffolding and contract tests. The CLI is functional, but there are hardening and release-readiness gaps.

## Key Gaps

1. `upload` create path hardcodes `"notebook"` instead of using mapped `relation_property`.
2. `tests/test_slice5_upload.sh` includes stray lines near the top, which weakens test reliability.
3. Homebrew formula still has placeholder `sha256`, so publish flow is incomplete.
4. API behavior is only partially contract-tested (limited pagination/live integration coverage).
5. CLI logic is still monolithic in `lib/notion_cli.zsh` instead of PRD-aligned modules.
6. Config versioning exists (`version: 1`) but no migration path is implemented.
7. Diagnostics can be improved to better match PRD intent (close-match guidance and clearer ambiguity help).

## Prioritized Roadmap

## P0: Correctness and Release Blocking

1. Fix relation property behavior in upload create path
- Update page-create payload to use configured `relation_property` instead of hardcoded `notebook`.
- Add regression test for non-default relation property on create path.

2. Stabilize test suite quality
- Remove accidental stray lines in `tests/test_slice5_upload.sh`.
- Run all slice tests and fix any regressions.

3. Complete Homebrew release path
- Cut tagged release tarball.
- Replace placeholder `sha256` in `Formula/notion.rb`.
- Validate clean-machine install + `notion help` smoke test.

## P1: Reliability Hardening

1. Improve Notion API robustness
- Add pagination handling where needed (query/children retrieval loops).
- Add retry/backoff for transient API/network failures.
- Improve HTTP/error diagnostics from `curl` responses.

2. Expand sync stress coverage
- Add tests for large notes (>100 blocks) for upload create and update.
- Add tests for download overwrite/create in deeper nested directories.

3. Strengthen config safety
- Add `notion config validate` (or equivalent internal validator).
- Validate mapping schema consistently (legacy string and object forms).

## P2: Maintainability and Developer Experience

1. Refactor to PRD-aligned modules
- Split monolithic CLI into modules:
  - command router
  - config repository
  - relation resolver
  - notion API client
  - sync engine
  - diagnostics
- Keep command surface unchanged.

2. Improve automation and documentation
- Add CI to run tests consistently.
- Add shell linting checks.
- Expand README troubleshooting and relation property examples.

3. Prepare config evolution
- Implement version migration scaffold for future schema updates.

## P3: Post-MVP Feature Additions

1. Add safe introspection commands
- `notion status <file.md>` to show resolved config/mapping/page lookup intent.
- Optional `--dry-run` for upload/download.

2. Improve sync safety UX
- Richer conflict/ambiguity reporting.
- Clearer remediation hints for mapping and title mismatches.

## Suggested Execution Sequence

1. P0 correctness fix + test cleanup.
2. P0 release artifact + formula finalization.
3. P1 reliability hardening and stress tests.
4. P2 module refactor with CI guardrails.
5. P3 quality-of-life command additions.

## Definition of Done (Near-Term)

1. All current slice tests pass reliably.
2. Upload/create respects configured relation property.
3. Homebrew formula has real release `sha256` and install is validated.
4. At least one large-note upload test and one nested-path download test are green.

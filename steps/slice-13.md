# Slice 13: Bash Compatibility

## Goal
Ensure `ns` works reliably when invoked from `bash`, not only `zsh`, and provide completion support for both shells.

## Scope
- Make launcher path resolution shell-agnostic.
- Support `ns completion bash` in addition to `ns completion zsh`.
- Keep existing zsh behavior unchanged.
- Add contract coverage for bash invocation and bash completion output.

## Acceptance Criteria
- Running `bash -lc 'ns help'` works.
- `ns completion bash` prints a valid bash completion function and registration line.
- Existing zsh completion behavior remains available.
- CI executes bash compatibility test.

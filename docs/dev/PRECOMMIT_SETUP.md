Pre-commit Hook Setup

To run fast local checks before each commit, use the repo installer (official path).

Official install (recommended):

```bash
bash tool/dev/install_hooks.sh
```

This installs `.git/hooks/pre-commit` to run the maintained sanity hook (`tool/dev/precommit_sanity.sh`).

Alternative (legacy/manual, not default):

Manually create `.git/hooks/pre-commit` only if you cannot use the installer. Prefer the installer so the hook content stays aligned with repo conventions.

That's it. The hook will print concise results:

- `FAST_LIVE: PASS/FAIL`
- `FAST_CONTENT: PASS/FAIL`

Commit aborts if any check fails.

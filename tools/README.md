# tools/ (SSOT)

This folder is the single source of truth for maintained developer/CI tooling scripts.

Rules:

- Add new maintained tools here (not under `tool/`).
- Keep behavior deterministic by default (explicit inputs/outputs, reproducible ordering).
- Avoid hidden side effects; require explicit flags for write/apply operations.
- Preserve backward compatibility when replacing legacy `tool/*` entrypoints (use thin wrappers).

Common entrypoints (examples):

- `./tools/fast_loop_world1_v1.sh`
- `./tools/release_gate_world1.sh`
- `dart run tools/validate_training_content.dart --ci`
- `dart run tools/release_readiness_snapshot_v1.dart`
- `dart run tools/operational_review_packet_v1.dart --timestamp <iso8601> --write`

See `tools/TOOLS_INDEX.md` for a small curated index of core scripts.

## Pre-push Dart test lint

From the repository root, run `python3 -I tools/test_lint_v1.py --base origin/main`
to check tracked Dart changes since the branch point, including local edits.
You can also pass explicit file paths. The command checks all of `test/` for
untracked test and golden sources. Those findings warn only. Dart formatting
runs when a Dart SDK is on PATH. Flutter tests are not required.
The baseline records existing TL1 findings on main. A changed file with a
listed finding still fails the check.

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

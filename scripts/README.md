# Scripts

Operational scripts used by CI and developer workflows.

Status rules:
- `scripts/` = ACTIVE scripts (CI/dev referenced or currently supported operational entrypoints).
- `scripts/_archive/` = legacy scripts with no active CI/dev references, preserved for traceability.

Archive policy:
- See `docs/governance/ARCHIVE_POLICY_v1.md`.
- Do not move scripts into `scripts/_archive/` based on filename heuristics alone; require reference checks first.

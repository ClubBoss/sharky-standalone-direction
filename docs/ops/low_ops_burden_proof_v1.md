# Low Ops Burden Proof v1

Definition
- Low ops burden means no always-on servers or manual daily curation are required to keep core learning/content paths healthy.
- Evidence is local, deterministic, and reproducible from repo state.
- CI/local gates must stay green from committed artifacts only.

Deterministic Proof Commands
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `dart run tools/compile_daily_schedule_v1.dart --check`
- `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 9`
- `dart run tools/audit_why_v1_coverage_v1.dart --world-min 1 --world-max 9`

Expected PASS Signatures
- `compile_daily_schedule_v1: OK check (...)`
- `checkpoint_drills_content_v1: OK worlds=0..9 ... why_audit=OK why_missing=0 why_invalid=0`
- `audit_why_v1_coverage_v1: OK sessions=27 sessions_ok=27 sessions_missing=0 invalid_why_v1=0`

Allowed and Forbidden Artifacts
- Allowed local/generated bucket: `out/` (see `docs/governance/ARCHIVE_POLICY_v1.md`).
- Allowed tracked artifacts: canonical content manifests and schedule snapshot under `content/`.
- Forbidden: committing generated workdir/temp artifacts (see `docs/content/SESSION_PRODUCTION_PIPELINE_v1.md`).

When to Run Tier 2
- Follow tiered rule from `docs/reference/history/EXECUTION_RULES.md`:
  - Tier 2 full suite is required at block completion, before phase transitions, and before release gates.
- World1 policy loop defaults are in `AGENTS.md` (`fast_loop`, `release_gate`, periodic `checkpoint`).

Failure Triage (ordered)
- Check `git status --porcelain` first; ensure no accidental local drift.
- Re-run schedule immutability check (`compile_daily_schedule_v1.dart --check`).
- Re-export/validate content manifests via checkpoint gate.
- Re-run why coverage audit and inspect missing/invalid counts.
- If still failing, isolate first failing gate and fix fail-fast before rerunning full chain.

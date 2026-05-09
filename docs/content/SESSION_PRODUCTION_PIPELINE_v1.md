# Session Production Pipeline v1

This pipeline orchestrates deterministic batch content preparation, linting, and ingest for session bundles across worlds 0..9 (10 worlds).

## Workflow
1. Prepare packet templates into a workdir.
2. Committee fills bundle templates outside the repo commit flow.
3. Lint bundles before ingest.
4. Ingest with dry-run first, then apply.
5. Emit hashes to confirm deterministic artifacts.

## Templates (authoring references)
- Canonical template index: `../../content/_templates/README.md`
- Session/checkpoint examples:
  - `../../content/_templates/checkpoint_template_v1.md`
  - `../../content/_templates/quiz_template_v1.jsonl`

## Commands (example)
- Prepare:
  - `dart run tools/run_session_production_pipeline_v1.dart --prepare --packets 3 --workdir /tmp/sharky_pipeline_v1`
- Lint:
  - `dart run tools/run_session_production_pipeline_v1.dart --lint --workdir /tmp/sharky_pipeline_v1 --bundles /tmp/sharky_pipeline_v1/bundles`
- Ingest dry-run:
  - `dart run tools/run_session_production_pipeline_v1.dart --ingest --dry-run --workdir /tmp/sharky_pipeline_v1 --bundles /tmp/sharky_pipeline_v1/bundles`
- Full flow:
  - `dart run tools/run_session_production_pipeline_v1.dart --all --dry-run --packets 3 --workdir /tmp/sharky_pipeline_v1`
- Hashes:
  - `dart run tools/run_session_production_pipeline_v1.dart --hash --workdir /tmp/sharky_pipeline_v1`

## Pipeline v2 one-shot driver
- Prepare templates for 6 packets (prints next lint/ingest commands):
  - `dart run tools/run_session_production_pipeline_v2.dart --prepare --packets 6 --workdir /tmp/sharky_pipeline_v2`
- Lint a filled bundle file (no writes to content tree):
  - `dart run tools/run_session_production_pipeline_v2.dart --lint content/_meta/sample_session_bundle_v1.txt --packets 6 --workdir /tmp/sharky_pipeline_v2`
- Lint all bundles in a directory:
  - `dart run tools/run_session_production_pipeline_v2.dart --lintDir /tmp/sharky_pipeline_v2/bundles --packets 6 --workdir /tmp/sharky_pipeline_v2`
- One command end-to-end (dry-run ingest default):
  - `dart run tools/run_session_production_pipeline_v2.dart --lintDir /tmp/sharky_pipeline_v2/filled --ingestDir /tmp/sharky_pipeline_v2/filled --packets 6 --workdir /tmp/sharky_pipeline_v2 --dry-run`
- One command end-to-end apply:
  - `dart run tools/run_session_production_pipeline_v2.dart --lintDir /tmp/sharky_pipeline_v2/filled --ingestDir /tmp/sharky_pipeline_v2/filled --packets 6 --workdir /tmp/sharky_pipeline_v2 --apply`

## Generating LLM prompts per packet (v1)
- Prepare packets + templates:
  - `dart run tools/run_session_production_pipeline_v2.dart --prepare --packets 6 --workdir /tmp/sharky_promptgen`
- Render prompts from packets + templates:
  - `dart run tools/render_session_generation_prompts_v1.dart --packetsJson /tmp/sharky_promptgen/packets_v1.json --templatesDir /tmp/sharky_promptgen/bundles --outDir /tmp/sharky_promptgen/prompts`
- After committee fills bundles, lint + ingest dry-run:
  - `dart run tools/run_session_production_pipeline_v2.dart --lintDir /tmp/sharky_promptgen/filled --ingestDir /tmp/sharky_promptgen/filled --packets 6 --workdir /tmp/sharky_promptgen --dry-run`
- Apply after dry-run passes:
  - `dart run tools/run_session_production_pipeline_v2.dart --lintDir /tmp/sharky_promptgen/filled --ingestDir /tmp/sharky_promptgen/filled --packets 6 --workdir /tmp/sharky_promptgen --apply`

## Drill Production Pipeline v1
- Prepare drill packets + templates (for worlds 0..9 drills) into a workdir:
  - `dart run tools/run_drill_production_pipeline_v1.dart --prepare --packets 6 --workdir /tmp/sharky_drill_pipeline_v1`
- Lint filled drill bundles (no writes to content tree):
  - `dart run tools/run_drill_production_pipeline_v1.dart --lintDir /tmp/sharky_drill_pipeline_v1/bundles --packets 6 --workdir /tmp/sharky_drill_pipeline_v1`
- Ingest dry-run then apply:
  - `dart run tools/run_drill_production_pipeline_v1.dart --lintDir /tmp/sharky_drill_pipeline_v1/filled --ingestDir /tmp/sharky_drill_pipeline_v1/filled --packets 6 --workdir /tmp/sharky_drill_pipeline_v1 --dry-run`
  - `dart run tools/run_drill_production_pipeline_v1.dart --lintDir /tmp/sharky_drill_pipeline_v1/filled --ingestDir /tmp/sharky_drill_pipeline_v1/filled --packets 6 --workdir /tmp/sharky_drill_pipeline_v1 --apply`
- Determinism notes:
  - Packet and template ordering is stable (sorted drill items, sorted sessions, sorted drill ids).
  - Do not commit generated workdir artifacts.

## Generating LLM prompts per DRILL packet (v1)
- Refresh drills manifest and prepare drill templates:
  - `dart run tools/export_world_drills_manifest_v1.dart`
  - `dart run tools/shard_world_drills_v1.dart --packets 6 --out /tmp/sharky_drill_promptgen`
  - `dart run tools/render_drill_bundle_templates_v1.dart --in /tmp/sharky_drill_promptgen/packets_drills_v1.json --out /tmp/sharky_drill_promptgen/bundles`
- Render copy-ready drill prompts per packet (embeds exact template content):
  - `dart run tools/render_drill_generation_prompts_v1.dart --packetsJson /tmp/sharky_drill_promptgen/packets_drills_v1.json --templatesDir /tmp/sharky_drill_promptgen/bundles --outDir /tmp/sharky_drill_promptgen/prompts`
- After committee fills bundles, lint and ingest with the drill pipeline driver:
  - `dart run tools/run_drill_production_pipeline_v1.dart --lintDir /tmp/sharky_drill_promptgen/filled --ingestDir /tmp/sharky_drill_promptgen/filled --packets 6 --workdir /tmp/sharky_drill_promptgen --dry-run`
  - `dart run tools/run_drill_production_pipeline_v1.dart --lintDir /tmp/sharky_drill_promptgen/filled --ingestDir /tmp/sharky_drill_promptgen/filled --packets 6 --workdir /tmp/sharky_drill_promptgen --apply`

## Drill-to-World Alignment Audit v1
- Run before scaling drills to protect SSOT world meaning:
  - `dart run tools/audit_drills_world_alignment_v1.dart --world 0`
  - `dart run tools/audit_drills_world_alignment_v1.dart --world 1`
- v1 rules are intentionally minimal and deterministic:
  - World0: drill kinds must stay within the core tap/action set.
  - World1: same drill kinds allowed, but `intent_v1` is required and must be one of the World1 allow-list values.
- World intent rules are centralized in `../../tools/world_intents_ssot_v1.dart`.
- Validators (`validate_world_content_v1.dart`), drill lint/ingest tools, and the alignment audit read from that SSOT to avoid rule drift.
- This audit is a guardrail only; it does not change content or pipeline outputs.
- SSOT references:
  - `../README_SSOT.md`
  - `CONTENT_SYSTEM_v2.1.md`
  - `CONTENT_PLAN_PER_WORLD_v2.1.md`

## Drill Content Checkpoint v1
- One-command integrity gate (validate + export + per-world audits + why_v1 coverage audit):
  - `dart run tools/checkpoint_drills_content_v1.dart`
- Optional range:
  - `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 5`
- Optional skips:
  - `--skip-export` to skip manifest export.
  - `--skip-why-audit` to skip why_v1 coverage audit.
- By default the checkpoint runs `audit_why_v1_coverage_v1.dart` with `--fail-on-missing` for the same world range.

## World1 Contracts Checkpoint v1
- Deterministic contracts gate for World1 routing/map/runner invariants:
  - `bash tools/checkpoint_world1_contracts_v1.sh`
- Guarantees:
  - Fixed explicit test file list (no git-diff heuristics), fail-fast on first failing file.
  - Stable summary line: `checkpoint_world1_contracts_v1: OK tests=<n>` or `FAIL file=<path>`.
- Run before risky merges and after changes in routing, map, runner, or contract harness keys.

## World1 Fast Loop v1
- Canonical command: `bash tools/fast_loop_world1_v1.sh`.
- `--force-world1-contracts` always enables `bash tools/checkpoint_world1_contracts_v1.sh`.
- Without force, checkpoint enables only when changed files match high-risk paths:
  `lib/ui_v2/**`, `lib/services/today_router_v1.dart`, `lib/campaign/**`.
- `--print-plan` prints deterministic keys:
  `world1_contracts_checkpoint`, `reason`, `tier0_only`.
- `reason` values are fixed: `force flag`, `changed files match high-risk paths`, `no matching changes`.
- `tier0_only=true` only when no flutter tests run and world1 contracts checkpoint is disabled.

## Workdir layout
- `<workdir>/packets_v1.json`
- `<workdir>/bundles/bundle_template_packet_<i>_v1.txt`

## Notes
- The driver delegates parsing/writing to existing tools (`shard`, `render`, `lint`, `ingest`).
- The driver does not parse bundle contents itself.
- Generated workdir artifacts should not be committed.
- Determinism depends on a stable content tree and stable tool versions.

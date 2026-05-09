# Poker Analyzer

> Authority note:
> Active product/learning/content SSOT starts at `docs/README_SSOT.md`.
> Root-level roadmap, architecture, and report files are not the active SSOT chain unless they are explicitly linked from that entrypoint.

**Poker Analyzer** — система для анализа и обучения принятию решений в покере. Фокус: корректность, измеримая EV, автоматика, стабильность.

---

## Active milestone

- Active milestone: R6 (Visual Perfection + Placement Suite)
- R6 Counter - 0/100 (+Delta%)
- Note: R5 is complete at 100/100 and frozen.

### R6 Counter weights

- 1) Stadium ratio restore + aspect contract (P0) - 25
- 2) Seat-quiz caption collision fix + seat-quiz state contract test - 25
- 3) Placement/visual matrix contract suite (devices + textScale + key states) - 25
- 4) PNG proofs only when needed policy enforcement + checklist closeout - 15
- 5) Visual regression triage playbook addendum (small) - 10

---

## Основные возможности

### 🎯 Тренажёр (Session Player)
- **Уровни**: L2 (Push/Fold), L3 (Jam vs Raise), L4 (ICM).
- **Логика**: SpotKind, correct, autoWhy, _replayed.
- **Повторы**: Ошибки накапливаются, доучиваются через SmartTraining.
- **Интерфейс**: Гибкий UI с Drill, Demo, Quiz, Recap, Checkpoint.

### 📦 Пакеты (Training Packs)
- **Формат**: `.pack` архивы с theory.md, drills.jsonl, allowlist.txt и др.
- **Экспорт**: `generate_and_export_packs.dart` → `.pack` в `pack_release/`
- **Индекс**: `generate_packs_index.dart` → `packs_index.json`
- **Каталог**: `pack_release/`, запускаются через `TrainingLauncherService`.

### 📈 Отчёты и прогресс
- **TrainingReportScreen**: прогресс по темам, лупам, модулям.
- **TelemetryService**: логирует все события (см. `TELEMETRY_EVENTS.md`).
- **Streak / Badge / Loop Cards**: мотивация и удержание.

### ⚙️ Smart Training Engine
- Планирование сессий (SmartTrainingPlannerService).
- Повторы, NextTopic, Review Checkpoint.
- Интеграция с `TopicProgressService`, `SessionLogService`.
- Микро-планирование через SmartTrainingCard (Review, Checkpoint, Loop, NextTopic)

---

## Архитектура

```
+---------------------+     +------------------------+
|     Flutter UI      |<--->|    Learning Engine     |
+---------------------+     +------------------------+
           |                          |
           v                          v
+---------------------+     +------------------------+
|  Autogen Pipeline   |     |   Theory/EV Validator  |
+---------------------+     +------------------------+
```

- `Flutter UI` — карточки, экраны, отчёты.
- `Learning Engine` — бизнес-логика сессий, повторов, подсказок.
- `Autogen` — пайплайн генерации .pack, валидация, экспорт.
- `Validator` — проверки теории, SpotKind, EV и формат JSONL.

---

## Установка и запуск

- Flutter ≥ 3.10
- `flutter pub get`
- `flutter gen-l10n`

Экспорт .pack файлов:
```
dart run tool/generate_and_export_packs.dart
dart run tool/generate_packs_index.dart
```

Сборка пака (опц.):
```
dart run tool/precompile_all_packs.dart
```

Запуск:
```
flutter run -t main.dart
```

Демо APK:
```
flutter build apk --target=main.dart
```

---

## Инструкции и стандарты

- [📘 PROJECT_INSTRUCTIONS.txt](./docs/_archive/misc/PROJECT_INSTRUCTIONS.txt)
- [📦 PACK_EXPORT_RULES.md](./PACK_EXPORT_RULES.md)
- [🧠 TRAINING_ARCHITECTURE.md](./TRAINING_ARCHITECTURE.md)
- [📡 TELEMETRY_EVENTS.md](./TELEMETRY_EVENTS.md)
- [🧪 CI_INSTRUCTIONS.md](./CI_INSTRUCTIONS.md)
- [🗺️ Current Roadmap](./docs/ROADMAP_vNext.md)

---

## Dev Workflow

- Codex-поток: Prompt → PR → Review → Merge.
- Микро-PR: ≤2 файла, tiny diff, ASCII-only.
- Enum discipline: `SpotKind` append-only.
- Guard: centralized, проверяется в `guard_single_site_test.dart`.

CI:
```
dart format --set-exit-if-changed .
dart analyze
```

---

## CLI команды (см. README_DEV.md)

- `flutter test` — unit-тесты
- `dart run tool/validate_training_content.dart` — валидация теории
- `dart run tool/generate_and_export_packs.dart` — экспорт .pack файлов в pack_release/
- `dart run tool/generate_packs_index.dart` — создать packs_index.json по содержимому pack_release/

## Pre-commit check

Before committing, run:

```bash
dart format --set-exit-if-changed . && dart analyze
```

This ensures formatting and analyzer clean output across the repo.

## R2 Content QA

Run the full deterministic R2 content QA suite with one command:

```bash
dart run tools/run_content_qa_r2_v1.dart
```

Expected behavior:
- Runs in fixed order: `validate_world_content_v1` -> `audit_worlds_0_4_scoreboard_v1` -> `audit_worlds_0_4_progression_v1` -> `audit_worlds_0_4_telemetry_v1` -> `audit_worlds_0_4_session_chain_v1`
- Prints `RUN`, per-step `OK/FAIL`, then a final `SUMMARY`
- Exit codes: `0` on full pass, nonzero on first failing step, `64` for invalid args

When to run:
- Before commit for content/tooling changes
- Before merge for R2 content QA checkpoints

## R5 Release gate

Run the deterministic R5 release gate with one command:

```bash
./tools/run_release_gate_r5_v1.sh
```

What it checks (in order):
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `dart run tools/run_content_qa_r2_v1.dart`
- `flutter test` critical guards:
- `test/guards/world_campaign_map_home_contract_test.dart`
- `test/guards/world_campaign_routing_matrix_contract_test.dart`
- monetization-critical tests (when present):
- `test/payments/payment_service_restore_verification_policy_v1_test.dart`
- `test/services/energy_service_entitlement_ssot_test.dart`

Behavior:
- Prints per-step `OK/FAIL` and stops on first failure with the same nonzero exit code
- Prints final `[r5-gate] PASS` when all steps pass
- Optional quick mode: `./tools/run_release_gate_r5_v1.sh --quick` (skips targeted flutter test step)

When to run:
- Before merge
- Before tagging a release

CI wiring:
- Workflow file: `.github/workflows/r5-release-gate.yml`
- Triggers: `pull_request` and `push` to `main`
- Runs: `./tools/run_release_gate_r5_v1.sh` (same local gate path used for release readiness)

Tier checkpoint cadence:
- Tier0 always
- Tier1 selective
- Tier2 full suite on checkpoints (every 3-4 PRs / before main merge / before release tag)
- Tier2 CI workflow: `.github/workflows/r5-tier2-checkpoint.yml`
- Manual Tier2 run: GitHub Actions -> `R5 Tier2 checkpoint` -> `Run workflow`
- Automatic Tier2 run: push tags matching `v*`

Fresh clone readiness check:
- Command: `./tools/check_repo_ready_r5_v1.sh`
- Runs command/tooling preflight (`flutter`, `dart`, `bash`), executable checks, then `./tools/run_release_gate_r5_v1.sh`
- Run this after first clone/setup and before your first PR on a new machine
- Quick mode for CI preflight-only checks: `./tools/check_repo_ready_r5_v1.sh --quick`

## R5 Operations playbook

### Release checklist (before tag)

1. Ensure clean tree: `git status --porcelain` must be empty.
2. Run release gate: `./tools/run_release_gate_r5_v1.sh`.
3. Run manual smoke flow:
   - Cold launch app and reach map/home without errors.
   - Start World1 from Today Plan and confirm runner opens.
   - Make one wrong action and confirm deterministic feedback appears.
   - Finish session and confirm UP NEXT appears and continue works.
   - Open review entry (if due) and verify review session starts.
   - Open locked World5+ path while not entitled and verify premium preview opens.
   - Restore entitlement path and verify locked path opens on next attempt.
4. Confirm release notes include key changes and known limitations.
5. Create release tag and push:
   - `git tag vX.Y.Z`
   - `git push origin vX.Y.Z`

### Hotfix protocol

1. Branch from `main` using: `hotfix/YYYYMMDD-short-topic`.
2. Keep the diff minimal and scoped to one issue. No opportunistic refactors.
3. Required validation:
   - `flutter analyze`
   - `./tools/run_release_gate_r5_v1.sh --quick`
   - Run one targeted failing test/file related to the incident.
4. Open PR with incident link, root cause, and rollback note.
5. Merge hotfix, then backport by cherry-picking the hotfix commit to any maintained release branch.

### Rollback steps

1. Identify bad commit range from deploy/tag notes.
2. Revert with explicit commits (no history rewrite on shared branches):
   - `git revert <bad_commit_sha>`
   - or `git revert <oldest_bad_sha>^..<newest_bad_sha>`
3. Run:
   - `flutter analyze`
   - `./tools/run_release_gate_r5_v1.sh --quick`
4. Verify rollback with manual smoke flow (same release checklist steps).
5. Restore release artifacts:
   - re-tag only after verification if a bad tag was published
   - update release notes to mark rollback reason and replaced version

### Failure triage flow

1. If `flutter analyze` fails:
   - Fix compile/lint errors first; do not run deeper gates until clean.
2. If `fast_loop_world1_v1.sh` fails:
   - Treat as runtime/contract regression in critical flow.
   - Reproduce failing test locally and patch minimal root cause.
3. If `run_content_qa_r2_v1.dart` fails:
   - Treat as content structure/progression/telemetry audit failure.
   - Fix content/tooling source of truth before runtime changes.
4. If critical flutter tests fail:
   - Prioritize `world_campaign_map_home` and routing failures as release blockers.
   - For monetization failures, validate entitlement state assumptions and restore path.
5. STOP and revert when:
   - fix requires scope expansion beyond incident
   - deterministic repro is missing
   - more than one subsystem regresses in the same patch

### Flake handling protocol

- If an R5 CI gate fails, rerun once only when the failure matches a known flake signature.
- Known flake signatures are transient infrastructure issues (runner/network/bootstrap), not assertion/test logic failures.
- If the second run fails, STOP and fix the root cause before merge.
- No merges on red or flaky-unexplained gates.

## R5 Performance and Determinism Audit

### Determinism rules checklist

- No `DateTime.now()` defaults in core logic, routing, scoring, or test setup unless injected explicitly.
- No RNG without fixed seed. Prefer no RNG at runtime for critical flows.
- Keep iteration and traversal stable: sort lists/maps before selecting or reporting.
- Avoid platform-dependent rendering checks in contracts; assert on keys/state/text, not pixels.

### Performance budgets and no-jank checklist

- Avoid heavy `BackdropFilter` and stacked `Opacity` layers in hot UI paths.
- Use `RepaintBoundary` for complex, frequently updated subtrees where repaint isolation is needed.
- Keep animations deterministic and minimal: fixed durations, no timer drift dependence, no random motion.
- No-jank hotspots checklist:
- runner table and action bar remain responsive under standard text scales
- map/home transitions do not stall on first interaction
- result screen opens without visible hitch
- paywall preview open/close remains smooth

### PNG proofs vs contract tests

- Prefer contract/widget tests for behavior, routing, state, and invariants.
- Add PNG proofs only for true visual regression risk.
- Use PNG proofs when validating layout-sensitive rendering that contracts cannot reliably cover.
- Examples:
- Use contract tests for lock/unlock gating, UP NEXT continuity, and entitlement behavior.
- Use PNG proof for a specific table layout regression where overlap is visual-only and key-state assertions are insufficient.

### Audit procedure

1. Run release gate: `./tools/run_release_gate_r5_v1.sh`
2. Run content QA directly when auditing content pipelines: `dart run tools/run_content_qa_r2_v1.dart`
3. Use screenshot harness only when regression risk is visual and contracts cannot capture it deterministically.
4. Record pass/fail status and blocking step in the PR summary.

## R5 Content Authoring and CI Playbook

### Canonical content locations and rules

- `content/` is canonical for authored training content.
- Do not author new training content in `assets/content/`.
- World tree structure must remain deterministic:
- `content/worlds/worldN/v1` contains `world.md`, `atoms.md`, `index.md`.
- Sessions follow `wN.s01..wN.s10` with `session.md`, `notes.md`, `index.md`, and drills `d.*.json`.
- Role markers are fixed by session id:
- Learn: `s01..s03`
- Practice: `s04..s09`
- Checkpoint: `s10`
- Mixed checkpoint cadence markers must follow validator-enforced convention in world/session indexes.

### Author workflow (local)

1. Edit only files under `content/` for curriculum changes.
2. Run structural validator:
   - `dart run tools/validate_world_content_v1.dart`
3. Run content QA suite:
   - `dart run tools/run_content_qa_r2_v1.dart`
4. Run release gate:
   - `./tools/run_release_gate_r5_v1.sh`
   - For quick incident loops only: `./tools/run_release_gate_r5_v1.sh --quick`
5. Expected outputs:
   - validator ends with `OK`
   - content QA ends with `run_content_qa_r2_v1: OK`
   - release gate ends with `[r5-gate] PASS`
6. On failure:
   - stop and fix the reported source-of-truth issue first
   - rerun the failing command before moving to the next gate

### CI expectations before merge

- Required local-equivalent checks:
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`
- `dart run tools/run_content_qa_r2_v1.dart`
- `./tools/run_release_gate_r5_v1.sh`
- Tier cadence policy:
- Tier0 always
- Tier1 selective for touched surfaces
- Tier2 full suite on checkpoints (every 3-4 PRs / before main merge / before release tag)

### Common failure modes and fixes

- Missing markers or required files:
- Failing command: `validate_world_content_v1`
- Fix: add missing top-level/session files and ensure role/cadence markers are present.
- Drill density or pacing lint failures:
- Failing command: `validate_world_content_v1`
- Fix: adjust drill counts per session/role to satisfy min/max ranges.
- Progression audit failures:
- Failing command: `audit_worlds_0_4_progression_v1`
- Fix: repair missing/invalid session or pack references to registered ids.
- Telemetry audit failures:
- Failing command: `audit_worlds_0_4_telemetry_v1`
- Fix: add or restore required event emission in the referenced runtime path; avoid content-side workarounds.

## R5 Rest-state checklist

Use this list as the canonical autonomous maintenance baseline.

1. Fresh clone or new machine:
- `./tools/check_repo_ready_r5_v1.sh`
2. Before merge:
- `./tools/run_release_gate_r5_v1.sh`
3. CI workflows:
- `r5-release-gate.yml` runs on PR and push to `main`
- `r5-tier2-checkpoint.yml` runs on manual dispatch and push tags `v*`
4. Tier cadence reminder:
- Tier0 always
- Tier1 selective
- Tier2 every 3-4 PRs checkpoint, before main merge, and before release tag

---

## Лицензия

© 2025 Poker Analyzer contributors. License pending.

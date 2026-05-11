# M1 Readiness Audit v2

Counter — (unknown/100) (Δ pending)

Date: 2026-02-27
Scope: Repository-state audit after content expansion to 6 micro-sessions for Worlds 0-4.
Primary SSOT: `docs/plan/MASTER_PLAN_v2.2.md`, `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md`, `docs/content/CONTENT_SYSTEM_v2.1.md`, `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`.

## PIEC Validation
- `docs/plan/MASTER_PLAN_v2.2.md` exists and shows `MASTER PLAN v2.2 (SSOT)` and `Status: ACTIVE`.
- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md` exists and shows `UNIFIED LEARNING ARCHITECTURE v4.3.1`.
- `docs/content/CONTENT_SYSTEM_v2.1.md` exists and shows `CONTENT SYSTEM v2.1`.
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md` exists and shows `CONTENT PLAN PER WORLD v2.1`.

## SECTION 1 — Worlds 0-4 Production Status
Plan target reference: `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md` (MVP Worlds 0-4, `6-10 micro-sessions`, `6-12 decisions` per micro-session).

| World | Micro-sessions (actual) | Average decisions/session (actual) | why_v1 coverage (repo state) | Completeness vs plan |
|---|---:|---:|---|---|
| 0 | 6 | 4.17 (25/6) | 0/6 sessions contain `why_v1` key; staged why audit does not include world0 | PARTIAL (session count in range; decision depth below 6-12) |
| 1 | 6 | 3.50 (21/6) | 6/6 sessions contain `why_v1` key; staged audit reports `sessions=3 sessions_ok=3` for staged set `w1.s01..w1.s03` | PARTIAL (session count in range; decision depth below 6-12) |
| 2 | 6 | 6.00 (36/6) | 6/6 sessions contain `why_v1` key; staged audit reports `sessions=3 sessions_ok=3` for `w2.s01..w2.s03` | COMPLETE (session count and average decision depth in range) |
| 3 | 6 | 6.00 (36/6) | 6/6 sessions contain `why_v1` key; staged audit reports `sessions=3 sessions_ok=3` for `w3.s01..w3.s03` | COMPLETE (session count and average decision depth in range) |
| 4 | 6 | 6.00 (36/6) | 6/6 sessions contain `why_v1` key; staged audit reports `sessions=3 sessions_ok=3` for `w4.s01..w4.s03` | COMPLETE (session count and average decision depth in range) |

Evidence:
- Session/drill counts from `content/worlds/world0..world4/v1/sessions/**/drills/d.*.json`.
- why_v1 staged set and validator: `tools/why_v1_ssot_v1.dart`.
- why audit outputs from `dart run tools/audit_why_v1_coverage_v1.dart --world-min <w> --world-max <w>`.

## SECTION 2 — Today Loop Determinism
MASTER PLAN ladder requirement: gauntlet -> leaks -> practice (`docs/plan/MASTER_PLAN_v2.2.md`, section 3).

Findings:
- Ladder order is implemented in `lib/services/today_router_v1.dart` via `TodayRouteKindV1` and `_resolveLadderFromGauntletId(Sync)`:
  - gauntlet when not completed today and gauntlet exists,
  - leaks when enabled and due,
  - practice otherwise.
- Deterministic schedule selection is implemented in `TodayRouterV1.resolveGauntletIdFromScheduleMarkdown`:
  - exact date match -> latest date <= day -> earliest date.
- Deterministic one-primary-CTA behavior is covered in `test/guards/world_campaign_map_home_contract_test.dart` (`today router is deterministic ... one primary CTA`, ladder exclusivity tests).
- No RNG usage is present in `lib/services/today_router_v1.dart`.

## SECTION 3 — Economy & Exactly-Once Spend
MASTER PLAN requirement: exactly-once spend with required `txn_id` and idempotent ledger (`docs/plan/MASTER_PLAN_v2.2.md`, section 5).

Findings:
- Idempotent spend path exists in `lib/services/progress_service.dart`:
  - `_chipsAppliedTxnIdsV1Key` tracks applied transaction IDs.
  - `applyChipsTxnIdempotentV1` checks duplicate `txnId` and returns already-applied result.
  - `txnId` and context are validated via ASCII token guard.
- 1 free Today/day entitlement hook exists:
  - `ProgressService.getTodayEntitlementsV1()` returns `TodayEntitlementsV1.free()` with `todayEntriesPerDay: 1`.
- Deterministic txn construction exists:
  - `buildTodayEntryTxnIdV1`, `buildDailyDripTxnIdV1`, and corresponding `apply*TxnV1` methods.
- Contract tests exist:
  - `test/services/chips_ledger_v1_test.dart` validates deterministic idempotent txn IDs and free entitlement value.

## SECTION 4 — Leaks v1-lite
MASTER PLAN requirement: append-only local log, deterministic due function, daily cap (`docs/plan/MASTER_PLAN_v2.2.md`, section 7).

Findings:
- Append-only leak event paths exist in `lib/services/progress_service.dart`:
  - `appendLeakLogEntryV1` (base log append),
  - `appendLeakResolutionEntryV1` (resolution append).
- Deterministic due/queue logic exists:
  - `computeLeaksQueueForDayV1` and `isLeaksDueForDayV1`.
- Daily cap and queue version constants exist:
  - `leaksDailyCapV1 = 5`, `leaksQueueAlgoVersionV1 = 'leaks_queue_v1'`.
- Contract coverage exists in `test/guards/world_campaign_map_home_contract_test.dart`:
  - deterministic queue ordering/cap,
  - deterministic suppression by resolution,
  - append-only base log assertion.

## SECTION 5 — 90-Day Schedule Snapshot
MASTER PLAN requirement: deterministic 90-day snapshots and immutability boundaries (`docs/plan/MASTER_PLAN_v2.2.md`, section 4 and DoR item 7).

Findings:
- Deterministic schedule compiler exists: `tools/compile_daily_schedule_v1.dart`.
- Default schedule horizon is 90 days (`days = 90` in parser defaults).
- Snapshot check mode exists (`--check`) and fails on byte mismatch against `content/schedules/daily/v1/schedule.md`.
- Current snapshot file exists with version header:
  - `content/schedules/daily/v1/schedule.md` starts with `@schedule v=1`.
- MASTER PLAN names boundary fields (`schedule_version`, `gauntlet_template_version`, `content_schema_version`) in spec text; explicit `schedule_version` field is not present in `schedule.md` artifact.

## SECTION 6 — Definition of Ready Gap Table
Source: `docs/plan/MASTER_PLAN_v2.2.md`, section 9 (DoR 1.0 items 1..8).

| DoR item | Status | Evidence |
|---|---|---|
| 1. Today loop fully deterministic and stable | COMPLETE | `lib/services/today_router_v1.dart` ladder + deterministic date selection; deterministic guard coverage in `test/guards/world_campaign_map_home_contract_test.dart`. |
| 2. Endless perception exists (gauntlets + tiers + leaks) | PARTIAL | Gauntlet and leaks flows are present (`lib/services/today_router_v1.dart`, `lib/services/progress_service.dart`); tier primitives exist but unified DoR-level proof across all three loops is not consolidated in one contract. |
| 3. Content platform fully validated and versioned | PARTIAL | Content gates/checkpoints and manifests are active (`tools/checkpoint_drills_content_v1.dart`, `content/_meta/world_sessions_manifest_v1.json`, `content/_meta/world_drills_manifest_v1.json`); explicit named boundary fields from MASTER PLAN are only partially reflected in content artifacts. |
| 4. Exactly-once spend proven by contract tests | COMPLETE | Idempotent ledger path in `lib/services/progress_service.dart`; deterministic idempotency tests in `test/services/chips_ledger_v1_test.dart`. |
| 5. 1 free Today/day enforced | COMPLETE | `TodayEntitlementsV1.free()` (`todayEntriesPerDay: 1`) and deterministic daily today-entry txn IDs in `lib/services/progress_service.dart`; asserted in `test/services/chips_ledger_v1_test.dart`. |
| 6. Subscription hooks defined (UI optional) | PARTIAL | Entitlement structure exists (`TodayEntitlementsV1`), but audited runtime path exposes only free-tier concrete behavior. |
| 7. 90-day schedule snapshot generated and immutable | PARTIAL | `tools/compile_daily_schedule_v1.dart` provides deterministic generation and `--check` immutability guard; snapshot exists at `content/schedules/daily/v1/schedule.md`; explicit `schedule_version` field is not present in file content. |
| 8. Low ops burden (no manual daily curation) | PARTIAL | Deterministic compiler and snapshot-driven router path exist (`tools/compile_daily_schedule_v1.dart`, `lib/services/today_router_v1.dart`); no separate explicit no-manual-curation enforcement contract found in audited files. |

---

Determinism notes:
- Report ordering is fixed: Worlds 0->4; DoR items 1->8.
- All statements are based on current repository files and command outputs only.

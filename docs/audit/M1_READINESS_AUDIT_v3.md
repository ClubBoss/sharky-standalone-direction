# M1 Readiness Audit v3

Counter — (unknown/100) (Δ pending)

Date: 2026-02-27
Scope: Repository-state audit after expansion to 8 micro-sessions for Worlds 0-4.
Primary SSOT: `docs/plan/MASTER_PLAN_v2.2.md`, `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md`, `docs/content/CONTENT_SYSTEM_v2.1.md`, `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`.

## PIEC Validation
- `docs/plan/MASTER_PLAN_v2.2.md` exists and declares `MASTER PLAN v2.2 (SSOT)` and `Status: ACTIVE`.
- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md` exists and declares `v4.3.1`.
- `docs/content/CONTENT_SYSTEM_v2.1.md` exists and declares `v2.1`.
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md` exists and declares `v2.1`.

## SECTION 1 — Worlds 0-4 Production Status
Plan target reference: `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md` (MVP Worlds 0-4: 6-10 micro-sessions, 6-12 decisions per micro-session).

| World | Micro-sessions (actual) | Avg decisions/session (actual) | why_v1 coverage (repo state) | Completeness vs plan |
|---|---:|---:|---|---|
| 0 | 8 | 6.50 (52/8) | 8/8 sessions contain `why_v1`; staged why audit set excludes world0 | COMPLETE |
| 1 | 8 | 6.00 (48/8) | 8/8 sessions contain `why_v1`; staged why audit reports `sessions=3 sessions_ok=3` for staged set `w1.s01..w1.s03` | COMPLETE |
| 2 | 8 | 6.00 (48/8) | 8/8 sessions contain `why_v1`; staged why audit reports `sessions=3 sessions_ok=3` for `w2.s01..w2.s03` | COMPLETE |
| 3 | 8 | 6.00 (48/8) | 8/8 sessions contain `why_v1`; staged why audit reports `sessions=3 sessions_ok=3` for `w3.s01..w3.s03` | COMPLETE |
| 4 | 8 | 6.00 (48/8) | 8/8 sessions contain `why_v1`; staged why audit reports `sessions=3 sessions_ok=3` for `w4.s01..w4.s03` | COMPLETE |

Evidence:
- Session/drill counts from `content/worlds/world0..world4/v1/sessions/**/drills/d.*.json`.
- Staged why set/validator: `tools/why_v1_ssot_v1.dart`.
- Checkpoint export/audit output: `tools/checkpoint_drills_content_v1.dart`.

## SECTION 2 — Today Loop Determinism
MASTER PLAN ladder requirement: gauntlet -> leaks -> practice (`docs/plan/MASTER_PLAN_v2.2.md`, section 3).

Findings:
- Ladder order implemented in `lib/services/today_router_v1.dart` (`TodayRouteKindV1` + `_resolveLadderFromGauntletId` and sync variant).
- Deterministic schedule resolution implemented in `TodayRouterV1.resolveGauntletIdFromScheduleMarkdown`:
  - exact date match -> latest `<=` date -> earliest date.
- Deterministic ladder/CTA behavior covered by guards in `test/guards/world_campaign_map_home_contract_test.dart`.
- No RNG usage in `lib/services/today_router_v1.dart`.

## SECTION 3 — Economy & Exactly-Once Spend
MASTER PLAN requirement: idempotent exactly-once spend with required `txn_id` (`docs/plan/MASTER_PLAN_v2.2.md`, section 5).

Findings:
- Idempotent txn application implemented in `lib/services/progress_service.dart`:
  - `_chipsAppliedTxnIdsV1Key` for dedup,
  - `applyChipsTxnIdempotentV1` duplicate guard and already-applied result,
  - ASCII token validation for `txnId`.
- Today entitlement hook exists:
  - `ProgressService.getTodayEntitlementsV1()` -> `TodayEntitlementsV1.free()` with `todayEntriesPerDay: 1`.
- Deterministic txn ID constructors exist:
  - `buildTodayEntryTxnIdV1`, `buildDailyDripTxnIdV1`.
- Contract coverage exists in `test/services/chips_ledger_v1_test.dart`.

## SECTION 4 — Leaks v1-lite
MASTER PLAN requirement: append-only local log, deterministic due function, daily cap (`docs/plan/MASTER_PLAN_v2.2.md`, section 7).

Findings:
- Append-only log entry paths exist in `lib/services/progress_service.dart`:
  - `appendLeakLogEntryV1`, `appendLeakResolutionEntryV1`.
- Deterministic queue/due logic exists:
  - `computeLeaksQueueForDayV1`, `isLeaksDueForDayV1`.
- Cap/version constants exist:
  - `leaksDailyCapV1 = 5`, `leaksQueueAlgoVersionV1 = 'leaks_queue_v1'`.
- Guard coverage exists in `test/guards/world_campaign_map_home_contract_test.dart` (ordering/cap/suppression determinism).

## SECTION 5 — 90-Day Schedule Snapshot
MASTER PLAN requirement: deterministic 90-day snapshots and immutability boundary (`docs/plan/MASTER_PLAN_v2.2.md`, section 4 and DoR item 7).

Findings:
- Deterministic compiler exists: `tools/compile_daily_schedule_v1.dart`.
- Default horizon is 90 days (`days = 90`).
- `--check` mode enforces byte-level snapshot consistency against `content/schedules/daily/v1/schedule.md`.
- Snapshot artifact exists with header `@schedule v=1` at `content/schedules/daily/v1/schedule.md`.
- MASTER PLAN references named boundary fields (`schedule_version`, `gauntlet_template_version`, `content_schema_version`); explicit `schedule_version` field is not present in `schedule.md` content.

## SECTION 6 — Definition of Ready Gap Table
Source: `docs/plan/MASTER_PLAN_v2.2.md`, section 9 (DoR 1.0 items 1..8).

| DoR item | Status | Evidence |
|---|---|---|
| 1. Today loop fully deterministic and stable | COMPLETE | `lib/services/today_router_v1.dart` deterministic ladder + deterministic date fallback; guard tests in `test/guards/world_campaign_map_home_contract_test.dart`. |
| 2. Endless perception exists (gauntlets + tiers + leaks) | PARTIAL | Gauntlet/leaks paths are present (`lib/services/today_router_v1.dart`, `lib/services/progress_service.dart`); unified DoR-level proof artifact for all three loops is not centralized in a single contract file. |
| 3. Content platform fully validated and versioned | PARTIAL | Deterministic content checkpoint is active (`tools/checkpoint_drills_content_v1.dart`), manifests updated (`content/_meta/world_sessions_manifest_v1.json`, `content/_meta/world_drills_manifest_v1.json`); named version-boundary fields from MASTER PLAN are partially represented in artifacts. |
| 4. Exactly-once spend proven by contract tests | COMPLETE | Idempotent spend path in `lib/services/progress_service.dart` and deterministic idempotency assertions in `test/services/chips_ledger_v1_test.dart`. |
| 5. 1 free Today/day enforced | COMPLETE | `TodayEntitlementsV1.free()` and deterministic today-entry txn IDs in `lib/services/progress_service.dart`, verified in `test/services/chips_ledger_v1_test.dart`. |
| 6. Subscription hooks defined (UI optional) | PARTIAL | Entitlement structure exists (`TodayEntitlementsV1`), audited path currently exposes free-tier concrete behavior. |
| 7. 90-day schedule snapshot generated and immutable | PARTIAL | Deterministic compiler + `--check` immutability guard in `tools/compile_daily_schedule_v1.dart`; snapshot present at `content/schedules/daily/v1/schedule.md`; explicit `schedule_version` field not present in file body. |
| 8. Low ops burden (no manual daily curation) | PARTIAL | Deterministic compiler and snapshot-consumer router path exist (`tools/compile_daily_schedule_v1.dart`, `lib/services/today_router_v1.dart`); no explicit standalone no-manual-curation contract file found in audited set. |

---

Determinism notes:
- Ordering is fixed (World 0->4; DoR 1->8).
- Findings are based on current repository files and deterministic command outputs.

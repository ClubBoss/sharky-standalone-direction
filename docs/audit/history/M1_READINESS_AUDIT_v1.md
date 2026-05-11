# M1 Readiness Audit v1

Counter — (unknown/100) (Δ pending)

Date: 2026-02-26
Scope: Repository state audit only (no behavior changes)
Primary SSOT: `docs/plan/MASTER_PLAN_v2.2.md`, `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md`, `docs/content/CONTENT_SYSTEM_v2.1.md`, `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`

## PIEC Validation
- `docs/plan/MASTER_PLAN_v2.2.md` exists and header shows `MASTER PLAN v2.2 (SSOT)` / `Status: ACTIVE`.
- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md` exists and title shows `v4.3.1`.
- `docs/content/CONTENT_SYSTEM_v2.1.md` exists and title shows `v2.1`.
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md` exists and title shows `v2.1`.

## SECTION 1 — Worlds 0–4 Production Status
Source for target scope: `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md` (MVP worlds 0–4, `6–10 micro-sessions`, `6–12 decisions` per micro-session).

| World | Micro-sessions (actual) | Avg decisions/session (actual) | why_v1 coverage presence | Exit criteria implemented (if defined) | Completeness vs Content Plan |
|---|---:|---:|---|---|---|
| 0 | 3 | 7.33 (22/3) | No staged coverage in why_v1 gate (`sessions=0`, audit limited to staged set w1..w9) | Defined in plan (`85% accuracy`, `decision time <5s`); implementation artifact not found in world0 content/runtime contracts | PARTIAL (sessions below 6–10; decisions within 6–12) |
| 1 | 3 | 6.00 (18/3) | Present (`sessions=3`, `sessions_ok=3`, `invalid_why_v1=0`) | Not explicitly defined in Content Plan section for World 1 | PARTIAL (sessions below 6–10; decisions at lower bound 6–12) |
| 2 | 3 | 6.00 (18/3) | Present (`sessions=3`, `sessions_ok=3`, `invalid_why_v1=0`) | Not explicitly defined in Content Plan section for World 2 | PARTIAL (sessions below 6–10; decisions at lower bound 6–12) |
| 3 | 3 | 6.00 (18/3) | Present (`sessions=3`, `sessions_ok=3`, `invalid_why_v1=0`) | Not explicitly defined in Content Plan section for World 3 | PARTIAL (sessions below 6–10; decisions at lower bound 6–12) |
| 4 | 3 | 6.00 (18/3) | Present (`sessions=3`, `sessions_ok=3`, `invalid_why_v1=0`) | Not explicitly defined in Content Plan section for World 4 | PARTIAL (sessions below 6–10; decisions at lower bound 6–12) |

Evidence:
- Content counts from `content/worlds/world0..world4/v1/sessions/*/drills/d.*.json`.
- why_v1 staged set and validator SSOT: `tools/why_v1_ssot_v1.dart`.
- Coverage command outputs: `dart run tools/audit_why_v1_coverage_v1.dart --world-min N --world-max N` for N=0..4.

## SECTION 2 — Today Loop Determinism
MASTER PLAN ladder requirement: gauntlet → leaks → practice (`docs/plan/MASTER_PLAN_v2.2.md`, section 3).

Findings:
- Ladder logic is implemented in order in `lib/services/today_router_v1.dart`:
  - If `!gauntletPlayedToday` and gauntlet exists => `TodayRouteKindV1.gauntlet`.
  - Else if `leaksEnabled && leaksDue` => `TodayRouteKindV1.leaks`.
  - Else => `TodayRouteKindV1.practice`.
- No RNG usage found in router path (`lib/services/today_router_v1.dart` has no `Random`/shuffle calls).
- Deterministic ordering exists in schedule resolution in `TodayRouterV1.resolveGauntletIdFromScheduleMarkdown`:
  - exact day match, else latest `<= utcDayKey`, else earliest.
- Single primary CTA dominance is contract-tested in `test/guards/world_campaign_map_home_contract_test.dart`:
  - test case: `today router is deterministic ... one primary CTA`.
- “1 free Today/day” enforcement logic exists in economy contract path:
  - entitlement: `ProgressService.getTodayEntitlementsV1() => TodayEntitlementsV1.free()` (`todayEntriesPerDay=1`) in `lib/services/progress_service.dart`.
  - deterministic daily txn id gate for Today entry in `applyTodayEntryTxnV1` + idempotent `txnId` handling in `applyChipsTxnIdempotentV1`.

## SECTION 3 — Economy & Exactly-Once Spend
MASTER PLAN requirement: idempotent ledger with required `txn_id` and tests (`docs/plan/MASTER_PLAN_v2.2.md`, section 5).

Findings:
- Ledger idempotency logic exists:
  - `lib/services/progress_service.dart` uses `_chipsAppliedTxnIdsV1Key` and dedup checks in `applyChipsTxnIdempotentV1`.
  - Duplicate `txnId` returns already-applied result; no double-application.
- `txn_id` enforcement exists:
  - `applyChipsTxnIdempotentV1` validates ASCII token via `_requireAsciiTokenV1(txnId, ...)`.
- Exactly-once spend/test references exist:
  - `test/services/chips_ledger_v1_test.dart` (`today entry and daily drip use deterministic idempotent txn ids`).
  - `test/services/campaign_spine_runner_v1_test.dart` (double completion idempotency assertions).
  - `test/guards/world1_campaign_telemetry_contract_test.dart` includes idempotent completion contract wording.

## SECTION 4 — Leaks v1-lite
MASTER PLAN requirement: append-only local log, deterministic due, daily cap (`docs/plan/MASTER_PLAN_v2.2.md`, section 7).

Findings:
- Append-only local leak log path exists:
  - `appendLeakLogEntryV1` appends entries to `_leaksLogV1Key` in `lib/services/progress_service.dart`.
  - Resolution log appends via `appendLeakResolutionEntryV1` to `_leaksResolutionLogV1Key`.
- Deterministic due/queue function exists:
  - `computeLeaksQueueForDayV1` sorts deterministically (`utcTsMs`, then `leakId`) and suppresses by latest resolution.
  - `isLeaksDueForDayV1` derives due state from computed deterministic queue.
- Daily cap exists:
  - `leaksDailyCapV1 = 5` in `lib/services/progress_service.dart`.
- Contract references exist:
  - `test/guards/world_campaign_map_home_contract_test.dart` checks queue ordering/cap, algo version, suppression behavior.

## SECTION 5 — 90-Day Schedule Snapshot
MASTER PLAN requirement: deterministic 90-day snapshot, immutable snapshots, version boundaries (`docs/plan/MASTER_PLAN_v2.2.md`, section 4 and DoR item 7).

Findings:
- Generator exists:
  - `tools/compile_daily_schedule_v1.dart`.
- 90-day default boundary exists:
  - `_parseArgs` default `days = 90` in `tools/compile_daily_schedule_v1.dart`.
- Immutability design exists as deterministic snapshot check:
  - `--check` mode compares byte-identical output with `content/schedules/daily/v1/schedule.md` and fails on mismatch.
- Snapshot artifact exists:
  - `content/schedules/daily/v1/schedule.md` with `@schedule v=1` header.
- Version-boundary implementation status:
  - Present in content artifacts: `@schedule v=1` and gauntlet `@gauntlet v=1` headers.
  - Explicit fields named `schedule_version`, `gauntlet_template_version`, `content_schema_version` are specified in MASTER PLAN but not found as explicit fields in current schedule artifact.

## SECTION 6 — Definition of Ready Gap Table
DoR source: `docs/plan/MASTER_PLAN_v2.2.md` section 9 (items 1..8).

| DoR item | Status | Evidence |
|---|---|---|
| 1. Today loop fully deterministic and stable | COMPLETE | `lib/services/today_router_v1.dart` deterministic ladder/order; deterministic contract tests in `test/guards/world_campaign_map_home_contract_test.dart` and routing matrix checks in `test/guards/world_campaign_routing_matrix_contract_test.dart`. |
| 2. Endless perception exists (gauntlets + tiers + leaks) | PARTIAL | Gauntlets and leaks are implemented (`lib/services/today_router_v1.dart`, `lib/services/progress_service.dart`); tier artifacts exist (`lib/personalization/world_mastery_v1.dart`, `enum MasteryTierV1` in `lib/ui_v2/screens/universal_intake_plan_screen.dart`), but DoR-level integrated proof for full “gauntlets + tiers + leaks” loop is not centralized in one contract. |
| 3. Content platform fully validated and versioned | PARTIAL | Validation/audit tooling exists (`tools/validate_world_content_v1.dart`, `tools/checkpoint_drills_content_v1.dart`, `tools/audit_why_v1_coverage_v1.dart`); version markers are present (`@schedule v=1`, `@gauntlet v=1`), but explicit named version-boundary fields from MASTER PLAN are not present in schedule artifact. |
| 4. Exactly-once spend proven by contract tests | COMPLETE | Idempotent txn ledger in `lib/services/progress_service.dart`; tests in `test/services/chips_ledger_v1_test.dart` and idempotency contract references in campaign runner tests. |
| 5. 1 free Today/day enforced | COMPLETE | `TodayEntitlementsV1.free()` (`todayEntriesPerDay=1`) and deterministic `today_entry:v1:<day>:<cohort>` idempotent transaction enforcement in `lib/services/progress_service.dart`; test in `test/services/chips_ledger_v1_test.dart`. |
| 6. Subscription hooks defined (UI optional) | PARTIAL | Entitlement model type exists (`TodayEntitlementsV1`) and is consumed by Today entry pricing path; explicit subscription-tier entitlements are not surfaced as separate runtime states in audited paths. |
| 7. 90-day schedule snapshot generated and immutable | PARTIAL | Generator + default 90-day output + `--check` byte-match guard exist in `tools/compile_daily_schedule_v1.dart`; schedule snapshot exists at `content/schedules/daily/v1/schedule.md`; explicit `schedule_version` field is not found in schedule artifact. |
| 8. Low ops burden (no manual daily curation) | PARTIAL | Deterministic compiler path exists (`tools/compile_daily_schedule_v1.dart`) and router consumes schedule snapshot deterministically (`lib/services/today_router_v1.dart`); audited artifacts do not include a formal “no manual curation” enforcement contract beyond process/tooling conventions. |

---

Determinism notes:
- This report uses deterministic path ordering (World 0→4; DoR 1→8).
- All findings are repository-state facts at audit time.

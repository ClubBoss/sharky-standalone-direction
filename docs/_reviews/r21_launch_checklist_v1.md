# R21 Launch Checklist v1 (Authoritative Go/No-Go)

## 1) Launch Thesis
### v1 shipping scope
- Deterministic learning loop is live end-to-end:
  onboarding -> world1 -> world2 -> world10 -> track choice -> track sessions -> result -> map return.
- Checkpoint loop is live and deterministic (pending strip, checkpoint entry, seeded top-3 review, bounded 6-step runner).
- Core guard and gate discipline is in place (`flutter analyze`, `fast_loop`, release gate scripts).

### Explicitly deferred (not in v1 launch)
- New drill families/schema expansions.
- New world/content trees beyond current shipped spine.
- Gamification/economy expansion and localization expansion.
- Non-critical visual polish not tied to route integrity.

## 2) Must-Pass Gates
Run in order.

1. `flutter analyze`
- Pass criteria: `No issues found`.

2. `./tools/fast_loop_world1_v1.sh`
- Pass criteria: `FAST LOOP PASS` and no failing selected guard tests.

3. `./tools/release_gate_world1.sh` (policy-gated)
- Pass criteria: script exits 0 and prints `World1 release gate passed.`
- Note: includes formatting checks and tier checks; full-suite behavior follows test policy.

4. Content gates (required only when content changes are included in release cut)
- `dart run tools/validate_world_content_v1.dart`
- `dart run tools/run_content_qa_r2_v1.dart`
- Pass criteria: both exit 0.

Fail policy:
- Any gate FAIL => NO-GO.

## 3) Surface Checklist
| Surface | Status | Evidence |
|---|---|---|
| Map / entry | PASS | `docs/_reviews/r18_mastery_checkpoints_ux_audit_v1.md`; `test/guards/world_campaign_map_home_contract_test.dart` (map-first flow, checkpoint strip visibility/CTA). |
| Runner | PASS | `docs/_reviews/r13_rc_cut_report_v1.md`; `docs/_reviews/r18_mastery_checkpoints_ux_audit_v1.md`; runner step/cue contracts in `test/ui_v2/session_result_screen_contract_test.dart`. |
| Result loop | PASS | `docs/_reviews/r13_rc_cut_report_v1.md`; deterministic return contracts in `test/ui_v2/session_result_screen_contract_test.dart` (`r9 p0.5`, checkpoint clear path). |
| Checkpoint loop | PASS | `docs/_reviews/r18_mastery_checkpoints_ux_audit_v1.md`; `docs/_reviews/r19_checkpoint_content_quality_audit_v1.md`; `docs/_reviews/r20_entitlement_paywall_matrix_v1.md`. |
| Track routing | PASS | `docs/_reviews/r13_rc_cut_report_v1.md` (must-pass E2E route includes track choice -> s01..s03 -> result -> return). |
| Monetization / entitlement / paywall | PASS (with bounded debt) | `docs/_reviews/r20_entitlement_paywall_matrix_v1.md` proves launch-critical deterministic routes for non-entitled/trial/premium/restore; `docs/plan/MONETIZATION_SSOT_v1.md` tracks unified-ledger hardening debt (not observed route bug). |
| Content validity / determinism | PASS | `docs/_reviews/r13_rc_cut_report_v1.md` (validator + QA PASS in RC run), deterministic contracts across R18/R19 audits. |

## 4) Operational Checklist
- [x] PRE `git status --porcelain` is empty.
- [x] Gates from section 2 pass on release candidate commit.
- [x] POST `git status --porcelain` is empty after any release prep scripts.
- [x] Release notes reviewed: `docs/RELEASE_NOTES.md`.
- [x] Store package checklist reviewed against `docs/release/store_package_v1.md`.
- [x] Manual verification required before GO:
  - entitled and non-entitled startup smoke,
  - restore path smoke,
  - checkpoint re-entry smoke,
  - map -> runner -> result -> map no-dead-end smoke.

Operational status now:
- PASS: Slice C verification complete on target commit `b53840561`.
- Manual smoke evidence resolved with deterministic contracts:
  - entitled/non-entitled startup: `today plan gates world5 placement behind premium preview and restore unblocks next attempt`.
  - trial-active startup: `today plan allows trial-active entitlement to open premium-target placement deterministically`.
  - restore path: `restore purchased premium product converges entitlement to true`.
  - checkpoint re-entry: `r17 checkpoint pending routes to checkpoint pack and clears after checkpoint completion`.
  - map -> runner -> result -> map no-dead-end: `r9 p0.5: after cash s03 result, back-to-map return path is deterministic`.

Gate run evidence on target commit `b53840561`:
- `flutter analyze`: PASS
- `./tools/fast_loop_world1_v1.sh`: PASS
- `./tools/release_gate_world1.sh`: PASS

## 5) Go / No-Go Rule
GO only if ALL are true:
1. All must-pass gates pass on the candidate commit.
2. No BLOCKED items in Surface Checklist.
3. Operational checklist manual items are checked complete.
4. Open launch-risk list is empty or explicitly accepted as non-launch-critical by product owner.

NO-GO if ANY are true:
- any gate fails,
- deterministic routing regression appears,
- manual smoke detects dead-end/entitlement mismatch,
- unresolved P0 launch blocker remains.

## 6) Deferred-Before-Launch List (Anti-Drift)
Do NOT pull into launch cut:
- new worlds/tracks/drill types,
- schema or telemetry redesign,
- economy/gamification/localization expansions,
- broad UI refactors,
- non-critical polish work.

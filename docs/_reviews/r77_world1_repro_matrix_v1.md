# R77 World1 Repro Matrix v1

## Scope
- Focused high-EV World1 pilot issues only.
- Not a broad bug database.

## Matrix

| Issue ID | Observed Symptom | Route/Phase | Reference | Authoritative Renderer | Likely Source Chain | Current Contract Status | Target Contract Needed | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1-RM-001 | Facing-bet state can show illegal/contradictory expected-action family in outcome mismatch flow | Action-decision -> footer/outcome mismatch | Fresh-install contradiction family; R75/R76 closeouts | `world1_foundations_microtask_runner_screen.dart` | `_runEngineV2FullHandLoop` -> mismatch expected label -> outcome reason lines | R75 + R76 targeted guards exist | R78 pilot truth compiler + validator legality checks now guard explicit-illegal expected-action metadata across pilot packs | guarded by pilot truth |
| W1-RM-002 | Expected/why family semantic divergence risk under explicit metadata precedence | Action-decision -> footer/outcome | R75 observed class | same runner screen | `world1SpineExpectedActionKindV1` + `_buildOutcomeWhyLineV1` + `_buildOutcomeBecauseLineV1` | Guarded by existing unit/widget contracts | R78 pilot truth compiler now emits expected/why from one path; validator enforces expected/why coherence for pilot families | guarded by pilot truth |
| W1-RM-003 | Start Now/progression truth suspicion (wrong first pack or stale route context) | map/start-now -> first launch | historical suspicion; still high EV to keep validated | `ui_v2_progress_map_screen_v2.dart` + `progress_service.dart` | `_handleCampaignStartNowActionV1` -> `_resolveEarliestIncompleteWorld1PackIdV1` -> `_openNextCampaignPackFromSsoT` | R79 compact phase-lock contract now validates fresh-install and earliest-incomplete ladder through Act0 -> spine handoff | Keep this route-truth contract mandatory for any Start Now seam edits | guarded by route truth lock |
| W1-RM-004 | Facing-bet affordance contradiction (CHECK/BET semantics) could re-enter via future edits | action bar | R73 family | runner screen action chips | `_buildCampaignActionChips` with facing-bet semantics | Existing R73 coverage in foundations contract suite | R78 validator now verifies expected + acceptable action coherence against legal affordances for pilot families | closed (guarded) |
| W1-RM-005 | Result/finish composition can drift (CTA/why/up-next mismatch) and weaken pilot coherence | result/finish -> progression return | historical finish-chain risk | `session_result_screen.dart` + `progress_service.dart` | `_primaryCtaLabelV1` / `_resultWhyLineV1` / `_upNextFocusLineV1` | R80 seam contracts now lock single framing family, deterministic primary handoff, and idempotent completion write behavior | Keep these contracts mandatory for any result/progression seam edits | guarded by result/finish coherence lock |

## Notes
- `W1-RM-001` and `W1-RM-002` are now guarded through the R78 pilot truth path and must stay locked in future migrations.
- `W1-RM-003` is now explicitly phase-locked by compact Start Now -> Act0-first -> earliest-incomplete route contracts.
- `W1-RM-005` is now explicitly guarded on the authoritative seam through compact result/finish contracts; continue treating this as a drift-sensitive phase.

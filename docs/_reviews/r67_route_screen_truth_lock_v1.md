# R67 Route/Screen Truth-Lock Closeout v1

## Canonical first-user route (locked)
- App entry: map/home flow to world campaign shell.
- Primary CTA seam: `today_plan_start_cta` / `world_campaign_next_pack_cta` in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
- Start-now dispatcher: `_handleCampaignStartNowActionV1()`.
- First opened pack/session on fresh install:
  - `_resolveEarliestIncompleteWorld1PackIdV1()` iterates `kWorld1CanonicalModuleOrder` and first unresolved id is `world1_act0_table_literacy`.
  - Launch via `_openNextCampaignPackFromSsoT()` -> `_openCampaignPack(...)` -> `World1FoundationsMicroTaskRunnerScreen`.
- First several runner steps:
  - early Act0/seat-quiz and early action-mode branches in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`.
- First result screen:
  - `lib/ui_v2/screens/session_result_screen.dart` primary CTA + why/focus lines.
- Return/progression implication:
  - result next/back path into map/module summary via existing route contracts.

## Candidate seam mapping (screen/branch truth)

### A) Facing-bet action-contract / affordance seam
- Screen: `World1FoundationsMicroTaskRunnerScreen`.
- Branch/seam: action bar generation and allowed-action label mapping (`RAISE TO` / `RAISE MIN`, `toCall` branches).
- Runtime/content/mixed: runtime.
- In canonical route for first-user steps: **PLAUSIBLE but unproven adjacent**.
- Route-truth notes:
  - This seam is strongly contract-backed from R60/R61 and exists primarily in spine/followup action branches.
  - Canonical first pack is Act0 (`world1_act0_table_literacy`), so direct causal link to currently observed dominant issue is not proven from repo-state alone.
- Existing proof:
  - `test/guards/world1_foundations_microtask_contract_test.dart` action-contract determinism suite.
- Missing proof:
  - artifact-level confirmation that observed fresh-install issue is emitted by facing-bet branch in canonical route steps.

### B) Finish/result duplication seam
- Screen: `SessionResultScreen`.
- Branch/seam: primary CTA label resolver `_primaryCtaLabelV1(...)` and up-next/why lines.
- Runtime/content/mixed: runtime.
- In canonical route: **CONFIRMED route presence, issue-causality unproven**.
- Route-truth notes:
  - User definitely reaches result screen in canonical route.
  - R64 closed previous `CONTINUE` ambiguity; current dominant observed issue is not proven to be duplicate finish framing from this exact branch.
- Existing proof:
  - `test/ui_v2/session_result_screen_contract_test.dart` (`NEXT LESSON` contract + route continuity coverage).
- Missing proof:
  - direct symptom-to-branch mapping from observed fresh-install issue.

### C) Action-mode highlight/visual bleed seam
- Screen: `World1FoundationsMicroTaskRunnerScreen`.
- Branch/seam: seat-quiz vs hand-loop visual state and highlight toggles (`seatQuizVisualMode`, target highlight, instruction overlays).
- Runtime/content/mixed: runtime.
- In canonical route: **PLAUSIBLE but unproven adjacent**.
- Route-truth notes:
  - Canonical route includes seat-quiz states, so this seam is adjacent and relevant.
  - Current repo contracts show mode separation and highlight discipline are heavily guarded after R59/R62/R63.
- Existing proof:
  - mode-separation + seat-quiz instruction/highlight contract tests in `test/guards/world1_foundations_microtask_contract_test.dart`.
- Missing proof:
  - exact confirmation that observed issue is produced by highlight/bleed branch in first-user route.

### D) Stronger seam candidate: entry-path pack-branch mismatch (Act0 vs spine assumption drift)
- Screen: map start-now -> runner launch path.
- Branch/seam: `_resolveEarliestIncompleteWorld1PackIdV1()` with `kWorld1CanonicalModuleOrder` (Act0-first), then `_openNextCampaignPackFromSsoT()`.
- Runtime/content/mixed: runtime.
- In canonical route: **CONFIRMED**.
- Route-truth notes:
  - This is the highest-confidence truth-lock finding: fresh-install path is Act0-first, while many prior candidate fixes were spine-focused.
  - This seam explains how future fixes can target wrong branches even when local contracts pass.
- Existing proof:
  - deterministic resolver code path + route contract surfaces in map/home tests.
- Missing proof:
  - external observed-symptom timestamp-to-branch linkage for one specific visual defect.

## Confirmed vs adjacent vs unsupported classification
- CONFIRMED current-route seams:
  - D) entry-path pack-branch seam (Act0-first route truth).
  - B) result screen is on route, but specific dominant issue causality remains unproven.
- PLAUSIBLE but unproven adjacent branches:
  - A) facing-bet action-contract seam.
  - C) action-mode highlight/visual-bleed seam.
- NOT SUPPORTED as currently confirmed issue source:
  - any seam treated as dominant defect source without direct route-branch symptom evidence.

## Exact R68 direction lock
- Verdict: **bounded NO-GO on implementation**.
- R68 is locked as bounded evidence continuation only:
  - confirm one exact observed symptom -> route step -> screen -> state branch mapping,
  - then either lock one implementation seam or reaffirm NO-GO.
- Reason:
  - one confirmed route truth exists (Act0-first branch), but no single user-visible defect branch is strongly proven as the dominant current issue source.

## Open-risk list
- Fixing spine/adjacent seams without explicit Act0-route symptom mapping can repeat “fixing the wrong thing.”
- Remaining low-severity polish issues may be mistaken for dominant defects without branch-level evidence.

## Anti-drift note
- R67 intentionally performs no runtime/content changes.
- Next milestone is constrained to branch-proof evidence capture before any new implementation.

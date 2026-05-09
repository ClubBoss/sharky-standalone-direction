# R68 Observed Symptom -> Branch Proof Closeout v1

## Milestone purpose/scope recap
- Purpose: prove one exact observed first-user symptom maps to one exact branch/state seam in canonical Act0-first route.
- Scope: doc-only route/branch proof and one R69 lock.
- Out of scope: runtime/content implementation, multi-seam selection, broad redesign.

## Exact Act0-first route steps inspected
1. Entry/start-now
- Screen/seam: `UiV2ProgressMapScreenV2` start CTA (`today_plan_start_cta` / `world_campaign_next_pack_cta`).
- Branch: `_handleCampaignStartNowActionV1()`.
2. First pack open
- Branch: `_resolveEarliestIncompleteWorld1PackIdV1()` iterates `kWorld1CanonicalModuleOrder`.
- Fresh-install first unresolved id: `world1_act0_table_literacy`.
- Launch seam: `_openNextCampaignPackFromSsoT()` -> `_openCampaignPack(...)`.
3. First runner states
- Screen: `World1FoundationsMicroTaskRunnerScreen` Act0 seat-quiz + early guided states.
4. First result screen
- Screen: `SessionResultScreen` primary CTA/why lines.
5. Return/progression implication
- Result continue/back path to map/module summary continuity.

## Candidate symptom-to-branch mapping

### A) Action-bar legality/affordance symptom
- Route step where visible: early action-decision states (typically spine/followup, not guaranteed earliest Act0 seat-quiz moments).
- Branch/seam: action-bar allowed-action mapping + `toCall` legality and raise-label normalization in runner.
- Classification: **PLAUSIBLE-ADJACENT**.
- Proof exists: strong R60/R61 contracts for `RAISE TO`/`RAISE MIN`, expected/correct/why alignment.
- Missing proof: direct observed-symptom evidence that this is the dominant issue in canonical Act0-first path.

### B) Finish/result duplication symptom
- Route step where visible: first session result screen.
- Branch/seam: `_primaryCtaLabelV1(...)` and up-next/why lines in `SessionResultScreen`.
- Classification: **PLAUSIBLE-ADJACENT** (route presence confirmed, dominant symptom causality unproven).
- Proof exists: R64 contract lock (`NEXT LESSON`/`REVIEW`/`BACK TO MAP`/`FINISH`) and result-route continuity tests.
- Missing proof: explicit observed symptom demonstrating active duplication from this branch.

### C) Action-mode visual highlight/bleed symptom
- Route step where visible: seat-quiz/action-mode transition visuals.
- Branch/seam: `seatQuizVisualMode` + highlight/overlay state in runner.
- Classification: **PLAUSIBLE-ADJACENT**.
- Proof exists: mode separation and highlight discipline tests in runner guard suite.
- Missing proof: observed symptom explicitly tied to highlight/bleed branch rather than guidance copy branch.

### D) Stronger Act0-first symptom (selected)
- Symptom: early first-user guidance feels command-following/mechanical via explicit command line `Tap the highlighted seat.`
- Route step where visible: first Act0 seat-quiz states immediately after first pack launch.
- Branch/seam:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - seat-quiz guidance fallback path (examples in code include `Tap the highlighted seat.` lines).
- Classification: **CONFIRMED current-route seam**.
- Proof exists:
  - canonical route proof that first pack is Act0 (`world1_act0_table_literacy`),
  - runner code contains the exact user-visible string on Act0 seat-quiz branch,
  - Act0-focused runner contracts validate this branch is exercised.
- Missing proof:
  - none required for branch identity lock; implementation details are deferred to R69.

## Confirmed vs adjacent vs unsupported classification
- CONFIRMED current-route seam:
  - D) Act0 seat-quiz command-style guidance seam (`Tap the highlighted seat.`) in first-run branch.
- PLAUSIBLE but unproven adjacent seams:
  - A) action-bar legality/affordance,
  - B) finish/result duplication,
  - C) highlight/bleed.
- UNSUPPORTED as current dominant target:
  - any seam not on canonical Act0-first route step sequence or lacking branch-level symptom proof.

## Exact R69 lock
- R69 is locked to one implementation-ready seam only:
  - File/surface: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Route step: first Act0 seat-quiz guidance state after first pack launch
  - Branch/state: seat-quiz instruction fallback branch that emits `Tap the highlighted seat.`
  - User-visible symptom: command-style low-meaning guidance in first-user Act0 flow
  - Bounded family to fix: one deterministic Act0 seat-quiz guidance wording family (no multi-branch copy sweep)
- Anti-drift boundaries:
  - no action-bar legality redesign,
  - no result-screen overhaul,
  - no multi-surface highlight system rewrite,
  - no personalization/schema/runtime expansion beyond selected seam.

## Open-risk list
- Adjacent seams (A/B/C) may still contain low-severity issues but are intentionally deferred.
- Over-broad copy cleanup would risk reintroducing wrong-target drift.

## Anti-drift note
- R68 performs no runtime changes; it locks only one proven symptom->branch target for R69.

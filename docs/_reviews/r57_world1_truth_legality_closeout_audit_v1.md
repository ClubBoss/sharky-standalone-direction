# R57 World1 Truth & Legality Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: execute a verify-first World 1 emergency triage and close one highest-risk bounded regression class only.
- Verified inventory included three classes: legality/runtime truth, prompt/feedback content truth, and map/progression continuity.
- Selected scope held: one content-integrity family only (`"Choose fold/call/raise."` direct-answer leakage in World 1 `action_choice` drills).
- Out-of-scope held: runner architecture redesign, broad all-world cleanup, onboarding/personalization expansion, schema/dependency changes.

## Verified regression inventory summary
- A) Illegal action-state / poker truth regressions
  - Surface checked: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`, `lib/campaign/campaign_pack_registry_v1.dart`.
  - Contract evidence: `test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 preflop action-state truth invariants hold for pot/currentBet/toCall"` passed.
  - Result: no reproducible active repo-state regression for `CHECK while facing bet` or `BET when only raise is legal` in bounded World 1 spine path.
- B) Lingering content/prompt/feedback regressions
  - Confirmed: direct-answer prompt leakage persisted in World 1 drills (`"Choose fold/call/raise."`) across 26 files under `content/worlds/world1/v1/sessions/**/drills/`.
  - Existing guard gap: `hasPromptAnswerLeakV1(...)` did not fence this exact family.
- C) Map/progression state regressions
  - Contract evidence: `test/guards/world1_daily_completion_persistence_contract_test.dart` passed.
  - Additional trust wording contracts remained green (`test/ui_v2/map_top_leak_context_label_contract_test.dart`, `test/guards/world_campaign_map_home_contract_test.dart --plain-name "campaign map keeps learning stats in details only"`).
  - Result: no reproducible active repo-state progression regression in selected World 1 seams.

## Why the selected subset won
- Selection priority was respected. Class A/C could not be confirmed as active regressions in repo state; class B had confirmed user-visible leakage with deterministic footprint and bounded cleanup.
- Selected family is a single deterministic class with low false-positive risk and one clear guard contract.

## Exact closure evidence
- New bounded guard helper:
  - `tools/why_v1_ssot_v1.dart`
  - `hasDirectChooseActionPromptLeakV1(...)` with exact regex `^choose\s+(?:fold|call|raise)\.?$`.
- World 1-scoped validator fence:
  - `tools/validate_world_content_v1.dart`
  - Adds `prompt_direct_action_leak_world1_v1` only when `sessionId.startsWith('w1.') && kind == 'action_choice'`.
- Bounded violation-driven cleanup:
  - 26 World 1 drill files updated from `"Choose fold/call/raise."` to `"Choose the best action."`.

## Proof recap (gates + targeted tests)
- Targeted contract:
  - `dart test test/tools/why_v1_ssot_v1_test.dart` (includes direct choose-action leak fence cases) PASS.
- Required gates:
  - `flutter analyze` PASS
  - `./tools/fast_loop_world1_v1.sh` PASS
  - `dart run tools/validate_world_content_v1.dart` PASS
  - `dart run tools/run_content_qa_r2_v1.dart` PASS

## Open-risk list
- Same direct-answer prompt family may still exist outside World 1 by design (for example World 0) and is deferred to avoid multi-world expansion in this emergency pass.
- Manual-playtest-only legality concerns outside covered contracts may require a dedicated reproduction-first follow-up slice.

## Explicit defer list
- Broad generic `choose <action>` cleanup across all worlds.
- Any runtime legality engine redesign.
- Multi-surface onboarding/map UX consolidation.

## Anti-drift note
- R57 closed exactly one bounded emergency family.
- No drift into broad world rewrite, architecture redesign, or multi-family cleanup.

## Ambiguous P0 status
- No ambiguous P0 remains for the selected R57 direct-answer World 1 prompt leakage family.

## Transition note (next focus only)
- Define `# Milestone R58` before execution work starts.

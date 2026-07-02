# Sharky Phrase Tier Contract v1

## 1. Verdict

`sharky_phrase_tier_contract_landed_with_bounded_migration`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `156dcebe6140dfb8fa3c23fcebe7b950baf6ebdd`
- Tracked/staged changes at start: none
- Untracked scope at start: `output/**` only
- Initial `graphify hook-check`: passed

## 3. Capsule/authority check

`ACTIVE_ROUTE_CAPSULE_v1.md` matched the prompt: Phase 4 was closed, Phase 5
was active, and `Sharky Phrase Tier Contract v1` was the current task. No
`stale_capsule_scope` stop was needed. The higher-authority task prompt narrowed
the active phrase tiers to Foundation and Developing only, so the previous
future `sharp` phrase tier in the code was removed from active runtime truth.

## 4. Current phrase ownership audit

| Surface | Phrase owner | Current trigger | Evidence source | Tier | Safe/unsafe | Duplication issue | Migration recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Welcome | Welcome/placement widgets and authored `Act0SharkyCueV1` copy | first open / placement | route/onboarding state | Foundation | safe | hardcoded active welcome copy | leave for phrase-set pass |
| Correct feedback | runtime feedback voice + authored feedback line | correct outcome | current task outcome | Foundation/Developing | safe | not owned by Sharky phrase contract | leave until feedback phrase set is admitted |
| Wrong feedback | runtime feedback voice + authored feedback line | wrong/suboptimal outcome | current task outcome | Foundation/Developing | safe | not owned by Sharky phrase contract | leave until feedback phrase set is admitted |
| Repair feedback | repair outcome/proof seams plus phrase contract wrapper | successful repair proof | repair outcome projection | Foundation/Developing | safe | existing wrapper covered proof fallback | preserve wrapper |
| Session Summary | phrase contract for proof line; summary/earned-moment widgets for other copy | proof hero / earned moment | proof and repair projections | Foundation | safe | hardcoded earned proof line remains | leave non-duplicated earned proof copy |
| Home | Home widget hardcoded line | active mission | route/home state | Foundation | safe | one localized hardcoded cue | leave for phrase-set pass |
| Review | phrase contract wrapper | active repair note | active repair evidence | Foundation | safe | contract and widget already connected | preserve surface-specific phrase |
| Profile | Profile widget hardcoded proof identity | proof card | banked-fix projection | Foundation | safe | no phrase resolver use yet | leave for profile phrase-set pass |
| Practice | phrase contract wrapper | active repair item | repair queue projection | Foundation | safe | contract and widget already connected | preserve |
| World completion | phrase contract wrapper | W1/W2-W6 completion | completion state | Foundation/Developing | safe | already contract-owned | preserve |
| Band transition | moved to phrase contract wrapper | W4 complete -> W5 next | exact W4->W5 completion route truth | Foundation -> Developing boundary | safe | previously one hardcoded identity line | migrated now |

No active Sharky copy audit found Russian/English mixed-copy risk that required
this contract to rewrite UI copy. Existing RU localization keeps `Sharky` as a
proper product name.

## 5. Phrase context contract

The new deterministic model is `Act0SharkyCoachPhraseContextV1` with:

- `surface`
- `momentType`
- optional `tier`
- `evidenceKind`
- optional `conceptFamilyId`
- optional `repairState`
- optional `transferState`
- optional `proofState`
- optional `completionState`
- `claimBoundary`
- `fallbackKey`
- optional `worldNumber` and `nextWorldNumber` for the W4->W5 boundary

The resolver is `act0ResolveSharkyCoachPhraseV1`. Existing widgets can keep the
legacy string wrapper `act0SharkyCoachLineForMomentV1`; that wrapper now builds
structured phrase contexts rather than selecting copy directly from a tier-only
switch.

## 6. Tier rules

Only active tiers are:

- `foundation`: W1-W4, concrete and beginner-safe.
- `developing`: W5-W12 and safe fallback for later worlds until a future scope
  admits another tier.

No widget infers tier from display copy. Missing tier falls back to Foundation.
No W13+ or advanced phrase tier was introduced.

## 7. Claim boundaries

Allowed claim classes:

- neutral orientation
- direct observation
- repair
- conservative transfer
- pattern observation
- progression

Forbidden language remains blocked by tests: mastery, AI discovery, solver/GTO
claims, biggest/weakest leak claims, always/never behavior, fixed-forever
claims, memory guarantees, ratings, radar, levels, and unsupported
intermediate-player identity claims.

## 8. Phrase families

The bounded families are:

- `orient`
- `explain`
- `repair`
- `confirm`
- `reinforce`
- `reflect`
- `transition`

Each family is selected only through a moment plus matching evidence state.
Unsupported evidence returns the neutral fallback.

## 9. Ownership and fallback rules

Phrase selection belongs to `act0_sharky_coach_phrase_contract_v1.dart`.
Repair, proof, transfer, completion, Review, Session Summary, and Profile remain
the owners of truth. Widgets receive resolved copy or phrase keys; they do not
parse copy to infer state. Telemetry does not own phrase selection. The fallback
is deterministic, non-blank, ASCII, and contains no template tokens.

## 10. Bounded migration

One active hardcoded phrase was migrated:

- `Act0BlockCompletionSummaryV1.bandTransitionIdentityLabel` now resolves
  through `Act0SharkyCoachMomentV1.bandTransitionPayoff`.

Rendered UI copy remains `Foundation complete`, preserving the existing W4->W5
milestone tests. Review and Practice kept their existing surface-specific
phrases through the resolver. No broad phrase-library migration was attempted.

## 11. Telemetry boundary

No telemetry was added. No learner-facing phrase text is logged. Future local
events may record deterministic phrase keys only if a separate telemetry prompt
admits that scope.

## 12. Tests/validation

Focused validation run during implementation:

- `flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_w4_w5_band_transition_milestone_v1_test.dart`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/ui_v2/act0_review_shell_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart test/ui_v2/act0_w4_w5_band_transition_milestone_v1_test.dart`

Final validation:

- focused tests above passed in the final combined run (`136` tests)
- `flutter analyze`: no issues
- `graphify hook-check`: passed
- `git diff --check`: passed
- targeted capsule route checks: passed
- generated Flutter drift was restored for
  `macos/Flutter/GeneratedPluginRegistrant.swift`

## 13. Rolling Capsule Advance

`ACTIVE_ROUTE_CAPSULE_v1.md` advances from `Sharky Phrase Tier Contract v1` to
`Foundation + Developing Phrase Sets v1`. `VISUAL_PROOF_CAPSULE_v1.md` and
`LEARNING_REPAIR_CAPSULE_v1.md` record the durable phrase context, tier,
family, evidence, claim-boundary, and fallback rules without adding visual
state, motion, or AI/chat scope.

## 14. Scope safety

No new screen, route, Sharky asset, visual state, motion, localization
architecture, AI phrase generation, dependency, W13+ content, Modern Table
visual change, broad refactor, or telemetry was added. The implementation
touched one active contract, one existing completion-label consumer, one focused
test file, route capsules, and this review artifact.

## 15. Known limitations

The contract is intentionally small. Welcome, Home, Profile, feedback
authored-copy, and earned-moment copy still contain some hardcoded Sharky lines.
They are safe enough for this PR and should move only in the dedicated
Foundation + Developing phrase-set pass.

## 16. Next recommendation

`Foundation + Developing Phrase Sets v1`

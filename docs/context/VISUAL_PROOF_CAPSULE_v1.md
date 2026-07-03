# Visual Proof Capsule v1

Status: ACTIVE visual/proof capsule.
Freshness date: 2026-07-03.
Verified product HEAD: pending commit (this task's own commit advances it).
Verified active route artifact: `docs/_reviews/phase_6_closure_audit_v1.md`.
Refresh trigger: every committed visual token, surface acceptance, screenshot
lane, proof/progression, motion, or design-system change.

## Accepted Visual System

- Shell: navy app frame and dense premium surfaces.
- Felt: deep teal-green material.
  - base `#146B56`
  - shadow `#0F5A47`
  - deep `#0B4A3B`
- Rail: `#14273A`
- Primary CTA: flat blue `#0A64D8`
- Pressed primary CTA: `#0858BE`
- CTA label: white
- Gold: earned/proof emphasis only; no gold button identity.
- Panels on felt: navy-glass, not bright cyan cards.
- Objective flag: neutral teal, not reward gold.

## Accepted / Frozen Surfaces

- Premium Visual Foundation is CLOSED; the static premium visual regression
  passed with no P0 or new P1 visual regression.
- Welcome: accepted.
- Review: accepted.
- Table felt: accepted.
- Home structure: frozen unless evidence reopens it.
- Practice structure: frozen unless evidence reopens it.
- Profile: frozen unless evidence reopens it.
- Bottom nav: frozen.
- Feedback structure: frozen.

Do not reopen a frozen surface for adjacent polish unless the active prompt
names that surface or new evidence shows a concrete defect.

## Current Proof State

Session Summary's existing gold-contained proof receipt consumes the structured
banked-fix projection when available and retains its repair-outcome fallback.
Cross-Session Proof Profile landed in the existing Profile `Progress proof`
card: it consumes lifetime and recent proof while preserving the navy-glass
hierarchy. Achievement Visual Language / Icons v1 landed a small shared
`Act0ProofIconV1` seam (`lib/ui_v2/act0_shell/act0_proof_icon_v1.dart`) with
three semantic roles (`repairCompleted`, `reinforced`, `milestone`). W1
Completion Payoff v1 gave `milestone` its first valid consumer via a shared
`_WorldMilestoneCardV1` layout inside `Act0BlockCompletionShellV1`. W2-W6
Completion Payoff v1 extended that same shared card to ordinary World 2-6
completions (`_WorldCompletionPayoffV1`, gate
`Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff`). W4->W5 Band
Transition Milestone v1 closed Phase 4: World 4 now renders a dedicated,
higher-priority `_BandTransitionPayoffV1` wrapper (gate
`hasBandTransitionPayoff`, `worldNumber == 4 && nextWorldNumber == 5`,
checked before `hasWorldCompletionPayoff` at the render site so World 4
never falls through to the ordinary card) with its own claim-safe copy
(`Foundation complete` / `Next: Developing Player`, mirroring the real
`foundation`/`developing` tier boundary already encoded at world number 5 in
`act0SharkyCoachTierForWorldNumberV1`). It reuses the exact same
`_WorldMilestoneCardV1` hierarchy and proof contract with one bounded
addition: `Act0ProofIconV1.emphasized` (default false) renders a stronger
milestone rim and an extra accent ring, used only by this one moment. World
1-3/5-6 render byte-identically to before (regression-proven). No gallery,
grid, motion, XP, level, mastery, or RPG badge economy was introduced, and no
general multi-band framework exists — `hasBandTransitionPayoff` is
intentionally `worldNumber == 4` only. Phase 4 - Proof Progression is now
CLOSED. Sharky Phrase Tier Contract v1 landed the first Phase 5 companion
contract: `act0_sharky_coach_phrase_contract_v1.dart` now owns a deterministic
phrase context/resolver with `surface`, `momentType`, `tier`, `evidenceKind`,
optional repair/transfer/proof/completion state, claim boundary, and fallback
key. Only `foundation` and `developing` phrase tiers are active; W13+ does not
introduce a new phrase tier and falls back to the currently proven developing
contract until a later explicit scope reopens it. Phrase families are bounded
to `orient`, `explain`, `repair`, `confirm`, `reinforce`, `reflect`, and
`transition`. Missing evidence returns the neutral fallback, not a specific
claim. The initial product migration was the existing W4->W5 `Foundation
complete` identity label moving under the phrase contract while preserving
rendered copy. Foundation + Developing Phrase Sets v1 then added the first
bounded phrase set for the Welcome orientation line, Home mission/done/return
support lines, and Session Summary earned-moment proof line. Foundation copy
names one concrete table clue or local proof; Developing copy can connect
action, table state, position, price, and signal-action links while staying
claim-safe. Widgets no longer own the migrated English phrase text, and W13+
still falls back to the proven Developing tier. Sharky Saw You Improve v1 then
added a source-backed later-improvement observation derived only from
reinforced Fix Proof and admitted it into the existing Session Summary
banked-fix receipt. It adds no new card, route, visual state, pose, asset,
motion, animation, chat, AI copy, telemetry, or personality engine. Sharky
Companion States v1 then closed Phase 5's visual-state gap: a bounded
`Act0SharkyCompanionStateV1` vocabulary (`neutral`, `coach`, `repair`,
`confirm`, `improve`, `milestone`) is resolved deterministically in
`act0_sharky_coach_phrase_contract_v1.dart` from the exact same structured
context (`Act0SharkyCoachPhraseContextV1`) the phrase resolver already
gates on — never from resolved phrase text, never random, never an inferred
emotion. `act0_sharky_presence_v1.dart` maps each state onto the existing
five-mood asset family (no new Sharky asset) via
`act0SharkyMoodForCompanionStateV1`, and adds one bounded, opt-in visual
seam: `Act0SharkyCompanionAvatarV1` plus an additive `ringed`/`emphasized`
accent (reusing the same echo-ring pattern already accepted for
`Act0ProofIconV1`) reserved for `improve`/`milestone` only. Two consumers
were admitted: Session Summary's two existing Sharky bubbles (now resolving
`milestone` > `improve` > `confirm` > `repair` > `neutral` from the same
receipt/completion flags already on screen, replacing two previously
hardcoded mood picks — including one bubble that used to always render
`celebrate` regardless of context) and Welcome's two existing beats (intro
now `neutral`, handoff now `coach`, replacing hardcoded `happy`/`celebrate`
moods). Home's identity-row mood was deliberately deferred: it is threaded
through ~9 ad hoc `preSessionMood:` literals inside the large
`act0_shell_preview_screen_v1.dart` preview-screen file, and migrating it
safely was out of this bounded wave's scope. No new screen, route, asset,
animation, growth/evolution, or mood/rank/XP semantics were added. W1
Completion Copy Regression Repair v1 then restored the accepted W1-specific
payoff identity line (`You banked the first table read.`) through the existing
phrase resolver by marking the W1 completion context with `worldNumber == 1`;
generic W2-W6 completion copy, W4->W5 band-transition copy, companion states,
and Home's deferred state migration remain unchanged. Sharky Visual Growth /
Evolution v1 then closed Phase 5: a bounded `Act0SharkyGrowthStageV1`
(`foundation`, `developing` — exactly two stages) is derived only from the
existing W4->W5 tier boundary (`act0SharkyGrowthStageForWorldNumberV1`,
built directly on `act0SharkyCoachTierForWorldNumberV1`, so growth and tier
can never disagree). It is a strictly separate axis from
`Act0SharkyCompanionStateV1` — proof count, companion state, and completion
events never change growth stage; only world number does. The shared seam
(`Act0SharkyCompanionAvatarV1`, `Act0SharkyGuideCardV1`,
`Act0SharkyPresenceBubbleV1`) gained an additive, default-`foundation`
`growthStage` parameter that composes a second, independent visual layer: a
persistent `act0_shell_sharky_mascot_frame_growth_ring` (using the app's
existing `primary` token, not a mood color) plus a marginally stronger
border/shadow on the base frame — both structural, not color-only, signals.
The existing `improve`/`milestone` companion-state accent ring is untouched
and composes cleanly underneath the growth ring when both are present. Two
consumers were admitted: Welcome (fixed `foundation`, since Welcome always
precedes any world) and Session Summary (derived from
`summary.worldNumber`, the same real per-completion world field already
used for copy — covers both ordinary lesson completions and world
completions). Profile was evaluated as a candidate third consumer (it
already renders `Act0SharkyPresenceMascotV1` in its accepted hero card) but
was deliberately deferred: its frame is a bespoke, frozen `Act0VisualCanonV1`
gradient/border implementation, and giving it growth truth would require
either forbidden consumer-specific styling logic or a risky swap onto the
shared seam that could regress a frozen surface. No new asset, animation,
cosmetics, rarity, XP, level, or rank was introduced. Companion Semantic
Consistency Gate v1 then passed without production repair: phrase, companion
state, and growth stage all resolve from structured evidence rather than
English text or mood inference; Session Summary priority remains
`milestone` > `improve` > `confirm` > `repair` > `neutral`; the W4->W5
transition is classified as `intentional_boundary_behavior` (milestone state
on the World 4 transition screen, Developing growth beginning only in World
5); and Home/Profile remain deferred, harmless legacy surfaces rather than
active contradictions. The remaining evidence gap is that deterministic
screenshot lanes do not naturally expose a W5+ Developing fixture, so
structural/widget tests remain the proof source for that state. Claude
Implementation Quality Gate v1 then accepted the implementation with one
bounded repair: `Act0SharkyGuideCardV1` now forwards `growthStage` in both
compact-stacked and row layout branches, so the shared API behaves
consistently. Architecture conclusions: proof truth remains outside widgets,
phrase/state/growth each have one resolver owner, Session Summary composition
is dense but explicit, and completion payoff wrappers remain bounded rather
than a future-world framework. Home/Profile remain deferred. Hygiene backlog
candidates: `_worldCompletionMetaByNumberV1[4]`, Profile fallback trophy
metaphor, Home `preSessionMood:` literals, Profile growth integration, and
legacy `Good fixes:` payoff-hero compatibility. No unresolved blocker remains
for Phase 6. Street Replay / How We Got Here v1 then landed as a bounded
inline Act0 decision-context consumer, not a modal or replay engine. Its
contract derives from existing `Act0TableStateV1` street, board, seat,
active-actor, pot/price, and ordered action-trail truth. It supports preflop,
flop, turn, and river only when source truth exists; board cards are
street-capped, the pending action is excluded, missing optional values are not
guessed, and missing actor/action truth fails closed. The visible consumer is
one compact `How we got here` block inside the existing decision panel, with a
separate `You are here` marker when the current street has no prior action.
No motion, sheet, timeline scrubber, persistence, solver, Modern Table change,
or full replay architecture was admitted. The active task is now
`W7-W12 Table-Context Readiness Audit v1`. W7-W12 Table-Context Readiness
Audit v1 then passed with optional gaps only. The active W7-W12 screenshot lane
renders source-owned route specs through `Act0LessonRunnerShellV1` with BTN
hero/active position, flop board, pot label, source-owned board/context copy,
and W9-only call-price context. Street Replay remains intentionally hidden for
those captures because their action-trail value is learning-purpose prose, not
source-owned poker action history; the new guard proves the replay projection
fails closed instead of fabricating steps. Optional gaps (stack labels and
multi-street action history) remain deferred until a future task admits a
source-backed owner. No production repair, route expansion, Modern Table
redesign, solver layer, Practice mapping, W13+, or broad curriculum rewrite was
introduced. The active task is now `Phase 6 Closure Audit v1`.
Phase 6 Closure Audit v1 then closed Advanced Learning Presentation with
optional gaps only (`phase_6_closed_with_optional_gaps`). Closure evidence:
Street Replay remains source-truth-safe, deterministic, compact, table-adjacent
but not table-replacing, and fail-closed on incomplete truth; W7-W12 route
captures remain context-ready with BTN hero/active context, flop board, pot
labels, and W9 call-price context; active route screenshots show the table
hierarchy and action buttons remain clear; first_week and full_scroll compact
lanes remain clean. Optional deferred gaps are stack labels, full multi-street
history, full replay/browser/motion, and broader content/glossary depth. No
unresolved Phase 6 blocker remains. Phase 6 - Advanced Learning Presentation is
CLOSED; Phase 7 - Content & Correctness is ACTIVE with
`W1-W12 Content Depth Gate v1`.

## Remaining Visual Route

1. Achievement Visual Language / Icons - CLOSED
2. W1 Completion Payoff - CLOSED
3. W2-W6 Completion Payoff - CLOSED
4. W4->W5 Band Transition Milestone - CLOSED

Phase 4 - Proof Progression is fully CLOSED. No motion or generalized
completion-payoff framework exists; the shared `_WorldMilestoneCardV1` is a
bounded, world-ID-gated layout reused by three thin wrappers (W1-specific,
W2-6 ordinary, W4->W5 band-transition), not a public/reusable component.
`milestone` proof-icon role is used only by true world-completion moments
(W1-W6, including the stronger W4 band-transition variant) and must remain
scoped that way — W7-W12 payoff is the next dedicated completion-payoff
stage, not a green light to treat `milestone` as a generic achievement badge
or to widen `hasBandTransitionPayoff` to any other world boundary. Do not
reopen generic visual design outside a dedicated stage or concrete new
regression evidence.

## Proof / Progression Rules

- Proof before points.
- No fake progress.
- No XP, coins, rating, radar, or level capability claims.
- Achievements must name real evidence.
- Sharky growth must be proof-triggered.
- Do not imply mastery, fixed-forever, public readiness, or learning effect
  without the required evidence gate.

## Screenshot Lanes

- `core compact`
- `first_week compact`
- `day2_return compact`
- `full_scroll compact`
- `active_route_w7_w12 compact`

Use screenshot artifacts only when visual evidence is required. Do not inspect
old `output/**` folders by default.

## Local-Only Rule

`output/**` is local evidence and is never committed unless a future prompt
explicitly admits a specific output artifact.

## Visual Acceptance

- Screenshots are required for UI claims.
- Motion evidence is required for motion claims.
- Do not write "looks okay" as evidence.
- State the exact screen, lane, artifact, and acceptance issue.
- Capture-tool artifacts can be evidence limitations; do not convert them into
  product defects without source/runtime confirmation.

## Agent Guidance

- Fable: define target state and art direction; do not edit route truth.
- Sonnet: handle design-sensitive bounded implementation or copy hierarchy.
- Codex: implement deterministic tokens/layout/tests/evidence and preserve
  scope boundaries.

## Reference Artifacts

- `docs/_reviews/focused_pre_human_visual_ux_upgrade_wave_v2.md`
- `docs/_reviews/apply_owner_patch_sequence_a_b_c_d_v1.md`
- `docs/_reviews/cta_rhythm_learn_cleanup_pr_v1.md`
- `docs/_reviews/static_premium_visual_regression_check_v1.md`
- `docs/_reviews/fixes_banked_weekly_proof_v1.md`
- `docs/_reviews/cross_session_proof_profile_v1.md`
- `docs/_reviews/achievement_visual_language_icons_v1.md`
- `docs/_reviews/w1_completion_payoff_v1.md`
- `docs/_reviews/w2_w6_completion_payoff_v1.md`
- `docs/_reviews/w4_w5_band_transition_milestone_v1.md`
- `docs/_reviews/sharky_phrase_tier_contract_v1.md`
- `docs/_reviews/foundation_developing_phrase_sets_v1.md`
- `docs/_reviews/sharky_saw_you_improve_v1.md`
- `docs/_reviews/sharky_companion_states_v1.md`
- `docs/_reviews/w1_completion_copy_regression_repair_v1.md`
- `docs/_reviews/sharky_visual_growth_evolution_v1.md`
- `docs/_reviews/companion_semantic_consistency_gate_v1.md`
- `docs/_reviews/claude_implementation_quality_gate_v1.md`

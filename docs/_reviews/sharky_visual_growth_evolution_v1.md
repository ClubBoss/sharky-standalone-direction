---
status: "sharky_visual_growth_evolution_landed_with_bounded_consumers"
status_source: "derived"
baseline: "e7d3c8143581"
generated_by: "docs_frontmatter_v1"
---

# Sharky Visual Growth / Evolution v1

## 1. Verdict

`sharky_visual_growth_evolution_landed_with_bounded_consumers`

Two of "at most three" consumers were safely admitted (Welcome, Session
Summary). Profile was evaluated as a genuine third-consumer candidate and
deliberately deferred — see Section 10 and Section 17.

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `e7d3c814358139a2ef496b103b51c92935d207a7` (matches expected)
- Tracked/staged changes at start: none
- Untracked scope at start: `output/**` only
- `graphify hook-check`: passed. `graphify-out/graph.json` does not exist in
  this worktree — the same known condition documented in every prior task of
  this sequence; proceeded with direct `rg`/Read per the task's own explicit
  read-order instructions.

## 3. Capsule/authority check

Read in order: `AGENTS.md`, `CONTEXT_ROUTER_v1.md`,
`ACTIVE_ROUTE_CAPSULE_v1.md`, `VISUAL_PROOF_CAPSULE_v1.md` (the routed
Sharky/companion capsule), `LEARNING_REPAIR_CAPSULE_v1.md` (proof semantics
only), `sharky_phrase_tier_contract_v1.md`,
`foundation_developing_phrase_sets_v1.md`, `sharky_saw_you_improve_v1.md`,
`sharky_companion_states_v1.md`, `w1_completion_copy_regression_repair_v1.md`.
Both route capsules matched the prompt exactly (Phase 5 active, prior four
tasks CLOSED, `Sharky Visual Growth / Evolution v1` active, verified artifact
`w1_completion_copy_regression_repair_v1.md`). No `stale_capsule_scope` stop
was needed.

## 4. Existing visual progression audit

| Surface | Current asset | Current state | Current tier | Progression signal today | Safe evolution consumer verdict |
| --- | --- | --- | --- | --- | --- |
| Welcome intro | `Act0SharkyGuideCardV1`, five-mood PNG family | resolves `neutral` (Sharky Companion States v1) | always Foundation (pre-any-world) | none | admit — fixed `foundation` |
| Welcome handoff | `_WelcomeSharkyPresenterTileV1`, separate 3-SVG family (`thinking`/`celebrate`/`idle`), hardcoded `primary` tone | resolves `coach` | always Foundation | none | out of the shared seam entirely (doesn't route through `_SharkyMascotFrameV1`); always Foundation by definition, no visible change needed |
| Session Summary (both bubbles) | `Act0SharkyPresenceBubbleV1`, five-mood PNG family | resolves `milestone`/`improve`/`confirm`/`repair`/`neutral` (Sharky Companion States v1) | `summary.worldNumber` (real, always populated per-completion field — set from `progressedWorld.worldNumber` for both ordinary lesson and world completions) | none | admit — derive from `summary.worldNumber` |
| World/band completion card | `Act0ProofIconV1` only — no Sharky avatar at all | n/a | n/a | n/a | still no Sharky present; growth stage is expressed via the Session Summary bubble that already sits above it on the same screen (unchanged from the Companion States precedent) |
| Profile hero card | `Act0SharkyPresenceMascotV1` directly, wrapped in a **bespoke** `Act0VisualCanonV1` gradient/border/shadow container (not `_SharkyMascotFrameV1`) | fixed `neutral` mood, no companion-state wiring | n/a | none | evaluated, deferred (Section 10, Section 17) |
| Home identity row | `Act0SharkyPresenceMascotV1`, mood from `sharky.preSessionMood` | ad hoc, ~9 scattered literals in `act0_shell_preview_screen_v1.dart` | n/a | none | deferred (unchanged from Sharky Companion States v1) |

No existing asset or frame variant already implied progression — the five
PNG moods and Welcome's 3-SVG subset are all mood-driven, not tier-driven.
Visual treatment was identical across Foundation and Developing worlds
before this task (no world-number-aware frame logic existed anywhere).
Existing screenshot lanes (`core`, `first_week`, `full_scroll`) only ever
exercise early, low-world-number fixtures — none currently exposes a
Developing-tier state, the same gap noted for `improve`/`milestone` in the
Companion States task.

Determinations: (1) evolution is fully expressible with the existing asset
family — no new pose/asset needed, only frame/ring treatment; (2) the growth
signal is frame/presence-based (an extra layered ring plus a marginal
border/shadow bump), not pose-based; (3) exactly two stages are sufficient
and match the existing tier boundary precisely; (4) Welcome and Session
Summary can safely show progression with zero layout change; Profile and
Home cannot be touched without either forbidden styling logic or broadening
scope into an already-fragile file; (5) Welcome should remain visually fixed
at Foundation (it always precedes any world).

## 5. Growth contract

`Act0SharkyGrowthStageV1 { foundation, developing }` in
`act0_sharky_coach_phrase_contract_v1.dart`, next to the tier/state
resolvers it is built from:

```dart
Act0SharkyGrowthStageV1 act0SharkyGrowthStageForTierV1(Act0SharkyCoachTierV1? tier)
Act0SharkyGrowthStageV1 act0SharkyGrowthStageForWorldNumberV1(int worldNumber)
```

`act0SharkyGrowthStageForWorldNumberV1` is built directly on top of
`act0SharkyCoachTierForWorldNumberV1` (not a second, independent boundary
check), so growth stage and phrase tier can never disagree about which
world crosses W4->W5. A missing/null tier resolves `foundation`
(`act0SharkyGrowthStageForTierV1(null)`). No new persistence — both
functions are pure and stateless.

## 6. Admission rules

- Worlds 1-4 -> `foundation`; world 5 and every world above (including
  W13-W36) -> `developing` — verified for worlds 0-20 against the existing
  tier function.
- A missing/zero/negative world number falls back to `foundation`.
- Proof count, companion state, and completion events never change growth
  stage on their own — growth stage is computed once from
  `summary.worldNumber` alone, independent of `receipt`/`companionState`;
  dedicated tests vary proof/state/completion while holding world number
  fixed and confirm the growth ring never toggles.
- Widgets never infer stage from text: a source-scan test confirms the
  growth-stage functions never reference `context.` or `.line`.
- The W4->W5 boundary remains the only transition in v1 — growth stage
  always reads the *current* world (`summary.worldNumber`), never
  `nextWorldNumber`, so it does not special-case the band-transition moment
  itself. This is a deliberate design choice: the crossing moment is already
  fully expressed by the `milestone` companion state (stronger seal, state
  ring); growth becomes visible starting the very next session once the
  learner is actually working through World 5, keeping the two axes (moment
  vs. persistent presence) cleanly separated rather than conflating them at
  the exact transition screen.

## 7. Visual direction

Two structural signals distinguish Developing from Foundation (verified in
a dedicated composition test), neither dependent on color alone:

1. A new, persistent **growth ring** — a `Stack`-layered outer border
   (`act0_shell_sharky_mascot_frame_growth_ring`), using the app's existing
   `Act0ShellTokensV1.primary` token at low alpha (`0.22`), not a mood
   color — always present when `growthStage == developing`, in every frame
   mode including `simpleFrame` (so it is visible even in Session Summary's
   bubble, which has no border/gradient of its own).
2. A marginally **stronger base frame**: border width `1.0 -> 1.3` and
   alpha `0.22 -> 0.30`, plus a slightly deeper shadow (`blurRadius`
   `size*0.28 -> size*0.34`, alpha `0.18 -> 0.25`) — verified numerically in
   a widget test comparing the two stages' `BoxDecoration`.

No new costume, crown, armor, badge, trophy, glowing eyes, neon aura, halo,
star field, or cartoon transformation — the same five PNG assets (and
Welcome's 3-SVG subset, untouched) render throughout; only the frame around
them differs.

## 8. State/growth composition

Composition precedence is enforced structurally, not by a merged enum:
`Act0SharkyCompanionStateV1` (moment) and `Act0SharkyGrowthStageV1`
(persistent presence) are independent parameters passed separately into
`_SharkyMascotFrameV1`. The state's accent ring (`ringed`, for
`improve`/`milestone`) and the growth ring nest cleanly: when both are
present, the growth ring wraps the state ring, which wraps the frame — a
dedicated test confirms both ring keys coexist for a Developing-world
`improve` fixture, and confirms only the growth ring is absent (state ring
still present) for a Foundation-world `improve` fixture. Repair/confirm
states were verified against both growth stages with no visual conflict —
repair stays gold-toned in both Foundation and Developing.

## 9. Shared component API

`Act0SharkyCompanionAvatarV1` gained one additive parameter,
`growthStage` (default `Act0SharkyGrowthStageV1.foundation`), alongside its
existing `state`/`size`/`simpleFrame` — no mood, level, rank, XP, arbitrary
color, arbitrary decoration, animation controller, asset selector, rarity,
or random seed. A source-scan test confirms the class body contains no
`mood`/`level`/`rank`/`xp`/`rarity`/`seed`/`Colors.` reference.
`Act0SharkyGuideCardV1` and `Act0SharkyPresenceBubbleV1` gained the
identical additive `growthStage` parameter (both default `foundation`, so
every existing caller that doesn't pass it renders byte-identically).
Consumers pass structured stage (`Act0SharkyGrowthStageV1.foundation` or
`act0SharkyGrowthStageForWorldNumberV1(worldNumber)`), never a style token.

## 10. Consumer integration

- **Welcome**: the intro beat's `Act0SharkyGuideCardV1` call now passes
  `growthStage: Act0SharkyGrowthStageV1.foundation` explicitly (a fixed
  constant — Welcome always precedes any world, so there is no visible
  change, only an explicit, testable structural declaration). The handoff
  beat is untouched (it uses a separate SVG presenter widget outside the
  shared seam and is always Foundation by definition).
- **Session Summary**: both existing bubble call sites now also receive
  `growthStage: act0SharkyGrowthStageForWorldNumberV1(summary.worldNumber)`
  — the same real, always-populated world field the screen's own copy and
  proof already key off. Layout, copy, and CTA are untouched.
- **Profile — evaluated, not admitted**: Profile already renders
  `Act0SharkyPresenceMascotV1` in its accepted hero card, making it a
  legitimate third-consumer candidate per this task's own fallback list.
  However, its frame is a bespoke `Act0VisualCanonV1` gradient/border/shadow
  implementation with its own double-radius `ClipRRect`, entirely separate
  from `_SharkyMascotFrameV1`. Giving it real growth truth would require
  either (a) adding Profile-specific style knobs to the shared component
  (forbidden: "no consumer-specific styling logic," "do not add arbitrary
  colors/decoration") or (b) swapping its frame for the shared component,
  which risks a visible regression to a `VISUAL_PROOF_CAPSULE`-frozen
  surface ("Profile: frozen unless evidence reopens it"). Deferred with the
  same reasoning the task already sanctions for Home.
- **Home**: still deferred, unchanged from Sharky Companion States v1 (ad
  hoc `preSessionMood` literals scattered across the large preview-screen
  file).
- No surface without existing Sharky presence was given a new avatar
  instance.

## 11. Claim safety

- No UI copy anywhere says Sharky "leveled up," "evolved," or names a rank —
  a widget test scans rendered text for `xp`, `level up`, `leveled up`,
  `rank`, `rarity`, `evolved`, `evolution` and finds none.
- `Developing` implies only that the learner crossed into World 5+; no
  mastery, permanent-expertise, or player-rank claim is made anywhere in
  code or copy — this task added no new copy at all, only frame treatment.
- W13+ resolves the identical `developing` stage as W5-W12 — no third form,
  verified for worlds 13/20/24/36.
- Growth stage is sourced only from `act0SharkyCoachTierForWorldNumberV1`
  (already-accepted tier truth); missing/unknown data fails to `foundation`.
- Visual growth creates and mutates nothing: it is a pure function of
  `worldNumber`, computed fresh at each `build()`.

## 12. Screenshot evidence

Ran the three required lanes:

- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

All three passed. Local-only copies under
`output/sharky_visual_growth_evolution_v1/{core_fast,first_week_fast,full_scroll_fast}/`
(not committed). Visual review: `compact.session_summary.png` and
`compact.welcome_handoff.png` are visually unchanged from the Companion
States task's evidence (both fixtures are low-world-number/Foundation, and
Welcome's handoff never touches the growth seam) — same character identity,
no layout shift, no cyan/gold containment regression, companion-state
accents remain exactly as before. As anticipated, no lane fixture reaches
World 5+, so the Developing frame/ring comparison is not naturally exposed
by these deterministic lanes — this is a documented, bounded evidence gap
(consistent with the same gap already accepted for `improve`/`milestone` in
the prior task), proven instead by the dedicated structural-distinction
widget test (Section 7) which numerically compares both stages'
`BoxDecoration` side by side. No tooling work was opened to work around
this.

## 13. Tests/validation

New test files, all passing:

- `test/ui_v2/act0_sharky_growth_stage_v1_test.dart` (9 tests): pure
  resolver admission rules (Foundation/Developing boundary, W13+, missing
  tier/world-number fallback, tier/growth agreement, determinism, bounded
  vocabulary, no string-driven inference).
- `test/ui_v2/act0_sharky_growth_stage_consumer_v1_test.dart` (14 tests):
  Session Summary and Welcome consumer admission, proof-count/companion-
  state/completion-alone independence, repair/improve composition across
  both stages, CTA preservation, compact overflow, claim-safety scan,
  structural (not color-only) distinction, and shared-component API
  boundedness.

Regression suites re-run and green (230 tests total across the run below):
`act0_sharky_companion_state_v1_test.dart`,
`act0_sharky_companion_states_consumer_v1_test.dart`,
`act0_sharky_presence_v1_test.dart`,
`act0_sharky_coach_phrase_contract_v1_test.dart`,
`act0_sharky_identity_contract_v1_test.dart`,
`sharky_visual_consistency_foundation_v1_test.dart`,
`act0_sharky_improvement_observation_v1_test.dart`,
`act0_repair_outcome_consumer_v1_test.dart`,
`act0_session_summary_earned_moment_v1_test.dart`,
`session_summary_gold_containment_v1_test.dart`,
`wave4_3_premium_reward_session_summary_payoff_v1_test.dart`,
`act0_world1_completion_payoff_v1_test.dart` (confirms the W1 copy repair
remains intact — `You banked the first table read.` still renders),
`act0_w2_w6_completion_payoff_v1_test.dart`,
`act0_w4_w5_band_transition_milestone_v1_test.dart` (confirms W4->W5 route
truth is unchanged), `onboarding_welcome_screen_compact_contract_test.dart`.

`flutter analyze` (whole project): no issues. `graphify hook-check`: passed.
`git diff --check` / `git diff --cached --check`: clean.
`macos/Flutter/GeneratedPluginRegistrant.swift` drift from `flutter
test`/`analyze` runs was restored via `git checkout --` before every status
check and before the final commit. The broad `act0_shell_preview_screen_v1_test.dart`
mega-suite was not used as the gate (per Stage 15 instruction), consistent
with its already-documented pre-existing failures unrelated to this task.

## 14. Rolling Capsule Advance

- `ACTIVE_ROUTE_CAPSULE_v1.md`: Phase 5 Sequence item 5 (`Sharky Visual
  Growth / Evolution`) marked CLOSED with a summary note; Phase 5 -
  Sharky Companion marked CLOSED; a new "Post-Phase-5 Gates" section adds
  `Companion Semantic Consistency Gate` ACTIVE and `Claude Implementation
  Quality Gate` pending, both required before Phase 6 opens; current active
  task updated; verified active route artifact updated to this review.
- `VISUAL_PROOF_CAPSULE_v1.md`: "Current Proof State" extended with the
  growth-stage contract, admission rules, the two admitted consumers, the
  Profile evaluation-and-deferral reasoning, and an explicit no-animation/
  no-cosmetics/no-extra-tier note; reference artifact list extended;
  verified active route artifact updated.
- `LEARNING_REPAIR_CAPSULE_v1.md` was not touched — no learning/repair/proof
  truth changed.

## 15. Phase 5 closure decision

`close_sharky_companion`

## 16. Scope safety

No new route, screen, progression store, XP, coins, level number, rank,
rarity, skins, inventory, collection grid, animation, motion system, random
visual variation, AI/adaptive claim, W13+ evolution tier, new dependency,
broad refactor, or Modern Table change. The diff touched exactly: the one
shared contract file (`act0_sharky_coach_phrase_contract_v1.dart`), the one
shared visual seam file (`act0_sharky_presence_v1.dart`), the two admitted
consumer files (`act0_lesson_runner_shell_v1.dart`,
`act0_welcome_shell_v1.dart`), two new focused test files, route capsules,
and this review artifact.

## 17. Known limitations

- **Profile and Home remain deferred**, for two different but equally
  bounded reasons: Profile's frame is bespoke and frozen (Section 10); Home's
  mood is ad hoc across a large, fragile file (unchanged from the prior
  task). A future `Visual Growth Consumer Follow-up` could tackle either,
  most likely by first giving Profile's hero card its own small,
  Profile-owned growth accent that does not touch the shared component, or
  by centralizing Home's `preSessionMood` derivation.
- Developing-stage evidence is not exercised by any current screenshot lane
  fixture (all lanes stay below World 5); covered by the dedicated
  structural-distinction test instead (Section 12).
- Growth stage intentionally does not special-case the exact W4->W5
  band-transition screen (Section 6) — Developing presence becomes visible
  starting the next session, not on the transition screen itself. This is a
  considered design choice, not an oversight, but is worth flagging in case
  product wants the crossing moment itself to already look "grown."

## 18. Next recommendation

`Companion Semantic Consistency Gate v1`

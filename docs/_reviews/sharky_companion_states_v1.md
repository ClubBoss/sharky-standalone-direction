---
status: "sharky_companion_states_landed_with_bounded_consumers"
status_source: "derived"
baseline: "81f9ee6e0486"
generated_by: "docs_frontmatter_v1"
---

# Sharky Companion States v1

## 1. Verdict

`sharky_companion_states_landed_with_bounded_consumers`

Two consumers were safely admitted (Session Summary, Welcome). Home's
identity-row mood was deliberately deferred — see Section 9 and Section 17.

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `81f9ee6e04860efa1c117b8af765061a995b2b1a` (matches expected)
- Tracked/staged changes at start: none
- Untracked scope at start: `output/**` only
- `graphify hook-check`: passed. `graphify-out/graph.json` does not exist in
  this worktree (only in the main repo checkout), the same known condition
  documented in every prior task of this sequence — proceeded with direct
  `rg`/Read per the task's own explicit read-order instructions.

## 3. Capsule/authority check

Read in order: `AGENTS.md`, `CONTEXT_ROUTER_v1.md`,
`ACTIVE_ROUTE_CAPSULE_v1.md`, `VISUAL_PROOF_CAPSULE_v1.md` (the routed
Sharky/companion capsule — no separate dedicated Sharky capsule file exists;
`CONTEXT_ROUTER_v1.md`'s own capsule table routes Sharky/proof/progression
work to `VISUAL_PROOF_CAPSULE_v1.md`, consistent with all three prior Phase 5
review artifacts), `LEARNING_REPAIR_CAPSULE_v1.md` (evidence semantics only),
`sharky_phrase_tier_contract_v1.md`, `foundation_developing_phrase_sets_v1.md`,
`sharky_saw_you_improve_v1.md`. Both route capsules matched the prompt exactly
(Phase 5 active, prior three tasks CLOSED, `Sharky Companion States v1`
active, verified artifact `sharky_saw_you_improve_v1.md`). No
`stale_capsule_scope` stop was needed.

## 4. Existing Sharky visual audit

| Surface | Owner | Visual treatment | Phrase context | Evidence source | Candidate state | Migration verdict |
| --- | --- | --- | --- | --- | --- | --- |
| Welcome intro | `Act0SharkyGuideCardV1` via `_WelcomeTextBeatV1`, hardcoded `mood: happy` | rounded-square frame, gradient, glow | `welcomeOrientation` moment (already migrated) | none (orientation) | `neutral` | migrate now (bounded) |
| Welcome handoff | `_WelcomeSharkyPresenterTileV1`, hardcoded `mood: celebrate` | separate small SVG-idle/thinking/celebrate asset family, fixed `primary` tone | none (hardcoded English/RU strings) | none (onboarding done, not curriculum milestone) | `coach` | migrate now (bounded) |
| Session Summary (ordinary) | `Act0SharkyPresenceBubbleV1`, `mood: qualifiesForNextLesson ? celebrate : repair` | speech-bubble frame, simple frame, animated presence mascot | `summary.sharkyLine` (author copy) | `qualifiesForNextLesson` gate only | `neutral`/`repair`/`confirm`/`improve`/`milestone` (full range) | migrate now (bounded) |
| Session Summary (payoffHero) | Same widget, hardcoded `mood: celebrate` unconditionally | same bubble frame | `sessionSummaryProof` moment or `summary.sharkyLine` | `payoffHero` (correct-read or raw "Good fixes" activity) | same full range | migrate now (bounded) |
| World/band completion card | `_WorldMilestoneCardV1` — no Sharky avatar at all, only `Act0ProofIconV1(milestone)` | proof-icon seal, not a Sharky mascot | `worldOneCompletionPayoff`/`worldCompletionPayoff`/`bandTransitionPayoff` | completion flags | `milestone` | folded into the Session Summary bubble above (see Section 9) rather than adding a second avatar to this frozen card |
| Home identity row | `_HomeIdentityRowV1`, `Act0SharkyPresenceMascotV1(mood: sharky.preSessionMood)` | small 38x38 rounded-square avatar | none | ~9 ad hoc `preSessionMood:` literals scattered across the large `act0_shell_preview_screen_v1.dart` file | would span `neutral`/`coach`/`repair`/`confirm` | **deferred** — not a bounded touch |

No existing Sharky asset variants beyond the accepted five moods
(`neutral`, `happy`, `thinking`, `repair`, `celebrate`) plus Welcome's own
three-SVG subset (`thinking`, `celebrate`, `idle`) were found; both families
already fully cover the new six-state vocabulary. Existing screenshot lanes
(`core`, `first_week`, `full_scroll`) already exercise Welcome intro/handoff
and Session Summary; no dedicated Sharky-state coverage existed before this
task.

Highest-value consumers selected: Session Summary (both existing bubble call
sites, which together already express the full evidence range on screen) and
Welcome (both existing beats).

## 5. State contract

`Act0SharkyCompanionStateV1 { neutral, coach, repair, confirm, improve,
milestone }`, defined in `act0_sharky_coach_phrase_contract_v1.dart` next to
the phrase contract it shares evidence with. No `happy`/`sad`/`angry`/
`disappointed`/`excited`/`confused`/`mastery`/`streak`/`locked`/`unlocked`/
`rarity` value exists — a dedicated test enumerates `.values` and asserts the
exact six names.

## 6. Admission rules

`act0ResolveSharkyCompanionStateV1(Act0SharkyCoachPhraseContextV1)` is a pure
function that gates on the exact same `momentType` + `evidenceKind` +
`repairState`/`transferState`/`proofState`/`completionState` fields the
phrase resolver already checks — never on resolved phrase text. Missing or
mismatched evidence always falls back to `neutral`. Specifically:

- no evidence/context -> `neutral`
- `repairPrompt` + open repair target -> `coach`
- `repairFailed`/`reviewPattern` (a repeated miss pattern) -> `repair`
- `repairCompleted`/`sessionComplete` (real local proof)/`decisionCorrect`
  -> `confirm`
- `laterImprovementObserved` (the Sharky-Saw-You-Improve evidence gate) ->
  `improve`
- `worldComplete`/`bandTransition` (with the exact W4->W5 numbers) ->
  `milestone`

Enforced exclusions: activity count alone never reaches `confirm` (the
Session Summary helper only grants `confirm` when
`receipt.isBankedFixProof == true`, the structured banked-fix flag — a raw
"Good fixes: N" activity-fallback receipt, or a bare `payoffHero` triggered
only by a single "First correct read" achievement moment, resolves at most to
`neutral`/`repair`, never `confirm`); a single correct answer never creates
`improve` (`decisionCorrect` maps to `confirm`, never `improve`); a repeated
multi-session pattern maps to `repair`, not `improve`; an incomplete world
never reaches `milestone` (both the resolver's own `completionState` guard
and the existing `hasWorldOneCompletionPayoff`/`hasWorldCompletionPayoff`/
`hasBandTransitionPayoff` gates it is built from).

## 7. Visual grammar

`act0SharkyMoodForCompanionStateV1` maps every state onto one of the five
already-approved moods (no new asset):
`neutral->neutral`, `coach->thinking`, `repair->repair`, `confirm->happy`,
`improve->happy`, `milestone->celebrate`. Tone comes for free from the
existing, unmodified `act0SharkyToneForMoodV1` mapping (`repair->gold`,
`thinking->info` teal, `happy`/`celebrate->primary`/`gold` depending on
context, `neutral->textMuted`) — no new arbitrary color was introduced.
`act0SharkyCompanionStateHasAccentRingV1` reserves an extra accent ring
(structurally identical to the existing `Act0ProofIconV1` reinforced/
emphasized echo pattern) for `improve` and `milestone` only — the strongest
treatment (`milestone`) and "I noticed the later proof" (`improve`) both read
as a step up from the plain frame, while staying below any future
evolution/motion moment. `repair` renders in gold, never red — verified by a
test that also proves `act0SharkyToneForMoodV1(repair) != Colors.red`.

## 8. Shared component

`Act0SharkyCompanionAvatarV1` (in `act0_sharky_presence_v1.dart`) accepts
only `state`, `size`, and an optional `simpleFrame` layout toggle — no mood,
score, level, percentage, rarity, animation config, arbitrary color,
arbitrary icon, or random seed. It renders through the existing
`_SharkyMascotFrameV1`, extended with one additive, default-false `ringed`
parameter so every current caller (`Act0SharkyGuideCardV1`,
`Act0SharkyPresenceBubbleV1`, `Act0SharkyPresenceMascotV1` direct callers)
renders byte-identically unless it explicitly opts in.
`Act0SharkyPresenceBubbleV1` also gained the same additive `ringed` parameter
(default false) so the two existing Session Summary bubble call sites could
route through the new grammar without changing that widget's public bubble
layout.

## 9. Consumer integration

- **Session Summary**: a new `_act0SessionSummaryCompanionStateV1` helper in
  `act0_lesson_runner_shell_v1.dart` resolves
  `milestone > improve > confirm > repair > neutral` from
  `hasWorldOneCompletionPayoff || hasWorldCompletionPayoff ||
  hasBandTransitionPayoff`, `receipt.hasImprovementObservation`,
  `receipt.isBankedFixProof`, and `!qualifiesForNextLesson` — the exact same
  flags this screen's copy and proof icons already consume. Both existing
  bubble call sites (ordinary and payoffHero-linked) now use the resolved
  mood/ring instead of their previous hardcoded picks. Folding `milestone`
  into these existing bubbles (rather than adding a Sharky avatar to the
  separate, frozen `_WorldMilestoneCardV1`) satisfies "no additional Sharky
  instance on a screen": a dedicated test confirms exactly one presence
  mascot renders per Session Summary screen in every fixture, including
  world completion.
- **Welcome**: intro beat's mood literal changed from hardcoded `happy` to
  `act0SharkyMoodForCompanionStateV1(neutral)`; handoff beat's mood literal
  changed from hardcoded `celebrate` to
  `act0SharkyMoodForCompanionStateV1(coach)`. Copy, CTA, and routing are
  untouched — a widget test confirms the primary CTA still opens the demo
  spot beat.
- **World/band completion**: intentionally not given a third, separate
  Sharky avatar (see above) — its `milestone` truth is expressed through the
  Session Summary bubble that already sits above the completion card on the
  same screen.
- **Home**: deferred. See Section 17.

## 10. Phrase/state consistency

`act0ResolveSharkyCompanionStateV1` and `act0SharkyCompanionStateForMomentV1`
are pure functions of the identical `Act0SharkyCoachPhraseContextV1` fields
the phrase resolver gates on; a source-scan test confirms the resolver body
never reads `.line` or any resolved phrase text. A table-driven test asserts
the exact resolved state for every legacy `Act0SharkyCoachMomentV1`, and
dedicated tests prove `repair` never accompanies any of the confirm/
milestone-mapped moments and `milestone` never appears on an ordinary
moment. The Session Summary helper mirrors this: `repair` only wins when
`!qualifiesForNextLesson` and no stronger evidence exists, so it can never
coexist with the `milestone`/`improve`/`confirm` branches above it in the
same priority chain. UI never infers state from phrase text anywhere in this
change — states are always resolved from structured booleans/enums.

## 11. Tier behavior

State resolution takes no `tier` parameter at all (only the legacy
convenience wrapper accepts one, purely to build a legacy context) — a test
iterates every `Act0SharkyCoachMomentV1` and asserts Foundation and
Developing tiers resolve the identical companion state. Tier continues to
control wording only (unchanged from the prior two tasks); companion state
controls moment semantics, exactly as this stage requires. No separate
"advanced Sharky" asset set, rank-like tiering, or W13+ visual was
introduced — Developing/W13+ reuse the same five-mood asset family.

## 12. State isolation

The resolver and avatar are pure/stateless: no field was added to any
persisted model, no new `StatefulWidget`, no read/write to Review, Practice
queue, Profile, or learning-evidence history. Session Summary/Profile proof
counts, the completion route, and Fix Proof truth ownership are all
unchanged — verified by the full unmodified regression suites for those
surfaces passing. Visual state is derived fresh at each `build()` call from
already-in-scope render-time values (the `summary`/`receipt` objects), never
persisted.

## 13. Screenshot evidence

Ran the three required lanes:

- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

All three passed. Local-only copies under
`output/sharky_companion_states_v1/{core_fast,first_week_fast,full_scroll_fast}/`
(not committed). Visual review:

- `compact.welcome_handoff.png` now shows the calmer `coach`/thinking pose
  (idle-family SVG, no gold celebration glow) instead of the previous
  blanket `celebrate` treatment — reads as guidance toward the next step,
  not a cheap win.
- `compact.session_summary.png` (the `first_week` fixture, whose accuracy
  does not clear the unlock threshold) now correctly shows the `repair`
  state (gold-toned, thoughtful pose) instead of the old payoffHero bubble's
  previous *unconditional* `celebrate` — this is an intentional fix, not a
  regression: the old code hardcoded `celebrate` for that bubble regardless
  of whether the lesson actually still needed repair.
- `compact.home.png` is unchanged (Home was not touched).

`neutral`/`coach`/`confirm`/`repair` states are all exposed by these lanes'
existing fixtures; `improve` and `milestone` are not naturally exposed by any
current lane fixture (none of the three lanes' scripted states happen to
carry a reinforced-improvement receipt or a completed world), so those two
states are proven exclusively via the 20 focused widget/pure tests below —
a bounded, documented evidence gap, not a defect.

## 14. Tests/validation

New/updated test files, all passing:

- `test/ui_v2/act0_sharky_companion_state_v1_test.dart` (21 tests): pure
  resolver admission rules, tier-independence, phrase/state consistency,
  vocabulary boundedness.
- `test/ui_v2/act0_sharky_companion_states_consumer_v1_test.dart` (13
  tests): Session Summary and Welcome consumer widget behavior, ring
  presence, single-instance proof, CTA preservation, compact overflow, no
  forbidden language.
- `test/ui_v2/act0_sharky_presence_v1_test.dart` (+3 tests): the shared
  `Act0SharkyCompanionAvatarV1` component in isolation.

Regression suites re-run unmodified and green: `act0_sharky_coach_phrase_contract_v1_test.dart`,
`act0_sharky_identity_contract_v1_test.dart`,
`sharky_visual_consistency_foundation_v1_test.dart`,
`act0_sharky_improvement_observation_v1_test.dart`,
`act0_repair_outcome_consumer_v1_test.dart`,
`act0_session_summary_earned_moment_v1_test.dart`,
`session_summary_gold_containment_v1_test.dart`,
`wave4_3_premium_reward_session_summary_payoff_v1_test.dart`,
`act0_w2_w6_completion_payoff_v1_test.dart`,
`act0_w4_w5_band_transition_milestone_v1_test.dart`,
`onboarding_welcome_screen_compact_contract_test.dart`.

One pre-existing failure was found and is **not** caused by this task:
`act0_world1_completion_payoff_v1_test.dart` — `completed W1 shows milestone
role and full copy hierarchy` expects the text "You banked the first table
read." but the phrase resolver now returns "World complete with a real table
read." for the `worldOneCompletionPayoff` moment. Reproduced identically by
stashing this task's entire diff and re-running against the untouched
starting HEAD `81f9ee6e` — confirmed this predates Sharky Companion States
v1. Root cause: `Sharky Phrase Tier Contract v1` folded `worldOneCompletionPayoff`
and `worldCompletionPayoff` onto the same `worldComplete` resolver branch,
which lost W1's original distinct copy. Left unfixed here — rewriting phrase
copy is out of this task's scope (a visual-state PR) and risks scope creep
into a different wave's contract; flagged clearly for a fast, separate fix.

Final validation: `flutter analyze` (whole project) — no issues.
`graphify hook-check` — passed. `git diff --check` / `git diff --cached --check`
— clean. `macos/Flutter/GeneratedPluginRegistrant.swift` drift from
`flutter test`/`analyze` runs was restored via `git checkout --` before every
status check and before the final commit.

## 15. Rolling Capsule Advance

- `ACTIVE_ROUTE_CAPSULE_v1.md`: Phase 5 Sequence item 4 (`Sharky Companion
  States`) marked CLOSED, item 5 (`Sharky Visual Growth / Evolution`) marked
  ACTIVE; current active task updated; verified active route artifact
  updated to this review.
- `VISUAL_PROOF_CAPSULE_v1.md`: "Current Proof State" extended with the
  state vocabulary, admission rules, admitted consumers (Session Summary,
  Welcome), the deferred Home consumer, and an explicit no-animation/
  no-growth/truth-ownership-remains-external note; reference artifact list
  extended; verified active route artifact updated.
- `LEARNING_REPAIR_CAPSULE_v1.md` was not touched — no new learning/repair/
  proof truth was introduced; this task only consumes existing evidence.

## 16. Scope safety

No new screen, route, Sharky asset (every state reuses the five existing
approved mood assets, or Welcome's existing three-SVG subset), animation
(the only "motion" anywhere is the pre-existing, unmodified subtle presence
arrival animation shared by every Sharky consumer since before this task),
growth/evolution, facial-expression generation, mood engine, sadness/anger/
shame state, random state selection, AI/adaptive claim, XP/level/rank, new
dependency, Modern Table change, broad visual redesign, or W13+ work. The
diff touched exactly the two files needed for the shared contract/seam
(`act0_sharky_coach_phrase_contract_v1.dart`,
`act0_sharky_presence_v1.dart`), the two admitted consumer files
(`act0_lesson_runner_shell_v1.dart`, `act0_welcome_shell_v1.dart`), three new
focused test files, one existing test file extended, route capsules, and
this review artifact.

## 17. Known limitations

- **Home is deferred.** Its identity-row mood (`_HomeIdentityRowV1`,
  `sharky.preSessionMood`) is set by roughly nine ad hoc `Act0SharkyMoodV1`
  literals scattered across the large, already-fragile
  `act0_shell_preview_screen_v1.dart` preview-screen file (the same file
  behind the known 115-pre-existing-failure broad mega-suite). Migrating it
  safely would require touching that broad surface, which this bounded wave
  explicitly avoids. A future `Companion State Consumer Follow-up` can
  centralize those call sites behind a single resolver the way Session
  Summary and Welcome now are.
- **A pre-existing, unrelated test failure was found** (Section 14) — not
  introduced by this task, not fixed here, flagged for a fast follow-up.
- `improve` and `milestone` are not exercised by any current screenshot lane
  fixture; covered by focused tests only (Section 13).
- `_worldCompletionMetaByNumberV1[4]`-style dead-data patterns from prior
  tasks are unaffected and out of scope here.

## 18. Next recommendation

`Companion State Consumer Follow-up`

Rationale: before starting `Sharky Visual Growth / Evolution v1` (which
builds on top of these states), it is lower-risk to first decide how/whether
to bring Home's identity-row mood under the same deterministic resolver, and
to resolve the pre-existing W1 phrase-text regression, so the next wave
builds on a fully consistent state/phrase foundation rather than carrying
two known gaps forward.

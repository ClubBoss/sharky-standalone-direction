# MASTER PLAN v3.0

Status: ACTIVE
Last updated: 2026-05-11

Launch-readiness reference:

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

Working-surface policy:

- `docs/plan/DEV_MAIN_2_ACTIVE_CUTOVER_v1.md`

Supersedes:

- `docs/plan/MASTER_PLAN_v2.2.md` as the active product-working master plan

Keeps as reference:

- `docs/plan/MASTER_PLAN_v2.2.md` for deeper system, economy, and historical
  invariant context that is not part of the current simple-product route

Content planning references (AUTHORITY STACK FOR CURRICULUM):

**Top-level curriculum vision and route authority:**
- `docs/plan/LONG_HORIZON_MASTERY_MAP_v1.md` — long-term player growth strata and 0-3/3-6/6-12 month horizons
- `docs/plan/VOLUME_STRUCTURE_AND_SPECIALIZATION_POLICY_v1.md` — Volume I/II/III structure and Cash/MTT fork rules
- `docs/reference/LONG_TERM_WORLD_VISION_REFERENCE_v1.md` — W1–W36 full vision with competitive coverage audit

**Curriculum design and coverage:**
- `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md` — 47 concept families with world homes and reinforcement paths
- `docs/plan/CURRICULUM_OPERATING_SYSTEM_SSOT_v1.md` — operating principles for minimal-change curriculum updates
- `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md` — frozen route policy decisions (keep_late, move_earlier, split_seed_mastery)
- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.4.md` — cognitive shift + emotional win + transfer task contract per world
- `docs/learning/CONCEPTS_SOURCE_FULL_IMPORT_v1.md` — source concept universe

**Content and world production:**
- `docs/content/CONTENT_SYSTEM_v2.1.md` — content encoding and parsing
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md` — active content inventory truth
- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md` — release-quality standards per world
- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md` — MVP-first production plan (Worlds 0–4, skeleton for 5–9)
- `docs/plan/CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md` — minimum content density rules
- `docs/plan/WORLD_PROGRESSION_PACING_SSOT_v1.md` — pacing truth and difficulty scaling
- `docs/plan/CONTENT_AUTHORING_CONTRACT_CONTENT_GRAMMAR_v1.md` — grammar and style for content authoring
- `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md` — quality metrics for Volume I (W1–W12)
- `docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md` — recent calibration snapshot
- `docs/plan/SEAM_TRANSITION_AUDIT_TEMPLATE_v1.md` — template and protocol for world-to-world transitions

**Cross-world learning systems (owned, not sprinkled across world docs):**
- `docs/plan/LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md` — weakness map and repair routing
- `docs/plan/ADAPTIVE_SPACED_REPETITION_SSOT_v1.md` — concept resurfacing and interleaving
- `docs/plan/HAND_HISTORY_REVIEW_LAYER_SSOT_v1.md` — hand review and study-from-hands layer
- `docs/plan/SKILL_GRAPH_PROGRESS_MAP_SSOT_v1.md` — family-level progress state (not only world ladder)

Historical planning references retained for traceability only:

- `docs/plan/SKILL_COVERAGE_MATRIX_v1.md`
- `docs/plan/WORLD_NODE_MODE_MATRIX_v1.md`
- `docs/plan/PROGRESSION_PREREQUISITE_MATRIX_v1.md`

Retention and value references:

- `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/SHARKY_PROGRESSION_RETENTION_LAYER_v1.md`
- `docs/plan/RETENTION_RHYTHM_ANTI_BOREDOM_v1.md`
- `docs/plan/SESSION_ENERGY_BUDGET_v1.md`
- `docs/plan/PROGRESS_SIGNAL_DERIVATION_v1.md`
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`

Localization references:

- `docs/l10n/RU_POKER_TERMS_CANON_v1.md` — Russian terminology and tone canon
- `docs/plan/RUSSIAN_LOCALIZATION_ROLLOUT_v1.md` — active Russian rollout order
- `docs/plan/ACT0_CONTENT_LOCALIZATION_SCALING_v1.md` — scalable content-copy seam policy
- `docs/plan/ACT0_LOCALIZATION_FILE_MODEL_SSOT_v1.md` — Act0 storage model: one API layer, one language file per language, generated world packs
- `docs/plan/ACT0_EXECUTION_SNAPSHOT_2026_05_11_v1.md` — current Act0 continuity snapshot

## Purpose

This is the active product-working master plan for the current dev-first app.

The goal is not to build the deepest possible poker system right now.

The goal is to build a simple, beautiful, working poker learning app that a
new user can understand, enjoy, and trust quickly.

This plan is intentionally lighter than the older readiness plans. It keeps the
team focused on the current product experience instead of rebuilding the heavy,
hard-to-change shape that old main drifted toward.

## Authority

This file is the active SSOT for product work and day-to-day prioritization.

If a task asks "what should we build next?", this file wins.

- Auxiliary store-launch checklist: `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` (consult only for App Store submission prep)
- Archived execution doc: `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md` (superseded by the Priority Order below)
- Dev-first working surface: `docs/plan/DEV_MAIN_2_ACTIVE_CUTOVER_v1.md`
- Historical deep-system reference: `docs/plan/MASTER_PLAN_v2.2.md`

Use this file when choosing what to improve next in the learner-facing product.
Use the readiness reference only when discussing launch/readiness framing.

If a task asks "what should we build next in the app?", start here.

If a task asks "are we truly release-ready for launch/store prep?", use the readiness reference.

Do not use the readiness reference as the default bottleneck selector for day-to-day product work.

## Product 100

For this plan, 100% means:

1. A new user understands the app in seconds.
2. Starting feels easy, not like setup work.
3. The first session looks and feels polished.
4. The table is readable and teaches without overload.
5. Mistakes are useful and emotionally light.
6. Progress is clear without becoming a dashboard.
7. Home, Learn, Play, Review, and You each have a clear job.
8. The app feels fast, modern, and coherent.
9. The product can keep evolving without becoming heavy.
10. The release-visible worlds have enough content density to teach their job,
    not just names on a map.
11. The app has a light habit loop: daily return, streak-lite, earned rewards,
    and visible improvement without fake pressure.
12. Sharky gives the product a supportive soul through a compact mascot layer,
    not a noisy chat system.
13. Premium/trial messaging appears only after value and habit credibility are
    visible.

This is a practical product 100, not a final company/release 100.

App-wide monetization and retention north star:

- `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`

Use that guideline when the question is not only "is monetization allowed yet?"
but "what business shape should the full app actually optimize for over months
of learner use?"

## Out Of Scope For This Product 100

Do not let these slow the current route:

- heavy analytics dashboards
- complex monetization systems
- broad store/distribution packaging
- full AI coach/chat
- deep profile machinery
- full economy/lives/paywall design
- whole-app refactors
- old main surface polish
- feature depth that makes the first experience harder to understand

These may matter later, but not for the current simple-good-working target.

## Product Scorecard

Working estimate as of 2026-05-11: **82 / 100**

This number is a prioritization estimate, not release readiness.

The `Good enough for v1` column is the shipping-quality bar for this simple
product route. The `100 state` column is the direction of travel after that.

| Area | Weight | Now | Good enough for v1 | 100 state |
| --- | ---: | ---: | --- | --- |
| First start and placement | 8 | 78 | Placement is short, attractive, question-led, and routes the user clearly. | It feels personally useful without feeling like setup work. |
| Home, navigation, and re-entry | 7 | 83 | Home tells the user exactly what to do next; tabs have distinct jobs. | Returning to the app always feels obvious and low-friction. |
| Learn path and world map | 9 | 81 | The path is readable, sequential, and not cluttered. | It feels like a polished learning world, not a list. |
| Content and world readiness | 16 | 92 | Release-visible worlds have enough intro, practice, apply, and review content to teach their core job. | The ladder feels planned, smooth, and complete instead of random or thin. |
| Table/session core | 13 | 84 | One table session feels smooth, readable, and worth repeating. | The table feels like the premium core of the product. |
| Mistake repair and Review | 9 | 89 | A wrong answer becomes a clear, useful repair step without shame. | Review feels like a personal coach, not a correction log. |
| Play/practice hub | 6 | 78 | Play is a clean practice hub, not a duplicate of Learn. | Practice feels quick, useful, and habit-forming. |
| You/profile/identity | 5 | 72 | Profile shows simple progress, strengths, weak spots, and next focus. | The user sees identity and improvement without dashboard bloat. |
| Sharky, mascot, rewards, and habit | 9 | 78 | Sharky, streak-lite, achievements, and block celebrations exist without noise. | The product feels alive, rewarding, and worth returning to. |
| Visual and premium feel | 8 | 76 | Screens feel coherent, modern, and polished enough for external review. | The app looks premium across the whole active shell. |
| Copy and trust | 5 | 84 | Text is short, calm, useful, and beginner-safe. | The app sounds like a confident coach with no system noise. |
| Value/trial readiness | 3 | 37 | Premium/trial appears only as value-first preview after proof. | Upgrade feels like expansion, not pressure. |
| Simplicity and performance | 2 | 74 | The product stays fast, light, and easy to change. | New improvements remain cheap because the product stays simple. |

Weighted current estimate: about **82 / 100**.

Calibration note (2026-05-11):

- `Mistake repair and Review` increased after canonical review-queue behavior was
  stabilized and guarded by deterministic tests on the active World 1 runner
  path.
- `Copy and trust` increased after the Act0 localization seam was normalized to
  one core reader/API layer plus one RU language file with stable-id lookups,
  reducing drift and screen-level inconsistency risk.
- `Content and world readiness` increased slightly because localization
  production infrastructure (coverage/audit/pack workflows) now supports faster
  safe expansion without reopening runtime seams.
- Other rows are intentionally unchanged in this wave because no direct
  user-surface evidence moved them.

## Priority Order

Work in this order unless a clear user-visible blocker appears:

1. First start and placement
2. Home, navigation, and re-entry
3. Learn path and world map
4. Volume I launch polish and route packaging
5. Table/session core
6. Mistake repair and Review
7. Sharky, rewards, and habit
8. Play/practice hub
9. You/profile/identity
10. Value/trial readiness
11. Final visual and copy pass
12. Simplicity and performance pass
13. Russian localization pass

## Calibrated Execution Mode (Big Waves, Audit-Lite)

This plan should be executed in large, bounded, user-visible waves.

Do not run constant broad audits between every small change.

Use this stable rhythm instead:

1. Run 1 product wave that changes one clear area end-to-end.
2. Verify with minimum sufficient proof for that wave.
3. Record a short plan trace in this file.
4. Continue to the next wave in the same priority lane.
5. Perform a macro recalibration only every 3 waves, or once per week,
   whichever comes first.

Default mode is flow, not audit.

Audit becomes mandatory only when one of these triggers appears:

1. The same user-visible regression class repeats in two consecutive waves.
2. A seam transition fails in tests after being marked closed.
3. Product score direction is unclear for two waves in a row.
4. A wave touches two or more priority lanes unexpectedly.

If no trigger appears, continue wave delivery without pausing for full-route
re-audit.

## Wave Contract (Definition Of Ready / Done)

Every planned wave must be declared in this compact format before coding:

1. Wave goal: one user-visible improvement objective.
2. Scope boundary: exactly which product area and files are in scope.
3. Success signal: the behavior/copy/state that must be true after merge.
4. Verification set: minimum tests/checks required for this wave.
5. Stop condition: what is explicitly out of scope for this wave.

A wave is done only when all three artifacts exist together:

1. Code change in the bounded scope.
2. Regression lock (existing or updated tests).
3. Plan trace entry (what changed, why, and what is next).

## Current Calibrated Runway (2026-05-06)

To preserve project vision without constant audits, the active runway is:

1. `Volume I` public-launch strength pass across `W1-W12`.
   The route is now materially strong enough that the default next work is not
   broad new-world expansion. All visible `W1-W12` worlds now clear the public
   release-strength bar (`19+`), so the default next work is human review and
   launch polish rather than more score rescue.
2. Launch-surface coherence across Placement, Home, Learn, Play, Review, and
   You.
   Now that `Volume I` route truth is substantially stronger, the biggest
   remaining product risk is mismatch between route depth and launch-surface
   presentation.
3. Free-vs-premium launch-boundary implementation on top of the now-stable
   policy stack.
   This lane should move only as value-first implementation, not as pressure
   work.
4. Honest `W13+` coming-soon / Volume II packaging.
   Later worlds should stay visible only as credible future depth, not as
   pseudo-playable shells that dilute the finished first volume.
5. Only after the first four lanes are stable: later-volume frontier design
   truth around `W12 -> W13`.

Execution policy for this runway:

1. Prefer large bounded waves over micro-steps.
2. Keep one primary lane active until its visible bottleneck is resolved.
3. Only switch lane early when a blocker is clearly higher EV.

Curriculum route-policy authority for disputed concept timing:

- `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`
- Keep world progression and copy trust beginner-safe at all times.

Tie-break rule for next-wave selection:

- If `Volume I` density and seam truth are already green/stable but some
  visible worlds are still below `19`, finish that public-launch strength pass
  before opening `W13+`.
- Do not interpret the stronger `81 / 100` product score as permission to
  broaden into later-volume authoring early.

## Content 100 For First Release

Content is part of this product 100.

The app is not 100 if the screens look good but the world path feels thin,
random, or full of conceptual jumps.

For first release, content 100 does not mean every long-term advanced world is
fully built. It means:

1. every world shown as playable has enough density to teach its job
2. every locked future world is honest about being future content
3. the first release path has no major beginner learning gaps
4. skills progress in the planned order, not by local intuition
5. review/repair exists early enough that content is not disposable

Use the content planning references listed at the top of this document when
deciding what belongs in a world.

## First Independent Wave Policy (W1-W12)

For the current product route, the first self-directed learner wave is W1-W12.

Operational rules:

1. W1-W12 is the only route segment eligible for first-wave playable status.
2. W13+ must remain locked preview / coming soon by default.
3. No W13+ promotion is allowed until the immediate prior seam is audited as
  `release-playable` and targeted regressions are green.
4. If a world in W1-W12 regresses, route promotion pauses and the fix must
  follow seam gap protocol: code + regression lock + plan trace.

This first independent wave is also the canonical `Volume I` route.
See `docs/plan/VOLUME_STRUCTURE_AND_SPECIALIZATION_POLICY_v1.md` for the
three-volume packaging and post-core specialization policy.

First-wave readiness checklist:

1. Every W1-W12 world has Intro/Practice/Apply/Review rhythm.
2. Every W1-W12 seam has explicit bridge vocabulary and audit evidence.
3. Cross-world Review resurfacing remains non-punitive and deterministic.
4. World-map/UI state labels match reality: playable vs locked preview.
5. No expert-language shock in first-contact lessons of newly opened worlds.
6. Public `Volume I` launch target: no visible world should remain below the
   `release-strong` scorecard band (`19+`).

For future world-density and anti-thinness decisions inside `W1-W12`, the
default evaluation tools are:

1. `docs/plan/VOLUME_I_WORLD_QUALITY_SCORECARD_v1.md`
2. `docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md`
3. `docs/plan/VOLUME_I_CLUSTER_EXECUTION_POLICY_v1.md`

Default execution shape for the rest of `Volume I`:

1. plan by adjacent multi-world cluster
2. execute one bounded sub-wave inside that cluster
3. recalibrate at the cluster level after meaningful improvement

Current Volume I cluster state:

- `W10-W12` is materially strengthened after W10, W11, and W12 density waves
- no default new bounded sub-wave remains inside `Volume I`
- next honest route frontier is `W12 -> W13`, which remains locked preview /
  coming soon until later-volume work is explicitly admitted

## Canonical Content Alignment Rule

The practical product route must not invent its own curriculum order.

Content authority order:

1. `UNIFIED_LEARNING_ARCHITECTURE_v4.4` defines the product-quality
   cognitive-shift ladder.
2. `CONTENT_SYSTEM_v2.1` defines how content is produced and QA'd.
3. `CONTENT_EXCELLENCE_CANON_v1` defines the quality bar for best-in-segment
   content.
4. `CONTENT_PLAN_PER_WORLD_v2.1` defines per-world topic fill.
5. This master plan defines the practical execution route and readiness view.

If this file conflicts with the first three on curriculum structure, treat this
file as needing an alignment patch, not as permission to drift.

Practical naming note:

- The app shows `Poker from Zero` as the first visible world: this is W1 / world_1.
- W-numbers in this plan match world_ IDs in code: W1 = world_1, W7 = world_7,
  and so on. No more off-by-one confusion.
- The numbered learning ladder preserves the cognitive shifts:
  Hand Discipline (W2), Position Thinking (W3), Preflop Framework (W4),
  Bet Purpose + Price (W5), Board Awareness (W6), and then the later worlds.

The goal is not perfect numbering purity. The goal is that the learner never
gets several unrelated mental models mixed into one world.

## Long-Term World Vision (W13–W36)

The full late-world ladder, specialization details, competitive coverage,
and W13–W36 rationale now live in:

- `docs/reference/LONG_TERM_WORLD_VISION_REFERENCE_v1.md`

Use that reference when:

1. planning beyond the current release-visible route
2. checking late-world coherence or competitor-coverage rationale
3. auditing how W13–W36 fit the full novice-to-strong-player arc

Do not load that full reference by default during daily execution work.
Use this master plan for current route selection and near-term product
priorities, then open the late-world reference only when needed.

## Volume And Specialization Authority

High-level route packaging and specialization timing are now canonicalized in:

- `docs/plan/VOLUME_STRUCTURE_AND_SPECIALIZATION_POLICY_v1.md`

Short version:

1. `W1-W12` is the shared `Volume I` foundation route.
2. No hard Cash vs MTT fork is allowed before the shared spine is complete.
3. Post-core specialization belongs after `W12`, via a real gateway rather
   than an early blind preference split.
4. `W13-W24` and `W25-W36` remain the later depth and specialization volumes.

## Novice To Strong Player Ladder

The long-term course should move the learner from zero knowledge to strong
practical play without conceptual jumps.

Only release-ready worlds should be playable. Future worlds may be visible as
locked previews, but they must be honest about their state.

### Mental Foundation Requirement (W5 and W11)

The mental game is not an advanced topic — it is a survival concept.
Without a variance mindset, a technically correct learner will quit poker
after their first bad run.

The mental foundation must be planted in the W1–W11 block at two touch points:

**Touch 1 — W5 (Bet Purpose And Price):** When pot odds are introduced, the
learner must immediately encounter the core variance insight: a call can be
mathematically correct and still lose. This reframes losing not as failure but
as expected noise. The drill must show this explicitly — correct decision,
bad outcome, Sharky confirms the decision was right.

**Touch 2 — W11 (Capstone):** Before the learner graduates to real play, the
full mental primer must be delivered:
- Variance is not randomness punishing bad play — it is the expected range
  of outcomes from correct decisions over a small sample.
- Decision quality and outcome quality are independent.
- Tilt is a real phenomenon: emotional state degrades decision quality.
  Name the feeling, take a break, do not chase.
- A session that loses is not a failed session if the decisions were correct.

This seed planted in W5 and W11 prevents the most common beginner dropout
loop: correct play → bad result → believe strategy is wrong → quit.
The full mental game curriculum arrives in W20 and W31 — but the seed
changes everything about how the learner survives to get there.

| World | Job | Release expectation |
| --- | --- | --- |
| W1: Poker from Zero | Absolute table/rules onramp. | Playable and dense for v1. |
| W2: Hand Discipline | Not every hand deserves play. | Playable enough for v1 bridge. |
| W3: Position Thinking | Position changes hand value. | Playable enough for v1 bridge. |
| W4: Preflop Framework | First structured open/call/fold framework. | Playable enough for v1 bridge. |
| W5: Bet Purpose And Price | Why bets happen, price, and simple pot-odds intuition. First encounter with variance: a correct call can still lose. | Playable enough for v1 bridge. |
| W6: Board And Draws | Board texture, draws, outs, and street changes. | Playable enough for v1 bridge. |
| W7: Range Thinking Lite | Strong/medium/weak/missed buckets, board fit, and hand combination counting. AK = 16 combos, a pocket pair = 6 combos — combinations are how you measure range density, not just hand names. | Playable in the first independent wave once seam and regression gates are green. |
| W8: Stack Depth And Risk | Stack sizes, commitment, risk control, and format differences: same hand plays wider at 6-max, tighter at full ring — first explicit format-awareness concept. | Playable in the first independent wave once seam and regression gates are green. |
| W9: Tournament Pressure | Survival pressure, bubbles, and risk premium intuition. | Playable in the first independent wave once seam and regression gates are green. |
| W10: Player Adjustment | Player-type recognition (loose/tight/aggressive/passive). Micro-stakes specific exploits: most low-stakes opponents over-limp, call too wide preflop, fit-or-fold postflop, and fold to any aggression — recognizing these patterns is the primary edge at micro stakes. Not game selection — that is a professional tool in W27. | Playable in the first independent wave once seam and regression gates are green. |
| W11: Real Play Transfer / Capstone | Real-session readiness, capstone proof, and mental primer: variance as normal, decisions as process, tilt recognition seed. | Playable in the first independent wave once seam and regression gates are green. |
| W12: Mindset Bridge | Process-over-outcome discipline, tilt reset loop, confidence without ego, and emotional readiness before deeper postflop complexity. | Playable in the first independent wave once seam and regression gates are green. |

## Release-v1 World Content Bar

This is the practical launch-v1 content target.

| World | Release-v1 role | Good enough for v1 | Not good enough |
| --- | --- | --- | --- |
| W1 / World 1: Poker from Zero | Absolute beginner onramp. | Table, seats, opponents, pot, blinds, card ranks/suits, action order, streets, hand rankings, showdown basics, and first repair loop are all taught with intro/practice/apply/review rhythm. | A pretty map with one task per node, or questions before concepts are introduced. |
| W2 / World 2: Hand Discipline | First real choice filter after rules literacy. | Hand buckets, weak ace awareness, dominated hands, and fold discipline teach that not every hand deserves play. | Pushing hand discipline into later worlds after the user has already learned loose action habits. |
| W3 / World 3: Position Thinking | Position changes value and action comfort. | UTG/HJ/CO/BTN/SB/BB, IP/OOP, BTN advantage, and same-hand-different-seat examples are taught as one clean shift. | Mixing position with unrelated showdown, board, or initiative theory. |
| W4 / World 4: Preflop Framework | First structured decision framework. | First-in open, facing open, open/call/fold logic, and simple rule-based preflop choices without charts. Playing vs limpers: raise to isolate, do not passively complete with strong hands. Blind vs blind basics: ranges widen dramatically when folds to SB, BB must defend wide. | Charts, solver language, dominated-hand theory as first-time material, or random action questions without a clear framework. |
| W5 / World 5: Bet Purpose And Price | First bet-size and price intuition. | Why bets happen, what a size is trying to do, simple call price, basic pot-odds intuition, and implied odds — what you stand to win on future streets when you hit, not just the current pot. | Fine sizing comparisons before purpose is clear; implied odds without first establishing pot-odds. |
| W6 / World 6: Board And Draws | First board-awareness world. | Dry/wet board basics, obvious draws, outs as improvement paths, reverse implied odds (when hitting a draw creates the second-best hand — e.g., flopping a smaller flush draw when Ace-high flush is possible — the implied odds become negative; the call can become a mistake even with correct outs count), street changes, and semi-bluff as the concept of betting with a draw — equity + fold equity combine to make it profitable even when called. | Texture labels without card-level understanding; introducing semi-bluff before outs are solid. |
| W7-W12 / Worlds 7-12 | First independent extension path after core foundation. | Playable when density, seam audit verdicts, and regression locks are green; otherwise remain locked preview. | Showing any world as playable before density and seam proof exists. |
| Cross-world Review | Retention layer. | Mistakes and weak spots resurface simply across the path. | Review behaves like a static placeholder or punishment screen. |

## Minimum Content Density Rule

A release-visible playable world must have all four jobs:

1. Intro: explain the new idea clearly and briefly.
2. Practice: repeat the core recognition or action.
3. Apply: use the idea in a slightly more realistic spot.
4. Review: recap or repair the fragile part.
5. Suboptimal option: at least one drill task must include a playable-but-not-best choice
   (e.g. legal call vs. sharper raise, passive check vs. bet). This earns gold feedback
   and the label 'Sharper line exists' — it is NOT a mistake and must NOT be penalized
   as a wrong answer.

This does not require a huge number of screens.

It does require enough reps that the world does not feel like a placeholder.

## Content Excellence Rule

For this route, "content complete" does not mean "all topics mentioned once."

It means the world creates a durable learner change:

1. one cognitive shift
2. one emotional win
3. one visible table behavior
4. enough repetitions to stabilize it
5. a repair path for the common mistake
6. a short transfer task or planned transfer seam
7. a future mastery-tier path using the same atom

Use `CONTENT_EXCELLENCE_CANON_v1` when deciding whether a world is truly
release-playable or only a promising scaffold.

## Content Anti-Gap Rules

1. Do not ask before teaching.
2. Do not introduce three unrelated concepts in one short stretch.
3. Do not jump from recognition directly to strategy.
4. Do not use solver or expert language in beginner worlds.
5. Do not make later worlds responsible for teaching an earlier world's basics.
6. Do not treat a pilot slice as a complete world.
7. Do not show a world as playable if it is only a locked-preview shell.
8. Do not let hand strength, positions, streets, actions, bet purpose, board
   texture, draws, and review silently disappear from the roadmap.
9. Do not mix several cognitive shifts into one world because a local prototype
   already has useful tasks there.
10. Do not use initiative/range language as first-time beginner material before
   the learner has hand discipline, position, and preflop framing.
11. Do not build a drill task with only correct/wrong binary options. Every task
    where a second playable line exists (e.g. limp vs. raise, passive vs. aggressive,
    marginal fold vs. clear fold) must include that option as a suboptimal answer.
    Binary-only tasks are shallow. Suboptimal options are where EV understanding
    is built.
12. Do not open or mark a next world as release-playable until the previous
   world has a documented transition-readiness audit that proves the learner
   can cross the seam without conceptual shock.
13. Do not close a discovered learning gap as "fixed" unless three artifacts
   exist together: content change, regression test update, and master-plan
   policy trace.

## Transition Readiness Governance (Permanent)

This section is mandatory for all current and future world transitions.

Goal:

Prevent thin handoffs between worlds by enforcing one permanent quality loop:
detect gap -> patch content -> lock with tests -> record policy.

### Transition Contract (World N -> World N+1)

Before World N+1 is called release-playable, World N must satisfy all checks:

1. Concept bridge is explicit: World N recap states what mental model comes
  next in World N+1 (one-line forward framing, beginner-safe language).
2. Decision exposure is real: World N includes at least 2 true decision drills,
  not only recognition/tap tasks.
3. Contrast exposure exists: at least one mirrored pair shows playable line vs.
  disciplined line (e.g. continue vs. fold, passive vs. aggressive).
4. Suboptimal literacy exists: at least one non-punitive suboptimal option is
  present and explained as "playable, but sharper line exists".
5. Vocabulary handoff is smooth: terms used in the first two lessons of
  World N+1 are pre-introduced or clearly bridged in World N recap copy.
6. Emotional safety check passes: early tasks in World N+1 do not assume
  unstated strategy abstractions and do not punish reasonable novice logic.

### Gap Closure Protocol (Non-Negotiable)

When any seam gap is found (by audit, QA, test failure, or user confusion),
the fix is complete only when all steps are done:

1. Root-cause tag: classify the gap (missing concept, low reps, weak bridge,
  binary-only decisioning, terminology jump, or pacing shock).
2. Bounded patch: implement the smallest safe wave that fixes the class of
  issue, not only one local symptom.
3. Regression lock: add or update automated tests that would fail if this seam
  regresses.
4. Plan trace: record the closure in this master plan wave log with the exact
  seam and what guard now enforces it.

Definition of done for seam fixes: code + test + plan trace.

### Required Verification For Every Seam Audit

Use this checklist whenever validating readiness between adjacent worlds:

1. Curriculum check: no "ask before teach" violations at the seam.
2. Density check: Intro/Practice/Apply/Review rhythm exists on both sides.
3. Decision check: previous world has enough true decision reps to avoid shock.
4. Terminology check: no first-time expert language in first contact tasks.
5. Test check: targeted seam tests exist and pass.

Audit artifact requirement:

- Every seam audit must be recorded using
  `docs/plan/SEAM_TRANSITION_AUDIT_TEMPLATE_v1.md`.
- The artifact must include explicit evidence pointers (runner ids, lesson ids,
  and test names) and a final verdict (`bridge-playable` or
  `release-playable`).
- Any PR that promotes world status (locked -> current/playable/release-grade)
  must include the seam-audit artifact path in the PR description.

If any line fails, the next world remains bridge-playable only, not
release-playable.

## Content Priority

After the current first-start and UX clarity work, content fill should proceed
in this order:

1. Keep `Poker from Zero` as the release-grade W1 table-literacy world, not as
   the long-term W2+ strategy world.
2. Keep the detached early path aligned to the canonical W2-W4 shifts:
   Hand Discipline, Position Thinking, Preflop Framework.
3. Make W2 Hand Discipline real enough for v1: buckets, weak aces, dominated
   hands, fold discipline, and simple continue/fold choices.
4. Make W3 Position Thinking clean enough for v1: positions, IP/OOP, BTN
   advantage, and same-hand-different-seat drills without initiative overload.
5. Make W4 Preflop Framework clean enough for v1: first-in, facing open,
   open/call/fold, no charts.
6. Make W5 a simple bet-purpose and price world. Current detached preview now
   has the canonical purpose/price spine; next pass should human-review the
   size examples before calling it release-grade.
7. Keep W6 as a concrete board/draws world: dry/wet, connected boards,
   flush/straight draws, outs, and street-change basics.
8. Treat W1-W12 as the first independent wave. Keep W13+ as honest locked
  previews until their density exists and seam promotion is completed.

This gives the first release enough real learning value without pretending that
the entire long-term academy is already complete.

## Pre-W7 To W11 Start Checklist (Go / No-Go)

Before starting active build waves for W7-W11, pass this checklist.

### Gate A: Start W7 Authoring

**STATUS: COMPLETE (2026-05-06)**

All items must be true:

1. ✅ W2-W6 are stable in the active shell with green regression on the detached
  shell suite. — 174/174 tests green.
2. ✅ W6 has explicit bridge copy into W7 (Range Thinking Lite) in recap/checkpoint
  tasks. — `_world5BoardCheckpointRunner` correct-option feedbackReason bridges
  explicitly to range grouping.
3. ✅ Cross-world seam artifacts exist for W4->W5, W5->W6, and W6->W7 using
  the seam audit template. — See `docs/plan/SEAM_AUDIT_W3_TO_W4_2026_05_04_v1.md`,
  `docs/plan/SEAM_AUDIT_W4_TO_W5_2026_05_04_v1.md`,
  `docs/plan/SEAM_AUDIT_W5_TO_W6_2026_05_05_v1.md`.
  (Artifact filenames use legacy W-numbering where legacy W0 = current W1.)
4. ✅ W2-W6 each contain real decision exposure (not only recognition taps),
  including suboptimal literacy. — Verified by perfection wave tests.
5. ✅ Home/Play/Review recommendation copy and CTA behavior are aligned and stable
  (no active copy drift). — Wave R7 coherence pass completed.
6. ✅ Review loop proves weak-spot resurfacing across worlds without punitive tone.
  — New contract test `'Review resurfaces open mistake regardless of lesson context'`
  enforces this.

W7 authoring is now complete in the active shell. Do not promote W8 to
release-playable until its own content density wave and a follow-up seam audit
complete (see Gate B).

### Gate B: Open Any W7+ World As Playable

All items must be true:

1. The previous world transition is marked release-playable by seam artifact
  verdict.
2. The world being opened has Intro/Practice/Apply/Review rhythm and enough
  repetitions to avoid placeholder feel.
3. Early lessons avoid expert overload and do not assume unstated abstractions.
4. Targeted regression tests exist for the new world's key decisions and bridge
  semantics.
5. Plan trace is added in this master plan with: changed scope, tests, seam
  artifact path, and next bottleneck.

If any item fails, keep the world locked preview only.

Current seam frontier status:

- W8 -> W9 audited in `docs/plan/SEAM_AUDIT_W8_TO_W9_2026_05_06_v1.md`
  with verdict `release-playable` after W9 density and seam regression locks.
- W9 -> W10 audited in `docs/plan/SEAM_AUDIT_W9_TO_W10_2026_05_06_v1.md`
  with verdict `release-playable` after W10 density and seam regression locks.
- W10 -> W11 audited in `docs/plan/SEAM_AUDIT_W10_TO_W11_2026_05_06_v1.md`
  with verdict `release-playable` after W11 density and seam regression locks.
- W11 -> W12 audited in `docs/plan/SEAM_AUDIT_W11_TO_W12_2026_05_06_v1.md`
  with verdict `release-playable` after W12 density and seam regression locks.
- Next honest frontier is W12 -> W13 where content is still plan-truth.

### Completed First W7 Packet

Completed bounded packet before touching W8-W11:

1. W7 lesson scaffold with real decision drills (range buckets by board fit).
2. W6->W7 bridge reinforcement pass in recap/copy.
3. combo-count density layer so range weight is not only named but counted.
4. regression locks for W7 decision quality and seam language.

### Completed W9 Density Packet

Completed bounded packet before any W10+ density wave:

1. survival-pressure lesson gained a real cash-vs-tournament tradeoff rep
2. M-ratio lesson gained a yellow-zone planning rep so the urgency ladder is
   green -> yellow -> red, not a two-point jump
3. bubble lesson gained a short-stack urgency rep so bubble logic does not
   describe only medium-stack caution and big-stack leverage
4. regression locks now require 5-task lesson density and at least 11 real
   drill decisions across W9

### Completed W7-W8 Release-Strong Lift Packet

Completed bounded packet to move the two weakest visible extension worlds
toward the public `Volume I` launch bar:

1. W7 gained live bucket-first transfer, street-shift bucket logic,
   missed-hand action direction, and combo-weight comparison
2. W8 gained effective-risk notice, 40 BB middle-depth planning, SPR 4 middle
   feel, and real-table format adjustment
3. regression locks now require stronger lesson density and larger decision
   floors across W7 and W8
4. no visible `W1-W12` world remains below the `19+` public-launch bar

## Current Detached Content Migration Note

The detached shell has useful playable content. Its early world route has now
been re-homed to the v4.4 cognitive-shift order:

- Current `Poker from Zero` maps to W1 (world_1).
- Hand discipline is its own next world.
- Position thinking is its own next world.
- Preflop framework is its own next world.
- Bet purpose and price follows after preflop framework.
- Board and draws follows after bet purpose and price.

Keep this order unless a deliberate content-plan update changes the route:

- Current hand comparison and showdown basics stay in W1 unless they
  directly teach hand discipline.
- Dominated-hand material belongs in W2 Hand Discipline.
- Current pure position material belongs in W3 Position Thinking.
- Current first-in/facing-open material belongs in W4 Preflop Framework.
- Current initiative material should be softened to `last aggressor` only, or
  deferred to W7 Range Thinking Lite.
- Current W5 purpose/price material is structurally aligned and avoids relying
  on `draw` as first-time knowledge before W6 Board And Draws.
- Current W6 board/draw material is a real detached preview spine, but should
  still get human review for pacing and visuals before release-grade status.

This migration should be done as bounded content/state waves, not a broad UI
rewrite.

## Habit And Soul 100

The app is not 100 if it teaches correctly but feels sterile.

The product should become a light daily habit because the learner feels progress,
not because the app uses pressure.

Required v1 direction:

1. Sharky exists as a compact mascot coach with curated phrases only.
2. Sharky appears at useful moments: before a session, after an outcome, and
   after meaningful progress.
3. Daily play is small: a 2 to 5 minute loop is enough.
4. Streak-lite rewards returning without guilt-heavy reset pressure.
5. Achievements are tied to real learning evidence: clean pass, repaired leak,
   completed world, or stabilized skill family.
6. XP, badges, and celebrations reinforce useful behavior, not raw clicking.
7. Review and Play create return reasons through weak spots and daily drills.
8. Anti-boredom comes from structured variation, not random novelty.
9. Session energy stays bounded: heavy tasks are followed by recap, confidence,
   or repair.
10. Premium/trial messaging waits until value and return habit are believable.

Not allowed:

- open-ended Sharky chat
- fake urgency
- noisy mascot interruptions
- meaningless badges
- streak punishment
- monetization pressure before the first useful learning loop

Reason:

- The app already has enough internal logic for this stage.
- The biggest gaps are clarity, beauty, flow, and not overloading the user.
- A simple great product beats a deep confusing product.
- Content must be deep enough to teach, but not so broad that it recreates old
  main's heaviness.

## Screen Jobs

Each tab should have one clear job.

Detailed active surface mechanism and role contract:

- `docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md`

| Surface | Job | Should not become |
| --- | --- | --- |
| Home | Best next action and quick re-entry. | A dashboard. |
| Learn | Main sequential course path. | A content encyclopedia. |
| Play | Practice groups and quick reps. | A copy of Learn. |
| Review | Fix mistakes and weak spots. | A punishment screen or taxonomy view. |
| You | Simple identity, progress, strengths, weak spots. | A data warehouse. |
| Placement | Ask who the player is and place them. | A lesson or long onboarding course. |
| Runner | Teach and test one table concept. | A full poker engine UI. |

## Execution Waves

The detailed historical wave log now lives in:

- `docs/reference/history/MASTER_PLAN_EXECUTION_WAVE_TRACE_ARCHIVE_v1.md`

Use that archive when:

1. reviewing why a prior wave happened
2. tracing detailed implementation history
3. checking historical execution sequencing

For current execution, use only the active surfaces already above in this
document: Priority Order, Current Calibrated Runway, Content Priority, and
the active content stack.

## Guardrails Against Overbuild

1. If a feature makes the first experience harder to understand, cut it.
2. If a screen has more than one primary action, simplify it.
3. If copy explains the system instead of helping the learner, rewrite it.
4. If a new helper/model does not improve a visible user flow now, defer it.
5. If a product idea needs many new rules to explain, it is too early.
6. If a screen starts to look like old main, stop and simplify.
7. Prefer one good path over five half-finished paths.
8. Prefer deterministic content over clever dynamic behavior.
9. Keep placement short.
10. Keep Review helpful.
11. Keep Profile light.
12. Keep Play practical.

## Quality Gates For Each Wave

Every wave should answer these questions:

1. Is the user-visible flow clearer than before?
2. Is the visual result cleaner than before?
3. Did we avoid production route churn?
4. Did we avoid old main-style heaviness?
5. Are tests still green?

Verification should be the minimum sufficient proof for the touched wave.

Macro recalibration gate:

1. Run after each 3-wave packet or weekly cadence.
2. Update only: Priority lane status, active bottleneck, and next 2-wave
  packet.
3. Do not rewrite full plan sections unless the product route changed.

For documentation-only changes:

```bash
git diff --check
```

For detached shell UI/product changes:

```bash
dart format lib/ui_v2/act0_shell test/ui_v2/act0_shell_preview_screen_v1_test.dart
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart
flutter analyze
```

For changes that touch shared World1 behavior, routing, progression, or any
surface outside the detached shell:

```bash
./tools/fast_loop_world1_v1.sh
git diff --check
```

Do not run heavyweight gates just to perform a copy or documentation pass, but
do not skip gates when a user-visible flow or shared contract changed.

If native git is blocked by the known stale worktree pointer, use the parent
gitdir/work-tree fallback and report that explicitly.

Current wave note (2026-05-12):

1. Wave goal: clarify `Home / Learn / Play` so one dominant route wins without
   turning `Play` into a second map.
2. Scope boundary: `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`,
   `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`,
   `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`,
   `test/ui_v2/act0_shell_preview_screen_v1_test.dart`,
   `docs/plan/LAUNCH_SURFACE_MECHANISM_v1.md`.
3. Success signal: `Home` frames extra reps as optional, `Learn` states it owns
   the main route, and `Play` opens with one featured recommended rep before
   the secondary practice sections. Follow-up in the same route family:
   `Home` clean-state repair stays compact, and `Learn` opens on the active
   lesson instead of the top of the page. `Home` extra reps also stay as one
   calm secondary surface rather than nested cards. `Home` streak/daily truth
   should live in one momentum surface, while `Sharky` adds a distinct coaching
   line instead of repeating the same metric. The compact `Home` pass also
   keeps course title secondary, removes duplicate CTA hints, and tightens the
   optional rep lane so the screen reads in one quick scan.
4. Verification set: `dart format` on touched shell/test files, `flutter test
   test/ui_v2/act0_shell_preview_screen_v1_test.dart`, and `git diff --check`.
5. What changed / what is next: this wave tightened surface roles without
   reopening runner or review logic. Follow-up `You` refinement now locks the
   profile contract around one compact identity hero, a primary poker-skills
   board, a shorter rhythm/streak block, and an achievements preview with
   collection drill-down, while route/focus stays secondary. Skills and
   achievements may compress into compact two-column grids as long as they stay
   readable and the gains still come from real lesson/drill progression hooks,
   not decorative fake stats. The active `Review` density pass then removes
   duplicate repair-status rows from the prominent mistake card, keeps one
   visible diagnosis/contrast/CTA path, and leaves deeper context in quieter
   secondary treatment. The next default wave after that moves to
   `Placement` compression.

## How To Use This Plan

When choosing the next task, do not ask:

- what is the deepest system we can build?

Ask:

- what makes the current learner-facing app more obvious, prettier, faster, or
  more useful?

If the answer is not clear, choose the smaller product-facing wave.

The desired product is simple, strong, and easy to keep improving.

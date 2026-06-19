# Full Surface 10 UX UI Coherence Gate v1

Date: 2026-06-19
Branch: `codex/full-surface-10-ux-ui-coherence-gate-v1`
Base commit: `c19bb11c`
Mode: audit/spec; no implementation.

## 1. Inputs Read

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/compact_first_week_proof_packet_v1.md`
- `docs/_reviews/act0_rule_based_repair_visible_reason_surface_v1.md`
- `docs/_reviews/act0_repair_reason_copy_normalization_v1.md`
- `docs/_reviews/act0_rule_based_repair_result_receipt_v1.md`
- `docs/_reviews/act0_session_repair_summary_v1.md`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart`

## 2. Current Proven Product Spine

The compact first-week proof packet confirms this deterministic spine is now
proven:

`missed signal -> visible repair reason -> repair attempt -> fixed/repeated receipt -> session repair summary`

This closes the first proof of learning causality. It does not prove that the
full active product surface feels top-1, publish-ready, or commercially
packaged. The next bottleneck is full-surface UX/UI coherence, not another
repair feature.

## 3. Surface-by-Surface 10/10 Map

| Surface | Current expected role | 10/10 role | Known gap | Must keep | Must change | Redesign/rethink risk | Implementation timing |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Home | Show one next action, route continuation, repair/recheck/prove jobs, and the next useful hand reason. | Personal continuation surface: "here is the one useful hand now, why it matters, and what it repairs or proves." | The repair reason exists, but Home can still read like a checklist/work queue instead of a personal return moment. | One clear action, deterministic next useful hand, low-friction daily path, value before premium. | Clarify hierarchy between route continuation, daily practice, repair, recheck, prove, and completion return reason. | Medium. Existing Home may be polishable, but if checklist language dominates the first viewport it may need a new command-center layout. | First high-EV target after this gate: Home next-best-action clarity or after result/summary rhythm is specified. |
| Learn | Show structured route, worlds, lessons, task status, progress, and locked/future route clarity. | Learning-world surface: the learner sees where they are, why this lesson matters, and how the next hand fits the path. | The route is clear but may feel system-map heavy, with many status tokens and route mechanics competing with learning story. | Sequential route truth, current W1-W4 free foundation, W5+ future boundary, task clarity. | Reduce generic status language where it does not create learning value; connect lesson cards to one table skill and next useful action. | Medium-high. If world cards and volume pills feel like product scaffolding rather than an authored journey, redesign may be needed. | After Home/result rhythm, as part of Learn/Practice/Review/You coherence map. |
| Practice / Play | Provide quick reps, daily set, weak-spot repair, continuation, and topic packs. | Fast recommended reps surface: start the right rep in seconds and understand whether it reinforces, repairs, or explores. | Practice has useful groups, but group badges and tiles can feel like generic training categories rather than a personal table-coach path. | Quick daily start, weak-spot repair availability, no dashboard bloat, no fake adaptivity. | Make the featured recommendation feel causally selected, not merely sorted. Separate "quick rep", "repair", and "topic practice" through clearer rhythm. | Medium. Existing cards may work if recommendation hierarchy becomes sharper; rethink if packs dilute next useful hand. | After Home and result/summary, unless Practice becomes the first high-friction return point. |
| Review | Surface mistakes, active repairs, recovered spots, dominant patterns, and replay paths. | Personal repair coach: "this clue is still fragile, here is the repair hand, and here is proof of what recovered." | Review is close to the product promise, but can still resemble a repair board/error log if pattern cards, mistake cards, and recovered proof do not feel like one coach-led story. | Calm tone, no shame, one active repair first, recovered proof, deterministic same-signal logic. | Make Review feel less like a log and more like a guided repair session with clear before/after evidence. | Medium. Likely polishable if active repair and recovered proof become more ceremonial; rethink only if board/log grammar remains dominant. | Good candidate for second pass after result/summary ceremony. |
| You / Profile | Show identity, progress rhythm, next milestone, consistency, proof, skill stats, milestones, and settings. | Progress mirror: the learner sees "what kind of player I am becoming", current confidence, weak spots, and next focus without dashboard bloat. | Profile has many useful proof blocks, but identity and confidence may still feel like app stats rather than a personal learning mirror. | Light progress, strengths/weak spots, current focus, no heavy analytics dashboard. | Reframe stats around table-reading confidence and recent proof. Avoid making You a dump for all progress objects. | Medium-high. If top-1 quality requires identity and confidence, this may need a rethink rather than card polish. | Later in Learn/Practice/Review/You coherence map; not first unless user tests show profile is central to trust. |
| Result / Feedback | Explain correct/wrong/suboptimal answers, signal proof, skill receipt, repair receipt, and session summary lines. | Causal learning moment: the result should feel like a small coachable event, not a score screen. | The logic is strong, but the rhythm may still be text-first and stacked. It needs visual hierarchy for clue, why, repair outcome, and next step. | Table-signal proof, calm copy, fixed/repeated receipt, no fake mastery, no AI/GTO claims. | Create a consistent result beat grammar: answer result -> table clue -> why -> receipt -> next action. | High. This is the highest-EV visual/spec target because it carries the core learning proof. Existing structure may need a dedicated rhythm pass. | Recommended first implementation target after this audit/spec wave. |
| Repair Receipt | Show whether the repair was fixed or repeated, and avoid overclaiming exact replay transfer. | Mini proof: the learner instantly understands "I repaired it" or "same clue still needs one more rep." | Copy is safe and proven, but the visual moment may be too small to create emotional proof. | Fixed/repeated distinction, exact replay caution, calm tone, deterministic source. | Give receipt a distinct proof shape without turning it into celebration spam. | Medium. Could be upgraded inside result rhythm; not a standalone redesign yet. | Bundle with Result / Feedback rhythm. |
| Session Summary | Summarize active/most-recent repair result and next focus. | One-session progress proof: "today I improved this clue" or "this is the next repair focus." | Current summary covers active/most-recent repair, not multi-result aggregation. Visual ceremony and placement are not yet top-1 proven. | Honest limitation, no permanent mastery claims, next focus tied to same table clue. | Decide how summary appears at end of session and how it feeds Home return reason. | High. Summary may need ceremony and a stronger end-state surface. | Candidate B after result rhythm, or paired with it if scope allows. |
| Premium / Value | Soft preview after completed value, no price/trial/purchase/restore/route gate. | Proof-based packaging: premium feels like deeper proven coaching after free value is trusted. | Current preview is safety-correct but not yet a top-tier commercial surface. It must not move before UX proof. | W1-W4 free foundation, W5+ future paid depth, post-value preview, no commerce launch. | Later packaging should point to experienced repair value, not withheld basics. | High, but intentionally deferred. Commercial polish before UX proof would be premature. | Later only, after full-surface coherence and commerce safety gates. |
| Onboarding / Placement / Welcome | Fast first start, two-question placement, welcome handoff, no over-explanation. | Fast first value: the learner reaches a real hand quickly and understands why Sharky feels easier. | Welcome/placement are much better than a long setup, but still need proof that they accelerate the first repair moment rather than explain the app. | Short, no-pressure placement, beginner-safe route, first useful hand. | Measure against time-to-first-table-clue, not against onboarding completeness. | Medium. Could be polishable; rethink only if first-value testing shows setup still feels like friction. | After result/session proof unless activation evidence becomes the blocker. |

## 4. Design-Language Concern: Pills, Chips, Tags

Pills, chips, badges, and status tags are useful for compact state, but they are
not a final design language by default.

Current risk:

- Too many tags can make the app feel generic, admin-like, or cheap.
- Status language can compete with the table clue and repair proof.
- Pills are efficient for tests and state clarity, but top-1 learning products
often need richer proof shapes than small labels.

Research alternatives later:

- cards;
- timeline;
- receipts;
- compact proof blocks;
- badges/ribbons;
- progress beats;
- rows/lists;
- game-like result moments;
- premium learning-app patterns.

No final replacement is prescribed in this wave. The rule is:

If pill-heavy language cannot reach top-1 quality, replace or rethink it.

## 5. Redesign / Rethink Policy

Do not default to broad visual polish. Visual work is allowed later only when it
improves:

- repair proof;
- feedback rhythm;
- session proof;
- activation;
- commercial trust.

Use these classifications:

- Polish existing UI when the surface has the right job, hierarchy, and learner
  emotion, but lacks spacing, emphasis, motion, or proof styling.
- Redesign/rethink when the surface's current grammar fights the job. Examples:
  checklist-first Home when the job is personal continuation, dashboard-like You
  when the job is identity/progress mirror, or generic tags when the job is
  proof/receipt.

Modern Table remains maintenance mode. Do not reopen table geometry or
screenshot-led table polish unless a later gate proves it directly improves
repair understanding.

## 6. Publishing / Top-1 Blocker Statement

Do not claim top-1 readiness, 10/10 UX/UI, commercial publish readiness, or App
Store packaging readiness until this full-surface coherence gate is resolved.

The product now proves the repair-learning spine, but the full active shell
must still prove that Home, Learn, Practice, Review, You, result/feedback,
repair receipt, session summary, premium/value, and onboarding all feel like one
intentional product.

## 7. Deferred External Design Research Note

External design research is intentionally deferred. A later benchmark pass may
study premium learning apps, poker-learning apps, result moments, session
summaries, receipts, and commercial packaging patterns.

Do not restore Runout assets/docs, copy Runout layouts, or commit generated
screenshots in this gate. Use external references only as principle-level
benchmarks in a later admitted research wave.

## 8. Recommended Next Execution Sequence

1. Keep this TOP1/docs anchor small and merge it as a docs/spec PR.
2. Run `Result / Feedback Rhythm Visual Spec v1`.
   - Define the exact beat grammar for answer result, table clue, why, repair
     receipt, session summary, and next action.
   - Audit/spec first; no immediate implementation.
3. Then run `Session Summary Ceremony Spec v1`.
   - Decide how one-session proof appears, how it avoids fake mastery, and how
     it feeds Home return reason.
4. Then run `Home Next-Best-Action Clarity Spec v1`.
   - Decide whether Home is a checklist, command center, return card, or hybrid.
5. Then run `Learn Practice Review You Coherence Map v1`.
   - Align route, reps, repair coach, and progress mirror around one product
     language.
6. Only after these specs should implementation waves begin, each with a
   narrow target and visual acceptance criteria.

## 9. What Was Intentionally Not Changed

- No product implementation.
- No visual redesign implementation.
- No route changes.
- No Modern Table polish.
- No table geometry changes.
- No dashboard.
- No commerce, public paywall, pricing, purchase, restore, trial, or Premium
  Hub work.
- No AI, ML, adaptive, coach/chat, GTO, solver, optimal-frequency, win-rate, or
  guaranteed-improvement claims.
- No telemetry owner or network telemetry changes.
- No content expansion.
- No generated screenshots or proof outputs.
- No workflow changes.
- No `external_competitors/` changes.
- No Runout assets, binaries, screenshots, docs, or extracted materials.

## 10. Verification / Checks

Run for this docs/spec PR:

- `git diff --check`
  - passed
- `./tools/fast_loop_world1_v1.sh`
  - passed, `FAST LOOP PASS`

No targeted product tests are required because no runtime code or tests changed.
No release gate is required unless repo policy or PR checks require it.

## 11. Final Verdict

Gate admitted.

The repair-proof spine is proven, but the active product surface is not yet
allowed to claim top-1, 10/10 UX/UI, or commercial publish readiness. The next
work should start with result/feedback rhythm because that is where Sharky's
core promise becomes emotionally visible.

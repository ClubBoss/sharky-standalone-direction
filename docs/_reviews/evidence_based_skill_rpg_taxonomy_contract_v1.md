# Evidence-Based Skill/RPG Taxonomy Contract v1

## 1. Verdict

skill_rpg_taxonomy_ready_with_partial_sources

## 2. TOP1 and Achievement Taxonomy alignment

Primary sources:

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/achievement_taxonomy_v1.md`

Achievement Taxonomy v1 closed with
`achievement_taxonomy_ready_existing_seeds_aligned`. It established that
Sharky can reward evidence-backed learning moments now, but must not ship badge
art, RPG profile, levels, rating, radar, share cards, or commercial packaging
until the skill/RPG evidence contract exists.

This contract is that next step. It defines what Sharky may say about skill
families from current evidence and what must stay blocked until future source
owners or thresholds exist.

## 3. Why skill/RPG evidence contract is needed before levels/rating/radar

Levels, ratings, radar charts, and RPG profiles turn small proof into perceived
identity. That is high dopamine, but high claim risk.

Current Sharky evidence can safely say:

- the learner practiced a named skill atom;
- a recent route produced proof;
- a repair target was attempted;
- a better action was chosen on a repair target;
- an unresolved miss exists;
- a session had a repair receipt;
- an earned moment came from an admitted source.

Current Sharky evidence cannot safely say:

- a skill is mastered;
- a level was reached;
- a poker rating improved;
- a radar dimension is strong or weak;
- a leak was fixed;
- a mistake was cleared forever;
- Sharky/AI/GTO/solver diagnosed the learner.

Therefore RPG packaging must wait for source-owned thresholds and durable
history contracts.

## 4. Current evidence-source audit

| Source | Current evidence it owns | Durable? | Safe current use | Not safe for |
| --- | --- | --- | --- | --- |
| `Act0LearningEvidenceHistoryV1` | Completed decision records with world, lesson, task, selected/expected choice, correctness, error type, repair focus, `skillAtomId`, decision-time bucket, result kind, optional run key, and latest-run summary. | Yes, bounded to 200 records. | Practiced skill atom, correct read, current-run summary, first session complete. | Mastery, rating, radar, strongest/weakest skill, long-term trend without thresholds. |
| `Act0ProfileEvidenceProjectionV1` | Groups learning evidence by `skillAtomId`; emits attempt count, correct count, incorrect count, accuracy percent, sample threshold, positive threshold, world/lesson IDs, latest order, and eligibility state. | Derived from durable learning evidence. | `Recent proof from this route`, `First evidence signal`, `Action reading - practiced` when eligible. | Public skill score, level, rating, capability rank, strongest/weakest claim. |
| `Act0ProfileEvidenceConsumerV1` | First eligible profile evidence signal with safe skill labels and proof line. | Read-only consumer. | One compact proof signal. | Multi-skill profile, radar, ranking, level. |
| `Act0RepairIntentV1` | Source task, selected choice, result, error type, missed signal, `skillAtomId`, skill label, target world/lesson/task, mapping type, reason code. | In active shell state/source handoff. | Why this repair target exists, `Back to the spot`, `One miss to fix`. | Resolution, leak fixing, durable skill growth. |
| `Act0ReviewMistakeHistoryV1` | Persisted unresolved mistake records with source decision, selected/expected choices, error type, `skillAtomId`, repair focus, run data, unresolved-only state. | Yes, bounded to 200 records. | Unresolved miss exists, useful Review note, still-to-fix source. | Cleared/recovered/resolved history. |
| `Act0RepairOutcomeProjectionV1` | Repair-launched answer outcomes: attempted, correct, still-needs-rep, sequence, target IDs, queue item ID, source type. | Current projection, not a durable multi-session resolution model. | Fix attempt, first good fix, local repair proof. | Permanent repair, fix cleared, leak fixed, durable good-fix count across history. |
| `Act0RepairOutcomeConsumerV1` | Learner-safe repair proof and session receipt lines: `Fix attempt`, `Good fixes`, `Still to fix`, `Fixes tried`. | Read-only consumer over projection. | Session-scoped proof and counts. | Durable rating, queue removal, Review resolution. |
| `Act0AchievementSeedProjectionV1` | First correct read, Back to the spot, One miss to fix, First evidence signal, First session complete, Three-day rhythm; blocks lesson completion and clean mini-drill. | Derived from admitted owners. | Earned moments from admitted evidence. | Badge inventory, economy, RPG levels. |
| `Act0AchievementSeedConsumerV1` | Up to three earned moment labels from earned seeds only. | Read-only consumer. | Profile/Session Summary earned moments. | Progression, rewards, XP, badge art. |
| Session Summary repair receipt | Session-local repair outcome receipt. | Current session proof. | `Good fixes: N`, `Still to fix: N`, `Fixes tried: N`. | Durable good-fix history, cleared fixes. |
| Profile Earned moments | Compact proof chips from achievement seed consumer. | Read-only consumer output. | Small wins Sharky can prove. | Full achievement inventory or RPG profile. |
| Existing task/skill atom metadata | Known atoms: `action_read`, `table_read`, `table_position_read`, `starting_hand_read`, `board_read`, `price_read`. | Present in completed decision and receipt seams. | Skill-family mapping. | Complete 36-world skill model. |

Minimal safety copy alignment in this wave:

- Profile identity `Earned growth` no longer renders unitless `<skill> +N`; it
  renders `Practiced: <skill>`.
- Profile identity fallback no longer says `No live leak`; it says
  `No current focus`.

No source rule, threshold, route, progression, telemetry, UI surface, rating,
level, radar, or badge art changed.

## 5. Proposed Sharky skill families

### Table Reads

- Sub-families: action reading, no-bet-yet clue, facing bet, check/call/raise/fold context, general table read.
- Current status: `supported_now_v1`.
- Main atoms: `action_read`, `table_read`.
- Emotional job: "I can read what the table is asking me."

### Hand Discipline

- Sub-families: fold discipline, starting hand read, hand selection, avoiding weak continue.
- Current status: `partially_supported_now_v1`.
- Main atoms: `starting_hand_read`; fold discipline currently appears through decisions/error types, not a full family contract.
- Emotional job: "I can keep weak hands from pulling me in."

### Position Thinking

- Sub-families: in position, out of position, blinds, button/cutoff/basic positional context.
- Current status: `partially_supported_now_v1`.
- Main atoms: `table_position_read`; richer position buckets are future.
- Emotional job: "Seat and action order matter before I click."

### Board Reading

- Sub-families: board texture, made-hand recognition, draw recognition, danger cards.
- Current status: `partially_supported_now_v1`.
- Main atoms: `board_read`.
- Emotional job: "I can see what the board changes."

### Bet Purpose / Price

- Sub-families: value vs bluff basics, price/pot odds, call/fold threshold, bet sizing intent.
- Current status: `partially_supported_now_v1`.
- Main atoms: `price_read`; bet-purpose atoms need future content/source mapping.
- Emotional job: "I can tell what the price is asking."

### Repair / Comeback

- Sub-families: fix attempts, good fixes, still to fix, returned to fix a spot.
- Current status: `supported_now_v1` for local/session proof, `deferred_until_resolution_contract_v1` for durable cleared/fixed semantics.
- Main sources: repair intent, Review history, repair outcome projection/consumer, achievement seeds.
- Emotional job: "Mistakes become useful reps."

### Rhythm / Consistency

- Sub-families: sessions, rhythm, returned to training, useful sessions.
- Current status: `partially_supported_now_v1`.
- Main sources: Profile `streakDays`, latest-run summary, achievement seed `three_day_streak_v1`.
- Emotional job: "I am becoming consistent without pressure."

## 6. Family-to-source mapping table

| family_id | learner_title | description | current_source_status | current_supported_evidence | allowed_now_copy | blocked_copy | future_threshold_candidates | achievement_links | Runout benchmark analogue | claim risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `table_reads_v1` | Table Reads | Reading the current table/action clue before choosing. | `supported_now_v1` | `action_read`, `table_read`, completed decisions, profile evidence signals, repair intents. | `Practiced: Action reading`; `Table reads - practiced`; `Good action read`; `Recent proof from this route`. | Level 2 table reads, Table sense +4, strongest skill, mastered action reading. | `practiced_v1`, `recent_proof_v1`, future `consistent_read_v1`. | First correct read, First evidence signal, Practiced action reading, Good action read. | Runout concept/category completeness, but Sharky keeps table-signal proof. | Medium. Easy to overclaim as "table sense" score. |
| `hand_discipline_v1` | Hand Discipline | Starting-hand and fold/continue discipline. | `partially_supported_now_v1` | `starting_hand_read`, selected/expected choice, result kind, error type. | `Starting hand reading - practiced`; `Good hand-discipline read` only when the atom is present. | Disciplined player, mastered folding, weak hand leak fixed. | `practiced_v1`, future family-specific mistake thresholds. | Future First hand-discipline read. | Runout preflop/concept mastery analogue. | Medium-high until hand-selection taxonomy is richer. |
| `position_thinking_v1` | Position Thinking | Using seat/action order to frame the decision. | `partially_supported_now_v1` | `table_position_read`, world/lesson/task IDs, completed decisions. | `Position reading - practiced`; `Good position read`. | In-position expert, positional rating, advanced player. | `practiced_v1`, `recent_proof_v1`, future in/out-position source. | First position read. | Runout position category analogue. | Medium because source atoms are early/simple. |
| `board_reading_v1` | Board Reading | Reading board cards and texture changes. | `partially_supported_now_v1` | `board_read`, completed decisions, profile evidence signals. | `Board reading - practiced`; `First board read`; `Good board read`. | Board mastered, danger-card expert, solver-backed board read. | `practiced_v1`, `recent_proof_v1`, future texture/draw sub-atoms. | First board read. | Runout street/concept mastery analogue. | Medium-high until board subfamilies are split. |
| `bet_purpose_price_v1` | Bet Purpose / Price | Understanding price, pot-to-call, and later bet intent. | `partially_supported_now_v1` | `price_read`, completed decisions, profile evidence signals. | `Price reading - practiced`; `Good price read`. | Pot odds mastered, solver price, value/bluff rating. | `practiced_v1`, future price/pot-odds thresholds, future bet-purpose atom. | Future first price read. | Runout math/betting analogue. | Medium-high because only price_read is admitted now. |
| `repair_comeback_v1` | Repair / Comeback | Returning to mistakes and trying/good-fixing the target. | `supported_now_v1` | repair intent, Review history, Practice queue launch target, repair outcome projection/consumer, session repair receipt. | `Fix attempt`; `Good fixes: 2`; `Still to fix: 1`; `Back to the spot`; `One miss to fix`. | Leak fixed, cleared fix, resolved, fixed forever, comeback mastery. | `first_fix_attempt_v1`, `first_good_fix_v1`, `still_to_fix_v1`; future `good_fix_count_v1`, `cleared_fix_v1`. | Back to the spot, One miss to fix, First fix attempt, First good fix, Good fixes today. | Runout daily trainer/history analogue, but Sharky is proof-first. | High if copy implies resolution. |
| `rhythm_consistency_v1` | Rhythm / Consistency | Showing up and completing useful sessions without pressure. | `partially_supported_now_v1` | Profile `streakDays`, latest-run summary, first session complete seed. | `Three-day rhythm`; `First session complete`; `Finished a useful session`. | Streak broken, must return, advanced habit level, 7-day rating. | `practiced_v1`, future durable session calendar, future weekly source. | Three-day rhythm, First session complete, Finished a useful session. | Runout daily training/streak analogue. | Medium because habit copy can become manipulative. |

## 7. Allowed-now learner copy

Allowed with current evidence:

- `Practiced: Action reading`
- `Practiced: Table reading`
- `Action reading - practiced`
- `Table reads - practiced`
- `Board reading - practiced`
- `Position reading - practiced`
- `Price reading - practiced`
- `Recent proof from this route`
- `First evidence signal`
- `First correct read`
- `Back to the spot`
- `One miss to fix`
- `Fix attempt`
- `You gave the fix a try.`
- `Nice - you chose the better action.`
- `Not fixed yet - one more.`
- `Good fixes: 2`
- `Still to fix: 1`
- `Fixes tried: 1`
- `Three-day rhythm`
- `First session complete`

Rules:

- Use skill labels as practiced/evidence labels, not capability scores.
- Use counts only when they come from a current source and keep the scope local
  or session-specific.
- Use `still to fix` only for unresolved repair/review sources, not as a
  permanent weakness label.

## 8. Blocked/deferred/forbidden copy

Blocked or deferred until a future contract:

- `Practiced 3 skill families` - deferred until skill-family thresholds exist.
- `5 good fixes` - deferred until durable repair outcome history exists.
- `Clean repair run` - deferred until repair-run grouping exists.
- `Cleared a fix` - deferred until queue/review resolution contract exists.
- `First board read` / `First position read` - allowed as future names, but
  deferred until family mapping/threshold admission.
- `RPG profile` - deferred until the evidence contract is implemented and
  visual system is admitted.
- `Badge/Icon Visual System` - deferred until taxonomy and visual scope are
  admitted.

Forbidden now:

- `Level 2`
- `+4`
- `Poker rating`
- `Skill score`
- `Mastered`
- `Leak fixed`
- `AI found your leak`
- `GTO approved`
- `Solver backed`
- `Pro-level`
- `Advanced player`
- `Win-rate improved`
- `Strongest skill`
- `Weakest skill`

`Strongest skill` and `Weakest skill` remain blocked unless a future contract
defines a safe, cited comparison variant with thresholds and sample-size
guardrails.

## 9. Threshold candidates

These are proposed contract candidates only. Do not implement them in this
task.

| threshold_id | Meaning | Source required | Source exists now? | Durable? | Safe copy it could support | Current status |
| --- | --- | --- | --- | --- | --- | --- |
| `practiced_v1` | At least one valid evidence event in a family. | `Act0LearningEvidenceHistoryV1` with family mapping. | Partially. Atoms exist; family map is this contract. | Yes for records. | `<family> - practiced` | `partially_supported_now_v1` |
| `recent_proof_v1` | At least three attempts in family in current route/session window. | Learning evidence with run/source window. | Partially. Run keys exist for grouped runs. | Yes for records, current-window semantics need admission. | `Recent proof from this route` | `blocked_missing_threshold_v1` |
| `consistent_read_v1` | At least five attempts and 60%+ correct in family. | Profile evidence thresholds plus family mapping. | Partially. Current profile evidence uses 5 attempts and 3 correct per atom. | Derived from durable records. | `Consistent read` only if future copy review admits it. | `blocked_missing_threshold_v1` |
| `eligible_signal_v1` | Five attempts and at least three correct for one skill atom. | `Act0ProfileEvidenceProjectionV1`. | Yes. | Derived from durable records. | `First evidence signal`; `<skill> - practiced`. | `supported_now_v1` |
| `good_fix_count_v1` | N correct repair outcomes. | Durable repair outcome history. | No. Current repair outcomes are projection/session-scoped. | No. | `5 good fixes` after durable owner exists. | `blocked_missing_durable_history_v1` |
| `still_to_fix_v1` | Unresolved repair/review source exists. | `Act0ReviewMistakeHistoryV1` or active repair intent. | Yes. | Review history is durable; active intent is stateful. | `Still to fix: N`; `One miss to fix`. | `supported_now_v1` |
| `cleared_fix_v1` | Source-owned queue/review resolution event exists. | Future queue/review resolution contract. | No. | No. | `Cleared a fix` only after contract. | `deferred_until_resolution_contract_v1` |
| `family_coverage_v1` | Evidence exists in N distinct skill families. | Skill-family map plus durable evidence history. | Partially. Needs implemented family aggregation. | Yes for records once mapped. | `Practiced 3 skill families`. | `blocked_missing_threshold_v1` |
| `weekly_rhythm_v1` | N useful sessions in a week. | Durable session calendar/week owner. | No. | No. | `Two sessions this week`; `7-day learning week`. | `blocked_missing_durable_history_v1` |

## 10. Achievement taxonomy links

Supported or near-supported achievement links:

- Table Reads -> First correct read, First evidence signal, Practiced action
  reading, Good action read.
- Hand Discipline -> future First hand-discipline read, future Good hand read.
- Position Thinking -> First position read, Good position read.
- Board Reading -> First board read, Good board read.
- Bet Purpose / Price -> future First price read, Good price read.
- Repair / Comeback -> Back to the spot, One miss to fix, First fix attempt,
  First good fix, Good fixes today.
- Rhythm / Consistency -> First session complete, Three-day rhythm, Finished a
  useful session.

Blocked/deferred achievement links:

- `Practiced 3 skill families` waits for family coverage threshold.
- `5 good fixes` waits for durable good-fix history.
- `Clean repair run` waits for repair-run grouping.
- `Cleared a fix` waits for queue/review resolution contract.
- Badge art waits for the visual system wave.

## 11. Runout benchmark boundary

Runout is useful as benchmark pressure only:

- perceived completeness;
- concept categories;
- rating/radar/difficulty;
- daily training;
- session history.

Do not copy:

- Runout labels as the Sharky system;
- Runout layout;
- Runout radar;
- Runout rating;
- Runout category naming one-for-one;
- Runout visual system;
- Runout analytics theatre.

Sharky's answer is not breadth-first analytics. It is auditable learning
causality:

`choice -> table signal -> why -> repair -> proof`

## 12. Future RPG profile implications

A future RPG profile may be safe only after:

1. skill-family aggregation is implemented over durable evidence;
2. thresholds are admitted and tested;
3. comparison language is avoided or guarded by sample-size rules;
4. resolution semantics exist for any "cleared" or "fixed" copy;
5. visual badges/icons are designed from taxonomy, not the other way around;
6. premium packaging points to already experienced proof, not locked basic
   usefulness.

Allowed future RPG directions:

- practiced families;
- recent proof chips;
- earned moments;
- repair comeback proof;
- cited session rhythm.

Blocked future RPG directions:

- global poker rating;
- radar chart;
- skill levels;
- strongest/weakest ranking;
- mastery state;
- leak-fix state;
- social share card without cited proof.

## 13. Claim-safety guardrails

- Skill families describe evidence buckets, not player identity.
- A single correct answer can support `good read`, not mastery.
- Profile evidence can support `practiced` and `recent proof`, not `level`,
  `rating`, or `score`.
- Repair outcomes can support `fix attempt`, `good fix`, and `still to fix`,
  not `cleared`, `resolved`, or `leak fixed`.
- Review history is unresolved-only until a resolution contract exists.
- Rhythm copy must avoid guilt, pressure, loss aversion, and streak punishment.
- Runout-style completeness must be translated into Sharky's evidence model,
  not copied as category/rating/radar UI.
- No AI, GTO, solver, pro-level, win-rate, or guaranteed-improvement claims.

## 14. Tests / validation

Required validation:

- `git diff --check` - passed.
- `git status --short` - only admitted docs/code changes plus pre-existing
  generated output directories.
- `graphify hook-check` - passed.

Because this task includes one minimal Profile copy-safety alignment, also run:

- focused Profile evidence / claim-safety tests;
- `flutter analyze`;
- `dart format --set-exit-if-changed` on touched Dart/test files.

Validation run:

- `flutter test test/ui_v2/act0_profile_evidence_projection_v1_test.dart test/ui_v2/act0_profile_evidence_consumer_v1_test.dart test/ui_v2/act0_profile_claim_safety_v1_test.dart` - passed.
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_profile_shell_v1.dart` - passed.
- `flutter analyze` - passed.
- targeted unsafe-copy scan over `lib/ui_v2/act0_shell` - clean; forbidden
  terms appear only in this contract's blocked/forbidden sections.

No screenshot generation is required because no new UI surface, RPG UI, radar,
rating, badge art, or visual system was added.

## 15. Next recommended PR

Fixes You've Banked / Proof Home Contract v1.

That contract should define whether Sharky can create one compact proof-home
concept from existing evidence without adding a dashboard, fake backlog, queue
resolution, Review clearing, levels, rating, radar, or badge art.

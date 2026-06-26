# Achievement Taxonomy v1

## 1. Verdict

achievement_taxonomy_ready_existing_seeds_aligned

## 2. TOP1 source alignment

Primary strategy source:

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`

The TOP1 source names `Achievement Taxonomy v1 - No Art` as the current active
candidate after Repair Loop Copy / Claim-Safety Pass v1.

This artifact follows the current TOP1 guardrails:

- no fake mastery;
- no abstract levels, ratings, radar, or skill scores without evidence;
- no badge art before taxonomy;
- no Runout copying;
- no Modern Table reopening;
- no public paywall before proof/commercial safety;
- no queue or Review resolution before explicit resolution contracts.

## 3. Why taxonomy before art

Badge art would force meaning before the achievement system knows what it may
truthfully reward.

The correct order is:

`evidence stats -> achievement taxonomy -> skill/RPG taxonomy -> badge/icon visual system -> commercial packaging`

This keeps Sharky from making attractive but unsafe claims like mastered skill,
fixed leak, poker rating, level up, or solver-backed proof.

## 4. Gamification design principles

Every achievement must reward a behavior Sharky wants the learner to repeat.

Reward:

- useful decisions;
- noticing table signals;
- returning to a mistake;
- trying the fix;
- choosing the better action on a repair target;
- practicing consistently without guilt;
- building cited evidence in a skill family;
- completing meaningful learning loops.

Do not reward:

- vanity;
- fake skill;
- time wasting;
- only clicking through;
- fake resolution;
- abstract level/rating movement;
- Runout-style analytics theatre without Sharky evidence.

## 5. Existing achievement seed audit

| Existing seed | Decision | Learner-facing title | Evidence source | Emotional job | Risk | Surface | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `first_correct_read_v1` | keep | First correct read | `Act0LearningEvidenceHistoryV1`, first completed correct decision | I made a useful read. | Low. Avoid "strong read" or mastery. | Session Summary, Profile Earned moments | P0 |
| `first_repair_note_v1` | rename | Back to the spot | `Act0RepairIntentV1` or `Act0ReviewMistakeHistoryV1` | I have a real spot to return to. | Low-medium. Do not imply the fix was attempted yet. | Profile Earned moments | P0 |
| `first_review_history_item_v1` | rename | One miss to fix | `Act0ReviewMistakeHistoryV1`, persisted unresolved mistake record | Sharky kept the useful miss for me. | Medium. Do not imply resolved/cleared. | Profile Earned moments, future Review proof | P1 |
| `first_evidence_signal_v1` | keep | First evidence signal | `Act0ProfileEvidenceProjectionV1`, first `eligible_signal_v1` | Sharky has one proof point about my play. | Medium. Do not imply capability level. | Profile Earned moments | P0 |
| `first_session_complete_v1` | keep | First session complete | `Act0LearningEvidenceHistoryV1.latestRunSummary`, grouped current-run summary with spots played | That session mattered. | Low. Do not imply course/lesson/world completion. | Session Summary, Profile Earned moments | P0 |
| `three_day_streak_v1` | rename | Three-day rhythm | `Act0ProfileStateV1.streakDays >= 3` | I am becoming consistent. | Medium. Avoid guilt/streak pressure. | Profile Earned moments | P0 if owned streak remains admitted |
| `first_lesson_complete_v1` | block | First lesson complete | Blocked until durable lesson-completion owner/proof is named | I finished a meaningful lesson. | Medium. Could imply route/progression truth not owned here. | Blocked | deferred |
| `first_clean_mini_drill_v1` | block | Clean mini-drill | Blocked until all-correct mini-drill run owner/proof is named | I had a clean practice run. | Medium-high. Could imply perfection/mastery. | Blocked | deferred |

Minimal copy alignment performed:

- `first_repair_note_v1`: `First repair note` -> `Back to the spot`
- `first_review_history_item_v1`: `First review note` -> `One miss to fix`
- `three_day_streak_v1`: `3-day streak` -> `Three-day rhythm`

No seed IDs, source owners, projection rules, surfaces, routes, progression,
telemetry, or art changed.

## 6. Achievement families

### A. First-value achievements

Purpose: make the first session feel rewarding quickly.

Expected emotional job: "I started learning for real."

Examples: First correct read, First useful mistake, First fix attempt, First
evidence signal, First session complete.

### B. Repair comeback achievements

Purpose: reward returning to a mistake and improving it.

Expected emotional job: "I made a mistake, came back, and did better."

Examples: Back to the spot, First fix attempt, First good fix, One miss to fix,
Good fix after a miss.

Avoid fixed forever, cleared, resolved, or leak fixed until explicit resolution
contracts exist.

### C. Skill evidence achievements

Purpose: start building future RPG/skill identity from countable facts.

Expected emotional job: "I am building a specific poker skill."

Examples: Practiced action reading, Good action read, Practiced table reads,
First board read, First position read.

No mastered, `Lv`, `+N`, rating, radar, or skill-score copy.

### D. Rhythm / habit achievements

Purpose: create return behavior without guilt.

Expected emotional job: "I am becoming consistent."

Examples: Three-day rhythm, Back tomorrow, Returned to fix a spot, Two sessions
this week.

No loss aversion, streak punishment, timer pressure, or guilt copy.

### E. Session / completion achievements

Purpose: make sessions feel complete and productive.

Expected emotional job: "That session mattered."

Examples: First session complete, Finished a useful session, One repair session
done, Good fixes today.

No fake lesson/world/course completion if the source is missing.

### F. Collection / journey achievements

Purpose: future medium-term goals and RPG feel.

Expected emotional job: "I am building a portfolio of poker skills."

Examples: First read in every core family, Practiced 3 skill families, 5 good
fixes across skills, 7-day learning week.

Most are deferred until the skill/RPG taxonomy contract exists.

### G. Rare / premium-feeling achievements

Purpose: future high-dopamine moments.

Examples: Clean repair run, Perfect mini-drill, Comeback rhythm, No-bet-yet read
in motion.

Most are blocked or deferred until clean-drill, resolution, or skill-level
contracts exist.

### H. Forbidden achievement family

These must not exist now:

- Leak fixed
- Skill mastered
- GTO approved
- Solver backed
- AI found your leak
- Poker rating milestone
- Level up
- Pro player
- Premium-only skill
- Guaranteed improvement

## 7. Candidate scoring model

Scores are `1` to `5`.

- `learning_ev`: does it reinforce a learning behavior?
- `dopamine_ev`: does it feel earned and satisfying?
- `retention_ev`: does it create a reason to continue or return?
- `viral_share_ev`: could it become a clean future share card?
- `claim_risk`: higher means more risk of implying mastery/resolution/AI/GTO.
- `evidence_readiness`: higher means deterministic source ownership exists now.

Statuses:

- `available_now_v1`: deterministic source exists and the concept is safe for
  current or near-current earned-moment use.
- `needs_copy_alignment_v1`: source exists but the current label needed safer or
  higher-EV wording.
- `blocked_missing_source_v1`: no admitted source owner/proof event yet.
- `deferred_until_resolution_contract_v1`: source may exist, but resolution
  semantics are not admitted.
- `deferred_until_skill_rpg_contract_v1`: needs skill/RPG source thresholds.
- `deferred_until_visual_system_v1`: taxonomy may be safe, but badge/share art
  waits.
- `forbidden_v1`: should not be built.

## 8. Candidate table

| id | family | learner_title | short_description | emotional_job | proof_event | source_owner | status | allowed_surfaces | learning_ev | dopamine_ev | retention_ev | viral_share_ev | claim_risk | evidence_readiness | overall_priority | forbidden_overclaim_note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- |
| `first_correct_read_v1` | First-value | First correct read | First completed decision with the expected answer. | I made a useful read. | completed decision where `isCorrect == true` | `Act0LearningEvidenceHistoryV1` | `available_now_v1` | Session Summary, Profile Earned moments, future share card | 5 | 4 | 3 | 3 | 1 | 5 | P0 | No mastered/strong read claim. |
| `first_repair_note_v1` | Repair comeback | Back to the spot | First admitted repair intent or unresolved mistake saved for return. | Sharky found a useful spot to revisit. | active repair intent or unresolved Review history record | `Act0RepairIntentV1`, `Act0ReviewMistakeHistoryV1` | `needs_copy_alignment_v1` | Profile Earned moments, future Review proof | 5 | 4 | 5 | 3 | 2 | 5 | P0 | Does not imply a fix attempt happened. |
| `first_review_history_item_v1` | Repair comeback | One miss to fix | First persisted unresolved mistake record. | The miss is useful, not shameful. | first unresolved mistake history record | `Act0ReviewMistakeHistoryV1` | `needs_copy_alignment_v1` | Profile Earned moments, future Review proof | 5 | 3 | 5 | 2 | 3 | 5 | P1 | No cleared/resolved/fixed copy. |
| `first_evidence_signal_v1` | First-value | First evidence signal | First eligible profile evidence signal. | Sharky has one proof point. | first `eligible_signal_v1` | `Act0ProfileEvidenceProjectionV1` | `available_now_v1` | Profile Earned moments, future proof home | 4 | 4 | 3 | 4 | 3 | 5 | P0 | No level, score, or capability claim. |
| `first_session_complete_v1` | Session / completion | First session complete | First grouped current-run summary with spots played. | That session mattered. | current-run summary where `spotsPlayed > 0` | `Act0LearningEvidenceHistoryV1.latestRunSummary` | `available_now_v1` | Session Summary, Profile Earned moments | 4 | 4 | 4 | 3 | 1 | 5 | P0 | No lesson/world/course completion claim. |
| `three_day_streak_v1` | Rhythm / habit | Three-day rhythm | Owned Profile streak count reaches three. | I am becoming consistent. | `streakDays >= 3` | `Act0ProfileStateV1.streakDays` | `needs_copy_alignment_v1` | Profile Earned moments, future share card | 3 | 4 | 5 | 4 | 2 | 4 | P0 | No guilt, loss aversion, or streak pressure. |
| `first_fix_attempt_v1` | Repair comeback | First fix attempt | Learner tries an active repair target once. | I gave the fix a try. | repair-launched answer with attempted outcome | `Act0RepairOutcomeProjectionV1` | `available_now_v1` | Session Summary, Profile Earned moments, future share card | 5 | 4 | 5 | 4 | 2 | 5 | P0 | No fixed/resolved claim. |
| `first_good_fix_v1` | Repair comeback | First good fix | Learner chooses the better action on a repair target. | I came back and did better. | repair outcome state `correct` | `Act0RepairOutcomeProjectionV1` | `available_now_v1` | Session Summary, Profile Earned moments, future share card | 5 | 5 | 5 | 5 | 3 | 5 | P0 | No "fixed forever" claim. |
| `practiced_action_reading_v1` | Skill evidence | Practiced action reading | Learner has enough action-read attempts to show practice. | I am building action reading. | eligible action-read evidence sample | `Act0ProfileEvidenceProjectionV1` | `deferred_until_skill_rpg_contract_v1` | Profile, future proof home | 5 | 4 | 4 | 4 | 3 | 4 | P1 | No skill level or rating. |
| `good_action_read_v1` | Skill evidence | Good action read | A correct action-read decision is recorded. | I made a specific good read. | correct decision with `skillAtomId == action_read` | `Act0LearningEvidenceHistoryV1` | `available_now_v1` | Session Summary, Profile, future share card | 5 | 4 | 3 | 4 | 2 | 4 | P1 | No mastered action reading. |
| `returned_to_fix_spot_v1` | Rhythm / habit | Returned to fix a spot | Learner starts a session from an existing repair focus. | I came back for the useful miss. | return/open repair source handoff | `Act0PracticeRepairQueueLaunchTargetV1`, source handoff | `available_now_v1` | Practice, Session Summary, Profile | 5 | 4 | 5 | 4 | 3 | 4 | P1 | No resolved/cleared claim. |
| `good_fixes_today_v1` | Session / completion | Good fixes today | One or more correct repair outcomes in a session. | Today's practice turned mistakes into better choices. | session receipt with good repair count | `Act0RepairOutcomeConsumerV1` | `available_now_v1` | Session Summary, Profile | 5 | 5 | 4 | 4 | 3 | 5 | P1 | Count is local/session-scoped only. |
| `one_miss_to_fix_v1` | Repair comeback | One miss to fix | A current unresolved miss is named as useful next work. | I know the next useful thing. | unresolved Review history or active repair intent | `Act0ReviewMistakeHistoryV1`, `Act0RepairIntentV1` | `available_now_v1` | Review, Profile | 5 | 3 | 5 | 2 | 3 | 5 | P1 | No resolution promise. |
| `practiced_table_reads_v1` | Skill evidence | Practiced table reads | Learner has repeated table-read attempts. | I am building table awareness. | eligible table-read evidence sample | future skill taxonomy over evidence atoms | `deferred_until_skill_rpg_contract_v1` | Profile, future proof home | 5 | 4 | 4 | 4 | 3 | 2 | P1 | No rating/radar/level. |
| `first_board_read_v1` | Skill evidence | First board read | First decision in board-reading family. | I started reading boards. | decision tagged to board-read skill family | future skill taxonomy over evidence atoms | `deferred_until_skill_rpg_contract_v1` | Profile, Session Summary | 4 | 4 | 3 | 3 | 3 | 2 | P1 | No mastered board reading. |
| `first_position_read_v1` | Skill evidence | First position read | First decision in position-reading family. | Position started to matter. | decision tagged to position skill family | future skill taxonomy over evidence atoms | `deferred_until_skill_rpg_contract_v1` | Profile, Session Summary | 4 | 4 | 3 | 3 | 3 | 2 | P1 | No position expert claim. |
| `two_sessions_this_week_v1` | Rhythm / habit | Two sessions this week | Two owned sessions in the week. | I am showing up. | durable session calendar/week owner | future habit/session source | `blocked_missing_source_v1` | Profile, future share card | 3 | 4 | 5 | 4 | 2 | 1 | deferred | No guilt or pressure. |
| `finished_useful_session_v1` | Session / completion | Finished a useful session | A session has evidence and a summary. | That session counted. | grouped run summary plus at least one evidence/repair proof | `Act0LearningEvidenceHistoryV1`, achievement consumer | `available_now_v1` | Session Summary, Profile | 4 | 4 | 4 | 3 | 2 | 4 | P1 | No lesson/world completion claim. |
| `one_repair_session_done_v1` | Session / completion | Repair session done | Session includes at least one repair attempt. | I worked on the right thing. | repair receipt exists for current session | `Act0RepairOutcomeConsumerV1` | `available_now_v1` | Session Summary, Profile | 5 | 4 | 4 | 3 | 3 | 5 | P1 | No repair resolved claim. |
| `first_read_each_core_family_v1` | Collection / journey | First read in every core family | At least one practiced read in each defined core family. | I am building a portfolio. | skill-family coverage thresholds | future skill/RPG taxonomy | `deferred_until_skill_rpg_contract_v1` | Profile, future share card | 5 | 5 | 4 | 5 | 4 | 1 | deferred | Needs family definitions. |
| `practiced_3_skill_families_v1` | Collection / journey | Practiced 3 skill families | Evidence exists in three admitted skill families. | My poker toolkit is growing. | three family evidence samples | future skill/RPG taxonomy | `deferred_until_skill_rpg_contract_v1` | Profile, future share card | 5 | 5 | 4 | 5 | 4 | 1 | deferred | No capability ranking. |
| `five_good_fixes_v1` | Collection / journey | 5 good fixes | Five correct repair outcomes across sessions or skills. | I turned mistakes into better decisions. | durable count of correct repair outcomes | future resolution/durable outcome store | `deferred_until_resolution_contract_v1` | Profile, future share card | 5 | 5 | 5 | 5 | 4 | 2 | deferred | No leak fixed or permanent repair. |
| `seven_day_learning_week_v1` | Collection / journey | 7-day learning week | Seven owned learning days in a week. | I built a learning rhythm. | durable weekly habit owner | future habit/session source | `blocked_missing_source_v1` | Profile, future share card | 3 | 5 | 5 | 5 | 3 | 1 | deferred | No pressure if missed. |
| `clean_repair_run_v1` | Rare / premium-feeling | Clean repair run | A repair-focused run has all correct outcomes. | I had a clean comeback. | repair run grouping plus all-correct outcomes | future repair-run owner | `deferred_until_resolution_contract_v1` | Session Summary, Profile, future share card | 5 | 5 | 4 | 5 | 4 | 1 | deferred | No perfect player claim. |
| `perfect_mini_drill_v1` | Rare / premium-feeling | Perfect mini-drill | All-correct mini-drill run. | I nailed this small drill. | all-correct mini-drill proof | future practice run source | `blocked_missing_source_v1` | Practice, Session Summary, Profile | 4 | 5 | 4 | 5 | 4 | 1 | deferred | No mastery/perfection beyond run. |
| `cleared_a_fix_v1` | Rare / premium-feeling | Cleared a fix | A repair item is explicitly resolved by a source-owned contract. | I closed the loop. | source-owned queue/review resolution event | future queue/review resolution contract | `deferred_until_resolution_contract_v1` | Profile, Review, future share card | 5 | 5 | 5 | 5 | 5 | 1 | deferred | Blocked until resolution contract. |
| `level_up_v1` | Forbidden | Level up | Abstract RPG level movement. | I got stronger. | none admitted | none | `forbidden_v1` | blocked | 2 | 5 | 4 | 5 | 5 | 0 | forbidden | Implies level system and capability. |
| `poker_rating_milestone_v1` | Forbidden | Poker rating milestone | Runout-style rating milestone. | My rating improved. | none admitted | none | `forbidden_v1` | blocked | 2 | 5 | 4 | 5 | 5 | 0 | forbidden | No rating contract. |
| `skill_mastered_v1` | Forbidden | Skill mastered | Claims a skill is mastered. | I mastered it. | none admitted | none | `forbidden_v1` | blocked | 1 | 5 | 3 | 5 | 5 | 0 | forbidden | Fake mastery. |
| `leak_fixed_v1` | Forbidden | Leak fixed | Claims permanent leak repair. | Sharky fixed my leak. | none admitted | none | `forbidden_v1` | blocked | 1 | 5 | 3 | 5 | 5 | 0 | forbidden | No leak or permanent resolution claim. |
| `ai_found_leak_v1` | Forbidden | AI found your leak | Claims AI diagnosis. | AI analyzed me. | none admitted | none | `forbidden_v1` | blocked | 1 | 5 | 4 | 5 | 5 | 0 | forbidden | No AI claim. |
| `gto_approved_v1` | Forbidden | GTO approved | Claims solver/GTO validation. | My play is solver-backed. | none admitted | none | `forbidden_v1` | blocked | 1 | 5 | 3 | 5 | 5 | 0 | forbidden | No GTO/solver claim. |
| `premium_only_skill_v1` | Forbidden | Premium-only skill | Achievement tied to paywall status. | I bought power. | none admitted | none | `forbidden_v1` | blocked | 1 | 3 | 2 | 2 | 5 | 0 | forbidden | No premium/paywall achievement. |

## 9. P0 / P1 / deferred / forbidden recommendations

P0:

- First correct read
- Back to the spot
- First evidence signal
- First session complete
- Three-day rhythm
- First fix attempt
- First good fix

P1:

- One miss to fix
- Practiced action reading
- Good action read
- Returned to fix a spot
- Good fixes today
- Practiced table reads
- First board read
- First position read
- Finished a useful session
- Repair session done

Deferred:

- First lesson complete
- Clean mini-drill
- Two sessions this week
- First read in every core family
- Practiced 3 skill families
- 5 good fixes
- 7-day learning week
- Clean repair run
- Cleared a fix
- Badge/icon visual system

Forbidden:

- Leak fixed
- Skill mastered
- GTO approved
- Solver backed
- AI found your leak
- Poker rating milestone
- Level up
- Pro player
- Premium-only skill
- Guaranteed improvement

## 10. Dopamine and retention rationale

Highest dopamine should come from earned comeback moments, not abstract reward
currency.

Best near-term dopamine:

- `First good fix`: the learner made a miss useful and chose better next time.
- `First fix attempt`: the learner gets credit for returning without requiring
  immediate success.
- `First correct read`: a simple early proof beat.
- `Three-day rhythm`: habit proof without guilt.

Best retention:

- `Back to the spot`: creates a clear reason to continue.
- `One miss to fix`: makes the next rep obvious.
- `Returned to fix a spot`: rewards day-two behavior.
- `Good fixes today`: gives the session a reason to feel complete.

## 11. Future viral/share-card potential

No sharing is implemented in this task.

Future share-card candidates:

- First good fix: "I came back to a mistake and got it right."
- Three-day rhythm: "Three days of poker training."
- 5 good fixes: "Five mistakes turned into better decisions."
- First evidence signal: "My first proven skill signal."
- Practiced 3 skill families: "My poker toolkit is growing."

Share cards must cite the underlying evidence and avoid claims of mastery,
rating, AI, GTO, solver, or permanent leak repair.

## 12. Surface mapping

Current safe surfaces:

- Session Summary: First correct read, First session complete, First fix
  attempt, First good fix, Repair session done, Good fixes today.
- Profile Earned moments: First correct read, Back to the spot, One miss to
  fix, First evidence signal, First session complete, Three-day rhythm.

Future surfaces:

- Review proof home: Back to the spot, One miss to fix, Returned to fix a spot,
  Good fixes today.
- Practice: First fix attempt, First good fix, Repair session done.
- Future share card: First good fix, Three-day rhythm, 5 good fixes, First
  evidence signal.

Blocked surfaces:

- Badge inventory screen.
- RPG profile.
- Rating/radar.
- Social sharing.
- Premium achievement surface.

## 13. Runout/RPG benchmark boundary

Runout can inform future structure:

- broad skill categories;
- rating/radar/difficulty as a warning about perceived completeness;
- concept mastery as a taxonomy input;
- daily training and session history as future habit/proof inputs.

Do not copy:

- Runout layout;
- Runout asset style;
- Runout copy;
- Runout category system one-for-one;
- Runout rating/radar now.

Sharky should beat Runout by making the cause visible:

`choice -> table signal -> why -> repair -> proof`

## 14. No-art boundary

This task defines taxonomy only.

No badge art, icons, animation, inventory screen, RPG profile UI, visual badge
system, social sharing, economy, XP changes, levels, rating, radar, or premium
packaging was added.

## 15. Forbidden claims

The taxonomy forbids:

- mastery;
- leak fixed;
- fixed forever;
- cleared or resolved without source-owned resolution;
- AI diagnosis;
- GTO/solver approval;
- poker rating;
- level up;
- pro-player framing;
- guaranteed improvement;
- premium-only skill;
- leaderboard/ranking copy.

## 16. Tests / validation

Focused validation after the naming alignment:

- `flutter test test/ui_v2/act0_achievement_seed_projection_v1_test.dart test/ui_v2/act0_achievement_seed_consumer_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart` - passed.
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart lib/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart test/ui_v2/act0_achievement_seed_consumer_v1_test.dart` - passed.
- `flutter analyze` - passed.
- `graphify hook-check` - passed.
- `git diff --check` - passed.
- `git status --short` - only admitted docs/code/test changes plus pre-existing
  generated output directories.

No screenshot generation is required because this is a label-only alignment and
taxonomy doc with no new UI surface or visual system.

## 17. Next recommended PR

Evidence-Based Skill/RPG Taxonomy Contract v1.

Define skill families, source owners, thresholds, and allowed future level/rating
language before any RPG profile, radar, badge art, or commercial packaging work.

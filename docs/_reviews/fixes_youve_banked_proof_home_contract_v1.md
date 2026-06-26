# Fixes You've Banked / Proof Home Contract v1

## 1. Verdict

fixes_banked_session_only_contract_ready

## 2. TOP1 / Achievement / Skill-RPG alignment

Primary sources:

- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/achievement_taxonomy_v1.md`
- `docs/_reviews/evidence_based_skill_rpg_taxonomy_contract_v1.md`
- `docs/_reviews/session_summary_repair_outcome_receipt_v1.md`
- `docs/_reviews/repair_outcome_consumer_local_proof_v1.md`
- `docs/_reviews/repair_outcome_projection_v1.md`

Achievement Taxonomy v1 established evidence-backed earned moments with no art
and no fake mastery. Evidence-Based Skill/RPG Taxonomy Contract v1 established
that Table Reads and Repair / Comeback are supported now, while skill levels,
ratings, radar, strongest/weakest skill, durable good-fix counts, and
cleared/resolved fix claims remain blocked.

This contract defines a compact proof-home concept without opening dashboard,
RPG profile, queue resolution, Review clearing, rating, radar, levels, badge art,
or share-card implementation.

## 3. Why proof home is needed

Repair proof currently exists, but it is distributed across:

- local answer feedback;
- Session Summary repair receipt;
- Profile evidence;
- earned moments;
- Practice repair queue;
- Review unresolved history.

The learner-facing question is simpler:

> What fixes have I banked, and what is still worth working on?

The answer must stay evidence-safe. It can summarize current/session proof and
read-only unresolved work, but it must not invent all-time progress, queue
resolution, Review clearing, leak fixing, mastery, or RPG status.

## 4. Current proof-source audit

| Source | Current proof it owns | Count scope | Safe proof-home use | Not safe for |
| --- | --- | --- | --- | --- |
| `Act0RepairOutcomeProjectionV1` | Repair-launched answer outcomes: `repair_attempted_v1`, `repair_correct_v1`, `repair_still_needs_rep_v1`; target/source IDs; sequence. | Current projection/session scope only. | Latest repair result, session good-fix count, session still-to-fix count, attempted count. | Durable all-time fixes, queue removal, Review resolution. |
| `Act0RepairOutcomeConsumerV1` | Local proof and receipt lines: `Fix attempt`, `Good fixes`, `Still to fix`, `Fixes tried`. | Current projection/session scope only. | Session-only proof home. | Cross-session totals, "fixed forever", "cleared", "resolved". |
| Session Summary repair receipt | Compact read-only receipt from repair outcome consumer. | Current Session Summary only. | Best current home for `Good fixes`, `Still to fix`, `Fixes tried`. | Durable profile history or all-time repair bank. |
| `Act0ReviewMistakeHistoryV1` | Persisted unresolved mistake records with `skillAtomId`, repair focus, selected/expected choices, run data, unresolved-only state. | Durable unresolved-only history. | Read-only `One miss to fix`, `Still to fix`, repair context. | Cleared/recovered/resolved history, banked fix counts. |
| `Act0RepairIntentV1` | Active repair intent with source, missed signal, skill atom/label, and target. | Active shell/source handoff. | Why the next fix exists, latest target context. | Durable all-time history or resolution. |
| Practice repair queue projection | Active repair rows and passive history rows; launchability only for active repair target. | Current projection over active repair/history sources. | Read-only Practice context: what is available to try now. | Queue clearing, done state, fixed state. |
| `Act0ProfileEvidenceProjectionV1` / consumer | Eligible skill evidence by `skillAtomId` and one safe evidence signal. | Derived from durable learning evidence. | `Practiced: Action reading`, `Recent proof from this route`. | Good-fix totals, proof-home counts, strongest/weakest/rating. |
| Achievement seed projection/consumer | Earned moments such as First correct read, Back to the spot, One miss to fix, First evidence signal, First session complete, Three-day rhythm. | Derived from admitted sources. | Supporting "small wins" around the proof home. | Badge inventory, RPG levels, fix resolution. |
| Skill/RPG taxonomy contract | Supported skill families and allowed copy. | Contract only. | Safe family labels: Table Reads, Repair / Comeback. | Implemented RPG profile, rating, radar. |

Conclusion: current proof home can be source-safe only as a session/latest
repair proof plus read-only still-to-fix context. Durable all-time "banked
fixes" remains blocked until a durable repair outcome history exists.

Minimal copy alignment in this wave:

- Existing Profile achievement label `Cleared a fix` was renamed to `Good fix`
  because "cleared" requires a future queue/Review resolution contract.
- The stable achievement id and locked/unlocked behavior were not changed.

## 5. Definitions

### banked_fix_v1

Meaning: a repair-launched target was answered correctly.

Current source:

- `Act0RepairOutcomeProjectionV1`
- `Act0RepairOutcomeConsumerV1`

Safe current scope:

- current repair projection/session only.

Allowed copy:

- `Good fix`
- `Good fixes`
- `You chose the better action`
- `Fix landed` only if scoped to the attempt/session and not used as permanent
  resolution.

Blocked:

- durable all-time good-fix count;
- queue removal;
- Review clearing;
- `Cleared a fix`;
- `Leak fixed`;
- `Fixed forever`;
- `Resolved`;
- `Mastered`.

### still_to_fix_v1

Meaning: there is an unresolved repair/review item, an active repair intent, or
a repair outcome that still needs another attempt.

Current sources:

- `Act0ReviewMistakeHistoryV1`
- `Act0RepairIntentV1`
- `Act0RepairOutcomeProjectionV1`
- `Act0RepairOutcomeConsumerV1`

Safe current scope:

- read-only context; may be durable for unresolved Review history but not as a
  resolved backlog.

Allowed copy:

- `Still to fix`
- `One miss to fix`
- `Not fixed yet - one more`
- `Worth another try` only when paired with clear source context.

Forbidden copy:

- `Failed`
- `Weakness`
- `Leak`
- `Broken`
- `Unresolved leak`

### attempted_fix_v1

Meaning: learner launched/answered a repair target and the outcome was recorded
as attempted.

Current source:

- `Act0RepairOutcomeProjectionV1`
- `Act0RepairOutcomeConsumerV1`

Safe current scope:

- current session/latest attempt only.

Allowed copy:

- `Fix attempt`
- `You gave the fix a try`
- `Fixes tried`

Recommendation:

- useful in Session Summary and latest-proof contexts;
- less useful as a standalone Profile proof because it is not success or
  durable progress.

### latest_fix_v1

Meaning: most recent repair outcome in the current projection.

Current source:

- latest ordered item from `Act0RepairOutcomeProjectionV1`, consumed through
  `Act0RepairOutcomeConsumerV1`.

Safe current scope:

- latest/session-only.

Allowed copy:

- `Latest fix`
- `Latest repair attempt`
- `Latest: Good fix`
- `Latest: Still to fix`

Recommendation:

- strong compact proof-home ingredient because it avoids all-time counts and
  still gives the learner a fresh status.

### skill_touched_v1

Meaning: the repair/proof touched an admitted skill family.

Current sources:

- `skillAtomId` in learning evidence, repair intent, Review history, and Profile
  evidence projection;
- Evidence-Based Skill/RPG Taxonomy Contract v1.

Safe current scope:

- Table Reads and Repair / Comeback are supported now.
- Other families are partial and require cautious copy.

Allowed copy:

- `Touched: Table reads`
- `Practiced: Action reading`
- `Repair / Comeback`

Forbidden copy:

- `Best skill`
- `Weakest skill`
- `Level`
- `Rating`
- `Skill score`

## 6. Source ownership table

| proof_state | Source owner | Source exists now | Durable now | Count allowed now | Blocked count |
| --- | --- | --- | --- | --- | --- |
| `banked_fix_v1` | `Act0RepairOutcomeProjectionV1` / `Act0RepairOutcomeConsumerV1` | Yes | No durable all-time owner | Current session/projection `Good fixes: N` | All-time banked fixes, cross-session totals |
| `still_to_fix_v1` | `Act0ReviewMistakeHistoryV1`, `Act0RepairIntentV1`, repair outcome consumer | Yes | Review unresolved history is durable; active intent/outcome are local | Current unresolved/context count only when source is explicit | Resolved backlog, cleared count |
| `attempted_fix_v1` | `Act0RepairOutcomeProjectionV1` / consumer | Yes | No durable all-time owner | Current session/projection `Fixes tried: N` | Lifetime fix attempts |
| `latest_fix_v1` | `Act0RepairOutcomeConsumerV1.proof` | Yes | No | Latest/session-only | Historical latest across app relaunch unless source owns it |
| `skill_touched_v1` | Skill/RPG taxonomy + `skillAtomId` owners | Partial | Durable for learning evidence; local for repair outcome | Safe labels for Table Reads and Repair / Comeback | Skill ranking, rating, radar, levels |

## 7. Allowed copy

Allowed now:

- `Fixes you've banked`
- `Good fixes`
- `Good fix`
- `Still to fix`
- `One miss to fix`
- `Fix attempt`
- `Fixes tried`
- `Latest fix`
- `Latest repair attempt`
- `Latest: Good fix`
- `Latest: Still to fix`
- `You chose the better action`
- `You gave the fix a try`
- `Not fixed yet - one more`
- `Practiced: Action reading`
- `Touched: Table reads`
- `Repair / Comeback`
- `Recent proof from this route`

Copy rules:

- Add `this session`, `this route`, or local placement when a count could be
  misunderstood as all-time.
- Prefer `good fix` over `fixed`.
- Prefer `still to fix` over `failed`.
- Prefer `proof` over `score`.

## 8. Forbidden copy

Forbidden now:

- `Leak fixed`
- `Fixed forever`
- `Cleared`
- `Resolved`
- `Mastered`
- `Failed`
- `Weakness`
- `Leak`
- `Broken`
- `Unresolved leak`
- `All-time fixes`
- `Lifetime fixes`
- `Skill score`
- `Level`
- `Rating`
- `Radar`
- `Best skill`
- `Weakest skill`
- `AI found your leak`
- `GTO approved`
- `Solver backed`
- `Win-rate improved`
- `Premium fixes`

## 9. Proof-home model comparison

| Model | Example | learning_ev | dopamine_ev | retention_ev | claim_safety | source_readiness | implementation_risk | recommended_status |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Model 1 - Session-only proof home | `Fixes you've banked` / `Good fixes: 1` / `Still to fix: 1` / `Latest: Action reading` | 5 | 4 | 4 | 5 | 5 | 2 | `admit_now_v1` as contract; UI wave optional |
| Model 2 - Review-top proof home | `Fixes you're working on` / `One miss to fix` / `Last attempt: Good fix` | 5 | 4 | 5 | 3 | 4 | 4 | `spec_only_v1` until no-resolution wording and placement are proven |
| Model 3 - Profile mirror proof home | `Recent proof` / `Good fixes this route: 1` / `Practiced: Table reads` | 4 | 4 | 4 | 3 | 3 | 4 | `spec_only_v1`; defer broad Profile proof home until durable history/routing is clearer |
| Model 4 - Durable fixes bank | `5 fixes banked` / `2 skills improved` | 5 | 5 | 5 | 1 | 1 | 5 | `defer_until_durable_history_v1` |
| Model 5 - Resolution proof home | `Cleared 3 fixes` / `No active leaks` | 4 | 5 | 4 | 0 | 0 | 5 | `defer_until_resolution_contract_v1` / forbidden until source exists |

## 10. Recommended model

Recommended: Model 1 - Session-only proof home.

Why:

- it consumes current, accepted repair outcome sources;
- it can use `Good fixes`, `Still to fix`, `Fixes tried`, and latest repair
  proof without inventing durable history;
- it naturally fits the existing Session Summary repair receipt;
- it avoids queue resolution and Review clearing;
- it gives the learner a coherent proof concept without adding a dashboard.

Contract recommendation:

- Admit the concept now as `session_only_fixes_banked_v1`.
- Treat implementation as a later small UI/copy wave, preferably by reusing the
  existing Session Summary receipt or one compact existing proof slot.
- Do not create a new dashboard or Profile proof home until durable history and
  resolution contracts exist.

## 11. Surface mapping

| Surface | Contract status | Safe use | Guardrail |
| --- | --- | --- | --- |
| Session Summary | `admit_now_v1` | Best home for session-only proof: good fixes, still to fix, fixes tried, latest result. | Label counts as session/local if needed. |
| Review top | `spec_only_v1` | Read-only context: one miss to fix, last attempt. | Must not imply Review item was cleared/resolved. |
| Profile proof section | `spec_only_v1` | Mirror recent proof only: practiced family, earned moments, maybe latest proof later. | No all-time banked fixes until durable owner exists. |
| Practice queue context | `spec_only_v1` | Explain active repair context and what is still worth trying. | No done/remove/resolve semantics. |
| Future share card | `defer_until_durable_history_v1` | First good fix or session-only proof card. | Must cite session/current scope and avoid permanent claims. |

## 12. No-resolution boundary

This contract does not define:

- queue item removal;
- queue done state;
- Review clearing;
- Review recovered state;
- fix resolved state;
- cleared fix count;
- leak fixed state;
- permanent skill improvement.

`banked_fix_v1` means "this repair target was answered correctly in the owned
source scope." It does not mean the underlying queue item, Review item, leak,
or skill family is resolved.

## 13. No-dashboard / no-RPG boundary

This contract does not admit:

- dashboard UI;
- Profile redesign;
- Review redesign;
- Practice redesign;
- RPG profile;
- levels;
- rating;
- radar;
- skill score;
- strongest/weakest skill;
- badge art;
- icons;
- animation;
- share cards;
- social sharing;
- premium/paywall copy.

Future proof-home UI must be compact, evidence-cited, and preferably reuse an
existing surface before adding any new destination.

## 14. Future implementation options

Option A - Session Summary label/copy refinement:

- Reuse the existing Session Summary repair receipt.
- Potentially title it `Fixes you've banked` only when outcomes exist.
- Lowest implementation risk.

Option B - Review compact read-only proof:

- Add a small read-only line near active repair context.
- Shows `One miss to fix` and latest local repair result if available.
- Higher claim risk; must avoid resolution implication.

Option C - Profile recent proof mirror:

- Mirror latest session proof under existing proof language.
- Useful for future RPG path, but more likely to become dashboard creep.
- Defer until durable history and proof-home scope are clearer.

Option D - Durable proof bank:

- Requires a new durable repair outcome history/source owner.
- Not admitted in this task.

## 15. Tests / validation

Validation run:

- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` - passed.
- `flutter test test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart` - passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Profile earned achievement unlocks after first task and streak stat appears"` - passed.
- `flutter analyze` - passed.
- `graphify hook-check` - passed.
- `git diff --check` - passed.
- Targeted unsafe-copy scan over `lib/ui_v2/act0_shell` and `test/ui_v2` found no live `Cleared a fix` label. Remaining matches are negative test assertions or identifier substrings such as `resolved`.

Screenshot generation is not required because this is a label-only safety
alignment and no new proof-home UI surface was added.

## 16. Next recommended PR

Session Summary Fixes Banked Label v1 - Local Only.

If implementation is admitted, the safest next slice is a compact Session
Summary-only copy/use-case pass that reuses `Act0RepairOutcomeConsumerV1` and
does not add durable counts, queue resolution, Review clearing, Profile
dashboard, RPG profile, levels, rating, radar, or badge art.

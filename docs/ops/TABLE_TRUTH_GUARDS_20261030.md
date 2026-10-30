# TABLE.TRUTH source contract — Issue #333

BASE: `c1f69e1d36897f4a4d389e2b22dee511a2687a7d`, stacked on #332. English iPhone 14 Pro only; F7 remains default OFF. No release/Human/merge acceptance.

## Permanent validation

Normal `Table Truth` PR CI runs:

```sh
TABLE_TRUTH_LEDGER=table-truth-ledger.json flutter test \
  test/ui_v2/act0_table_truth_catalog_v1_test.dart \
  test/ui_v2/act0_first_hand_truth_v1_test.dart \
  test/ui_v2/act0_table_truth_render_v1_test.dart \
  test/ui_v2/act0_table_truth_mutation_v1_test.dart
```

The catalog enumerator walks `Act0ShellStateV1.sample` (367 tasks at admission), authored tables, every teaching step's raw and actual projected table, decision/review tables, each option's **final** feedback projection and supported choreography frames. These are source/projection states, not thousands of distinct native captures. Runtime and guard share the final feedback-table helper, including correct-option signal clues. The solver already used by the application owns hand ranking; the guard adds identity/claim checks, not a gameplay engine.

Invariants cover D1 actor existence/live state/consistency/decision ownership; D2 explicit folds; D3 named bet ownership, old blind amounts and chips, explicit current-street bets; D4 named hole cards, declared same-hand continuity and applicable made-hand/overcard claims; D5 unique physical cards; D6 street/card counts and explicit chronology. Approved complete histories have independent arithmetic/ordering tests. Mutation controls reject an underpair as top pair, board trips as a pocket set, and carrying an old flop bet into a checked turn.

Partial history does **not** establish whole-pot arithmetic. `NEEDS_SOURCE_CONTEXT` rows retain the task/state and reason. The reported 195 feasibility candidates are not 195 confirmed errors and do not authorize fabricated folds/antes/contributions. A passing guard does not prove every strategy sentence, every unprovided economic input, or native appearance.

`table_truth_learning_contract_v1.json` freezes baseline task/world/lesson and option IDs, grading quality/correctness, seat targets and repair-focus fields. The source fixes do not change these contracts. `table_truth_unresolved_v1.json` is empty at candidate freeze; any future exception requires exact state/invariant/detail and an owner-reviewed rationale. Tests reject both new failures and stale exceptions. CI uploads the ledger even on failure.

## Approved editorial decisions

- The eight `your_first_hand_*` tasks use A♠K♦ throughout. CO holds K♥J♥, hidden until showdown. UTG/HJ fold; CO limps 1; BTN raises to 3; SB/BB fold; CO calls 2 more. Pot 7.5 BB. CO and BTN check each later street. Board A♥7♣2♦J♣4♠; aces beat jacks. Only task-specific overrides change this story; unrelated showdown templates retain their examples.
- Action history is an explicitly retrospective **flop** snapshot, latest `Flop: CO checks`, with exactly three board cards. Historical choice ID `bb_check` is a legacy opaque persistence identifier; label/preferred/better-answer/feedback text now says CO. Correctness remains unchanged.
- `outs_improvement_w5_table_outs_straight_transfer`: Hero stays BTN; the approved bettor is BB for 3 BB. Source trail, current bet and actor agree.
- `w9_bubble_table_risk_transfer`: owner-approved no-ante line is UTG/HJ/CO fold, BTN raises to 2.5, SB folds, BB shoves to 18 total. Pot before Hero's response is 21 BB; to call 15.5 BB. Tournament risk-premium grading remains, rather than being inferred from chip arithmetic.
- Under the autonomous factual-repair policy, W6's explicitly named hands replace inherited QQ data. The impossible “9-8 two pair on 8-7-6” wording becomes top pair plus an open-ended straight draw, preserving the Value-versus-Bluff-versus-Missed objective and correct option. KQ's kicker is good, not best possible; AQ on K72 has one overcard.

## Evidence boundaries and handoff

Local raw evidence: `output/table_truth_20261030/`; previous integrated evidence remains untouched in the prior integration worktree's `output/en_v1_20261030/`. The permanent three-case guard is RED against exact BASE state (catalog, eight-task story, real fallback rendering) and GREEN after correction. The original wrong test expectation requiring an inherited HJ actor was corrected rather than treated as a product contract.

Independent engineering review identified stale blind sublabels, a too-weak top-pair test and an intermediate-only feedback projection. All were repaired, with a bounded read-only recheck. This is source/receipt review, not independent native or poker-rules acceptance. Opus #334 remains a separate read-only rules audit; no writer/native ownership was transferred.

Native captures, app/kernel hashes, exact final source identity, source applicability matrix and final scoped verdict belong in the local report. Never upgrade a source PASS or older build image to current native acceptance. F7 felt/rail geometry remains a separate open family.

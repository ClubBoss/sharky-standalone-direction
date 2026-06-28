# W1 Bet-Size Vocabulary Correctness Repair v1

Status: ACCEPTED implementation artifact.
Date: 2026-06-28.

## 1. Verdict

`w1_bet_size_vocabulary_correctness_repair_ready`

The P1 source-linked bet-size vocabulary boundary found by
`docs/_reviews/w1_poker_correctness_review_protocol_v1.md` is repaired.

W1 bet-size preview tasks now behave as strict beginner label-recognition
tasks. Broad source-level acceptable substitutes were removed from the strict
standalone prompts and the W1 first-bridge size-label steps, and exported
factory fixture tasks still have empty `acceptable_actions`.

## 2. Scope

Changed source truth:

- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_one_third_pot_keep_price.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_half_pot_value.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_min_raise_reopen.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_pot_pressure.json`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json`

Changed generated fixture:

- `test/fixtures/content_factory_mvp/w1_bet_size_vocabulary_preview_migration_pr3_v1.json`

Changed test:

- `test/tools/content_factory_import_export_mvp_v1_test.dart`

Intentionally not changed:

- no new tasks;
- no new concept families;
- no route, title, UI, telemetry, monetization, screenshot, Modern Table, or
  W2-W12 changes;
- no solver, GTO, or advanced sizing claim.

## 3. Repair Summary

Standalone strict prompt repairs:

| Source id | Expected preset | Previous broad substitute | Repaired state |
| --- | --- | --- | --- |
| `choose_one_third_pot_keep_price` | `one_third_pot` | `half_pot` | no accepted substitute |
| `choose_half_pot_value` | `half_pot` | `one_third_pot` | no accepted substitute |
| `choose_min_raise_reopen` | `min_raise` | `half_pot` | no accepted substitute |
| `choose_pot_pressure` | `pot` | `half_pot` | no accepted substitute |

Chain strict prompt repairs:

- `chain_world1_first_bridge_v1` step 3 now requires `one_third_pot` without
  accepting `half_pot`.
- `chain_world1_first_bridge_v1` step 4 now requires `half_pot` without
  accepting `one_third_pot`.

Feedback wording was tightened to beginner-safe vocabulary recognition:

- `min_raise` is framed as the smallest legal raise label.
- `pot` is framed as the largest pressure-size label.
- strategy-adjacent wording such as getting paid by weaker hands, pushing out
  marginal hands, or getting called by worse hands was removed from the
  repaired exported W1 bet-size fixture.

## 4. Correctness Result

Classification after repair:

`strict_w1_preview_label_recognition_p1_cleared`

The W1 bet-size vocabulary preview remains a basic size-label preview, not a
strategy lesson. The repaired source files and generated fixture support this
claim:

- strict prompts have one expected preset;
- source-level acceptable substitutes are absent for repaired strict prompts;
- exported fixture `acceptable_actions` remain empty for all six tasks;
- feedback is label-focused and beginner-safe.

No P0 or P1 bet-size vocabulary issue remains in the reviewed W1 certified
fixture/source slice.

## 5. Test Evidence

Added focused assertions in
`test/tools/content_factory_import_export_mvp_v1_test.dart`:

- every exported W1 bet-size PR3 task has empty `acceptable_actions`;
- standalone strict source files have no `acceptable_preset_ids`;
- chain size-label steps have no `acceptable_preset_ids`;
- `min_raise` and `pot` feedback uses explicit label-recognition wording;
- repaired fixture feedback avoids the previous strategy-adjacent phrases.

Red/green note:

- The focused test failed before repair on old min-raise feedback:
  `Min raise reopens the action while risking less than a bigger raise.`
- The same focused test passed after source repair and fixture regeneration.

## 6. Ledger Impact

- W1 score remains `8.0`.
- W1-W12 Volume I Premium Product Readiness remains `6.2`.
- Overall Top-1 Readiness remains `6.0`.
- The W1 poker correctness P1 bet-size blocker is cleared.
- W1 is still not 9.0 because human novice QA, payoff/progression proof, and
  broader W1 migration remain incomplete.

Recommended next wave:

`W1 Human QA Protocol`

Reason:

- The poker correctness repair needed before novice QA is now complete.
- Human QA remains the hard next gate before external beta, public learning
  claims, or any 9.0/launch-ready language.

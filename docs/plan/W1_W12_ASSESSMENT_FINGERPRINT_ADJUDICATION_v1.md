# W1-W12 Assessment Fingerprint Adjudication v1

Status: CURRENT_AND_VALID after Learning Content Integrity v1A (published-head
field is updated only by the publication commit).

## Authority and method

The canonical 291 assessed rows are extracted by
`test/guards/w1_w12_answer_position_distribution_contract_test.dart` from
`Act0ShellStateV1.sample.worlds`. The only authored row-content input is
`lib/ui_v2/act0_shell/act0_shell_state_v1.dart`; model classes determine the
shape but do not author a row value. The extractor serializes task identity,
phase/family, learner-visible task/runner text, and every option's identity,
correctness, quality, feedback, and repair-focus mapping before SHA-256.

`tools/contracts/w1_w12_assessment_fingerprint_v1.json` is the machine-read
baseline. Its guard validates row count, content fingerprint, and the SHA-256
of every declared input. It reports one of `CURRENT_AND_VALID`,
`STALE_FINGERPRINT`, `INVALID_FINGERPRINT`, or
`CONTENT_DIFFERENCE_REQUIRES_ADJUDICATION`; source changes therefore cannot
silently retain a valid-looking fingerprint.

| Baseline | HEAD | rows | state input SHA-256 | content fingerprint |
| --- | --- | ---: | --- | --- |
| prior valid | `7f77def08b35f8249889d4b23ffdd25e3bf14289` | 291 | `d646b28cee0e5d844680eca85d6c8c911f271238e73644974735517020eb2ecf` | `d57fd20fd62a3527be549e4c69d8a10aaf1788026c7dccf597b461373a0fd49d` |
| adjudicated | `d19ffad4a5bd9b5fb5a97efa1a5af3b1da19ac5a` | 291 | `f596ee8b512c26ac300b163c7e4a2f858eee72be49ec7e258e89ef8303a107af` | `ee91c4f9b43ed3893fb0d047631dd39122ac4711e0cedba8c917435fa8b6c3d9` |

The source changed after the prior valid baseline in `bff237bc`, `dcae04c3`,
`ff157920`, and `bbce4caf`. Direct serialized-row comparison shows that only
`bbce4caf` changes this fingerprint: five W1 identity teaching rows. The
other listed commits alter source structure or non-fingerprinted presentation
data. Stage A (`d19ffad4`) changes the runner shell and its geometry test, not
this input, so it is the immutable product baseline for this adjudication.

## Complete row result

## Learning Content Integrity v1A adjudication

The canonical extractor still returns 291 rows. The new source hash is
`dc3a7aad3669ac5a8fba0f2801eb324e29a861f25ac1c9ca3efabaf6007fcd8d` and
the content fingerprint is
`433136896f6d9841e74f123a55ca2e4c8ea388412c824e7f661e1e7afe7a9803`.

Changed learner-visible rows are limited to the W1 first-table identity
assessments (`what_poker_is_theory`, `what_poker_is_find_hero`), W4 value
assessment (`w4_value_missed`), and the four W7 visible-card rows. W1 changes
replace badge matching with action-order and identity-versus-position reading;
W4 replaces an inverted value question with the direct poker action; W7
replaces authored metadata on learner surfaces with intentional copy. There is
no task-id, option-count, correct-position, repair-focus, or route-transition
change. W4's correct option changes from `check` to poker-correct `bet_half`;
that is the admitted content correction, not accidental drift. The contract
guard re-runs every row and the separate census records the option-position
invariants.

Both baselines extract 291 rows. 286 serialized row payloads are identical;
five changed payloads are all in `world_1/what_poker_is`. Their old/new row
SHA-256 values below are the complete row-level fingerprint inventory.

| World / lesson / task | old row SHA-256 | new row SHA-256 | old → new authored value | adjudication |
| --- | --- | --- | --- | --- |
| W1 / what_poker_is / `what_poker_is_theory` | `ed91025b380a8531d5cac64db9f2922a459b6bcc6061d18520c83cf8f8e79cef` | `196b89da0d85c1724f768e5ec1662ac189ef197f67496a7ff36e9037490131c1` | caption “hero seat” → “bottom seat”; prompt “hero seat” → “You marker”; correct option/label “Bottom seat” → “You badge”; feedback consistently names You and BTN. | Expected `bbce4caf` identity-teaching change. Correct seat remains `btn`; correct option remains the third authored choice; no poker rule or repair mapping changes. |
| W1 / what_poker_is / `what_poker_is_find_hero` | `dd25e88d42c8de206ce47c73bfc5e006c928930d6b7bd8dce2dc3223ef9ba66b` | `63811de60c1fd9fa6dffa7477b5cc90e202a844c56d2d5527a091a43f7ab923f` | “Hero” caption/hint/question/feedback and “Bottom seat” answer → “You”/“You badge”. | Expected identity alignment. Same `bottom` correct option, same `btn` seat, same 3-option distribution, no repair focus. |
| W1 / what_poker_is / `what_poker_is_table_read_transfer` | `662affb9f352b1200a9ff4e57c8ca7922c897098633aed157538b8f08a7f164e` | `2d8f45f4367433c7fd8a4a77699f092fc87fac4e0ba1fb7e10e574904e92e124` | “Hero/private cards” learner wording → “your cards”; the correct answer stays “2 private cards, 3 board cards, 6 BB in the pot.” | Expected learner-visible wording only. Correct answer identity, 3-option distribution, quality classes, and no repair mapping are unchanged. |
| W1 / what_poker_is / `what_poker_is_table_read_recheck` | `a5f209220d7d402bf620e6b3d835216903f337c36cf4a2051d9f72227f6f1ba3` | `38df71dd26b4040ec2090f9724db5dde27a8d0c084472e874acc744fdfbbe557` | “Hero cards” → “your cards” in caption, hint, feedback, distractor label, and repair-focus label; the correct answer stays “2 private cards, 3 board cards, 4 BB in the pot.” | Expected identity wording. Correct option, 3-option distribution, card-id repair focus, and recheck mapping are unchanged. |
| W1 / what_poker_is / `first_table_guide_one_clear_choice` | `36bd6f9930c21c38a847e551696c532742958d18e82ad2642fc553e535419f53` | `435545fe81fa2c6fa00c2a0f787c99ca9d0d54405ca225e84c0014e2da403c30` | “Hero … Button/button” → “You … BTN” in caption, hint, all answer text/feedback, and repair-focus label. | Expected identity/BTN terminology alignment. Correct option remains `hero_btn_preflop_setup` at index 1; `btn/sb/bb` and `hero_0/hero_1` repair targets are unchanged. |

No changed row changes poker correctness, number of options, correct-option
identity/index, distractor quality/distribution, or card/seat repair mapping.
The only learner-visible content change is the explicit learner identity and
BTN wording. This is proof drift, not a current curriculum defect.

## Audit-sensitive checks

- **W1 identity:** the five changed rows consistently bind the learner to the
  visible `You` marker while retaining `BTN` as the table position; the
  first-session geometry repair is a separate runner-shell concern.
- **Wording overlap and duplicates:** the change set does not touch the
  historical W11/W12 overlap or duplicate-prompt task IDs; the grouped content
  and poker-correctness guards remain the authority for those families.
- **Answer/binary distribution:** all 291 correct-option indices are
  re-evaluated by the guard; the affected W1 choices retain their original
  indexes and the W10-W12 `{0:14, 1:14, 2:14}` invariant.
- **W7 metadata:** no W7 serialized row changes; W7 runtime/authoring metadata
  is separately covered by the active W7 route and first-use-jargon guards.
  That latter guard's stale W12 phrase was corrected from “terminal review” to
  the current, source-owned “Volume I review”; no learner content changed.
- **W10-W12 transfer/context:** no W10-W12 serialized row changes; this does
  not claim Human proof of felt variety or transfer depth.
- **Feedback, repeated misses, and recheck:** the W1 recheck keeps identical
  card-id repair targets and correct answer. No feedback/repair mapping moved.

## Concept Error & Repair Integrity v1 — no serialized-row impact

The concept-error and repair-adjudication wave does not edit
`lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, the contract's sole declared
authored input. New concept identities, the 34-row repair registry, runtime
target selection, telemetry projection, and compatibility tests are outside
the serialized fingerprint payload. The freshness guard still extracts 291
rows and retains fingerprint
`433136896f6d9841e74f123a55ca2e4c8ea388412c824e7f661e1e7afe7a9803`
with option distribution 121/165/5 and correct positions 111/116/62/2.
Accordingly the machine contract and input hash are not regenerated.

## Blinds Action-Order Truth Repair adjudication

`blinds_review` is the one additional changed serialized row. The canonical
six-max table orders voluntary preflop action from the seat left of BB: UTG,
HJ, CO, BTN, SB, then BB. The prior review inherited the last-actor runner's
BB/SB choices while asking who acts first; its hint and feedback already said
left of BB. The repair changes only this review's authored runner to the
first-actor UTG/BTN decision, preserving task id, lesson/world, phase, route,
concept-error id, repair-family identity, and schema/event contracts. Its
pre-choice caption and hint stay neutral and its table has no highlighted seat;
the left-of-BB explanation appears only in post-choice feedback.

| World / lesson / task | old row SHA-256 | new row SHA-256 | changed fields | adjudication |
| --- | --- | --- | --- | --- |
| W1 / blinds_action_order / `blinds_review` | `8f66ee81bbbd1e521f4f9c9e7aa8993ab9b5dcccd57331fa1a5626d00cdadc35` | `62e5b4073d3ec34c4cf64dd6a14d00d224fd5d79890b42d15c3ba8c9725ce7d2` | caption, hint, correct option `bb` index 1 → `utg` index 0, options `BB/SB` → `UTG/BTN`, option feedback, inherited runner identity, and pre-choice table highlights | Poker-correct first-actor recap; two options retained, one correct UTG choice, neutral pre-choice copy/table, no future knowledge, and no unrelated serialized row changed. |

The new state-input SHA-256 is
`77a393090fddb28d51b5f1e33b54e42d27763ac690a34145d4a0b1f8b01e383e` and
the new 291-row content fingerprint is
`1f11f46f766ede8a967a1044a9a8ac280a29e681c066d2a6d5b277ab1b767d91`.
All other 290 current serialized rows retain their prior payloads. The
machine contract was updated only after this row-level comparison.

## Scope boundary and freeze decision

This re-adjudication closes the stale 291-row proof gap and the published
first-session identity geometry repair closes its product debt. It does not
reconcile independent audit packets beyond their source-ID crosswalk, prove
Human learning effect, or authorize Final Deep Independent Audit, Human Novice
Proof, or AI Personalization. The candidate is permitted to freeze for the
downstream gates named in the active plan.

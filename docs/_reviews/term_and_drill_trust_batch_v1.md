# Term & Drill Trust Batch v1

## 1. Verdict

`implemented_term_batch_with_density_proof`

## 2. What changed

Files changed:

- `content/_meta/term_introduction_contract_v1.json`
- `content/worlds/world2/v1/sessions/w2.s06/session.md`
- `content/worlds/world8/v1/sessions/w8.s01/session.md`
- `test/tools/term_introduction_glossary_safety_v1_test.dart`
- `docs/_reviews/term_and_drill_trust_batch_v1.md`

| Item | Old wording / ownership | New wording / ownership |
| --- | --- | --- |
| ICM objective | `sorting tournament spots into simple ICM pressure buckets` | `sorting tournament spots into simple payout-pressure buckets` |
| ICM first use | No owned definition; `ICM` appeared before an expansion. | `ICM, or Independent Chip Model, is a tournament pressure idea: near prizes, losing chips can hurt more than winning the same chips helps.` |
| ICM scanner ownership | None. | `ICM` -> `world8/v1/sessions/w8.s01/session.md` with the exact first-use definition. |
| Outs objective | `counting simple outs` before a definition. | `counting simple improvement cards` before the definition. |
| Outs first use | No owned definition; active W2 counting drills used `outs`. | `Outs are cards that can improve your hand.` in W2 s06 before its decision and drill sources. |
| Outs scanner ownership | None. | `OUTS` -> `world2/v1/sessions/w2.s06/session.md` with the exact first-use definition. |

`pot odds` was not changed. The inspected active uses are deferred-layer
references (`before deeper ... pot-odds`) rather than an owned learner decision
term or formula lesson. Adding an artificial definition would broaden this
batch without proving an immediate learner action need.

## 3. Scope proof

- No route, access, clickability, entitlement, or UI change.
- No new lesson, drill, session, world, track, or content-family expansion.
- No glossary/tappable-definition architecture.
- No W11/W12 or W13+ content work.
- No localization architecture work, commerce, paywall/trial, or Modern Table
  change.
- The only production changes are two single-session first-use definitions and
  two metadata ownership entries.

## 4. Term verification results

| Term | Result |
| --- | --- |
| ICM | W8 s01 now expands the acronym before the `Choose the simple ICM pressure bucket` decision. Scanner ownership passes. The definition is tournament survival/payout pressure, not ICM mastery. |
| Outs | Scanner exposed the actual first learner source as W2 s06, not W5. The definition now appears before W2 s06’s outs decision/drills. Scanner ownership passes. |
| Pot odds | No change. The term remains a deferred-layer reference in inspected sources; it is not promoted to a first-use lesson or formula. |

## 5. W3/W5 drill-density proof

| World | Sessions inspected | Raw drill files | Unique `intent_v1` values | Chains / embedded decision steps | Same-signal variation and repair evidence | Conclusion |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| W3 | 14 | 18 | 18 file-level intent values, with repeated `action_sequence` chains | 14 chains / 42 `expected_action` steps | Repeats open/call/fold across hand buckets, position, unopened/facing-open, and mixed checkpoints; 60 explicit error-class fields. | Low file count is an inventory artifact, not current proof of thin learner decisions. No new drills. |
| W5 | 10 | 41 | 53 intent occurrences across recurring texture families | 8 chains / 57 `expected_action` steps | Dry/wet, paired, connectivity, high-card, turn/river, IP/OOP, blocker, and capstone variations; 65 explicit error-class fields. | Raw count is lower than W4/W6 but learner-visible decision variation is substantial. No new drills. |

This proof does not certify full pedagogical effectiveness or commercial
depth. It only removes the specific inference that W3/W5 are thin because
their raw drill-file counts are lower.

## 6. Scanner / validator proof

- `dart run tools/term_coverage_scanner.dart` passes with eight owned terms:
  `EQUITY`, `PROBE`, `BLOCKERS`, `OUTS`, `SPR`, `ICM`, `EV`, and `EXPLOIT`.
- `test/tools/term_introduction_glossary_safety_v1_test.dart` passes all four
  tests, including the new production-contract assertion for ICM and outs.
- Existing owned-term checks remain green; no scanner behavior or architecture
  was changed.

## 7. Deferred terms / residuals

- Seat codes, IP/OOP, pot, paired board, and combo remain later
  glossary/tappable-definition candidates.
- M-ratio, variance, and tilt remain deferred.
- The archived map-key mismatch remains separate.
- W11-W12 remains planned foundation; W13+ remains frontier-only.
- External/App Store packaging remains deferred.

## 8. Next recommended wave

`Glossary / Tappable Definition Contract v1`

The concrete first-use defects are fixed and W3/W5 are not proven thin. The
remaining quality opportunity is a bounded, non-UI contract for repeated
lightweight support of the P2 terms, rather than speculative new content,
drills, or a broad glossary implementation.

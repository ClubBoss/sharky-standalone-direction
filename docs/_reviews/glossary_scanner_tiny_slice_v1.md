# Glossary Scanner Tiny Slice v1

## 1. Verdict

`implemented_glossary_scanner_terms`

## 2. What changed

Files changed:

- `content/_meta/term_introduction_contract_v1.json`
- `content/worlds/world2/v1/sessions/w2.s03/session.md`
- `content/worlds/world2/v1/sessions/w2.s04/session.md`
- `content/worlds/world6/v1/sessions/w6.s01/session.md`
- `test/tools/term_introduction_glossary_safety_v1_test.dart`
- `docs/_reviews/glossary_scanner_tiny_slice_v1.md`

| Term | Previous state | New first-use wording and scanner ownership |
| --- | --- | --- |
| OOP | W2 s03 drill feedback used `OOP` without owned expansion. | `OOP, or out of position, means acting before your opponent on later streets.` at W2 s03. |
| Paired board | W2 s04 and later drills used `paired` without an owned definition. | `A paired board has two cards of the same rank.` at W2 s04; scanner term is exact `PAIRED`. |
| Combo | W6 s01 used `one exact combo` without an owned definition. | `A combo is one specific set of hole cards a player can hold.` at W6 s01. |

The scanner now owns `OOP`, `PAIRED`, and `COMBO` in addition to the prior
eight terms. No scanner-engine code changed.

## 3. Scope proof

- No glossary UI or tappable-definition UI.
- No route, access, clickability, entitlement, or UI change.
- No new lesson, drill, session, world, or content-family expansion.
- No W11/W12 or W13+ work.
- Modern Table and localization architecture untouched.
- The only content changes are three one-sentence first-use definitions.

## 4. Term ownership results

| Term | First-use source | Definition added | Scanner-owned | False-positive result | Final status |
| --- | --- | --- | --- | --- | --- |
| OOP | W2 s03 session precedes its same-session drill feedback use. | Yes. | Yes. | Exact token has bounded active use; scanner passes. | Owned. |
| Paired board | W2 s04 session precedes W2 s04 texture content and later board drills. | Yes. | Yes, as exact `PAIRED`. | Existing uses are board-texture context; scanner passes. | Owned. |
| Combo | W6 s01 session source. | Yes. | Yes. | Exact `combo` has a bounded current source; ordinary `combination` remains excluded. | Owned. |

## 5. Scanner / validator proof

- Focused scanner tests pass, including the production-contract assertion for
  all first-use learner terms.
- `dart run tools/term_coverage_scanner.dart` passes with eleven owned terms:
  `EQUITY`, `PROBE`, `BLOCKERS`, `OUTS`, `OOP`, `PAIRED`, `SPR`, `ICM`, `EV`,
  `EXPLOIT`, and `COMBO`.
- Existing owned terms continue to pass. No baseline validator residue was
  introduced or repaired outside this slice.

## 6. Deferred / excluded terms

- SB, BB, BTN, CO, and UTG remain contract-only pending a verified Starter/W0
  first-use owner.
- IP remains contract-only because no active `IP` abbreviation is owned.
- Generic `pot` remains excluded because it is too broad for a safe scanner
  token.
- Ordinary `combination` remains excluded; it is not equivalent to the owned
  poker shorthand `combo`.
- M-ratio, variance, and tilt remain deferred.
- W11+ terms remain planned/frontier-only.

## 7. Next recommended wave

`Volume I Surface Contract Implementation v1`

The first-use scanner set now covers the admitted narrow terminology risk, and
the W3/W5 density proof found no drill-expansion blocker. A future surface
implementation may now be evaluated against the existing Volume I status and
copy contracts; it must remain separate from glossary UI, route, and commerce
work.

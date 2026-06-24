# Glossary / Tappable Definition Contract v1

## 1. Verdict

`glossary_contract_ready_with_scanner_recommendation`

The remaining P2 terms merit lightweight reusable support, but no active Act0
tappable-definition owner is admitted. The safe next step is a scanner-only
slice for three bounded terms after their exact first-use paths are confirmed.

## 2. Current term-safety truth

Scanner-owned terms today are `EQUITY`, `PROBE`, `BLOCKERS`, `OUTS`, `SPR`,
`ICM`, `EV`, and `EXPLOIT`. The latest batch repaired first-use ownership for
`OUTS` at W2 s06 and `ICM` at W8 s01.

The remaining candidates are not current P1 defects after that repair. They
need lightweight support because their meaning is not always safely inferable
from a short prompt or a code-style label. M-ratio, variance, tilt, W11-W12,
and W13+ terms remain deferred.

## 3. Candidate term table

| Term | First known active source | Current explanation status | Learner risk | Proposed compact definition | Suggested owner | Scanner-owned now | Tappable later | Priority |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SB | Active seat data; first learner-facing prose unproven in W1-W10 scope. | No owned first-use definition. | Code label is opaque. | `Small blind: the forced bet just left of the dealer button.` | Starter/W0 seat-literacy source must be reconciled first. | No | Yes | P2 |
| BB | Active seat data; first learner-facing prose unproven in scope. | No owned first-use definition. | Code label is opaque. | `Big blind: the larger forced bet that helps start the pot.` | Starter/W0 seat-literacy source must be reconciled first. | No | Yes | P2 |
| BTN | Active seat data; first learner-facing prose unproven in scope. | No owned first-use definition. | Code label can hide positional meaning. | `Button: the dealer position, which acts last after the flop.` | Starter/W0 seat-literacy source must be reconciled first. | No | Yes | P2 |
| CO | Active seat data; first learner-facing prose unproven in scope. | No owned first-use definition. | Abbreviation is not self-explanatory. | `Cutoff: the seat just before the button.` | Starter/W0 or a verified first position source. | No | Yes | P2 |
| UTG | Active seat data; first learner-facing prose unproven in scope. | No owned first-use definition. | Abbreviation is not self-explanatory. | `Under the gun: the first seat to act before the flop.` | Starter/W0 or a verified first position source. | No | Yes | P2 |
| IP | No active `IP` token found; full phrase `in position` is used. | Full phrase is contextual, abbreviation absent. | Do not introduce shorthand merely for support. | `In position means acting after the other player after the flop.` | Verified position session before any abbreviation use. | No | Yes, only if IP is introduced | P2 |
| OOP | W2 s03 drill uses `OOP`; W6 s07 continues it. | Full phrase is also used, but abbreviation has no owned expansion. | Short prompt can be unclear. | `Out of position means acting before the other player after the flop.` | Verify W2 s03 exact learner-visible ordering. | Yes, after first-use verification | Yes | P2 |
| Pot | Repeated active prompts and size language; 331 scoped matches. | Basic meaning is implied, not owned. | Generic word creates scanner false-positive risk. | `The pot is the chips already in the middle of the hand.` | Starter/W0 table-literacy source. | No | Yes | P2 |
| Paired board | W5 s01 paired-texture drill; repeated through W5. | No owned first-use definition. | Texture word changes the decision. | `A paired board has two cards of the same rank.` | W5 s01. | Yes, after first-use definition | Yes | P2 |
| Combo | W6 s01 says `one exact combo`. | No owned first-use definition. | Shorthand is non-obvious. | `A combo is one specific set of hole cards a player can hold.` | W6 s01. | Yes, after first-use definition | Yes | P2 |
| Combination | W2 s10 uses the ordinary phrase `board and draw combination`. | Ordinary-language use; not a poker-combo definition. | Low if left as ordinary language. | No separate definition now. | None. | No | No | Deferred |

## 4. Definition style rules

- Use plain English and one sentence whenever possible.
- Explain the current decision, not the whole poker theory.
- Use no solver/GTO jargon, formulas, mastery language, or commercial language.
- Do not claim guaranteed improvement, premium access, or specialization.
- Prefer a concrete table relationship over a taxonomy definition.
- Never dump a glossary onto the first screen; a definition appears only near a
  term that the learner must understand now.

## 5. Tappable-definition admission rules

A term may become tappable only when all conditions are true:

1. It recurs in active learner-facing text or prompts.
2. Its meaning cannot be safely inferred from the immediate context.
3. The definition directly supports the current decision.
4. It has no route, access, entitlement, premium, or completion implication.
5. An active owner source and first-use order are known.
6. A contract or scanner can prove the exact wording and order.
7. The active Act0 surface owner explicitly admits the interaction; archived
   UIv3 `TermDefinitionOverlay` and the localization editor are not that owner.

## 6. Placement rules

Allowed future placements:

- Lesson/theory text immediately after a verified first use.
- A drill-prompt helper only when the term is required to answer the prompt.
- Compact current-route preview support, never as an availability promise.
- Review explanation support only where the term is already present and the
  explanation is repair-relevant.

Forbidden placements:

- Modern Table chrome.
- Commercial, paywall, trial, purchase, or entitlement surfaces.
- App Store or external packaging.
- Dashboard, XP, streak, mastery, or gamification surfaces.
- W11+ frontier previews unless active source truth is separately admitted.

## 7. Scanner / validator contract

Keep the current scanner narrow: exact token plus exact first-use definition
and curriculum ordering. Do not scan generic `pot`, all seat-code metadata, or
ordinary `combination`; those create false positives and lack verified current
first-use owners.

Recommended next scanner candidates are exactly:

1. `OOP`, after confirming W2 s03 is its first learner-visible abbreviated
   source and adding one first-use definition.
2. `PAIRED`, owned at W5 s01 with a board-rank definition.
3. `COMBO`, owned at W6 s01 with a specific-hole-card definition.

`SB`, `BB`, `BTN`, `CO`, `UTG`, `IP`, and `POT` remain contract-only until a
Starter/W0 or verified active first-use owner is established. Any future
scanner expansion must add focused source-order tests and avoid pattern
normalization broad enough to capture internal metadata accidentally.

## 8. Deferred list

- M-ratio, variance, and tilt.
- W11-W12 planned-foundation terms.
- W13+ frontier/specialization terminology.
- Any term not present in current route-backed learner sources.
- UI/tappable implementation until a current Act0 surface owner and
interaction contract are explicitly admitted.

## 9. Next recommended wave

`Glossary Scanner Tiny Slice v1`

Three bounded P2 terms have plausible active owners and can receive
first-use/scanner proof without UI work: OOP, paired board, and combo. This is
smaller and safer than a prototype because the active learner-facing tappable
surface has not been admitted.

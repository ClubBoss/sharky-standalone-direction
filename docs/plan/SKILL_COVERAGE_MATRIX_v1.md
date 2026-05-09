# Skill Coverage Matrix v1
Status: SSOT-lite
Purpose: Record which required learning skill families are currently covered, partial, missing, or deferred so essential learning content cannot silently fall out of the 10-world path.
Last updated: 2026-03-09

## Use

This document is the in-repo anti-gap reference for learning coverage.
It sits alongside:

- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md`
- `docs/content/CONTENT_SYSTEM_v2.1.md`
- `docs/plan/CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md`
- `docs/plan/MODE_FAMILY_STRATEGY_v1.md`

It does not replace those documents.
It answers a narrower question:

- which essential skill families belong in the long-term system
- where they should likely appear
- whether they are currently covered, partial, missing, or deferred/later

Core rule:

- “Mentioned in architecture” is not the same as “safely covered in product.”
- Future world/node mapping and guards should use this matrix to prevent silent omissions.

## Status Meanings

- `covered`: clearly represented in the current product path or live pilot in a way that already teaches the skill meaningfully
- `partial`: present, but still narrow, pilot-level, or not yet safely scaled
- `missing`: required by the long-term system, but not meaningfully represented yet
- `deferred/later`: intentionally later in the roadmap, not expected to be live now

## Coverage Matrix

| Skill family | Short description | Likely world anchor(s) | Preferred mode families | Current status | Note |
| --- | --- | --- | --- | --- | --- |
| Table / rules literacy | Learn the physical table, card basics, pot, stack, blinds, and the basic shape of play. | World 0, early World 1 onramp | Identify / Locate, Review / Recap | partial | Early live path covers seat/table literacy strongly, but the full World 0 rules/card-ranking system described in architecture is not yet visibly complete. |
| Positions / role recognition | Recognize BTN / SB / BB and late/early seat roles quickly. | World 0, early World 1 | Identify / Locate, Order / Sequence, Review / Recap | covered | This is the strongest live area today through the modernized Act0 seat-quiz class. |
| Action order / street transitions | Understand who acts next and how the sequence changes across preflop/flop/turn/river. | World 0, World 1 | Order / Sequence, Review / Recap | partial | Action order and street-flow anchors are live in Act0, but full cross-street transition logic is still narrow. |
| Hand strength / showdown comparison | Compare holdings and know what actually wins at showdown. | World 2, World 3, World 5 | Hand Strength / Showdown Comparison, Review / Recap | partial | A bounded World 2 showdown bridge slice is now live on the session-drill surface, but the family is not yet scaled as a full mainline world layer. |
| Initiative / aggressor logic | Track who drove the action and how initiative changes the next decision. | Worlds 2–5 | Identify / Locate, Classifier, Review / Recap | partial | A bounded World 2 initiative bridge slice is now live on the session-drill surface, but the family is not yet scaled as a full mainline world layer. |
| Action choice | Choose between fold / call / check / bet / raise with one compact local reason. | Worlds 1–4 | Action Choice, Review / Recap | partial | Live on campaign-spine and related surfaces, but not yet broadly scaled as a complete family across the roadmap. |
| Bet sizing purpose | Connect sizes to goals such as keeping weaker hands in, balanced value, pressure, and minimal reopen. | World 4, later review surfaces | Bet Sizing Choice, Review / Recap | partial | Live as a visible `w1.s01` betting-choice pilot mini-cluster with intro + drills + recap, but still pilot-surface only. |
| Board texture / spot classification | Recognize dry/wet boards, board connection, and broad spot types. | World 5, World 6 | Classifier, Explain the Why, Review / Recap | missing | Intended by architecture and mode strategy, but not yet meaningfully surfaced. |
| Draws / outs / improvement counting | Count improvement paths and understand simple draw pressure. | World 5, World 6 | Outs / Improvement Counting, Review / Recap | missing | Explicitly part of future canon and must be preserved, but not currently covered. |
| Equity / pot-odds intuition | Build intuitive feel for whether continuing is worth the price. | World 4, World 7, World 8 | Equity / Pot-Odds Intuition, Action Choice, Bet Sizing Choice | missing | Architecture and strategy preserve this family, but it is not safely represented in current product. |
| Fold discipline / dominated-hand awareness | Learn that not every hand deserves play and avoid obvious dominated trouble. | World 1 | Action Choice, Review / Recap | partial | The architecture assigns this to World 1, but the current visible World 1 live path is still earlier literacy/onramp work rather than a full discipline path. |
| Position thinking (IP vs OOP) | Understand that the same hand changes value depending on position. | World 2 | Identify / Locate, Order / Sequence, Review / Recap | partial | A bounded World 2 position bridge slice is now live on the session-drill surface, but the family is not yet scaled as a full mainline world layer. |
| Preflop framework / hand categories | Learn structured open / call / fold logic without charts. | World 3 | Action Choice, Classifier, Review / Recap | missing | Present in architecture, not yet represented as a mature live family. |
| Stack depth logic | Understand how 100bb vs 20bb changes decisions. | World 7 | Classifier, Action Choice, Explain the Why | deferred/later | Explicit future world, not expected to be live yet. |
| Tournament pressure / ICM intuition | Understand survival pressure, bubble pressure, and risk premium intuitively. | World 8 | Classifier, Action Choice, Explain the Why | deferred/later | Explicit future world, not expected to be live yet. |
| Real-player adjustment / exploit-lite | Adjust to loose/tight and passive/aggressive opponents without solver framing. | World 9 | Classifier, Mixed Challenge, Transfer / Real Table Application | deferred/later | Explicit future world, not expected to be live yet. |
| Review / correction / recap | Revisit mistakes, reinforce cluster ideas, and close loops cleanly. | Cross-world, especially World 1 onward | Review / Recap | covered | Review queue, recap behavior, and bounded intro/drill/recap patterns are already live on key surfaces. |
| Transfer to real play | Push learned patterns into lightweight real-table observation or application tasks. | Worlds 4+ | Transfer / Real Table Application, Review / Recap | deferred/later | Explicitly part of the architecture/content canon, but not yet a live system layer. |

## Practical Read Of Current State

What is strongest right now:

- positions / role recognition
- action order / sequence basics
- review / correction / recap
- the bounded bet-sizing pilot family

What is visibly present but not yet safely broad:

- action choice
- bet sizing purpose
- early World 1 discipline themes
- World 2 position-thinking intent

What remains the biggest anti-gap risk:

- hand strength / showdown comparison
- board texture / spot classification
- draws / outs
- equity / pot-odds intuition
- initiative / aggressor logic

These must remain explicit in future planning and must not vanish simply because the current live app is strongest in early table/order/action work.

## How To Use This Matrix In Future Work

Before expanding a world, node, or mode family:

1. identify which skill family the work serves
2. check this matrix for current coverage state
3. update the world/node plan intentionally rather than assuming the skill is already covered
4. add guards or truth-map notes if a family becomes live or moves from partial to covered

When planning the later unified world/node matrix:

- use this document as the anti-gap layer
- ensure each major skill family has an intended home
- ensure “deferred/later” items stay visible instead of disappearing from the roadmap

## Near-Term Implication

Near-term rollout should prioritize:

- strengthening current `partial` families into stable coverage
- protecting currently `missing` but essential families from roadmap drift
- using this matrix together with the mode-family strategy and truth-map/guard layers before broad world fill begins

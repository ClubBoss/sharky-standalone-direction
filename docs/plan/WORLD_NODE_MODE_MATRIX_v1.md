# World/Node Mode Matrix v1
Status: SSOT-lite
Purpose: Bridge high-level world architecture to actual exercise rollout by recording which worlds/nodes should teach which skill families through which preferred mode families.
Last updated: 2026-03-09

## Use

This document sits between:

- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md`
- `docs/content/CONTENT_SYSTEM_v2.1.md`
- `docs/plan/MODE_FAMILY_STRATEGY_v1.md`
- `docs/plan/SKILL_COVERAGE_MATRIX_v1.md`
- current truth-map / audit work

It does not replace runtime truth.
It answers a narrower planning question:

- where each major skill family should live
- which world/node family should carry it
- which mode families fit that node best
- what the current rollout reality is

Core rule:

- this matrix is the bridge between high-level world architecture and actual exercise rollout
- future guards should validate missing or invalid mappings
- future fill work should use this matrix to decide what gets added where

## Status Meanings

- `live`: clearly represented on a reachable production path
- `pilot`: represented on a bounded pilot or secondary surface
- `partial`: structurally present, but still narrow, coarse, or not yet scaled
- `placeholder`: structurally reserved but not yet meaningfully implemented
- `missing`: should exist here eventually but does not meaningfully exist yet
- `deferred/later`: intentionally later in roadmap timing

## Matrix

| World / node family | Intended cognitive role | Target skill families | Preferred mode families | Current status | Current reality / next gap |
| --- | --- | --- | --- | --- | --- |
| World 0 core ladder | Remove fear and basic table confusion. Establish first orientation on the table. | Table / rules literacy, positions / role recognition, basic action order, card ranking, hand combinations, stack / pot literacy | Identify / Locate, Order / Sequence, Review / Recap | live | The distinct World 0 ladder is now explicit as a visible session-drill world with authored sessions, governed repair routing, projection-backed representative surfaces, and screenshot-backed evidence. Remaining work is release-grade pedagogical finish, not world absence. |
| World 1 Act0 seat-quiz trio (`table_literacy`, `action_literacy`, `street_flow`) | Build fast table orientation and ordered table flow on a live table surface. | Positions / role recognition, action order / street transitions, table literacy anchors | Identify / Locate, Order / Sequence, Review / Recap | live | This is the strongest live class today. All three Act0 campaign hosts are now modernized on the same central seat-quiz smart-learning seam. |
| World 1 campaign spine (`world1_spine_campaign_v1`) | Move from recognition into real decision discipline with compact action reasoning. | Fold discipline / dominated-hand awareness, action choice, early hand discipline | Action Choice, Review / Recap | partial | The spine is live and reachable, but World 1 as a full hand-discipline world is still broader than the current live slice. |
| World 1 followup family (`b0/b1/b2`) | Reinforce and extend the first decision layer without leaving the main campaign path. | Action choice reinforcement, compact review / correction / recap | Action Choice, Review / Recap | partial | Followups are live in topology and runner coverage, but still function more like continuation slices than a fully mature world-scale discipline system. |
| World 1 session-drill pilot (`w1.s01` betting cluster) | Prove one compact repeatable mode family off the main campaign path. | Bet sizing purpose, compact review / recap | Bet Sizing Choice, Review / Recap | pilot | Visible intro + drills + recap are live, but still on the session-drill surface rather than the main campaign path. |
| World 2 core node family | Teach that position changes hand value and decision quality, with hand-strength comparison as the first bridge. | Hand strength / showdown comparison, position thinking (IP vs OOP), initiative / aggressor logic foundations, action choice | Hand Strength / Showdown Comparison, Identify / Locate, Order / Sequence, Classifier, Review / Recap | partial | Bounded showdown, position, and initiative bridge slices are now live on `w2.s01`, `w2.s02`, and `w2.s03`, but the fuller World 2 node family is still coarse relative to World 1. |
| World 3 core node family | Build structured preflop framework without chart-dependence. | Preflop framework, hand categories, open / call / fold logic, hand strength / showdown comparison foundations | Action Choice, Classifier, Review / Recap | missing | Architecture is explicit, but current runtime/node detail is not yet represented beyond coarse scaffold structure. |
| World 4 core node family | Teach bet purpose and basic price intuition as a mainline competency. | Bet sizing purpose, equity / pot-odds intuition foundations, action choice refinement | Bet Sizing Choice, Action Choice, Review / Recap | partial | This is partially de-risked by the visible bet-sizing pilot, but the main campaign/world implementation is not yet present. |
| World 5 core node family | Shift attention from private hand to board state. | Board texture / spot classification, draws / outs / improvement counting, hand strength / showdown comparison, street transition logic | Classifier, Outs / Improvement Counting, Review / Recap | missing | The architecture is clear, but there is no meaningful live board-awareness world layer yet. |
| World 6 core node family | Introduce scaffolded range thinking without solver language. | Range construction lite, board texture / spot classification, initiative / aggressor logic, explain-the-why reasoning | Classifier, Explain the Why, Multi-step Chain | deferred/later | World 6 is explicitly scaffolded in architecture and should remain visible as later planned work, not silently disappear. |
| World 7 core node family | Teach stack depth as a strategic variable. | Stack depth logic, action choice adjustment, equity / price intuition under stack change | Classifier, Action Choice, Explain the Why | deferred/later | Explicit future world; not expected to be live now. |
| World 8 core node family | Teach tournament pressure and intuitive ICM-adjacent reasoning. | Tournament pressure / ICM intuition, stack depth logic, action choice under survival pressure | Classifier, Action Choice, Explain the Why, Review / Recap | deferred/later | Explicit future world; not expected to be live now. |
| World 9 core node family | Teach population adjustment and real-player reasoning. | Real-player adjustment / exploit-lite, error spotting / leak detection, transfer to real play | Classifier, Mixed Challenge, Transfer / Real Table Application, Explain the Why | deferred/later | Explicit future world; not expected to be live now. |
| Cross-world review / recap layer | Reinforce and resurface mistakes across the ladder. | Review / correction / recap, compact reinforcement, bounded resurfacing | Review / Recap | live | Review queue and recap surfaces are already live and should remain a reusable cross-world layer. |
| Cross-world transfer layer | Push learned patterns into real-table observation and application. | Transfer to real play, initiative / aggressor observation, board / sizing observation | Transfer / Real Table Application, Review / Recap | deferred/later | Architecture/content canon requires this eventually, but it is not yet a live product layer. |

## Practical Read Of Current Placement

What is already concretely placed:

- World 1 Act0 seat-quiz class as the strongest live recognition/sequence layer
- World 1 spine/followups as the current live decision layer
- session-drill `w1.s01` as the current visible bet-sizing pilot placement
- cross-world review/recap as a reusable current layer

What is still only coarsely placed:

- Worlds 2–4 as meaningful cognitive worlds with strong intended roles, but not yet fully specified node families in runtime reality

What is still only architecture-level placement:

- Worlds 5–9
- transfer-to-real-play layer
- later range / stack / tournament / exploit-lite families

## How To Use This Matrix

Before adding or upgrading a node:

1. identify the target world/node family in this matrix
2. confirm the skill family belongs there
3. choose from the preferred mode families instead of inventing a one-off format
4. update truth-map status and guards when the node moves from placeholder/partial to live or pilot

Before broad world fill:

- use this matrix with the skill coverage matrix
- ensure each missing skill family has a concrete world/node home
- keep coarse worlds coarse until there is enough detail to place nodes honestly

## Near-Term Implication

Near-term work should favor:

- strengthening World 1 spine/followup placement for hand-discipline and action-choice work
- deciding how World 2 position-thinking nodes will map onto the curated mode families
- using the World 4 slot intentionally for eventual promotion of bet-sizing from pilot to mainline world coverage

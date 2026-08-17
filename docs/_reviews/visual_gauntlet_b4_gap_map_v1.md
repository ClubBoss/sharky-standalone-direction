# VISUAL GAUNTLET B4 — GAP MAP v1

Mission: `VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1`
Starting live `origin/main`: `da5115b3779a46eaa55275768ed9f16f1b1d782d`
(contains B3 integrated main `19f97534`, B3 = `CLOSED_PASS`)
Branch: `feat/visual-gauntlet-b4-object-attached-hud-v1`
Primary viewport: `402x874`.
Produced BEFORE any production mutation, from the merged B3 render.

## 0. What B3 left behind

Read from live source and the merged B3 capture.

The seat HUD is `_SeatNodeV1`: a dark rounded pill carrying a **generic person
icon** plus a position label, sitting on the felt below the seat's cards. Blind
commitments are `_BetChipPlacementV1`, placed from the legacy `chipSlots` ring
near the middle of the cloth.

Two things are now actively wrong rather than merely unfinished:

1. B3 put a **real person** at every seat. A generic avatar glyph beside a
   drawn player is redundant, and it is the single most app-like mark left in
   the scene.
2. B1 defined `betAnchor` precisely so commitments could belong to their owner.
   Nothing consumes it — bets still sit mid-felt, so the learner has to map a
   floating chip back to a player by position.

| Element | Current | Reading |
| --- | --- | --- |
| Identity plate | pill + person icon + position | floats on cloth; avatar duplicates the B3 figure |
| Stack | `seat.stackLabel` exists, shown conditionally | present in data, not owned by the player volume |
| Position | inside the same pill | reads as a UI tag, not table metadata |
| Dealer | generic `D` pill | screen UI, not a puck on the cloth |
| Bet / blinds | `chipSlots`, mid-felt | **`betAnchor` unused**; commitment not attached to its owner |
| Acting / eligible | ring + colour on the pill | lives on the label, not on the player's local object |
| Depth | plates identical at every seat | no depth scaling; far plate as heavy as near |
| Hero HUD | `You/BTN` plate | already near-plane, but same floating treatment |

## 1. Gap map — required classification

| # | Item | Class | Finding |
| --- | --- | --- | --- |
| 1 | Identity attachment | `B4` | **largest gap.** Generic avatar glyph beside a real B3 player; plate floats free of the seat volume. |
| 2 | Stack attachment | `B4` | data exists; presentation is not player-local. |
| 3 | Position attachment | `B4` | reads as a UI tag rather than table metadata. |
| 4 | Dealer attachment | `B4` | generic pill; should be a puck belonging to the cloth. |
| 5 | Bet ownership | `B4` | `betAnchor` defined in B1 and consumed by nothing. |
| 6 | Blind ownership | `B4` | same root cause as bets. |
| 7 | Acting-state ownership | `B4` | carried by label colour, not by the player's local object. |
| 8 | Active/inactive/folded ownership | `PARTLY STRONG` | B3 posture already carries this on the figure; B4 must not contradict it. |
| 9 | Eligible/tappable ownership | `ALREADY STRONG` | selectable seats read clearly; **must not regress** — this is interaction truth. |
| 10 | Hero HUD ownership | `B4` | correct plane from B1/B3, still a floating card treatment. |
| 11 | Feedback clue attachment | `B4` | Wave A already names the causal object in copy; the mark can sit closer to it. |
| 12 | HUD / character collisions | `RISK — B4 must manage` | plates sit directly under B3 figures; heavier plates would crowd them. |
| 13 | HUD / cards collisions | `RISK — B4 must manage` | blind chips already sit close to the board; moving them must not cover ranks. |
| 14 | HUD / table readability | `B4` | plates are flat app surfaces on a now-premium cloth. |
| 15 | Depth scaling | `B4` | no depth response at all; B1 `plateScale` exists and is unused here. |
| 16 | Far-seat legibility | `RISK — B4 must manage` | depth scaling must not push far labels below legibility. |
| 17 | Near-seat clutter | `RISK — B4 must manage` | near seats carry figure + plate + chips + cards. |
| 18 | Learning hierarchy risk | `RISK — B4 must manage` | nothing may obscure cards, board, pot, tappable seats, clue, actions or feedback. |

### Explicitly NOT B4

| Gap | Class |
| --- | --- |
| Attention-aware rendering, selective focus, depth of field | `DEFERRED B5` |
| Chip flight, plate reveal, any motion program | `DEFERRED B6` |
| Final parity, costume richness, table oval identity | `DEFERRED B7` |

Table oval residual debt stays `DEFERRED_TO_B7` and is not touched.

## 2. Largest class-level B4 gap

**Information does not belong to its owner.** Identity floats beside the player
instead of on them, and commitment floats mid-cloth instead of in front of the
player who made it — with the anchor for exactly that already defined in B1 and
consumed by nothing.

## 3. Iteration plan

1. **Iteration 1 — player-local identity ownership.** Nameplate becomes an
   engraved plate belonging to the seat, depth-scaled via B1 `plateScale`, with
   the generic avatar glyph removed now that a real player occupies the seat.
   Dealer becomes a puck on the cloth.
2. **Iteration 2 — commitment and state attachment.** Bets and blinds move onto
   B1's `betAnchor` so they sit in front of their owner; acting/eligible state
   becomes a property of the player's local object; hero HUD joins the same
   language.

## 4. Protected foundation

Unchanged: B1 planes, perspective, seat slots and all four anchors; B2 table
material, room and shared lighting; B3 characters, postures and hero
embodiment; Wave A learning hierarchy, interaction grammar, answer truth,
evaluation, feedback, causal clue, repair/recheck, continuation, telemetry,
accessibility, responsive support. No poker truth or calculation changes.

`HUMAN_PROOF = FALSE`

---

# B4 EXECUTION RESULT

## Iterations

| # | Class-level problem | Outcome |
| --- | --- | --- |
| 1 | Identity does not belong to the player | Engraved nameplate set into the surface; generic avatar glyph dropped now that B3 draws a real person |
| 2 | Commitment reads as an app card | Same engraved carrier as the nameplate; frosted-glass backdrop blur removed |

## HUD system

`lib/ui_v2/act0_shell/act0_scene_hud_v1.dart` — `Act0SceneNameplateV1`:
recessed fill the surface reads through, a dark top edge where the surface
steps down, a lit lower lip on the same lamp as B2's rail crown, and a contact
shadow instead of a glow. Existing seat visual state is passed straight through
as `stateTone`, so selectable / focus / hero semantics keep their exact meaning
and gain a physical carrier.

## What I got wrong, and how the repository caught it

The gap map claimed bets "float mid-felt" and that wiring B1's unused
`betAnchor` would attach them to their owner. Both halves were wrong:

1. Wave A's informative-object guard rejected the reposition **twice**. There is
   no offset from `betAnchor` that clears both the seat's own card+plate column
   and the board panel at `402x874`.
2. Measured baseline bounds show the legacy ring already seats each chip
   immediately beside its owner — `bb` seat `x82-150`, `bb` chip `x122-166`.

Chip placement was reverted to exactly what Wave A validated, and the B1
`betAnchor` definition restored untouched. The real gap was treatment, not
position.

## Foundation preservation

Across all 8 captured states, B3 baseline vs B4 candidate: table geometry
identical, action envelope top identical, informative-object collision guard
clean, tappable objects `9 -> 9`, six seat anchors intact, zero overflow. B1
planes/perspective/anchors, B2 material/room/light and B3 characters/postures
are untouched. Table oval debt untouched, still `DEFERRED_TO_B7`.

Interaction truth explicitly preserved: the selectable touch glyph and the
empty-seat mark were **not** removed with the avatar glyph.

## Honestly not done

Two admitted B4 sub-items were not reached inside the usage window and are not
claimed:

- **§7.4 dealer ownership** — the dealer marker is still the generic `D` pill;
  it did not become a puck belonging to the cloth.
- **§7.5 learning-clue attachment** — Wave A copy still names the causal object;
  no additional spatial attachment was added.

Stack presentation was also left as Wave A renders it, deliberately: changing
which seats surface a stack would alter displayed information rather than its
ownership.

`HUMAN_PROOF = FALSE`

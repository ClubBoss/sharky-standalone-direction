# VISUAL GAUNTLET B3 — GAP MAP v1

Mission: `VISUAL_GAUNTLET_B3_PLAYER_EMBODIMENT_V1`
Starting live `origin/main`: `13f33b0c97d95ea72872bcdb8bf509078dac96cb`
(contains B2 integrated main `dcb8baa3`, B2 = `CLOSED_PASS`)
Branch: `feat/visual-gauntlet-b3-player-embodiment-v1`
Primary viewport: `402x874`.
Produced BEFORE any production mutation, from the merged B2 render.

## 0. What B1/B2 actually left behind

Read from live source and the merged B2 capture, not from memory.

The player volume is `_Act0SceneCharacterVolumePainterV1`: a rounded-rect chair,
a capsule for shoulders, a circle for a head, three flat navy tones, plus a rim
arc. B1 shipped it deliberately as reserved space; B2 wired it to the shared
key light. Nobody has yet drawn a person.

At 402x874 the far/mid volumes render at roughly 60-70 px tall against a lit
wall of nearly the same value, so they read as furniture — or as nothing.

| Property | Current | Reading |
| --- | --- | --- |
| Silhouette | circle + capsule + rounded rect | precisely the "circles with shoulders" the acceptance bar rejects |
| Arms | none | the single strongest seated-player cue is absent |
| Value vs room | `_body 0xFF28405F` against a wall lit to `0xFF244B6E` | almost no figure-ground separation |
| Differentiation | one painter, one shape, every seat | identical mannequins |
| Posture | none | no body language, so no life |
| State | `active` toggles opacity only | folded vs in-hand is not embodied |

## 1. Gap map — required classification

| # | Item | Class | Finding |
| --- | --- | --- | --- |
| 1 | Human recognizability | `B3` | **largest gap.** No head/neck/shoulder/arm relationship; nothing reads as a person. |
| 2 | Player family language | `B3` | does not exist. One primitive shape repeated six times. |
| 3 | Far-player scale/readability | `B3` | scale from B1 is correct; readability fails on value separation against the B2 lit wall. |
| 4 | Mid-player scale/readability | `B3` | same: geometry fine, contrast absent. |
| 5 | Near-player cropping | `ALREADY STRONG` | B1 crops near volumes at the screen edge correctly; keep. |
| 6 | Hero embodiment | `B3` | B1/B2 hero foreground is a rim-lit mass with no arms and no relationship to the hero's cards. |
| 7 | Rail/player occlusion | `ALREADY STRONG` | B1 plane order already has the rail cutting the volumes. B3 must place arms so the cut reads as forearms on the rail. |
| 8 | Seat ownership | `B3` | figures are not visibly bound to their seat; they float behind it. |
| 9 | Active/inactive/folded | `B3` | opacity only. Posture should carry it where existing semantics already expose folded/in-hand. |
| 10 | B2 lighting integration | `B3` | rim colour is wired, but the figure has no form for light to describe. |
| 11 | Player differentiation | `B3` | zero. Six identical mannequins is an explicit reject condition. |
| 12 | HUD-anchor compatibility | `ALREADY STRONG` | `plateAnchor` / `betAnchor` / `cardAnchor` unchanged and unobstructed; B3 must not move them. |
| 13 | Visual clutter | `RISK — B3 must manage` | six figures plus plates plus chips can crowd the rail. Far detail must stay low. |
| 14 | Learning hierarchy risk | `RISK — B3 must manage` | figures must never obscure hole cards, board, pot, bets, tappable seats, clue, actions or feedback. |

### Explicitly NOT B3

| Gap | Class |
| --- | --- |
| Stacks/bets/position plates bound to the B1 anchors | `DEFERRED B4` |
| Attention-aware rendering, selective focus, depth of field | `DEFERRED B5` |
| Semantic motion, chip flight, seat reveal, camera moves | `DEFERRED B6` |
| Final parity, richer room detail, table oval identity refinement | `DEFERRED B7` |

Table oval residual debt stays `DEFERRED_TO_B7`. B3 touches the silhouette only
if rendered embodiment proves a causal placement/occlusion blocker.

## 2. Largest class-level B3 gap

**Nothing reads as a person.** Items 2, 8, 9 and 11 are all downstream of item 1:
a family language, seat ownership, state posture and differentiation are all
expressed *through* a human silhouette that does not currently exist.

## 3. Approach chosen, and why

**Procedural original vector silhouettes**, not raster assets.

The admission permits assets. At the scale that actually ships here — figures
60-110 px tall on a phone — assets buy detail the viewer cannot resolve while
costing an asset pipeline, licence surface, and a fixed lighting bake that would
fight B2's runtime key light. Vector figures are resolution-free across all four
responsive profiles, take zero new dependencies, and can be lit at runtime by
`Act0SceneLightV1`, which is the thing that makes them belong to the room.

Priority order per the admission: silhouette > body language > depth > lighting
> differentiation > facial detail. **No faces are drawn at all.** At far/mid
scale a face is 6-8 px and can only become noise; identity comes from silhouette
and posture instead.

The visual language, Sharky's own:

- **Figure-ground by value.** Far and mid players are dark silhouettes read
  against B2's lit wall; near players lift slightly as they approach the lamp.
  This uses the B2 room rather than fighting it.
- **Arms are the cue.** Upper arms angle down-forward into forearms that rest on
  the rail. B1's existing rail occlusion then reads as hands on the rail, which
  is what says "seated at this table" more than any head shape.
- **Facing.** Each figure turns toward the pot, derived from its own seat anchor.
- **Four archetypes** (shoulder width, head mass, hair silhouette, lean),
  assigned deterministically from `seatId` so a seat's occupant is stable across
  frames, states and captures.
- **Posture carries state.** In-hand: upright, forward, hands on rail. Folded:
  leaned back, arms down, further into the room haze.

New module `lib/ui_v2/act0_shell/act0_scene_player_v1.dart`. B1 geometry and B2
material are imported, never replaced.

## 4. Protected foundation

Unchanged: `environment -> farPlayer -> table -> nearPlayer -> overlay`; B1
perspective model, seat slots, `characterAnchor` / `plateAnchor` / `betAnchor` /
`cardAnchor`, hero zone; B2 table material, room and shared lighting; Wave A
learning hierarchy, interaction grammar, answer truth, feedback, repair/recheck,
continuation, telemetry, accessibility, responsive support.

`HUMAN_PROOF = FALSE`

---

# B3 EXECUTION RESULT

Branch: `feat/visual-gauntlet-b3-player-embodiment-v1`

## Iterations

| # | Class-level problem | Outcome |
| --- | --- | --- |
| 1 | Nothing reads as a person | Four-archetype vector family: head/shoulder silhouette in one filled path, single near arm into the rail cut, near-black against B2's lit wall |
| 2 | Hero not embodied | Learner joins the same family: same silhouette, same key light, forearms on the cloth routed clear of every learning object |

## Player system

- `Act0ScenePlayerArchetypeV1` — four builds varying shoulder span, head mass,
  hair silhouette, shoulder slope and lean. Assigned by a **stable** seat-id
  hash, because `String.hashCode` is not reproducible across runs and evidence
  captures must be.
- `Act0ScenePlayerPostureV1` — `inHand` / `folded`, driven only from seat
  semantics Wave A already exposes.
- `Act0ScenePlayerFigureV1` / `Act0ScenePlayerLayerV1` — replaces B1's
  `Act0SceneVolumeLayerV1`. Placement, ordering and anchors come from B1.
- `Act0ScenePlayerHeroV1` — the learner, same family, arms routed outside the
  hero card lane, identity plate and dealer button.

**No faces are drawn.** At 60-110 px a face is six pixels of noise; identity is
carried by silhouette and posture, which is the priority order the admission
sets.

## Three self-rejections in loop

1. A rounded-rect chair wider than the player became the dominant shape — the
   figure read as furniture. Chair removed entirely.
2. Two symmetric arms made figures read frontally, and the outer arm swept
   *away* from the table. Replaced with a single near arm reaching to the pot.
3. Figure value at `0x1A2C46` against a `0x244B6E` lit wall gave almost no value
   step, so no silhouette read. Pushed to near-black with the key-light rim
   carrying the form.

A fourth on the hero: arms at `h*0.30` read as black blobs and one sat on the
dealer button.

## Foundation preservation audit

Measured across all 8 captured states, B2 baseline vs B3 candidate:

| Contract | Result |
| --- | --- |
| Plane order `environment -> farPlayer -> table -> nearPlayer -> overlay` | preserved |
| B1 perspective model | unchanged |
| Seat slots and identities | six, unchanged |
| `plateAnchor` / `betAnchor` / `cardAnchor` | unchanged |
| `characterAnchor` | tightened by B3 to close a figure-to-rail gap (B3 owns rail occlusion) |
| B2 table material, room, shared lighting | unchanged |
| Table width/height and position | identical in all 8 states |
| Action envelope top | identical in all 8 states |
| Collision guard / overflow / tappable objects | clean / none / `9 -> 9` |

## Honest residual assessment

The figures read as silhouetted people seated at and occluded by the rail, and
they are differentiated. They remain **restrained** — dark rim-lit silhouettes
rather than fully rendered characters. Against the admission's ambition of one
of the largest perceptual jumps in the Gauntlet, this lands as a solid but not
dramatic step. Costume, prop and value-range richness is the honest remaining
gap and belongs to `B7` parity work.

## Deferrals

`B4` object-attached HUD, `B5` attention-aware rendering, `B6` motion, `B7`
final parity. Table oval identity refinement stays `DEFERRED_TO_B7` — rendered
embodiment surfaced no causal placement or occlusion blocker.

`HUMAN_PROOF = FALSE`

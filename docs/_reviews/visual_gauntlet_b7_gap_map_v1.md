# VISUAL GAUNTLET B7 — GAP MAP + ITERATION 1 LEDGER v1

Mission: `VISUAL_GAUNTLET_B7_BENCHMARK_COHESION_AND_POLISH_V1`.
Starting live `origin/main`: `ef0312688739edea8c74410a25f038682cc8e1e7`.
Required viewports: `375x812`, `402x874`, `430x932`.
`TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE`.
`HUMAN_PROOF = FALSE`.

Core rule for this wave: **the poker scene owns the screen; app chrome does
not.** Every claim below is a measured rect from the real canonical route
(`world_1 / fold_check_call_raise / actions_check_drill`), driven by real taps,
never by direct state mutation.

## 0. Method

CP0 was not a visual opinion pass. Two instruments were used:

1. `tools/act0_b7_cohesion_capture_v1.dart` — settled-endpoint rasters of the
   five canonical states across the three required viewports. Reuses the B6
   harness pattern rather than adding a second capture architecture.
2. A throwaway geometry probe printing the exact `Rect` of every scene object
   at every endpoint, plus automatic overlap assertions.

The probe is what made the difference. Three of the defects below are invisible
to a static screenshot read and only became actionable as numbers.

## 1. CP0 unified gap map

Post-B6 main, canonical `402x874`, measured not asserted.

| # | Audit item | Measured finding | Class |
| --- | --- | --- | --- |
| 1 | top instructional chrome | app bar 38px + guide 79px = 117px (13.4%); guide carries a 30px circular icon badge whose 40px column squeezes the headline | `ITERATION_1_CODE_FIX` |
| 2 | scene/table perceptual ownership | felt 263x451 in decision, 278x476 in feedback; capped by `allocation.tableHeight`, not by need | `ITERATION_1_CODE_FIX` |
| 3 | table oval identity | tall rounded stadium; reads poker-like once the centre is cleaned | `EVALUATE_AFTER_COMPOSITION` |
| 4 | centre dark frame | `act0_shell_center_info_card` = 182x133 panel: fill + border + drop shadow + 8px `BackdropFilter`. **This is the "app card inside a poker table" perception, confirmed.** | `ITERATION_1_CODE_FIX` |
| 5 | board hierarchy | board is 103px inside a 182px panel — framed by chrome rather than owning the felt | `ITERATION_1_CODE_FIX` |
| 6 | pot hierarchy | tinted app pill + meaningless `casino_rounded` dice glyph, same weight as everything else | `ITERATION_1_CODE_FIX` |
| 7 | street label | gold pill + border + `layers_rounded` glyph, competing with the clue chip directly above it | `ITERATION_1_CODE_FIX` |
| 8 | clue (`No bet yet`) | semantics correct; carries a standing decorative bloom that B5/B6 emphasis does not need | `SEMANTIC_GATE` + `ITERATION_1_CODE_FIX` (treatment only) |
| 9 | blind/bet/board legibility | **defect proven.** SB and BB chips overrun the first board card in **20 of 20** state x viewport combinations | `ITERATION_1_CODE_FIX` |
| 10 | hero-to-table relationship | intact | `ALREADY_GOOD` |
| 11 | lower feedback surface | **~86px of dead mass** between the outcome line and the CTA | `ITERATION_1_CODE_FIX` |
| 12 | action/continuation dock | decision dock intrinsic-bound and correct; feedback dock pinned oversized | `ITERATION_1_CODE_FIX` (feedback only) |
| 13-17 | decision / correct / wrong / repair / recheck | no state-specific defect beyond 11-12 | — |
| 18-20 | 375 / 402 / 430 viewports | item 9 present at all three | `ITERATION_1_CODE_FIX` |
| 21 | text scale | superseded mid-wave by `SINGLE_CANONICAL_PRODUCT_SCALE`; runtime enforcement now required | `ITERATION_1_CODE_FIX` |
| 22 | safe area | no double reservation found | `ALREADY_GOOD` |
| 23 | deterministic endpoints | stable across repeated runs | `ALREADY_GOOD` |
| 24 | inherited reduced-motion debt | owner identified; Iteration 1 does not touch it | `DEFER_TO_POST_B7_PRE_P02_MAINTENANCE` |

Explicitly **not** created as work: seat plates, dealer puck, hero cards, rail,
lighting, room plane, B5 recession, B6 motion. They were audited and left alone.

## 2. Root causes, not symptoms

Three findings share one cause each, and fixing the cause fixed the class.

### 2.1 The centre was a card

`_CenterPotV1` wrapped board, clue, street and pot in a decorated panel with a
backdrop blur. Felt does not refract, and a poker table has no card in the
middle of it. Every "too much app UI" symptom in the centre traced here.

### 2.2 The feedback dock was allocated, not measured

`learningSceneLowerFloor` is 132px for review/feedback states, and the dock's
content is one eyebrow, one line and a 48px CTA. But `tableHeight` was capped by
`allocation.tableHeight`, so the leftover fell into the dock as void:

```
feedback @402:  maxH 744  boundedLowerHeight 134  actual dock 218   -> 84px dead
```

The table was not too small. The dock was holding space it did not own.

### 2.3 The blind lane closes as the viewport shrinks

The board row is a **fixed 103px** while the table scales with the viewport, so
each side lane is `(feltWidth - 103) / 2`:

| viewport | felt width | side lane | widest blind chip | verdict |
| --- | --- | --- | --- | --- |
| 430x932 | 288.9 | 92.9 | 70.8 | fits |
| 402x874 | 264.2 | 80.6 | 70.8 | fits |
| 375x812 | 227.2 | **62.1** | **70.8** | **cannot fit** |

This is why a pure offset could never close compact: the object was wider than
the space. Padding/glyph/gap trimming recovers only ~7px of the needed 9.4px,
and shrinking the amount text puts real poker information under the legibility
floor.

The fix was to stop laying the chip out lengthwise. The glyph moved above the
amount, so chip width became `max(element)` instead of `sum(elements)`:

```
"0.5 BB"   70.8px -> 55.8px
"1 BB"     56.3px -> 41.3px
```

Same engraved carrier, same bet-kind colour, same glyph, same amount, same
owner, same key, same anchor family, and the **same form at every viewport** —
no compact special case. A chip stack labelled underneath is if anything the
more physical reading.

## 3. Iteration 1 change set

| Change | Owner | Nature |
| --- | --- | --- |
| centre panel dissolved (fill, border, shadow, `BackdropFilter`) | `_CenterPotV1` | treatment |
| street pill -> incised letterspaced mark, `layers_rounded` removed | `_CenterStreetStatusV1` | treatment |
| pot -> engraved B4 nameplate carrier, dice glyph removed, type up | `_CenterPriorityStatV1` | treatment |
| standing clue bloom removed | `_CenterSignalAnchorV1` | treatment |
| guide icon badge removed, padding tightened | `Act0LearningSceneGuideV3` | chrome |
| feedback states claim the dock surplus | runner allocation | composition |
| bet chip restacked vertically | `_BetChipV1` | object footprint |
| blind slots re-centred in the reopened lane | `_chipSlotsForVariant` | local offset |
| single canonical text scale enforced | `Act0ShellPreviewScreenV1` | policy |

**No** poker truth, evaluation, answer IDs/order, repair/recheck progression,
telemetry semantics, learning state, curriculum, or route was touched.

## 4. Protected contracts held

- `No bet yet` availability is **unchanged**. Only its bloom was removed. No
  phase gating, no removal, no semantic edit — the `SEMANTIC_GATE` was not
  opened, because nothing required opening it.
- B4 bracket, clue key, and clue text unchanged; B5 recession and B6
  interpolation untouched.
- Chip owner attachment, bet-kind colour semantics and guard keys preserved.
- Decision, repair and recheck docks keep `allocation.tableHeight`, so answer
  height, tap targets and the no-answer-scroll contract are untouched.
- Right-hand commitment slots left exactly as B4 set them: the canonical route
  never posts a chip there, so no raster proves a defect.

## 5. Result

Felt area, canonical `402x874`:

| state | before | after | delta |
| --- | --- | --- | --- |
| decision / repair / recheck | 263 x 451 | 264 x 454 | +1.2% |
| correct feedback | 278 x 476 | 308 x 526 | **+22.7%** |
| wrong feedback | 278 x 476 | 299 x 512 | **+15.9%** |

Blind/board overlap, canonical text scale:

| | before | after |
| --- | --- | --- |
| state x viewport combinations overlapping | **20 of 20** | **0 of 20** |

Top guide height: 79 -> 76 (decision), 92 -> 89 (correct), 109 -> 106 (wrong).

## 6. Dispositions

- `TABLE_OVAL_IDENTITY_REFINEMENT` — **NOT TAKEN.** The packet gates geometry on
  the table still reading materially weak *after* composition work. It does not.
  The card in the middle was the defect; removing it, not reshaping the oval,
  restored poker identity. Reopening the oval would ripple into B1 perspective,
  seat anchors and hero ownership for a preference-level gain.
- `INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT` — **`DEFER_TO_POST_B7_PRE_P02_MAINTENANCE`.**
  Iteration 1 does not touch the owning proof/feedback widget, so the packet's
  own condition for a bounded in-place correction is not met. Runtime unchanged.
- `COMPACT_BLIND_BET_BOARD_LEGIBILITY` — **RESOLVED** at all three viewports and
  all five states.

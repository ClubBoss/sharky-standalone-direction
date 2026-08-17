# VISUAL GAUNTLET B1 — GAP MAP v1

Mission: `VISUAL_GAUNTLET_B1_SPATIAL_CHARACTER_READY_FOUNDATION_V1`
Starting live `origin/main`: `da22a09b25ea36d5e2becfc5d2384b448840d265`
Branch: `feat/visual-gauntlet-b1-spatial-character-ready-foundation-v1`
Primary viewport: `402x874` portrait.
Produced BEFORE any production mutation.

## 0. Measured Wave A baseline (402x874, real harness capture)

Source: `test/ui_v2/action_sequence_canonical_raster_capture_v1_test.dart`
Evidence: `output/visual_gauntlet_b1/baseline_wave_a_402x874/`

| Metric | Value | Reading |
| --- | --- | --- |
| Table bounds (decision) | x 55.9-346.0, y 112.0-595.5 | 72% of screen width |
| Flank dead space | 55.9 px left + 56.0 px right | flat unowned navy on both sides |
| Far seat layout volume | 72 x 64 | `utg`, `bb`, `hj` |
| Near seat layout volume | 72 x 64 | `sb`, `co` — identical to far |
| Hero identity badge | 73 x 42 | a badge, not a volume |
| Action envelope top | y 625.5 | 249 px lower surface |
| Silhouette taper | far 0.80 w / near 0.97 w | ratio 0.82 — perceptually flat |
| Seat depth scale | 0.91 far / 0.97 mid / 1.05 near | 15% total range — below perception threshold |

Wave A already ships a nominal `integratedPerspectivePrototype`
(`_IntegratedPerspectiveTableShapeV2`, `_integratedPerspectivePointV2`,
`depthTieredPrototype`). It is real code but its magnitudes are too small to
read as perspective. B1 does not need to invent a depth concept from nothing;
it needs to promote a token gesture into a coherent, load-bearing scene model.

## 1. Benchmark structural principles extracted (PokerSkill)

Structure only. No art, character, branding, layout, or identity is copied.

1. One long-axis perspective: far rail materially narrower than near rail.
2. Rail has volume and catches light; it is an object, not a stroke.
3. Player bodies sit BEHIND the far rail and are OCCLUDED by it. This single
   overlap does more depth work than any gradient.
4. Seat scale falls off monotonically with depth on one shared curve.
5. Near/side players are large and cropped by the screen edge.
6. A room exists behind the table: horizon, wall, floor, falloff, light pool.
7. Hero owns the near/foreground plane, not a badge inside the diagram.
8. Seat HUD plates are attached to player volumes, not free-floating.
9. Teaching layer floats OVER a living scene; the scene never collapses.

## 2. Gap map — checklist classification

| # | Item | Class | Finding |
| --- | --- | --- | --- |
| 1 | Table-to-screen proportion | `B1` | 72% width with 112 px of unowned flat flank; table reads as a floating diagram card |
| 2 | Perspective coherence | `B1` | taper ratio 0.82 and 15% seat-scale range are below perception; no shared projection |
| 3 | Background / environment ownership | `B1` | flat single-value navy; zero environment; table floats |
| 4 | Far-player plane | `B1` | does not exist; far seats are the same pills as near seats |
| 5 | Near-player / hero plane | `B1` | does not exist as a plane |
| 6 | Stable character-safe volumes | `B1` | no reserved volume anywhere; B3 cannot land without a re-layout |
| 7 | Hero spatial integration | `B1` | 73x42 `You BTN` badge inside the felt; detached UI, exactly the anti-pattern named in §8.3 |
| 8 | Board / pot / bet ownership | `ALREADY STRONG` | center pot stack, street badge, blind chips and collision guard already coherent |
| 9 | Seat / position anchor stability | `B1` | anchors exist but carry no depth, no volume, no HUD attachment contract |
| 10 | Future HUD attachment feasibility | `B1` | no named anchors; B4 would have to reverse-engineer geometry |
| 11 | Feedback / table spatial continuity | `ALREADY STRONG` | Wave A keeps the table mounted through correct/wrong/repair/recheck |
| 12 | Empty-space usage | `B1` | flanks and the band under the table are dead |
| 13 | Scene depth cues | `B1` | one drop shadow; no occlusion, no horizon, no atmospheric falloff |
| 14 | Responsive survivability | `B1` | any depth model must hold at compact/tall/large and 1.4x text |
| 15 | Wave A information hierarchy | `ALREADY STRONG` | preserve unchanged |
| 16 | Interaction affordance | `ALREADY STRONG` | preserve unchanged; seat targets stay equal and tappable |
| 17 | Correct/wrong/repair/recheck continuity | `ALREADY STRONG` | preserve unchanged |

### Deferred classifications

| Gap | Class |
| --- | --- |
| Premium felt/rail material, wood grain, real room art, textures | `DEFERRED B2` |
| Final character family, faces, clothing, poses, folded/active art states | `DEFERRED B3` |
| Executed object-attached HUD (stack plates, bet flags, dealer pucks bound to volumes) | `DEFERRED B4` |
| Attention-aware rendering, depth-of-field, selective focus/blur | `DEFERRED B5` |
| Semantic motion, chip flight, seat reveal, camera moves | `DEFERRED B6` |
| Final benchmark cohesion/polish parity pass | `DEFERRED B7` |

## 3. The single largest B1 class-level gap

**There is no scene depth model.** Everything else in the `B1` column is
downstream of it: character volumes cannot be placed without a depth scale,
hero cannot own a foreground plane that does not exist, and an environment
cannot frame a table that has no ground relationship.

Iteration order follows that dependency:

1. **Iteration 1** — establish the depth/perspective architecture and the
   environment plane. Table stops floating; planes become real.
2. **Iteration 2** — character-ready player volumes with rail occlusion, and
   hero foreground ownership. Scene stops being a diagram.
3. **Iteration 3+** — only if a class-level gap survives.

## 4. Architecture chosen

New production module `lib/ui_v2/act0_shell/act0_scene_depth_v1.dart` as the
single owner of scene space:

- `Act0ScenePlaneV1` — `environment / farPlayer / table / nearPlayer / overlay`.
- `Act0ScenePerspectiveV1` — ONE projection used by every consumer:
  `projectX`, `depthOf`, `scaleAtDepth`. No widget invents its own fake depth.
- `Act0SceneSeatSlotV1` — per-seat stable slot: depth, character-safe volume,
  and named anchors (`plate`, `bet`, `cards`, `character`) for B4.
- `Act0SceneHeroZoneV1` — near-plane hero ownership.
- `Act0SceneEnvironmentV1` — room spec: horizon, wall/floor, light pool,
  vignette, grounding contact.

Wiring is confined to the canonical learning scene in
`act0_lesson_runner_shell_v1.dart` at the existing
`act0_integrated_scene_perspective_table` seam. Wave A semantics, truth,
evaluation, feedback, repair/recheck, telemetry and route architecture are not
touched.

## 5. Protected-semantics contract for this mission

No change to: information architecture, interaction affordances, answer truth,
evaluation, correct/wrong feedback, causal table clue, repair, recheck,
continuation, telemetry semantics, safe-area behavior, accessibility intent,
supported responsive profiles.

`HUMAN_PROOF = FALSE`.

---

# B1 EXECUTION RESULT

Candidate SHA: `c1b75eb8edc42644f49af50495cd3b8db998601f`
Branch: `feat/visual-gauntlet-b1-spatial-character-ready-foundation-v1`

## Iterations performed

| # | Class-level problem attacked | Outcome |
| --- | --- | --- |
| 1 | No scene depth model | One projection owns the scene; environment plane mounted; taper 0.82 -> 0.68 |
| 2 | No player volumes, no hero plane | `farPlayer` volumes occluded by the rail; hero near-plane lit; drop-shadow moat removed |
| 3 | Far plane invisible, hero still a badge | Hero foreground volume occludes the table; far seat clears the far rail |

## Player-slot geometry

Six stable slots resolved by `act0SceneSeatSlotsV1` from the Wave A base slots.
B1 did not renegotiate which seat sits where — only depth and reserved volume.

| Property | Value |
| --- | --- |
| Depth source | `Act0ScenePerspectiveV1.project` on normalized table space |
| Plate scale | `0.88` far -> `1.08` near (narrow on purpose; plates carry text) |
| Volume scale | `0.74` far -> `1.42` near |
| Volume size | `0.245 w x 0.275 w` of table width, times volume scale |
| Outward push | `x = 0.135 + 0.090 d`; `y = 0.078` far tier, else `0.060 + 0.035 d` |
| Named anchors | `plateAnchor`, `characterAnchor`, `betAnchor`, `cardAnchor` |

## Hero integration

Hero is the camera, so B1 gives it no face. It gives it a plane:
`Act0SceneHeroPlanePainterV1` lights the learner's side of the felt and rims the
near rail; `Act0SceneHeroForegroundV1` is the learner's own volume seen from
behind, drawn after the table so it cuts across the near rail.

Far players are occluded BY the table. The hero occludes it. That symmetry is
what seats the learner.

## Environment / depth architecture

`environment -> farPlayer -> table -> nearPlayer -> overlay`, painted in that
order. The environment plane carries wall, horizon bloom, floor falloff,
overhead light pool and corner vignette, reaching 1.46x horizontally past the
table into the 112 px flanks Wave A left flat.

## Future HUD anchors (B4)

Every seat exposes `plateAnchor` and `betAnchor` in normalized table space plus
a depth-resolved `plateScale`. Stacks, bets, position labels, player status and
acting indicators attach to those without moving the scene.

## Wave A semantic-preservation audit

Measured from matched harness geometry across all eight captured states:

| Contract | Result |
| --- | --- |
| Table allocation (w x h) | identical in all 8 states |
| Action envelope top | identical in all 8 states |
| Blind-chip / seat collision guard | clean in all states |
| Tappable table objects | `9 -> 9` |
| Runner phases | identical |
| Overflow exceptions | none |
| Answer truth / evaluation / feedback / repair / recheck | untouched |
| Routes / telemetry / personalization / curriculum | untouched |

B1 changed the scene's spatial architecture without moving a single Wave A
layout allocation.

## Residual gaps — explicit deferrals

| Gap | Owner |
| --- | --- |
| Felt/rail material, wood, cloth weave, real room art, textures | `B2` |
| Final character family; faces, clothing, poses, folded/active art | `B3` |
| Executed object-attached HUD bound to the anchors B1 defines | `B4` |
| Attention-aware rendering, depth of field, selective focus | `B5` |
| Semantic motion, chip flight, seat reveal, camera moves | `B6` |
| Final benchmark cohesion and polish parity | `B7` |
| Vertical room for a fully visible far-player plane above the rail | `B2` — needs the table-height trade B2 owns |

`HUMAN_PROOF = FALSE`

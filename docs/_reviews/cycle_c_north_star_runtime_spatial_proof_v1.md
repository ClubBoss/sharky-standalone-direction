# Cycle C — North Star → Runtime Spatial Proof v1

Status: candidate captured. `6MAX = LIMITED-PASS`, `9MAX = LIMITED`. Experimental only.
Freshness: 2026-09-10
Branch: `experiment/cycle-c-north-star-spatial-proof-v1` (from PR #212 head `e0617ae8`)
Starting main: `cc91e0421393aa94a29ab88fa2f75776dd17af8f` (unchanged). PR #212: OPEN / DRAFT, untouched.

Evidence: OBSERVED = executed/inspected. DERIVED = deterministic from OBSERVED. INFERRED = reasoned.

---

## C1 — North-Star spatial contract (extracted from the 4 supplied references — TARGET RELATIONSHIPS, not measurements)

| element | current runtime (OBSERVED) | C2 / C2-9 / R2.3 target (INFERRED from refs) |
|---|---|---|
| table screen occupancy | ~0.82 W, tall, near:far width ≈ 1.65:1, near-top-down | ~0.55 W at the near edge tapering to ~0.35 far; near:far ≈ 2:1+; ~40° camera, not top-down |
| table vertical placement | far rail ~y197 / 0.225 H | far rail lower (~0.30 H) so a room band sits above it; near edge runs off-frame behind the hero |
| far-centre tier | 74–85 px box, head+shoulder above far rail | head+shoulders+upper torso, elbows on rail, clearly visible, ~6% screen-height head |
| upper-flank tier | ~16–18 px visible sliver (hidden by felt) | 70–80% of body in visible room *outside* the felt oval, ~30–45° inward, side-rail cuts near forearm |
| near-flank tier | ~16 px sliver / partly off-screen | large foreground presence in the bottom corners, ~40–55% of body, strongly inward, body runs off-screen |
| hero | forearms on rail, bottom, ~0.19 H | same — POV forearms framing (not covering) the hole cards |
| environment | room painted, mostly behind/around table | substantial visible room: ~25–30% H above the far rail + ~15–20% W lateral bands of "room not table" |
| coach budget | progress y0–38 + strip y38–114 (76 px content) | progress (~38 px) + Sharky portrait (left, ~60 px) + connected bubble w/ label+headline+3 body lines+clue line ≈ 145 px content ⇒ ~183 px / 21% H total |

## C2 — Current causal gaps (ranked by product impact)

1. **SCENE_WORLD_WIDTH + LAYER/OCCLUSION** — the opponent layer is `Positioned.fill` inside the table's own stage rect (~0.82 W) and painted entirely *behind* the felt. Flank bodies can only ever show in the gap between their pushed anchor and the felt edge ⇒ 16 px slivers. (OBSERVED, Cycle B + C.)
2. **SEAT_ANCHOR / PLAYER_VOLUME** — one flat ring, `volumeScale` 0.95→1.42 (1.5×). No far/upper-flank/near-flank tiering; depth ladder too shallow for a C2 read.
3. **TOP_VERTICAL_BUDGET (CAMERA)** — `farRailFraction 0.225` ⇒ ~197 px from screen top to the far rail; R2.3 coach needs ~183 px and the far player needs ~55 px of relief above the rail ⇒ **~40 px hard deficit**. (DERIVED from OBSERVED anchors.)
4. TABLE_WIDTH / TAPER — near:far 1.65:1 vs target 2:1+. Deferred (frozen PR203).

## Primary candidate — `BOUNDED_SPATIAL_REBALANCE_V1` (no camera change)

Changes, all in `act0_scene_player_v1.dart` + the scene-stack wiring in `act0_lesson_runner_shell_v1.dart`:
- `Act0SceneTieredOpponentLayerV1` — opponents laid out in a world **1.32× wider** than the felt stage (`Positioned` with −0.16 W insets, `Clip.none`), re-tiered far-centre / upper-flank / near-flank with per-tier world anchor, scale and inward facing.
- **Front plane**: near-flank opponents render *after* the table so the felt edge occludes their outer body (like the hero foreground), instead of the whole figure hiding behind the rail.
- `_Act0SceneDiagnosticSeatedProxyPainterV1` for non-UTG seats — head + neck + shoulders + tapered torso + chair back + inward arm, filling the envelope. **Diagnostic, explicitly not production art.** UTG reuses the Cycle B authored asset.

**6-max runtime result (V1, no camera): INCONCLUSIVE → LIMITED.** OBSERVED at 402: flanks go from 16 px slivers to 55–73% on-screen seated figures with chair mass (gap 1–2 fixed). But the far-centre opponent then either drops below the felt (anchor low) or is overlapped by a 21%-H diagnostic coach box by ~15 px (anchor high). Residual owner = **TOP_VERTICAL_BUDGET / CAMERA**, exactly gap #3.

## Structural challenger — `STRUCTURAL_REBALANCE_V2` (bounded camera nudge)

`Act0SceneCameraV1.cycleCRebalanceV2`: `farRailFraction 0.225 → 0.27`, `projectedTableHeightFraction 0.50 → 0.47`. Width and taper unchanged. Table moves down ~39 px at the top, near rail nets ~+13 px lower.

### 6-max runtime proof (OBSERVED — real Flutter goldens, `test/ui_v2/goldens/cycle_c/`)

`test/ui_v2/cycle_c_spatial_rebalance_v1_test.dart` — **+3 PASS**, 375 / 402 / 430 × decide / correct / wrong / repair + a diagnostic-coach-budget frame each.

| check | 375 | 402 | 430 |
|---|---|---|---|
| far-centre (utg) box | 70.6 × 79.2 | 75.7 × 84.9 | 80.9 × 90.8 |
| utg head relief above far rail | ~27 px | ~29 px | ~31 px |
| gap: 21%-H coach budget bottom → utg top | **+21.9** | **+23.7** | **+25.2** |
| upper-flank (bb/hj) on-screen | 73% | 73% | 73% |
| near-flank (sb/co) on-screen | 55% | 55% | 55% |
| min on-screen fraction, any opponent | 0.55 | 0.55 | 0.55 |
| board / pot / hero-card collision | none | none | none |
| geometry stable decide↔correct↔repair | ✓ (≤0.6 px) | ✓ | ✓ |

Visual read (OBSERVED from goldens): all 5 opponents read as seated figures with chair mass — no slivers. Poker information (board, pot, reticle, hero cards) stays clearly dominant. Hero POV forearms preserved. Coach surface (mascot + bubble) coexists with a clean gap to the far player in every state. **Not C2-quality**: proxies are crude (diagnostic), the depth ladder is still modest, chair tone reads pale, and the scene is still more top-down than C2's ~40° room view (that needs table width/taper work = deferred).

### Regression (OBSERVED)

- `dart format` clean; `flutter analyze` (changed files + tests) — No issues.
- `act0_b7_canonical_scene_geometry_invariant_v1_test.dart` — **+11 PASS** under the V2 camera (hero band shrinks 375: 84→72 px, 402: 101→88 px but stays positive; cross-state stability holds; commitment-to-pot clearance holds).
- `test/ui_v2/runner/` + scene motion — **+230 PASS**, no regressions.

## C5 — 9-max headroom falsifier (OBSERVED — `test/ui_v2/cycle_c_9max_headroom_v1_test.dart`, +2 PASS)

Same tiered grammar, Hero + 8 synthetic opponents, same V2 stage. Result: `worstOverlapFrac 1.00`, `minBoxW 81–88 px`. Multiple same-tier seats collapse onto ONE per-tier anchor → only ~4 distinct figures show for 8 seats.

`9MAX_HEADROOM = LIMITED`. The tier skeleton (far / upper-flank / near-flank + wide world + front plane) and the same table/camera are reusable, but 9-max needs **intra-tier fanning** — an index-within-tier → lateral + depth offset so N seats spread along each table edge. That is a bounded seat-density feature, not a new architecture.

## Coach-surface headroom

`COACH_SURFACE_HEADROOM = PASS` for the spatial budget: a 21%-H (≈183 px on 874) diagnostic top box coexists with the V2 table + far player with a +22–25 px gap on all three viewports, across all learning states. No R2.3 visual art was implemented (out of scope).

## Score matrix (surviving candidate = V2; diagnostic prototype, not production — scored 0–10, not inflated)

| axis | score | note |
|---|---|---|
| 6-max physical embodiment | 6 | all 5 seated, chair mass, no slivers; proxies crude, far-centre modest |
| depth credibility | 5 | tiers exist; falloff shallow vs C2; camera still near-top-down |
| poker readability | 9 | board/pot/cards/reticle fully dominant, zero collision (OBSERVED) |
| Hero POV | 8 | forearms preserved; near rail 13 px lower, hero band 72–88 px (OK) |
| mobile 375 viability | 7 | all seats render, far-centre 70 px, coach gap +22 px |
| Coach Surface headroom | 8 | 21% budget coexists in every state |
| C2 visual-direction fidelity | 4 | right skeleton, wrong finish; needs table taper + real art + camera depth |
| 9-max extensibility | 5 | skeleton reusable; needs intra-tier fanning (bounded) |
| implementation complexity | 6 | ~430 LOC new; 2 camera params; 1 runner stack edit |
| regression risk | 7 | full suite green; camera change touches frozen PR203 (needs authority) |
| production-art friendliness | 7 | envelopes are now real per-tier boxes an artist can target; UTG asset already fits |
| overall expected EV | 6 | unlocks the flank tiers cheaply; camera + taper + art remain |

## Verdicts

- `6MAX_RUNTIME_RESULT = PASS` for the bounded question ("no accidental slivers, all seated, poker dominant, coach coexists, 375 usable, stable") — **with the V2 camera nudge**. Without any camera change: `LIMITED` (far-centre vs coach deficit).
- `9MAX_HEADROOM = LIMITED` — reusable skeleton, needs bounded intra-tier fanning.
- `CAMERA_STATUS = MODIFY_JUSTIFIED` — a small far-rail drop (0.225→~0.27) is causally required for the R2.3 coach budget + far-centre relief; it keeps the existing geometry invariant green. Larger taper/width change for full C2 depth = separately justified, not done here.
- `TABLE_GEOMETRY_STATUS = MODIFY_JUSTIFIED (bounded)` — only `farRailFraction` + `projectedTableHeightFraction`; width/taper preserved.
- `COACH_SURFACE_HEADROOM = PASS`.

## What remains unproven

- C2-grade *depth/perspective* (needs table taper 1.65:1→2:1+ and/or a lower camera — touches the frozen silhouette path).
- Final opponent art for the 4 flank seats (only diagnostic proxies exist).
- 9-max intra-tier fanning (identified, not built).
- Real R2.3 coach art and its interaction with the progress layer.
- Whether the frozen PR203 geometry owner will admit the camera nudge.

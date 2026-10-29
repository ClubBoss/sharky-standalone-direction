# F7 replaceable scene contract

Owner dispatch: F7 and Composition Calibration Amendment, 2026-10-29. Base is
Draft #327, `754758428cdbbc23ec7883e30f11f22078db1ad5`. This authorizes a bounded
presentation preview; it does not admit S12.V, Human, P02, release or a merge.

`SHARKY_F7_TABLE_SCENE_PREVIEW` is explicit opt-in, default OFF. F7.A supplies
the contract/asset gate only. F7.B integrates it with the existing Runner.
**Composition remains OWNER_SELECTION_PENDING.** Provisional profile values
are calibration inputs, not accepted production coordinates. Exactly three
native comparison families (Physical / Learning First / Balanced) belong in
local review evidence, not permanent production presets.

F7.B accepts review-only geometry through the compile-time
`SHARKY_F7_SCENE_PROFILE_JSON` define, only behind the preview flag. The JSON
round-trips the profile's `calibrationData` (including image alignment/crop).
It selects no task or learner state and cannot substitute a different asset.
Keep A/B/C JSON and native receipts under `output/f7_20261029/`; they are not
shipped presets or an owner selection. Preview OFF preserves the original
path. A compiled review binary is not promotion of its coordinates.

## Ownership

- `act0_scene_profile_v1.dart`: original image size, fit/alignment, normalized
  table/felt regions, UI exclusions, separate seat-label/hole-card/bet/dealer
  anchors, Hero/board/pot/street/clue anchors, card widths and Hero tilt.
- `Act0SceneRegistrationV1`: the single original-image-to-viewport transform,
  shared by artwork and all dynamic overlays. No people/image stretching.
- `act0_scene_profile_gate_v1.dart`: reuses the existing decode-once plate
  store, verifies actual decoded dimensions, and selects the original path on
  invalid/missing art or an unsupported complete scenario. Selection is
  latched per scenario key, including feedback; pending decode does not show
  another room. It owns no persistence, grading, task choice or learning data.
- The existing Runner continues to own source seat identities, cards, bets,
  action playback, clue state, callbacks, choices, assistance and navigation.

## Actual supplied art and capabilities

The only premium plate is
`assets/design/sharky/pw_c3/owner_clean_table_candidate_965x1629.png`, 965×1629.
It owns the room, felt, rail, five seated opponents and Hero foreground.
Independent character, Hero and procedural table/rail layers must not paint
over it. Its clean felt supports real runtime cards and commitments.

| Source state | Compatibility |
|---|---|
| Six occupied seats, one Hero, canonical clockwise order | Supported |
| Hero at another canonical position | Rotate source identity order around Hero; do not relabel poker positions |
| Preflop / flop / turn / river | 0 / 3 / 4 / 5 real board cards |
| Seated opponent folded | Retain seated person; hide their in-hand cards and show existing explicit Folded badge |
| Active / checked / bet / called / raised | Existing source HUD/cards/chips/action trail; body pose stays static |
| Face-up opponent cards | Existing true source card visibility only |
| Empty seat / removed actor | Unsupported: original scene for the entire scenario |
| Nine/ten seats, missing/duplicate identities, >2 hole cards | Unsupported: original scene |
| Moving/folding/away character poses | No such artwork exists; no animated-body claim |

All source teaching variants must pass compatibility before selecting a room.
A new occupancy/configuration mechanic must extend scenario preflight before
using this profile; it cannot silently reuse a baked occupied body as an empty
chair. No transparency mask, actor layer or state plate is fabricated.

## Replacing artwork later

1. Supply approved original artwork, exact dimensions/hash, and an explicit
   inventory of baked people, cards, hands, table and state-specific assets.
2. Instantiate a Scene Profile with that asset, size, normalized boundaries,
   card/label/bet/dealer/Hero/board anchors, card sizes, safe zones and truthful
   layer/state ownership. Review calibration can round-trip through
   `calibrationData` / `act0SceneProfileFromCalibrationV1`.
3. Validate no distortion, actual dimensions, anchor mapping, safe regions,
   missing/corrupt fallback and scenario compatibility. Capture actual native
   preflop/flop/feedback, plus supported later-street/fold cases.
4. Obtain owner composition selection before promoting the new geometry.

Task/choice IDs, poker rules, grading, source seat identity, evidence,
assistance, run/session linkage, XP, repair/due ownership and navigation do not
change for an art replacement. No new engine or dependency is required.

## C1 bounded calibration basis

The owner selected C — Balanced Premium as the next calibration basis on
2026-10-29, without final visual acceptance. The default premium profile now
contains the C1 candidate geometry, still behind the default-OFF preview flag.
Opponent cards move inward onto the felt and reduce slightly; UTG cards and
label separate; the SB chip moves below and clear of Hero; the board row uses
a slightly smaller width for four/five-card states. Image fit/alignment and all
overlay positions remain owned by the same Scene Profile registration.

This does not promote a final visual layout. The existing source-owned Coach
panel is retained: clearing the central head would require reducing readable
feedback or occupying another reserved region on the 393-point viewport.
Native comparison, exact build provenance and geometry deltas remain local
under `output/f7_c1_20261029/`. No additional layout family, artwork, learning
state, callback or navigation change is admitted by this calibration.

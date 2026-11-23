# Table skin contract v1

B33 uses `TableGeometryV1` for registered and preview placement and
`TableSkinV1` for the table pieces. This handoff records the existing
6-max calibration and the geometry and artwork needed for the designer's table.

## Ownership

- `Act0TableStateV1` and the hand timeline supply the seats, actor, dealer,
  visible cards, commitments and pot. The runner supplies focus, selection and
  playback state. Seat IDs, callbacks, grading, chip accounting and card
  visibility stay with their current owners.
- `TableGeometryV1` resolves one layout for 2–9 seats from the local viewport.
  The renderer rotates the source seat order to the hero and maps the
  provider's slot anchors into viewport points. The format and player count
  supply capacity, and the authored seat list also covers older snapshots.
  Registered art uses source-image coordinates and shares its affine transform
  with all overlays. Preview slots use normalized viewport coordinates.
- `TableSkinV1` draws the pieces below using resolved bounds, current visual
  state and motion progress. Artwork must leave dynamic labels, visible cards
  and interactive hit areas available to the renderer.
- `tableNineSeatV1` defaults to OFF. In a debug build, pass
  `--dart-define=tableNineSeatV1=true` and wrap the imported runner in
  `Act0NineSeatDebugScopeV1`. Widget fixtures can set the scope's `enabled`
  directly. The learner shell rejects full-ring runners during launch and
  rendering, including after restore. Seat capacity is independent of folds.
- `TableSkinScopeV1` installs a skin for a scene. The default
  `ModernTableSkinV1` produces the existing widgets and painter. Preserve
  interaction callbacks, semantic labels and keys when supplying a new skin.

## Skin pieces

Use logical points for sizes and text. Deliver vector art or transparent @3x
PNG, with painted bounds and, where applicable, a content inset and hit area.

| Piece | Required states | Current baseline and delivery sizing |
| --- | --- | --- |
| Felt and rail | Default, dimmed under sheet | Full table zone. Registered 6-max uses an undistorted, contained 965×1629 image with rail and scene baked in. Supply the fit, rail boundary and safe overlay region for each seat count. |
| Seat plate | Empty, occupied, hero, folded, all-in, acting, winner, selectable, selected, wrong-selected, confirmed, teaching target | Current hero and compact-opponent minimum widths are 84 and 72 pt. Height depends on content. Supply the plate sizes and text insets for each format, including a long position label and a two-line position/stack arrangement. Interactive bounds are at least 44×44 pt. |
| Card face | All 52 ranks and suits, regular, highlighted, opponent reveal | Current face boxes before scene scaling are 35×49 pt for hole cards and 31×43 pt on the board. Supply S and XS sizes with distinguishable rank and suit at XS, targeting at least 12 pt equivalent. |
| Card back | Hidden card, absent card | Current back is 22×31 pt before scene scaling. Supply the XS back and bounds for a two-card fan. |
| Chip stack | One to five chip heights, post, call, bet, raise, all-in | Current stack is 12×16 pt compact or 14×18 pt regular inside a content-sized label carrier. Supply the stack bounds and reserve room for the signed-off amount style at ≥12 pt. |
| Pot label | Single pot, main with side pots, overflow, optional adjacent call price | Current registered pill has 8×4 pt horizontal/vertical padding and 9.6 pt text. Its row is capped at 23% of fitted art width for pot only or 60% with price. Supply room for up to three pot rows. Additional pots use a `+N pots` row with access to all amounts. |
| Dealer button | Present for the dealer, absent | Current puck is 18×18 pt. Supply the puck diameter, contact shadow bounds and per-seat anchor. |
| Action badge | Fold, check, call, bet, raise, all-in, blind post, hidden | Current treatment uses content-sized chip labels and seat markers, including 16×16 pt blind markers. Supply badge bounds with the longest label, per-seat anchors and spacing from plate text. Clear on the next action. |
| Turn highlight | Idle, acting, teaching or answer focus | Current focus ring uses a 2 pt stroke on the plate bounds. Supply ring insets and any glow overflow. Use a static ring with Reduce Motion. |
| Board slot | Empty or occupied, highlighted card | Supply five card-sized slots, a row centre and spacing. Keep the slot grid stable during street changes. Current unscaled board gap is 5 pt. |

The winner plate, pot breakdown and expanded badge states are delivery
requirements. They depend on the corresponding source state being available.

## Geometry delivery

Supply one geometry set for each of 6 and 9 seats for the compact (375×667),
reference (393×852) and large (440×956) portrait viewports. Each set declares
the **actual table-zone width and height** available between surrounding
controls, in points after safe areas. Anchors are centres relative to that
zone's top-left. Supply the minimum usable zone and the scaling or compact
rule below it, including at 1.3× text.

- Supply seat centres in clockwise order from bottom-centre slot 0, with
  hero-relative rotation by source seat order. For a replay without a hero,
  specify the layout with BTN at slot 0.
- For each slot supply the hole-card centre and fan angle, chip offset from the
  plate toward the pot, dealer offset, action-badge offset, plate bounds and
  interactive bounds. Supply the fit and clipping policy for empty seats and
  revealed opponent hands.
- Supply the pot, board, street and clue centres, board card dimensions and
  spacing, and felt/rail extents. Include the exclusion areas for the history
  row and answer controls. Keep at least 4 pt between painted information
  bounds and keep 44×44 pt tap areas clear.
- Check the compact fixture with nine occupied seats, 1.3× text, a compact
  history row, `147.5 BB` stacks, two revealed opponent hands, a main pot and
  two side pots, with answers visible without scrolling. Repeat on the
  reference and large viewports.

### Debug placeholder

The preview reuses the registered overlay renderer over procedural felt.
Slots run from bottom centre in source order on an ellipse centred at
`(.5, .5)` with radii `(.35, .34)`. Bets move 27% inward. Cards sit .065
of the viewport height above their plate and the button sits .105 of the
width inward and .025 of the height below it. The board, pot, street and
clue centres are `(.5, .49)`, `(.5, .58)`, `(.5, .41)` and `(.5, .35)`.
The designer supplies the final anchors and confirms overlap and readability.

### Current registered 6-max reference

These are normalized **source-image** coordinates from
`act0PremiumTableSceneProfileV1`, in existing hero-relative slot order.
The renderer maps them through `BoxFit.contain` with alignment `(0, -1.57)`.
They are distinct from the table-local point values in the delivery above.

| Slot | Plate | Hole cards | Bet | Dealer |
| --- | --- | --- | --- | --- |
| 0 | .48, .778 | .48, .705 | .69, .755 | .635, .775 |
| 1 | .20, .695 | .31, .63 | .28, .755 | .27, .735 |
| 2 | .285, .478 | .405, .44 | .358, .507 | .40, .39 |
| 3 | .52, .362 | .52, .40 | .52, .458 | .61, .355 |
| 4 | .75, .472 | .635, .44 | .682, .507 | .64, .39 |
| 5 | .86, .67 | .69, .63 | .715, .685 | .79, .715 |

Board, pot/price, street and clue centres are respectively `(.52, .574)`,
`(.52, .632)`, `(.52, .528)` and `(.52, .492)`. Hero, opponent and board card
widths are 10%, 4.5% and 6.6% of fitted art width. The hero cards tilt by
±.035 rad and the hero plate has +8 pt vertical clearance. Revealed opponent
hands shift by `(0, .028)` at slot 3 and `(.08, -.045)` at slot 5 when a price
is shown, in source-image coordinates.

The procedural fallback owns a separate projection in `Act0SceneCameraV1`
and `Act0ScenePerspectiveV1`. Its outer width, projected height, far rail,
horizon offset and seat-to-chip separation fractions are .810, .470, .270,
.020 and .006. Its far and near width factors are .60 and .99. The registered
prototype and the fallback both retain their established 6-max values.

## Motion

The runner controls when an information state changes. The skin receives
progress for visual transitions and renders the destination frame immediately
when motion is disabled. Keep the current timing on the 6-max reference.
Delivery budgets apply to designer animations.

| Hook | Current 6-max behaviour | Delivery budget | Reduce Motion |
| --- | --- | --- | --- |
| Board reveal or deal | Source reveal beat holds 460 ms | ≤400 ms per deal | Show cards immediately |
| Placement and collection of chips | Placement animates 380 ms for a post, 360 ms for a call, 440 ms for a bet, raise or all-in. Collection beat holds 300 ms | ≤400 ms for collection | Jump to final placement or collected state |
| Action badge in/out | Action-focus and fold beats hold 340 ms. History item fades in 200–240 ms and moves in 220–260 ms | ≤200 ms | Static or ≤150 ms fade |
| Turn highlight | Static seat ring. Pot emphasis can pulse for 600 ms | Static ring with optional one pulse ≤600 ms | Static ring and pot |
| Replay step | History auto-play advances on a 900 ms cadence | ≤300 ms per step transition | Jump to the requested action |
| Street frame change | Board and commitments follow the runner's street beats | ≤300 ms | Static frame or ≤150 ms fade |

## Exact 6-max comparison

Run the explicit harness against the unchanged table with the F7 scene at
its default setting. Keep the eight PNGs in the ignored
`.dart_tool/b33_table_goldens/` directory. After extraction, rerun the same
test file without `--update-goldens` on the same Flutter version and platform.

```sh
flutter test --update-goldens test/ui_v2/act0_table_skin_contract_v1_goldens.dart
flutter test test/ui_v2/act0_table_skin_contract_v1_goldens.dart
```

The harness renders the production registered scene at 393×852 with settled
motion and fixed fixture state. It covers preflop opens, 3-bets, flop bets and
river all-ins, with BTN, BB and UTG heroes and a 1.3× text case. Flutter's
default local golden comparator requires exact pixel equality.

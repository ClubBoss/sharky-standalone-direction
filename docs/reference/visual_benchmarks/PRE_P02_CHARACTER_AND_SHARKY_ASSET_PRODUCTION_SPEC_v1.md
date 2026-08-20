# Pre-P02 Character + Sharky Expression Asset Production Spec v1

Status: PROPOSED PRODUCTION SPEC — external asset dependency, not authority
Freshness date: 2026-08-20
Repository: `ClubBoss/sharky-standalone-direction`

## Why this document exists instead of shipped art

`PRE_P02_VISUAL_ART_COMPLETION_GAUNTLET_V1` requires either genuinely premium
art or an exact production spec plus a clear external dependency — never
placeholder art dressed up as a slice. The execution environment for this
mission has no Blender and no image-generation tool. Faking final art with
procedural Dart/PIL shapes was explicitly ruled out by
`docs/_reviews/b7_character_slice_reconciliation_and_scene_geometry_admission_v1.md`
(`PREMIUM_CHARACTER_ART = NOT_YET_PROVEN`, Python/PIL `NOT_APPROVED_FOR_FULL_PRODUCTION_PACK`).
This spec is the valid terminal output of Part B under that constraint.

## Selected production direction

`ART_PRODUCTION_PIPELINE = A_AUTHORED_GENERATED_2D_2.5D_ASSET_PIPELINE`

Rationale is recorded in full in
`docs/_reviews/pre_p02_visual_art_completion_gauntlet_character_coach_slice_v1.md`
§Part A. Summary: this is already the project's own proven premium pipeline —
`assets/design/sharky_character_v1/` is an owner-approved,
"AI-assisted concept/reconstruction" package, and its
`sharky_neutral_fallback_v1.png` deliverable is genuinely premium (soft 3D
shading, real facial construction, clean alpha cutout) at 1254x1254. The B7
character vertical slice already proved the *architecture* (transparent PNG
onto the existing deterministic scene) rides seat anchors, projection, rail
occlusion, B2 lighting and B5 recession without another scene system. What it
proved was not production-approved is the *asset*, because it was produced by
`tools/art/act0_b7_character_art_v1.py` (PIL primitives), not by this
pipeline. Route A reuses the proven architecture and replaces only the asset
source.

## Non-negotiable rendering constraint

`Act0SceneCharacterAssetPainterV1.paint` (the proven painter from the closed
vertical slice) draws with:

```dart
canvas.drawImageRect(image, src, dst, Paint()..filterQuality = FilterQuality.high);
```

`src` is the *entire* source image and `dst` is the *entire* destination box —
there is no `BoxFit` and no aspect-ratio correction. **Every asset must be
authored at the exact aspect ratio of the seat/hero box it fills**, or it will
visibly stretch. This is the single most important production constraint in
this spec.

## Required re-measurement before final generation

The aspect/size envelope below is derived from the last measured evidence
(`docs/_reviews/b7_character_vertical_slice_art_direction_v1.md`: near-seat
opponent volume `61 x 68` logical px, hero foreground band `~255 x 55` logical
px) taken under the pre-`PR203` camera. `PR203` subsequently changed table
geometry (`outerTableWidthFraction 0.810`, `projectedTableHeightFraction
0.500`, `farRailFraction 0.225`, `nearRailFraction 0.725`,
`volumeScaleFar 0.95`). Before generating final art, re-read the exact current
destination rect for the target seat from
`lib/ui_v2/act0_shell/act0_scene_depth_v1.dart` /
`act0_scene_player_v1.dart` at canonical `402x874`, and treat the numbers
below as the starting reference envelope, not the literal final aspect.

## Slice scope (unchanged from the closed vertical slice)

- One authored opponent identity, resolved to the nearest left-flank seat via
  the already-proven `act0SceneAuthoredOpponentSeatIdV1` (largest non-hero
  `near`-tier volume; exercises rail occlusion, recession and lighting at
  once).
- One authored first-person hero foreground (forearms + hands on the rail).
- No second identity, no folded-variant art, no full pack. Full-pack scope
  remains a separate future admission.

## A. Opponent character — production brief

**Subject**: seated poker opponent, three-quarter view turned toward the
felt, near left-flank seat, upper body only (visible portion is head through
mid-torso plus the near arm/hand resting near their cards — legs are never
in frame).

**Direction (from the accepted A-candidate gauntlet)**: stylized premium
illustration, not photoreal, not graphic-monochrome silhouette. Confident,
few-value-step shape language. Facial features stated as clean planes, not
fine rendered detail — the governing constraint is that the seat renders at
roughly `60-70` logical px wide on a phone screen, so any quality that depends
on fine detail resolving is wasted production cost. Bold, simple hair
silhouette. Clear shoulder line and visible neck/collar so the silhouette
reads as a person, not a bust. Same "Deep Ocean" room-matched value grading as
the accepted candidate: nothing brighter than the felt, values graded toward
`#0A1725`/`#1B3350`, with a soft felt bounce-light on the near/lower edge and
a cool rim light on the upper silhouette edge facing the table's shared light
source (see `Act0SceneLightV1.canonical` in `act0_scene_material_v1.dart` for
the exact light direction/intensity to match).

**Wardrobe/identity**: distinct from Sharky's own palette (Sharky owns navy +
warm tan) and distinct from the felt (`green`) and rail (`steel blue`) — a
muted warm or neutral garment tone that reads clearly against both without
competing with pot/board chrome. Casual, timeless, no logos, no real-world
brand signifiers, no readable text.

**Canvas**: author at `1600 x 1800` px (portrait, generous headroom above and
below the subject so a future crop can be retargeted without re-generating),
transparent background, subject vertically centered with feet/torso-cutoff
edge bleeding to the bottom of frame (never a hard horizontal cutoff line
baked mid-torso — let the alpha fade or the garment naturally end so the
in-scene atmospheric recession treatment, which composites a haze tint via
`srcATop`, doesn't reveal a seam).

**Format**: PNG-32, straight (non-premultiplied) alpha, sRGB.

**Crop/safe margin**: keep the head fully inside the top `12%` of the canvas
and the widest silhouette point (shoulders) inside the middle `70%` width band
— this leaves margin for the runtime's own scale/anchor placement to clip
without ever clipping the face.

**State variants required for this slice**: one pose only (`in_hand`, i.e.
actively contesting the pot). A `folded` variant is out of scope for this
slice; the existing runtime contract already expresses "folded" as additional
recession/haze on the same asset (see `Act0SceneCharacterAssetPainterV1.recession`)
rather than a second bitmap, so no second pose is required to ship this slice.

**File naming** (matches the existing proven asset seam so the resolver class
needs no field renames, only a path swap):

```
assets/act0_characters/opponent_near_left_in_hand.png
```

### Exact generation prompt (opponent)

```
Stylized premium 2.5D character illustration, transparent background, for a
mobile poker-coaching app. Subject: a seated poker player, three-quarter
view turned toward a card table, visible from the head to mid-torso only
(no legs, no chair). Confident, simplified shape language with facial
features stated as clean soft planes rather than fine photoreal detail —
this will be viewed very small (roughly 60px wide on a phone screen), so
bold silhouette and clear value read matter far more than fine detail.
Bold simple hair silhouette, clear shoulder line, visible neck and collar.
Casual muted-neutral clothing with soft fabric shading, no logos, no
readable text, no real-world brand references. Lighting: soft cool rim
light along the upper silhouette edge from the upper-left, soft warm bounce
light along the lower edge as if lit from below by green felt, overall
value graded dark — deep navy blue-black room tone (#0A1725 to #1B3350),
nothing in the figure brighter than a mid-tone card table felt. Cinematic,
warm-and-cool contrast, painterly but clean, no harsh outlines. Full alpha
transparency around the figure, no background elements, no vignette baked
into the alpha edge. Portrait canvas, generous empty margin above the head
and below the torso.
```

## B. Hero foreground — production brief

**Subject**: the learner's own forearms and hands resting on the felt rail at
the bottom of the screen, first-person point of view — never a face, never a
torso, this is a POV prop, not a character portrait.

**Direction**: same value grading and lighting family as the opponent (Deep
Ocean room tone, felt bounce light on the underside of the forearms, rim
light along the upper edge from the shared table light). Hands read as
relaxed/attentive, not gripping or gesturing — this is a resting-state prop
that must not imply an action the learner hasn't taken, and must not be
tinted or posed in a way that reads as answer-leaking body language for any
particular decision.

**Skin tone**: author a small set (minimum 3, e.g. light / medium / deep) so a
later admission can offer representation choice without re-commissioning this
brief; this slice ships exactly one (mid-tone, matching the opponent's current
identity is *not* required — hero and opponent are different people and
should not be forced to match).

**Canvas**: author at `2600 x 700` px (wide band, matching the current
observed hero-foreground band aspect of roughly `4.6:1`; re-verify against
`act0_scene_player_v1.dart`'s current hero rect before finalizing — see
"Required re-measurement" above), transparent background, both forearms
entering from the top-left and top-right canvas edges and resolving to
resting hands roughly at the vertical center, leaving the canvas center-bottom
mostly clear so it never occludes the hero's hole cards or the bottom action
dock.

**Format**: PNG-32, straight alpha, sRGB.

**File naming**:

```
assets/act0_characters/hero_foreground.png
```

### Exact generation prompt (hero foreground)

```
Stylized premium 2.5D illustration, transparent background, for a mobile
poker-coaching app: a first-person point-of-view pair of forearms and
hands resting relaxed on a card table's felt rail, entering the frame from
the upper-left and upper-right corners, hands meeting near the lower
center in a relaxed resting pose (not gripping, not gesturing, not holding
cards or chips). No face, no torso, no chair — hands and forearms only.
Casual sleeve cuffs in a muted neutral tone, soft fabric shading. Lighting:
soft cool rim light along the upper edge of the forearms, soft warm bounce
light along the underside as if lit from below by green card-table felt.
Value graded dark and cinematic — deep navy blue-black room tone (#0A1725
to #1B3350), nothing brighter than table felt. Wide letterbox canvas
composition, full alpha transparency, no background elements, no baked-in
vignette, empty clear space at the bottom center of frame.
```

## C. Sharky mood-expression set — production brief

`act0SharkyCompanionAssetForMoodV1` in
`lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart` currently maps every
`Act0SharkyMoodV1` (`neutral, happy, thinking, repair, celebrate`) to the same
single `sharky_neutral_fallback_v1.png`. That file is genuinely premium — the
gap is not art quality, it is that Sharky never visibly reacts to what just
happened at the table. This is the one material Part C gap this gauntlet
found that is *not* fixable by implementation alone (see the companion review
doc §Part C); closing it requires four more mood renders in the same
established pipeline and identity.

**Identity lock**: every mood must read as the same canonical character as
`assets/design/sharky_character_v1/references/sharky_canonical_3q_front_authority_v1_1.png`
(authority rank 1 in `sharky_character_package_manifest_v1.json`) —
proportions, coloring (deep navy `#0A1725`-family body, warm tan belly, teal
fin accents), and the soft 3D-toy shading language of
`sharky_neutral_fallback_v1.png` must not drift between moods. Use that file
and the package's side/back reconstruction references as the generation
reference set; treat any crest visible in the back/side references as a
deprecated reconstruction inconsistency per the manifest's own note — never
include a crest.

**Canvas**: `1254 x 1254`, transparent background, matching the existing
neutral asset exactly so no runtime sizing/anchor code changes.

**Format**: PNG-32, straight alpha, sRGB.

**State variants required** (four new renders; `neutral` is already covered):

| Mood | Expression direction | Maps from `Act0SharkyMoodV1` |
| --- | --- | --- |
| `happy` | warm closed-mouth smile, eyes slightly narrowed with genuine warmth, relaxed fin posture | `happy` |
| `celebrate` | open joyful expression, slight upward tilt/lift as if mid-bob, brighter eye-catchlight | `celebrate` |
| `thinking` | one brow raised, eyes shifted slightly up-and-off-center, mouth neutral-closed, a touch of "considering" head tilt | `thinking` |
| `repair` | soft, encouraging, non-punitive concern — brows drawn slightly in, gentle closed-mouth expression, must not read as disappointed or scolding (a repair prompt is still a coach, never a scold) | `repair` |

**File naming**:

```
assets/images/mascot/sharky_happy_v1.png
assets/images/mascot/sharky_celebrate_v1.png
assets/images/mascot/sharky_thinking_v1.png
assets/images/mascot/sharky_repair_v1.png
```

### Exact generation prompt template (Sharky moods)

Use `sharky_neutral_fallback_v1.png` and
`sharky_canonical_3q_front_authority_v1_1.png` as direct image references
(image-to-image / reference-conditioned generation), not text-only, so
identity does not drift. Text prompt to pair with the reference images:

```
Same exact character, same pose, same camera angle, same lighting, same
navy-blue and warm-tan coloring, same soft 3D-toy shading style as the
reference image — change only the facial expression to: {EXPRESSION
DIRECTION}. Transparent background, full alpha, no background elements, no
crest or emblem anywhere on the body, no readable text, no new accessories.
1254x1254 canvas, subject framed identically to the reference.
```

Substitute `{EXPRESSION DIRECTION}` from the table above, one generation per
mood.

## Integration notes for whoever lands the approved assets

- Opponent + hero: drop the two files at the paths above; the proven resolver
  (`Act0SceneCharacterAssetV1`, `Act0SceneCharacterAssetStoreV1`,
  `Act0SceneCharacterAssetPainterV1`,
  `act0SceneAuthoredOpponentSeatIdV1`) already exists as a fully proven,
  closed-pass prototype pattern from the vertical slice
  (`B7_CHARACTER_VERTICAL_SLICE_V1 = CLOSED_PASS_PROOF`,
  `CHARACTER_ASSET_ARCHITECTURE = PROVEN`). Re-deriving it was deliberately
  out of scope for this PR (see the companion review doc) because rebuilding
  an already-proven scaffold with no real art behind it creates no additional
  evidence; land the scaffold and the art together in the same admission.
- Sharky moods: once the four files above exist, change only
  `act0SharkyCompanionAssetForMoodV1`'s body from the single hardcoded return
  to a `switch` over `mood`; every call site (`Act0SharkyPresenceMascotV1`,
  `Act0SharkyCompanionAvatarV1`, `_WelcomeSharkyPresenterTileV1`) already
  keys its `Image.asset` widget on `mood.name`, so no call-site changes are
  needed. No precache step is required for this either — see the companion
  review doc §Part C for why the first-appearance decode placeholder was
  fixed at the `Image.asset` loading contract itself rather than by racing
  the decode, which covers any number of mood assets automatically.
- Re-run `tools/act0_b7_cohesion_capture_v1.dart` before and after landing
  either set and diff against this PR's `baseline_main_e9101ae0` /
  `candidate_frameBuilder_fix_v1` evidence to confirm no geometry drift, per
  the deterministic geometry guard in
  `docs/_reviews/b7_character_slice_reconciliation_and_scene_geometry_admission_v1.md`.

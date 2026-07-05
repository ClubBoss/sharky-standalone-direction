# Mascot Visual Stream Deferral v1

Date: 2026-07-06

Branch: `codex/mascot-repair-draft-deferral-v1`

Mode: compatibility checkpoint and visual-stream deferral; no runtime asset
replacement, no image editing, no generated art, no motion implementation.

## 1. Status markers

- `MASCOT_STRATEGY_LOCKED`
- `CONTROLLED_EVOLUTION_OF_ORIGINAL_SHARKY`
- `VISUAL_ASSET_FINALIZATION_DEFERRED`
- `CURRENT_ASSETS_REMAIN_PLACEHOLDERS`
- `SUPPORTIVE_REPAIR_DRAFT_V1_SELECTED`
- `SUPPORTIVE_REPAIR_DRAFT_V1_SELECTED_PENDING_FORMAT_NORMALIZATION`

## 2. Compatibility verdict

`repair_asset_format_incompatible_stop`

The owner-selected draft is accepted as the preferred temporary Supportive
Repair direction, but it is not compatible with the active runtime asset
contract without visual editing.

Input draft:

`/Users/elmarsalimzade/Downloads/39aef078-22d5-4c09-b51d-df75a55739ac.png`

Input inspection:

- format: PNG
- dimensions: 1122x1402
- mode: RGB
- alpha/transparency: none
- visible background: baked yellow/orange pixels
- SHA-256:
  `d552003e7b0b0391747b4341db9db22404362d566467300c9ebf20481a38f2cc`

Active Repair contract:

- runtime path: `assets/images/mascot/sharky_repair.png`
- format: PNG
- dimensions: 373x462
- mode: RGBA
- alpha/transparency: required by the active character asset family
- alpha range: 0..255
- runtime resolver:
  `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`
- runtime mapping:
  `Act0SharkyMoodV1.repair => assets/images/mascot/sharky_repair.png`
- asset registration: directory bundle `assets/images/mascot/` in
  `pubspec.yaml`

Because the selected draft has no alpha channel and contains a baked
background, it was not copied over the active Repair asset. No background
removal, alpha fabrication, resizing, redraw, or replacement was performed.

## 3. Archive and runtime result

The previous active Repair asset remains in place:

`assets/images/mascot/sharky_repair.png`

No archive copy was added because the runtime asset was not replaced and Git
history already preserves rollback for the unchanged tracked file. The
owner-selected draft remains outside active runtime at the input path above.
No runtime reference points to the draft or to an archive-only file.

## 4. Strategy and route decision

Full mascot replacement remains rejected. The serious-premium exploration is
superseded. Original Sharky remains the canonical identity, and the active
strategy is controlled evolution of Original Sharky rather than full
replacement or serious-premium redesign.

The new Repair draft is emotionally safer than the current anxious Repair
state, but it is not final art and is not production-art locked. Further broad
mascot exploration is paused in the active route. Claude remains reviewer and
art director, not the primary illustrator.

Future final mascot work is deferred. The next active work should return to
the non-mascot product roadmap.

## 5. Deferred items

- final Repair lock
- Improve state
- Neutral cleanup
- 16dp mark
- motion-ready asset family
- Product / Progress / Marketing expression pack
- plush/merch proof
- final mascot bible
- animation
- cosmetics

## 6. Scope proof

No production code, runtime mapping, asset manifest, active mascot PNG, SVG
fallback, route, content, telemetry, Modern Table surface, motion behavior, or
cosmetic system changed. The only intended repository change is this checkpoint
document.

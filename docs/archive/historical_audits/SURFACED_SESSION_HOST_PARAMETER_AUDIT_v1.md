Status: active canon

# Surfaced Session Host Parameter Audit v1

## Purpose
This document converts the surfaced-session host gap into measurable layout and scene parameters.

It exists so the next host-migration step can target concrete values and parameter groups instead of another taste-driven polish pass.

This is not a redesign spec. It is a migration-readiness bridge between:
- the best earlier table-first host baseline
- the current surfaced World 2 session host baseline

## Compared hosts

### Best old table-first host baseline
- `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`

### Current surfaced session host baseline
- `lib/ui_v2/screens/session_drill_player_v1_screen.dart`
- embedded `lib/ui_v2/screens/modern_table_screen_v1.dart`

## Parameter groups audited
Only measurable groups that can guide a bounded migration are included:
- host vertical ratios
- table / felt silhouette
- seat-anchor geometry
- board tray placement and scale
- hero-card size and placement
- marker treatment
- prompt / top-rail placement
- action / post-table flow
- typography scale where it materially affects host hierarchy

## Parameter baseline: old host

### Host vertical ratios
- portrait stadium width scale: `1.22`
- portrait stadium height scale: `1.36`
- portrait table viewport width factor: `0.98`
- portrait table viewport height factor: `0.86`
- portrait center dy factor: `0.48`

Interpretation:
- the old host gives the stadium an intentionally dominant portrait footprint
- the table is treated as the central vertical band, not a subordinate module

### Stadium / felt silhouette
- stadium width: `0.68`
- stadium height: `0.86`
- effective portrait result is widened and stretched through the portrait multipliers above

Interpretation:
- the old host preserves a clear stadium silhouette while still filling portrait aggressively

### Seat-anchor geometry
- canonical seat anchors:
  - `btn`: `(0.50, 0.93)`
  - `sb`: `(0.16, 0.70)`
  - `bb`: `(0.16, 0.30)`
  - `utg`: `(0.50, 0.07)`
  - `hj`: `(0.84, 0.30)`
  - `co`: `(0.84, 0.70)`
- marker toward center factor: `0.14`

Interpretation:
- old host seat geometry is semantically authored around poker seat ids, not only generic radial slots
- anchor locations are part of the semantic readability, not just ornament

### Board tray placement / scale
- `boardCenter`: `(0.50, 0.46)`
- `boardCenterLower`: `(0.50, 0.57)`
- board card scale:
  - compact phone: `1.52`
  - regular portrait: `1.72`

Interpretation:
- board placement is intentionally chosen relative to learning mode and prompt density
- the old host treats the board lane as a true scene lane, not a decorative tray

### Hero-card size / placement
- `heroCardsCenter`: `(0.50, 0.72)`
- hero cards rect:
  - compact phone: `128 x 46`
  - regular portrait: `146 x 54`
- hero card scale:
  - compact phone: `2.15`
  - regular portrait: `2.42`

Interpretation:
- hero cards are meaningfully oversized relative to shared scene cards
- hero hand is a semantic primary object, not just another card widget

### Prompt / top-shell discipline
- old host prompt is scene-adjacent and lane-aware
- prompt density is constrained by the same portrait geometry that controls the table

Interpretation:
- prompt placement is a geometry contract, not just a padding choice

## Parameter baseline: current surfaced host

### Host vertical ratios
- surfaced World 2 top section max height:
  - `constraints.maxHeight * 0.105`
  - clamped to `64..92`
- surfaced World 2 top padding:
  - horizontal `12`
  - vertical `6 -> 0`
- current host middle-band improvement depends mostly on shell compression, not explicit table viewport math

Interpretation:
- current host top shell is much improved, but table dominance is still achieved indirectly
- it does not yet have an explicit “table owns portrait” parameter layer comparable to the old host

### Embedded table / felt silhouette
- table aspect ratio: `1.42`
- table width ratio: `0.89`
- board width ratio: `0.68`
- scene fill factor: `0.9`
- seat radius: `0.92`
- header height inside embedded table: `56`

Interpretation:
- current embedded table now has a better stadium feel than before
- but the main host still does not drive the scene through the same explicit portrait viewport contract as the old host

### Seat-anchor geometry
- current anchors are normalized slot anchors rather than semantic poker seat ids:
  - hero bottom: `(0.0, 1.0)`, radial `1.02`
  - top center: `(0.0, -1.0)`, radial `0.88`
  - right / left rail: `(±1.0, 0.0)`, radial `0.98`
  - lower corners: `(±0.74, 0.94)`, radial `0.99`
  - upper corners: `(±0.74, -0.90)`, radial `0.93`
  - upper rails: `(±0.96, -0.34)`, radial `0.98`

Interpretation:
- current seat anchors are workable and now visually stronger
- but they are still a generic host geometry, not as semantically intentional as the old host’s authored poker-seat map

### Board tray placement / scale
- board width ratio: `0.68`
- board padding:
  - vertical `6`
  - horizontal `8`
- board tray radius: `18`

Interpretation:
- current board tray is visually improved
- but its scene position and size are not yet parameterized relative to the host in the same expressive way as the old host

### Hero-card size / placement
- hero card scale: `1.28`
- hero card bottom padding: `8`
- hero card pot gap: `8`
- hero card board gap: `6`
- hero overlap ratio: `0.30`

Interpretation:
- current hero cards are improved
- but they are still much less dominant than the old host’s portrait hero-card treatment

### Prompt / top-rail discipline
- prompt rail is now scene-adjacent and compact
- prompt lives in the surfaced host shell, not in felt geometry

Interpretation:
- this is better than earlier stacked-card treatment
- but still weaker than the old host’s more geometry-bound scene prompt placement

### Action / post-table flow
- current surfaced host now correctly uses post-table consequence/action flow

Interpretation:
- this group is already in acceptable shape and is not the next highest-EV migration target

## Difference map by parameter group

### 1. Host portrait table dominance
Old host:
- explicit portrait viewport and center factors drive the entire scene

Current host:
- table dominance is improved mostly by shrinking chrome above it

Assessment:
- this is a structural gap, not a cosmetic gap
- current host still needs a stronger explicit host-to-scene ratio contract

Classification:
- `adaptation candidate`

### 2. Stadium / felt silhouette
Old host:
- uses portrait width/height multipliers on a smaller base stadium

Current host:
- uses a larger direct-width stadium with simpler fill rules

Assessment:
- current host is not wrong, but old values cannot be copied 1:1 because the new host embeds a reusable table module

Classification:
- `adaptation candidate`

### 3. Seat anchors
Old host:
- semantic poker-seat mapping

Current host:
- generic reusable slot system

Assessment:
- direct migration would couple embedded table too tightly to one specific runtime shape
- but semantic readability lessons from the old host still matter

Classification:
- `non-transfer candidate` for raw coordinates
- `adaptation candidate` for semantic intent

### 4. Board lane placement and scale
Old host:
- explicit board centers and lower board centers tied to mode/layout

Current host:
- fixed board width ratio and tray padding inside the reusable scene

Assessment:
- this is one of the highest-EV remaining gaps
- current host likely needs a more explicit board-lane position parameter, not only tray styling

Classification:
- `direct migration candidate` for “board lane is explicit and mode-aware”
- `adaptation candidate` for exact coordinates

### 5. Hero-card dominance
Old host:
- hero cards are clearly oversized and central to semantics

Current host:
- hero cards are improved, but still much smaller and quieter

Assessment:
- this is one of the clearest measurable remaining gaps

Classification:
- `direct migration candidate` for “hero hand is a semantic primary object”
- `adaptation candidate` for exact scale/rect values

### 6. Prompt placement
Old host:
- prompt is tied more tightly to scene geometry

Current host:
- prompt rail is compact but still a shell element

Assessment:
- the current host is close enough that this should be evolved, not rewritten

Classification:
- `adaptation candidate`

### 7. Post-table action flow
Old host:
- action/consequence follows the table

Current host:
- now already does this reasonably well after R200

Assessment:
- no longer a major migration blocker

Classification:
- `safe where it is`

## Minimum migration-ready invariant set for the next pass

### Direct migration candidates
These can be targeted next with relatively low conceptual risk:
- hero hand should be materially more dominant than shared scene cards
- board lane should be treated as a true semantic lane, not only a styled tray
- host should explicitly preserve a dominant middle-band table ratio at the parameter level

### Adaptation candidates
These should migrate by intent, not by copying raw values:
- portrait table viewport ratios
- stadium width/height relationship
- prompt placement relative to the scene
- exact board center and hero-card center geometry
- marker placement semantics

### Non-transfer candidates
These should not be copied directly:
- old host raw poker-seat anchor coordinates
- old host mode-specific runtime geometry branches
- old host portrait constants that assume the older runner/runtime contract

## Recommended next bounded migration prompt
The next host migration should be parameter-driven and target this exact set:

1. strengthen explicit table-dominance math in the surfaced host
2. increase hero-hand dominance using adapted, not copied, old-host scale logic
3. make board lane placement more explicit and scene-semantic
4. tighten prompt-to-scene placement only if it supports the three items above

It should avoid:
- raw seat-anchor transplantation
- broad retheme work
- more shell-only polishing

## Decision rule
If a proposed host change cannot be tied to one of the measured groups above, it is not the next migration step.

If a proposed host change depends on copying old-host runtime logic instead of adapting old-host layout intent, it should be rejected.

Status: active canon

# Old Table Dependency Transplant Audit v1

## Purpose
This document explains why the old World1 table host works as a coherent trainer surface, compares that dependency system to the current surfaced World 2 host, and defines the minimum coherent transplant package for a later bounded implementation step.

It exists to stop the surfaced host from drifting into more low-EV local polish and to make the next table migration a single system move instead of another pile of tweaks.

This is not a runtime plan. It is a visual/layout/system dependency plan.

## Reference baselines

### Old strong table baseline
- [world1_foundations_microtask_runner_screen.dart](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart)

### Current surfaced table baseline
- [modern_table_screen_v1.dart](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/lib/ui_v2/screens/modern_table_screen_v1.dart)
- [session_drill_player_v1_screen.dart](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/lib/ui_v2/screens/session_drill_player_v1_screen.dart)

### Related surfaced-host canon
- [SURFACED_SESSION_HOST_INVARIANT_AUDIT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/plan/SURFACED_SESSION_HOST_INVARIANT_AUDIT_v1.md)
- [SURFACED_SESSION_HOST_PARAMETER_AUDIT_v1.md](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/docs/plan/SURFACED_SESSION_HOST_PARAMETER_AUDIT_v1.md)

## Why the old table works as a system
The old World1 host works because its felt, seat map, board lane, markers, hero cards, and instruction placement are all controlled by one coherent portrait-scene contract.

The strongest system properties are:
- the felt owns the screen through explicit portrait scene ratios
- seat anchors are semantically authored around poker seats, not only generic radial slots
- board lane and hero hand are placed as part of one learning lane, not as isolated widgets
- dealer / blind / acting markers are positioned with seat-safe and board-safe rules
- instruction placement is geometry-aware, so prompt density never fully breaks scene dominance

The result is trainer feel, not just better decoration.

## Dependency groups

### 1. Table aspect ratio / silhouette / radius stack
Old host:
- smaller base stadium plus aggressive portrait width/height multipliers
- strong oval silhouette
- radius and safe-rect math tied to marker placement and hero/card lanes

Current surfaced host:
- direct reusable oval with simpler aspect-ratio and width-ratio settings
- improved silhouette, but still more generic and less mode-aware

Why the old host feels stronger:
- the silhouette is not only aesthetic; it controls everything else downstream

Classification:
- direct transplant candidate:
  - portrait-first table ownership as an explicit contract
- transplant with adaptation:
  - exact aspect-ratio / width / height values
  - radius stack and safe-rect calculations
- non-transfer:
  - old host branch-specific portrait bucket logic copied 1:1

### 2. Felt / border / shadow / contrast stack
Old host:
- felt, outer rail, inner ring, and lane contrast form one depth stack
- contrast is functional, not decorative

Current surfaced host:
- much improved from earlier state, but still more modular and slightly noisier

Why the old host feels stronger:
- the felt stack makes seats, lane, and cards belong to one plane

Classification:
- direct transplant candidate:
  - layered rail/felt contrast as one system
- transplant with adaptation:
  - exact gradients, opacities, and shadow strengths
- non-transfer:
  - any host-specific decorative overlays that exist only because of the old runtime composition

### 3. Normalized seat anchor geometry
Old host:
- authored around poker seat ids (`btn`, `sb`, `bb`, `utg`, `hj`, `co`)
- positions are semantically meaningful

Current surfaced host:
- reusable normalized slot anchors
- visually improved, but still generic

Why the old host feels stronger:
- seat placement reinforces poker meaning, not just visual balance

Classification:
- direct transplant candidate:
  - semantic seat grouping intent
- transplant with adaptation:
  - anchor family shape and relative grouping
- non-transfer:
  - raw old host seat coordinates copied directly into the reusable surfaced table

### 4. Seat spacing rules and relative grouping
Old host:
- top, rail, and lower seats form intentional families
- spacing works with board lane and hero lane, not independently

Current surfaced host:
- anchors are improved, but spacing still behaves more like generic ring distribution

Why the old host feels stronger:
- the eye reads position groups immediately

Classification:
- direct transplant candidate:
  - grouped spacing logic by semantic seat family
- transplant with adaptation:
  - spacing constants and radial pull factors
- non-transfer:
  - any grouping dependent on old host-only seat count branches

### 5. Board lane position / size / semantic integration
Old host:
- board lane is explicit and mode-aware
- board center, lower board center, and scale change with learning context

Current surfaced host:
- tray is much better than before
- still slightly too tray-like and insufficiently host-aware

Why the old host feels stronger:
- the board lane is treated as the semantic center of the visible poker state

Classification:
- direct transplant candidate:
  - board lane as an explicit semantic lane
- transplant with adaptation:
  - exact center/offset/scale parameters
- non-transfer:
  - raw old host lower-board branches without preserving new surfaced composition rules

### 6. Hero / villain card placement and hierarchy
Old host:
- hero hand is deliberately oversized and semantically primary
- hero placement is locked into the lane system

Current surfaced host:
- hero hand is stronger than before
- villain and hero comparison still feel more “added in” than lane-native

Why the old host feels stronger:
- card hierarchy is part of the scene grammar, not just scale

Classification:
- direct transplant candidate:
  - hero hand as semantic primary object
- transplant with adaptation:
  - exact card scale, overlap, tray/underlay, and lane offset
- non-transfer:
  - old host hand placement copied without adapting to embedded surfaced host constraints

### 7. In-table info / prompt placement
Old host:
- prompt/instruction is geometry-aware and scene-adjacent
- it participates in the table scene rather than sitting above it as a page block

Current surfaced host:
- strongly improved after recent host work
- still more shell-driven than felt-driven

Why the old host feels stronger:
- guidance lives near the scene it explains

Classification:
- direct transplant candidate:
  - scene-adjacent guidance principle
- transplant with adaptation:
  - exact prompt location, budget, and interaction with board lane
- non-transfer:
  - restoring old host runtime-specific prompt overlays or instruction branches

### 8. Table-to-header / table-to-post-band ratios
Old host:
- table owns portrait; header and consequence zones are subordinate

Current surfaced host:
- much improved, but still more shell-mediated

Why the old host feels stronger:
- the ratio system makes the table the trainer, not a child widget

Classification:
- direct transplant candidate:
  - explicit table-first ratio contract
- transplant with adaptation:
  - exact height ratios in the surfaced host
- non-transfer:
  - old host portrait ratio code copied verbatim without respecting the surfaced session shell

### 9. State marker placement / offsets
Old host:
- dealer, blind, and acting markers are placed with avoid-rect and centerward rules
- markers are part of seat + lane geometry

Current surfaced host:
- markers are much better than before
- still more overlay-like and less governed by a full marker placement contract

Why the old host feels stronger:
- markers support reading the state, not just labeling it

Classification:
- direct transplant candidate:
  - markers belong to seat/lane geometry, not free overlay space
- transplant with adaptation:
  - centerward shift factors, gap rules, safe-rect behavior
- non-transfer:
  - old host branch-specific marker collision code copied wholesale before phase 2 state richness exists

### 10. Typography / contrast dependencies that affect trainer feel
Old host:
- typography is secondary to geometry, but weights, contrast, and size support scene reading

Current surfaced host:
- readable, but still more modular and slightly less disciplined

Why the old host feels stronger:
- text never fights the felt

Classification:
- direct transplant candidate:
  - quiet secondary text, stronger primary semantic text
- transplant with adaptation:
  - exact size, shadow, and opacity values
- non-transfer:
  - old host typography tokens copied blindly without surfaced host context

## What must move together
The old table does not win because of one parameter. It wins because four dependency bundles reinforce each other:

### Bundle 1: Table / felt geometry contract
Includes:
- aspect ratio
- width/height ownership
- rail/felt contrast
- safe-rect assumptions

If this bundle does not move together, the scene still reads generic even if individual values improve.

### Bundle 2: Seat geometry + seat spacing contract
Includes:
- semantic anchor family
- rail/top/bottom grouping
- seat-to-felt anchoring
- marker-safe seat neighborhood

If only one part moves, the scene stays hybrid.

### Bundle 3: Board / hero / marker lane contract
Includes:
- board lane center and scale
- hero-hand dominance
- relative placement of state markers to seats and lane
- semantic lane treatment instead of decorative tray treatment

If only board styling moves, the scene still lacks trainer-grade state readability.

### Bundle 4: Host-to-scene ratio contract
Includes:
- top/header budget
- table ownership
- post-table consequence budget
- scene-adjacent guidance rule

This is already partly improved in the surfaced host, but it still constrains the previous three bundles.

## Minimum coherent transplant package
This is the smallest package that should be transplanted together in a later bounded implementation step.

### Package A: Coherent scene package
Move together:
- table/felt geometry contract
- seat geometry + seat spacing contract
- board / hero / marker lane contract

Why:
- these three are visually and semantically coupled
- moving only one keeps the surfaced table in an awkward hybrid state

### Package B: Host ratio support layer
Keep bounded but aligned:
- preserve the improved surfaced shell
- adjust only the ratio/framing needed to let Package A read correctly

Why:
- this layer should support the scene package, not become the main task again

## What can remain current for now
These are not required to reproduce the old trainer feel in the next bounded step:
- broad typography retheme
- new animation system
- broader session-shell restyling
- world-specific decorative variants
- deeper prompt language redesign
- broader marker richness beyond currently truthful projected state

## Recommended next bounded implementation slice
The next implementation step should be one large-but-bounded coherent transplant package centered on:

1. `modern_table_screen_v1.dart`
   - transplant/adapt the table/felt geometry contract
   - transplant/adapt the semantic seat grouping contract
   - transplant/adapt the board/hero/marker lane contract

2. `session_drill_player_v1_screen.dart`
   - only minimal host-framing changes if needed to preserve scene ownership

The next step should explicitly avoid:
- reintroducing old runtime logic
- copying raw old seat coordinates without adaptation
- mixing unrelated shell polish with the package

## Decision rule
If a proposed change does not move at least one whole dependency bundle, it is probably another low-EV local tweak and should not be the next implementation step.

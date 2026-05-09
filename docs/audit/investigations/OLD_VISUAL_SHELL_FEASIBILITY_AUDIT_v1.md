Status: Canonical planning audit  
Scope: Surfaced session host decision support  
Use: Decide whether to keep migrating the current surfaced host or reuse the old strong visual shell with the new runtime

# Purpose
This document answers one bounded question:

Can the old strong visual table shell from `world1_foundations_microtask_runner_screen.dart` host the new source-driven/session-driven/scenario runtime more effectively than continuing to migrate the current surfaced host?

This is a feasibility and EV decision artifact only. It does not authorize a shell transplant by itself.

# Reference Baselines
## Old strong visual shell
Source:
- `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`

Key characteristics:
- one integrated trainer surface
- strong portrait-first felt ownership
- geometry-aware prompt and instruction placement
- table-scene-first hierarchy
- lane-aware marker, blind, and seat treatment
- strong semantic coupling between prompt, board lane, hero area, and state markers

## Current surfaced host
Sources:
- `lib/ui_v2/screens/session_drill_player_v1_screen.dart`
- `lib/ui_v2/screens/modern_table_screen_v1.dart`

Key characteristics:
- correct active runtime path
- source/session/scenario driven
- embedded table scene inside surfaced session host
- truthful projection hooks already established for:
  - hero cards
  - board cards
  - villain cards
  - seat roles
  - folded/empty seats
  - acting state
  - `BTN` / `SB` / `BB` markers where derivable

# Decision Question
Which path is stronger now?

1. Continue migrating the current surfaced host
2. Reuse the old visual shell with the new runtime

# Coupling Audit: Old Shell vs New Runtime
## 1. Old event-flow coupling
Old shell is tightly coupled to:
- `checkpoint`
- `campaign_spine`
- `review_queue`
- guided seat intros
- old runner-specific progress and bankroll HUD
- old action validation and continuation flow

Evidence:
- runner modes and checkpoint logic are spread throughout `world1_foundations_microtask_runner_screen.dart`
- scene composition is interleaved with runner state, checkpoint seeds, review queue behavior, and campaign action UI state

Assessment:
- not safely reusable as-is
- any direct reuse would require stripping or bypassing a large amount of runtime-aware shell logic

Classification:
- non-transfer candidate

## 2. Old action-band and CTA coupling
Old shell owns:
- check / continue / retry flows
- action chip bars
- outcome surfaces
- hint bubbles
- portrait coach strips
- multiple old CTA placements

Assessment:
- this is not just a visual shell
- it is a visual shell merged with old trainer-state orchestration

Classification:
- non-transfer candidate

## 3. Old prompt / instruction placement coupling
Old shell has strong prompt placement, but it is intertwined with:
- old seat-quiz branches
- old intro/prelude variants
- old lane-safe overlay logic
- old mode-specific instruction surfaces

Assessment:
- principle is reusable
- exact implementation is not

Classification:
- transplant with adaptation

## 4. Old table-scene geometry and lane system
Old shell contains the strongest geometric system:
- felt ownership
- stadium grouping
- board-lane semantics
- marker-to-lane relation
- hero-area prominence

Assessment:
- this is the highest-value reusable part
- the system is visual/layout-first and can be adapted without importing old runtime behavior

Classification:
- reusable directly by system intent
- transplant with adaptation at implementation level

## 5. Old seat / marker safe-placement rules
Old shell includes strong rules for:
- seat grouping
- semantic spacing
- dealer/blind marker relation to seat geometry
- lane-safe marker positioning

Assessment:
- good candidate as a system reference
- exact rule code is too tied to the old host’s portrait branches and mode assumptions

Classification:
- transplant with adaptation

## 6. Old host-to-scene ratio contract
Old shell has better ratio discipline:
- less page-shell feel
- stronger table ownership
- prompt and consequence budget arranged around the scene

Assessment:
- principle is reusable
- current surfaced host can absorb this without adopting old runtime

Classification:
- direct migration candidate by intent

# Reusability Map
## Reusable directly
These are safe to keep using as reference standards and continue migrating into the current surfaced host:
- table-first ratio philosophy
- dominant middle-band ownership
- scene-adjacent guidance rule
- board lane as a semantic lane, not decorative tray
- hero hand as the semantic primary object when relevant

## Reusable with adaptation
These are the strongest practical migration targets, but should be adapted into the current surfaced host rather than copied:
- table/felt aspect and silhouette stack
- seat anchor family and spacing logic
- marker placement relative to seats and board lane
- prompt placement relative to scene geometry
- hero/villain/board relationship
- contrast hierarchy for trainer readability

## Too tightly coupled to old runtime
These should not be reused as a shell:
- checkpoint/review/campaign runtime branches
- old CTA / action-band / outcome-surface orchestration
- old progress/HUD stack
- mode-specific overlay branches tied to old microtask state
- old navigation and continuation flow

# EV Comparison
## Path A: Continue current surfaced-host migration
Pros:
- stays on the real active runtime
- preserves existing truthful source projection hooks
- lower integration risk
- every improvement lands directly on the current product surface
- avoids rebuilding host composition around old runner assumptions

Cons:
- requires more discipline to avoid low-EV polish loops
- must move coherent bundles, not local tweaks

Expected EV:
- high, if work stays package-based and system-level

## Path B: Reuse old visual shell with new runtime
Pros:
- visually attractive on paper because the old shell is stronger
- could produce a strong trainer feel if it were cheaply adaptable

Cons:
- shell is not actually just a shell
- deeply entangled with old runtime, prompts, CTAs, progress HUD, and mode logic
- high risk of building a second host path or spending substantial effort stripping old behavior
- threatens the “one canonical truth path” rule

Expected EV:
- lower than Path A at current repo state

# Recommendation
Recommendation: continue migrating the current surfaced host, not reuse the old visual shell wholesale.

Reason:
- the old shell is a strong visual-system reference
- but it is too tightly coupled to old runtime assumptions to be the next implementation vehicle
- the highest-EV path is to keep the new surfaced host as the canonical product surface and transplant old visual-system bundles into it

In short:
- old shell = reference system
- current surfaced host = implementation vehicle

# Minimum Safe Use of the Old Shell Going Forward
The old shell should continue to be used as:
- geometry reference
- ratio reference
- lane/marker/seat semantic reference
- trainer-feel benchmark

It should not be used as:
- a direct shell transplant target
- a runtime host
- a shortcut around current surfaced-host migration

# What Would Have To Be True To Reuse the Old Shell
Reusing the old shell would only become attractive if all of these were true:
- visual shell pieces could be cleanly separated from old runner logic
- CTA/action/outcome layers could be removed without destabilizing layout
- prompt placement system could be isolated without old mode branches
- scene-level components could be hosted without campaign/checkpoint/review assumptions

Current repo state does not satisfy that cheaply enough.

# Unambiguous Next-Step Rule
The next implementation prompt should assume:

1. keep the current surfaced host as the canonical surface  
2. use the old shell only as a visual/system reference  
3. move only coherent dependency bundles, not local tweaks  

Do not propose:
- “rebuild the current surface on the old shell”
- “reuse the old host directly”
- “temporarily branch a second host”

# Best Next Bounded Implementation Shape
If implementation resumes after this audit, the strongest next move is:
- continue current surfaced-host migration with one coherent bundle that still materially affects trainer feel
- likely centered on remaining scene-semantic projection or one more coherent visual-system bundle
- not a shell swap

# Decision Rule
If a future proposal depends on importing old runtime-aware shell code, it is almost certainly the wrong path.

If a future proposal uses the old shell only as a geometry/layout/semantic reference and lands directly on the current surfaced host, it remains aligned with the highest-EV path.

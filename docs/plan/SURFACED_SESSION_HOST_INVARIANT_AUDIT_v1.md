Status: active canon

# Surfaced Session Host Invariant Audit v1

## Purpose
This document defines the minimum high-EV layout/visual invariant set that should be migrated from the best older table-first host into the current surfaced session host.

It exists to prevent the next host-improvement step from degrading into vague "make it nicer" work or broad redesign churn.

## Compared hosts

### Best older table-first host baseline
- `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`

### Current surfaced session host baseline
- `lib/ui_v2/screens/session_drill_player_v1_screen.dart`
- embedded `lib/ui_v2/screens/modern_table_screen_v1.dart`

## Why the older baseline is better
The older host is materially stronger because it enforces a table-first layout contract instead of stacking instructional UI above a table scene.

Its strongest practical qualities are:
- compact header chrome
- dominant middle-band table/felt region
- instruction placement that feels scene-adjacent rather than page-adjacent
- less competing chrome above the table
- calmer transition from prompt -> table -> action
- stronger visual unity of one coherent table experience

## Current surfaced host strengths
The current surfaced host already has real advantages that must be preserved:
- source-driven/session-driven runtime
- embedded table mounting
- repaired asset/runtime/access path
- class-level surfaced World 2 live-session reliability
- calmer shell than the early repaired version
- feedback moved below the table in the latest host migration

This document does not recommend reverting any of that.

## Current surfaced host weaknesses
The current surfaced host is still weaker than the older baseline in the following class-level ways:

### Structural/layout weaknesses
- The top shell still consumes too much attention before the table.
- Prompting still reads as page content first, scene guidance second.
- The table does not yet dominate the screen as clearly as the older host.
- Meta/status chrome still feels closer to session/debug UI than premium table UI.
- The action/consequence zone is improved, but the whole stack still reads as layered boxes instead of one unified table surface.

### Cosmetic-only differences that matter less
- minor font weight/tone differences
- chip styling details
- exact shadow/radius choices
- exact color nuance

These should not drive the next migration step.

## Exact difference map

### 1. Vertical ratio discipline
Older baseline:
- header stays compact
- table owns the central and largest vertical band
- instruction and consequence are subordinate

Current surfaced host:
- top shell still competes too much with the felt

### 2. Prompt placement discipline
Older baseline:
- prompt/instruction feels attached to the scene
- the eye reaches the table quickly

Current surfaced host:
- prompt still feels like a card above a scene

### 3. Chrome compactness
Older baseline:
- status/header chrome is informational but visually quiet

Current surfaced host:
- status/meta still pull too much attention for a table-first flow

### 4. Action-zone calmness
Older baseline:
- action/consequence placement follows the table, not the other way around

Current surfaced host:
- action zone is improved, but still needs stronger "after the table" calmness as a host invariant

### 5. Scene unity
Older baseline:
- reads like one host with one central experience

Current surfaced host:
- still partially reads like a session shell plus an embedded table module

## Minimum invariant set worth migrating next
This is the bounded next migration set. Nothing larger is justified yet.

### Invariant 1: Compact header budget
- The surfaced host top shell must behave as compact status chrome, not a primary content region.
- Session title, progress, and status should remain visible but visually quiet.

### Invariant 2: Dominant middle-band table
- The table/felt must own the largest vertical band of the screen.
- The host should optimize around preserving table dominance before adding more pre-table chrome.

### Invariant 3: Scene-adjacent prompt placement
- The primary prompt should move closer to the table scene contractually.
- The surfaced host should stop reading like "page card above scene" and move toward "guidance attached to scene."

### Invariant 4: Post-table consequence/action flow
- Active feedback and action controls should belong to the area after the table.
- They should not visually compete with the table band unless the current mode absolutely requires it.

### Invariant 5: Low-noise status/meta treatment
- Session status/meta should be flattened and quiet.
- Anything debug-like or raw-id-like must remain suppressed in surfaced mode.

### Invariant 6: One-host scene unity
- The user should perceive one coherent surfaced table experience, not a stack of independent blocks.
- Embedded table mode should feel integrated into the host, not inserted into it.

## What should remain local for now
The following are not yet justified as shared migration requirements:
- broad color retheme
- full typography overhaul
- new animation system
- new design-system tokens
- world-specific decorative differences
- deeper table-engine visual rewrites

## Next bounded migration prompt should target
The next host-improvement step should migrate the invariant set above, in this order:
1. compact header budget
2. dominant middle-band table ratio
3. scene-adjacent prompt placement
4. calmer post-table consequence/action flow
5. final scene-unity cleanup

## Decision rule
If a proposed host change does not improve table dominance, prompt placement, chrome compactness, or scene unity, it is not part of this migration set and should not be mixed into the next bounded host step.

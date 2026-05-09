# Design Handoff Snapshot

This folder provides a static snapshot of the Poker Analyzer UI for design review.

## Structure
- `screenshots/` – placeholder for captures of key flows.
- `components/` – read-only copies of `lib/ui_v2/*.dart` widgets.
- `brand/` – palette and token exports for Figma/Sketch imports.
- `docs/` – guides covering layout, flow, and component catalogues.

## Usage
1. Review `layout_guides.md` before adjusting grid or spacing tokens.
2. Reference `components_index.md` when mapping widgets to design components.
3. Use `flow_map.md` to confirm navigation when building prototypes.
4. Consume `brand/palette.json` to seed design libraries.

All files are snapshots—no runtime logic is loaded from `/design/`. Update as part of each major UI release.

# Full-Scroll Screen Evidence v1

## Verdict

`full_scroll_evidence_lane_ready`

## Current screenshot limitation

The existing fast review packets captured one compact top viewport per deterministic Act0 state. That was sufficient for first-action and feedback proof, but it could not show lower-screen hierarchy, repetition, account/settings placement, or compact-screen scroll fatigue.

## Long-screen candidates

- Home: scrollable, though the seeded first-week state currently has a short extent.
- Learn: scrollable path and journey context.
- Practice: scrollable hero, quick-rep, and topic shelves.
- Review: included because it can grow with repair history; the current deterministic first-week state has no scroll extent.
- Profile: scrollable proof, rhythm, skill, achievements, and account/settings content.
- Session summary: scrollable block-completion evidence and handoff.

## Chosen full-scroll capture strategy

The new local-only `full_scroll` group repumps each existing deterministic capture state and captures its primary scrollable at top, midpoint, and bottom. The harness selects the scrollable with the largest extent, uses its live `ScrollPosition`, and records the applied offset. This uses no OCR, device automation, or image stitching.

The primary command is:

```bash
./tools/screen_review_fast_v1.sh full_scroll compact
```

The strategy deliberately captures viewport sequences rather than a synthetic full-page bitmap. It preserves exactly the compact viewport that a learner sees and remains deterministic in Flutter widget tests.

## Output naming

Output root:

```text
output/screen_review/current/full_scroll_fast/
```

Examples:

- `compact.profile.scroll_01_top.png`
- `compact.profile.scroll_02_mid.png`
- `compact.profile.scroll_03_bottom.png`
- `compact.session_summary.scroll_01_top.png`
- `contact_sheet.png`
- `screen_review_full_scroll_fast.zip`

## Metadata/package decision

`full_scroll_meta.json` is generated locally and includes each screen, capture order, source capture state, requested viewport, applied offset, maximum extent, and whether the bottom was reached.

The local zip includes all viewport PNGs, `manifest.json`, `full_scroll_meta.json`, the contact sheet, README, and packet index. None of these generated artifacts are committed.

## Implemented tooling slice

- `./tools/screen_review_fast_v1.sh full_scroll compact` accepts the new explicit local-only group.
- `tools/act0_real_text_surface_capture_v1.dart` defines the six existing deterministic screen states and records live scroll-position evidence.
- `tools/package_screen_review_v1.py` packages the `full_scroll_fast` viewport sequence and metadata.
- The existing capture contract test asserts the group, deterministic Profile and Session Summary entries, metadata, and package command.

## Local generated artifacts

- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/full_scroll_meta.json`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Observed Profile offsets in the deterministic compact state: `0.0`, `545.0`, and `1090.0` of `1090.0` pixels. The bottom capture reached the bottom.

## Boundary proof

- No app UI, copy, routes, progression, telemetry, content/glossary, Modern Table, or session-summary behavior changed.
- No new product state was added; every entry reuses an existing controlled Act0 demo surface.
- No OCR, device-dependent scrolling, CI gate, screenshot comparison, or full native capture lane was introduced.
- Generated screenshots, metadata, contact sheets, and zip remain ignored/local-only.

## Validation results

- Focused full-scroll capture contract test passed.
- `./tools/screen_review_fast_v1.sh full_scroll compact` completed and produced 18 viewport PNGs, metadata, contact sheet, and zip.
- Profile top/middle/bottom offsets were verified from `full_scroll_meta.json`.
- Review reports zero extent for the current seeded first-week Review state; its three captured viewports are intentionally equivalent rather than pretending a backlog exists.

## How Claude/Codex should use this evidence

- Use `contact_sheet.png` to review compact-screen hierarchy and continuity across the full active surface.
- Use individual `scroll_01_top`, `scroll_02_mid`, and `scroll_03_bottom` PNGs with `full_scroll_meta.json` when assessing lower-screen density, duplicated sections, settings placement, and scroll fatigue.
- Treat this as local visual evidence only. It does not prove native iOS fidelity and does not authorize product changes by itself.

## Next recommended wave

Run the planned Claude UX/UI v2 audit against the existing first-week, Day 2, and new full-scroll local evidence packets. Keep any resulting product work in a separately scoped implementation wave.

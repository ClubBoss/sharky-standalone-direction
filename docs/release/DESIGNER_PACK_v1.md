# Designer pack v1 · B107 / D2

From the repository root, after refreshing the capture inputs on the checkout the designer is working from:

```sh
python3 tools/designer_pack_v1.py
```

Open `build/designer_pack/index.html` in a browser. Python 3.9+ standard library only. The sheet is rebuilt on each invocation; it links to the original local PNGs (click to open full size). Keep the capture directories alongside the HTML. No images or generated HTML belong in git.

## Inputs and refresh

- `output/screen_review/current/`: `compact.{home,learn,practice,review,profile}.png` and `manifest.json` from `./tools/capture_act0_screens_v1.sh all compact`. This is the existing simulator capture lane; it reinstalls the app on its designated simulator.
- `build/v9/w01/` through `w12/`: PNGs and `row.json` from B100 (`./tools/capture_act0_screens_v1.sh v9 walkthrough`, which uses `tools/act0_widget_capture_v1.dart`). Available once B100 lands. This is a widget-rendered phone viewport, not physical-device evidence. Refresh both lanes after each merge; the pack itself only reads captures and never builds, installs or launches the app. The compact manifest records commit, status, time and device; B100 rows have no commit stamp, so the pack cannot certify freshness.
- `COMPONENT_INVENTORY*.md`: auto-discovered under `docs/`, `reasoning/design_brief/`, or the existing sibling `l0-audit/reasoning/design_brief/` design brief. If your inventory lives elsewhere, pass `--inventory /path/to/COMPONENT_INVENTORY_v1.md`. The generator does not copy or update the canonical inventory.
- `docs/plan/SCREEN_LOGIC_INVENTORY_v1.md`: documented states and data/actions, distinct from observed screenshots.

For alternate capture locations, use `--compact-dir`, `--v9-dir`, and `--inventory`. `--last-world 1` explicitly scopes the walkthrough to W1 for a smoke pass; omit it for the full pack.

## Reading the sheet

| Section | Coverage / meaning |
|---|---|
| Capture issues | Missing or invalid manifests/PNGs, unlisted files, compact capture commit mismatches and failed walkthrough rows. These are visible even when an upstream capture fails. Exit 1 means incomplete inputs; HTML is still written. Exit 0 means expected and manifest-listed captures are present, not exhaustive state coverage. |
| Compact tabs | Home, Learn/Map, Practice, Review, Profile/You, one compact screenshot per tab. |
| W1–W12 walkthrough | Every PNG declared by the per-world B100 row (plus any unlisted PNGs, explicitly flagged). The required minimum per world is lesson start, wrong feedback, repair, result and final result. Additional observed variants include W1 start chooser, map, home, review, learning-run payoff, route-practice phase, theory (text/table and task family), decision (choice/seat/sizing, text/table and family), and feedback (quality/family). B100 keeps one sample per observed kind per world; W2+ seed prerequisites. |
| State contracts and coverage gaps | Existing documented state tables from the screen logic inventory; these specify what designers need to cover, not what the captures prove. |
| Component inventory | All source table rows, including props, states, screen codes, table skin pieces and token references. Kit/New and orientation values are the designer contract, not a verified inventory of rendered widgets. |

## Known gaps

The capture producers do not guarantee a screenshot of every distinct state. Full Welcome demo, Placement/check results, Settings, Archive/Replay, Own hands/manual entry, startup/error/recovery, empty/locked/done variants, Help/sheets, interaction states, accessibility/device variations and optional routes may be absent. A manifest cannot reveal an unobserved dynamic variant; only the independently required five tabs and five baseline frames per world plus explicitly listed PNGs can be checked automatically. B100's `welcome` frame is the W1 start chooser, not the complete Welcome flow. The pack exposes these gaps instead of substituting old screenshots or presenting the state contract as rendered evidence.

Local verification: `python3 -m unittest tools/test/designer_pack_v1_test.py`.

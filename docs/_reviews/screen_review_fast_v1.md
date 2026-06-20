# Fast Real-Text Act0 Screen Review Lane v1

- Branch: `codex/act0-learn-route-clarity-v1`
- Mode: local-only tooling implementation.
- Goal: capture readable first-week Act0 core screens without iOS Simulator, Xcode build, native launch, or web Playwright.

## Why this lane exists

- Native iOS screen review is useful for final device proof, but it is too slow and flaky for daily product review because it builds, installs, and launches through CoreSimulator.
- Web Playwright is not canonical for Act0 real-text proof because prior probes produced blank or incomplete output.
- Product-100 remains the masked geometry and safe-area proof lane; it should not be changed or unmasked.

## Architecture

- `tools/screen_review_fast_v1.sh` is the public command.
- `tools/act0_real_text_surface_capture_v1.dart` generates a temporary Flutter widget test, pumps the existing deterministic Act0 debug surfaces, captures the root `RepaintBoundary`, and writes real-text PNGs.
- `tools/screen_review_fast_text_repair_v1.py` repairs Flutter-test-only Ahem button labels using temporary widget-tree overlay metadata, then removes the temporary overlay JSON before packaging.
- `tools/package_screen_review_v1.py` packages the `core_fast` group into a contact sheet and zip with the existing packet helper.
- Output is staged first and promoted only after every required PNG and manifest exists, preserving the previous good output on capture failure.

## Ahem button-text root cause and fix

- Root cause: `flutter test` uses the Ahem test font by default. Most Act0 text inherits the harness `Roboto` font, but locally styled `FilledButton.styleFrom(textStyle: ...)` CTA labels create a `DefaultTextStyle` with no font family, so those labels still rasterized as Ahem blocks.
- Fix: the generated widget test records only text widgets whose effective test style lacks a font family. The repair helper redraws those exact labels into the PNGs with a local system font and deletes the temporary overlay metadata before the packet is created.
- Product impact: none. This is capture-tooling-only and does not change Act0 UX, copy, layout, routes, telemetry, or Product-100.

## Command

```bash
./tools/screen_review_fast_v1.sh core compact
```

## Output

`output/screen_review/current/core_fast/`

- `compact.home.png`
- `compact.learn.png`
- `compact.practice.png`
- `compact.review.png`
- `compact.profile.png`
- `manifest.json`
- `contact_sheet.png`
- `screen_review_core_fast.zip`
- `README.txt`
- `screen_review_index.json`

## Supported v1 scope

- Group: `core`
- Device: `compact`
- Surfaces: Home, Learn, Practice, Review, Profile

## Lane differences

- Product-100: masked/nonliteral layout, geometry, and safe-area proof.
- Fast real-text Flutter lane: readable product/copy/commercial review proof for daily iteration.
- Native iOS lane: final device proof when native fidelity matters, but not the default daily review path.

## Limitations

- This is Flutter-rendered widget-test output, not a native iOS simulator screenshot.
- It supports only the compact core packet in v1.
- It uses existing deterministic debug surfaces; it does not add navigation, app behavior, or product UI changes.
- The lane includes a capture-only repair pass for Flutter-test button labels because `flutter test` forces Ahem for text styles without a font family.
- Generated screenshots, contact sheets, and zips are local-only and must not be committed.

## Acceptance verdict

- Final command: `./tools/screen_review_fast_v1.sh core compact`
- Runtime observed: about 16 seconds locally.
- Output: all five compact core PNGs, `manifest.json`, `contact_sheet.png`, `screen_review_core_fast.zip`, `README.txt`, and `screen_review_index.json`.
- Visual acceptance: Home, Learn, Practice, Review, and Profile text is readable; CTA/button labels are readable; no obvious Ahem/nonliteral blocks remain in the contact sheet.

## Checks

- `./tools/screen_review_fast_v1.sh core compact`
- `bash -n tools/screen_review_fast_v1.sh tools/package_screen_review_v1.sh`
- `python3 -m py_compile tools/package_screen_review_v1.py tools/screen_review_fast_text_repair_v1.py`
- `dart format tools/act0_real_text_surface_capture_v1.dart`
- `flutter analyze`
- `git diff --check`

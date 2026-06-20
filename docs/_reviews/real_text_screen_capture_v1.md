# Real-Text Act0 Screen Capture v1

- Main reference: `2847c0cd27bf14c7e3cf7e4a486e165cd4de4df1`.
- Web lane: not canonical for real-text proof. First-week Playwright emitted blank white PNGs with empty body semantics; the controlled demo stopped after placement.
- Native launch arguments and `-FlutterInitialRoute` did not select an Act0 capture state because the existing selector reads web `Uri.base` query parameters.
- Solution: debug builds may read `const String.fromEnvironment('SHARKY_CAPTURE_SURFACE')`. Only `home`, `learn`, `practice`, `review`, and `profile` map to the existing deterministic Act0 debug harness states. An empty or unsupported value has no effect; release builds ignore the selector.
- Command: `./tools/capture_act0_screens_v1.sh <home|learn|practice|review|profile|all> compact`.
- Batch command: `./tools/capture_act0_screens_v1.sh all compact`.
- Supported v1: iOS Simulator only, fixed `compact` preset (`iPhone 17`), and the five surfaces above.
- The command clears `output/screen_review/current/`, builds each requested surface with its compile-time define, starts that surface from a fresh iOS Simulator boot, installs and launches it, waits for the debug state to settle, captures with `xcrun simctl io`, and writes `compact.<surface>.png`.
- It also writes `output/screen_review/current/manifest.json` with commit, worktree status, timestamp, device, simulator, surfaces, output paths, and the local-only rule.
- Generated screenshots remain local-only and must not be staged or committed.
- Rule: Product-100 capture remains masked layout/geometry/safe-area proof; `capture_act0_screens_v1.sh` is the real-text product/copy/commercial proof lane. Web Playwright is not canonical for this use.

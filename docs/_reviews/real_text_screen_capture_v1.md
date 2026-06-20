# Real-Text Act0 Screen Capture v1

- Main reference: `2847c0cd27bf14c7e3cf7e4a486e165cd4de4df1`.
- Web lane: not canonical for real-text proof. First-week Playwright emitted blank white PNGs with empty body semantics; the controlled demo stopped after placement.
- Native launch arguments and `-FlutterInitialRoute` did not select an Act0 capture state because the existing selector reads web `Uri.base` query parameters.
- Solution: debug builds may read `const String.fromEnvironment('SHARKY_CAPTURE_SURFACE')`. Only `home`, `learn`, `practice`, `review`, and `profile` map to the existing deterministic Act0 debug harness states. An empty or unsupported value has no effect; release builds ignore the selector.
- Canonical packet command: `./tools/screen_review_v1.sh core compact`.
- Core packet surfaces: Home, Learn, Practice, Review, and Profile.
- Legacy/single-surface command: `./tools/capture_act0_screens_v1.sh <home|learn|practice|review|profile|all> compact`.
- Packet-only command: `./tools/package_screen_review_v1.sh current core` after an existing grouped capture.
- Supported v1: iOS Simulator only, fixed `compact` preset (`iPhone 17`), and the five surfaces above.
- `screen_review_v1.sh` captures into a staging directory first, then promotes the group only after every required surface and packet artifact succeeds. A failed run preserves the prior `output/screen_review/current/core/` packet.
- The grouped command isolates CoreSimulator by shutting down other booted simulators before each surface capture; this avoids stale/multiple-booted-device `simctl launch` hangs observed during local probes.
- Core output: `output/screen_review/current/core/compact.<surface>.png`, `manifest.json`, `contact_sheet.png`, `screen_review_core.zip`, `README.txt`, and `screen_review_index.json`.
- The packet helper writes the contact sheet and zip inside the group directory. Upload `contact_sheet.png` for fast visual review; upload the zip only when detailed per-screen files are needed.
- `learning_flow` is deferred in v1 because the requested states (`table_decision`, `answer_correct`, `answer_wrong`, `lesson_summary`, `result_receipt`, `review_after_error`) are not covered by the current native real-text selector without product/harness expansion.
- Generated screenshots remain local-only and must not be staged or committed.
- Rule: Product-100 capture remains masked layout/geometry/safe-area proof; `screen_review_v1.sh core compact` is the real-text product/copy/commercial proof lane. Web Playwright is not canonical for this use.

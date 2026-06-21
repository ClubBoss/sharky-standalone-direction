# Screen Review Packet v1

- Purpose: package a native real-text Act0 screen-review group into one review image plus a zip archive.
- Primary command: `./tools/screen_review_v1.sh core compact`.
- Packet-only command: `./tools/package_screen_review_v1.sh current core`.
- Core input/output directory: `output/screen_review/current/core/`.
- Core screenshots: `compact.home.png`, `compact.learn.png`, `compact.practice.png`, `compact.review.png`, and `compact.profile.png`.
- Core packet output: `contact_sheet.png`, `screen_review_core.zip`, `README.txt`, and `screen_review_index.json`.
- Contact sheet: labeled Home, Learn, Practice, Review, and Profile panels in a readable grid; original screenshots are not overwritten.
- Zip: includes the original compact PNGs, `manifest.json`, `contact_sheet.png`, `README.txt`, and `screen_review_index.json`.
- Preservation: `screen_review_v1.sh` captures into staging and only replaces `output/screen_review/current/core/` after the full group and packet succeed.
- Stability: the wrapper isolates the target compact simulator before each surface and shuts simulators down before packaging, so capture/packaging does not depend on stale booted simulator state.
- Deferred group: `learning_flow` is intentionally not implemented in v1 because the requested states need additional product/harness coverage.
- Local-only rule: generated PNGs and zip files are evidence artifacts and should not be committed.

Future workflow:

```bash
./tools/screen_review_v1.sh core compact
```

Upload `output/screen_review/current/core/contact_sheet.png` first for fast visual review. Upload `screen_review_core.zip` only when detailed files are needed.

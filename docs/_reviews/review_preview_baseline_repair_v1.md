# Review Preview Baseline Repair v1

- Branch/base: `codex/review-preview-baseline-repair-v1` from `37c88f65fb403e443c0628053f3166d8291222c2`.
- Failures: Review density and deeper-mistake preview tests still targeted the retired prominent mistake-card keys after Review Repair-Coach Entry v1.
- Root cause: stale test finders, not a Review behavior regression.
- Fix: focused preview expectations now assert the active `Repair coach` card and its stable key.
- Product files unchanged; telemetry and routing are untouched.
- Impact on Learn: removes the baseline block; Learn can now be verified against this corrected baseline.
- Next step: run the focused preview suite and fast loop, then package this baseline repair before the Learn PR.

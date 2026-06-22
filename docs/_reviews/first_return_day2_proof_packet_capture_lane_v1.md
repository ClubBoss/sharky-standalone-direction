# First Return / Day 2 Proof Packet Capture Lane v1

## Scope

Local-only deterministic evidence tooling. This pass adds a fast real-text
capture lane for the accepted Day 2 return story. It does not change product
UI, copy, routes, telemetry, Modern Table, Daily Trainer UI, dashboard, XP,
economy, AI/persona, or monetization behavior.

Generated screenshots, manifests, contact sheets, and zip packets remain
local-only and must not be committed.

## Command

```bash
./tools/screen_review_fast_v1.sh day2_return compact
```

Output:

```text
output/screen_review/current/day2_return_fast/
```

## Proof beats captured

The packet captures the Day 2 return proof chain:

1. `open_repair_source` - first-session wrong/suboptimal source with visible
   Repair focus/result context.
2. `return_home` - Day 2 Home prioritizes the open repair.
3. `practice_repair_target` - Practice/repair launch opens the same
   `actions_check_drill` repair target.
4. `review_continuation` - Review shows active repair continuation before
   unrelated recheck/proof work.
5. `profile_not_clear` - Profile remains available and does not falsely report
   a clear state while the repair is still active.

## Artifact paths

- `output/screen_review/current/day2_return_fast/compact.open_repair_source.png`
- `output/screen_review/current/day2_return_fast/compact.return_home.png`
- `output/screen_review/current/day2_return_fast/compact.practice_repair_target.png`
- `output/screen_review/current/day2_return_fast/compact.review_continuation.png`
- `output/screen_review/current/day2_return_fast/compact.profile_not_clear.png`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/manifest.json`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`

## Manifest truth

`manifest.json` uses `group: day2_return`, `packet: day2_return_fast`,
`device: compact`, and lists:

- `open_repair_source`
- `return_home`
- `practice_repair_target`
- `review_continuation`
- `profile_not_clear`

## Implementation notes

- The lane extends the existing fast real-text Flutter-rendered capture
  infrastructure.
- The Day 2 states are deterministic debug-only Act0 preview surfaces seeded
  from the existing accepted open-repair contract.
- The source miss and repair hand reuse the existing W1
  `fold_check_call_raise` / `actions_legal_context` ->
  `actions_check_drill` repair path.
- The first run of the combined wrapper exited 137 without logs, while the
  Dart capture, text-repair, and packaging steps all passed individually. A
  rerun of the full command then passed. No output promotion happened on the
  failed wrapper run until the Dart capture was run directly; the final
  supported command is green.

## Product safety

- Product UI/copy/routes/telemetry changed: no.
- Modern Table changed: no.
- Generated artifacts committed: no.

## Validation

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Fast screen review command exposes Day 2 return proof packet group|Debug Day 2 proof surfaces expose open repair return story'`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`

Pending for packaging:

- `dart format --set-exit-if-changed` on touched Dart files.
- `flutter analyze`.
- `bash -n` on touched shell scripts.
- `python3 -m py_compile` on touched Python scripts.
- `git diff --check`.
- `git status --short`.

## Remaining limitations

- The packet is deterministic proof, not a literal persisted-app replay capture.
- It does not add a native/simctl Day 2 lane.
- Fallback priority examples such as aged recheck, owned proof, and route
  continuation are not captured in this v1 packet because the core Day 2
  open-repair chain is the evidence bottleneck.
- Long contact-sheet labels can visually crowd filenames; the underlying
  per-screen screenshots remain readable.

## Recommendation

Use `day2_return compact` together with the existing `first_week compact`
packet for current product/design/commercial evidence review. Next, run a
commercial screenshot / renderer acceptance pass if final CTA-copy screenshot
quality becomes a release blocker.

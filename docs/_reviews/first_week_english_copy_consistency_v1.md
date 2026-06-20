# First-Week English Copy Consistency v1

- Branch: `codex/act0-learn-route-clarity-v1`
- Mode: local-only visible copy cleanup.
- Goal: keep core first-week Act0 screens English-first after real-text review exposed RU/EN mixing.
- Screenshot capture: intentionally deferred for this pass.

## Files changed

- `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

## Copy areas fixed

- Home: first-week shell copy resolves English visible labels even on RU-locale devices.
- Learn: route card labels, mission copy, and path support copy stay English.
- Practice: daily drill, topic, and calm fallback copy stay English through Act0 atom fallback.
- Review: repair-coach, recovered proof, and calm fallback copy stay English.
- Profile: growth, milestone, progress, level, and streak copy stay English.
- Bottom navigation: fixed to `Home`, `Learn`, `Practice`, `Review`, and `You`.

## Russian intentionally retained

- Existing RU localization bundles and RU alternatives remain in source as deferred localization data.
- Non-core onboarding, placement, and runtime strings were not broadened into this wave unless selected by the first-week core Act0 surfaces.

## Checks

- `flutter analyze`
- `git diff --check`

## Next visual check

After this copy commit, run:

```bash
./tools/screen_review_v1.sh core compact
```

# Visual SSOT v1

Visual SSOT v1 defines the canonical, visual-only constants and layout rules for ModernTableScreenV1.
It covers table geometry, board/card sizing ratios, hero card scale/rotation, and other visual
parameters that are scoped to the table presentation.

Out of scope:
- FSM, engine, scenario loading, and content behavior.
- Data models, gameplay rules, and logic flow.

Introducing SSOT v2:
- Create a new SSOT class or file (do not mutate v1 values in place).
- Add new guards/tests that explicitly target v2.
- Update callers to reference v2 intentionally.

Visual Baseline:
- Reference outputs:
  - out/modern_table_default.png
  - out/modern_table_json.png
  - out/modern_table_asset.png
- Regenerate with:
  - dart run tools/modern_table_screenshot_v1.dart
- Images are reference-only and are NOT tracked in git.

# Visual Lift Audit R2

## 1) Scope + rules (audit-only)
- Audit-only. No code changes, no new features, no telemetry changes.
- Release-path surfaces only.
- Findings are concrete, observable UI gaps.
- File paths referenced below are the audited sources.

Surfaces in scope:
- Progress map / campaign entry: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
- Module summary: `lib/ui_v2/screens/module_summary_screen.dart`
- Theory session: `lib/ui_v2/screens/theory_session_screen.dart`
- Drill runner: `lib/ui_v2/screens/drill_runner_screen.dart`
- Session result: `lib/ui_v2/screens/session_result_screen.dart`
- Onboarding (first launch flow): `lib/onboarding/onboarding_flow_manager.dart`
- Modern Table (audit only, no changes): `lib/ui_v2/screens/modern_table_screen_v1.dart`

## 2) Screen-by-screen gap list

### Progress map / campaign entry
File: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`

Premium already
- Consistent card styling for nodes with tokenized colors and elevation.
- Clear active/locked/completed states with iconography and connector styling.

Gaps
- P1 | typography | App bar title and stat text use mixed raw TextStyle and token styles, causing hierarchy drift. | Fix: unify app bar typography using AppTypography tokens for title and stat labels.
- P1 | state | Empty state is text-only and lacks guidance or CTA to start. | Fix: add a minimal empty state illustration or primary action that routes to the first module.
- P2 | layout | Top bar information cluster (streak/xp/chips) wraps unpredictably on narrow widths. | Fix: consolidate into a single compact status row with consistent spacing rules.
- P2 | color | XP and streak colors use raw literals (gold/orange) instead of system tokens. | Fix: map to design tokens for reward colors to align with palette.

### Module summary screen
File: `lib/ui_v2/screens/module_summary_screen.dart`

Premium already
- Uses SectionSurface and SectionHeader for structured content blocks.
- Clear primary CTA placement at bottom.

Gaps
- P1 | color | Tier pill uses hard-coded blue and does not match app palette. | Fix: map tier badge to tokenized semantic colors and surface styles.
- P1 | typography | CTA and headers mix raw TextStyle with AppTypography. | Fix: align title/subtitle/CTA typography with AppTypography tokens.
- P2 | layout | Module ID is surfaced with equal weight to primary content. | Fix: de-emphasize module ID as metadata (smaller size, lighter color, or collapsed).
- P2 | asset | Screen lacks a visual header/hero, making it feel flat. | Fix: add a lightweight header visual or icon treatment consistent with map nodes.

### Theory session screen
File: `lib/ui_v2/screens/theory_session_screen.dart`

Premium already
- Markdown rendering with readable line height and heading sizes.
- Fixed bottom action for practice is obvious.

Gaps
- P1 | typography | Header title uses raw TextStyle instead of AppTypography, inconsistent with other screens. | Fix: switch title and subheading styles to AppTypography tokens.
- P1 | state | Loading state is a generic spinner with no context. | Fix: add a branded loading placeholder for theory content.
- P2 | layout | Divider at bottom is visually faint and not aligned to content width. | Fix: align divider to content edges and match thickness with global divider rhythm.
- P2 | color | Floating action button uses hard-coded green. | Fix: map CTA color to tokens for primary actions.

### Drill runner screen
File: `lib/ui_v2/screens/drill_runner_screen.dart`

Premium already
- Clear question card container with rounded corners and centered text.
- Quiz flow uses bottom sheet for answer feedback.

Gaps
- P1 | state | No visible progress indicator beyond app bar title. | Fix: add a compact progress bar or step indicator near the top.
- P1 | contrast | Explanation container uses low-contrast surface variant, reducing readability. | Fix: increase contrast or use a tokenized callout surface.
- P1 | state | Quiz answers have no selected/disabled visual state. | Fix: add pressed/selected/disabled states for options.
- P2 | typography | Mixed use of raw TextStyle vs tokens across question, buttons, and explanation. | Fix: standardize on AppTypography for body and CTA styles.

### Session result / completion screen
File: `lib/ui_v2/screens/session_result_screen.dart`

Premium already
- Clear completion headline and summary card with XP emphasis.
- Strong primary CTA to continue.

Gaps
- P1 | layout | Screen feels vertically sparse with no celebratory motion or visual anchor besides icon. | Fix: introduce a lightweight celebratory visual (static or subtle animation) anchored above the summary.
- P2 | typography | Summary text and CTA styles use raw TextStyle rather than tokens. | Fix: align text styles to AppTypography for consistency.
- P2 | state | No secondary action (review details) even when accuracy is low. | Fix: add optional secondary action below CTA for review flow.

### Onboarding (first launch flow)
File: `lib/onboarding/onboarding_flow_manager.dart`

Premium already
- Step indicator conveys multi-step progress.
- Consistent full-width CTA buttons on key steps.

Gaps
- P1 | typography | Mixed font sizes and raw styles across steps create inconsistent hierarchy. | Fix: standardize headings, body, and CTA text with AppTypography tokens.
- P1 | layout | Large single-column blocks with no visual hierarchy beyond icons; screens feel flat. | Fix: add structured sections or cards to separate content groups.
- P1 | color | CTA button styling varies by step (default vs success color) without a clear system. | Fix: define a consistent primary and secondary CTA style across onboarding steps.
- P2 | asset | Icons are generic Material defaults without a cohesive brand set. | Fix: replace or style icons to match brand palette and weight.

### Modern Table (audit only)
File: `lib/ui_v2/screens/modern_table_screen_v1.dart`

Premium already
- Dense visual system with SSOT constraints and extensive QA coverage.
- No gaps found in this audit; do not change per contract.

## 3) Cross-cutting consistency issues
- Token usage drift: multiple screens use raw colors and TextStyle instead of AppTypography and design tokens.
- Padding rhythm varies between screens (AppSpacing vs raw constants), especially in headers and CTA blocks.
- Divider and card radii are inconsistent between map, theory, and drill screens.
- Button states (pressed/disabled/selected) are not consistent, especially in quizzes and onboarding.
- Empty/loading states are minimal and not branded across release surfaces.

## 4) No-go list (do not change)
- Do not change Modern Table SSOT or its contract tests: `lib/ui_v2/screens/modern_table_screen_v1.dart` and related modern table tests.
- Do not alter training logic, progression logic, or onboarding flow control.
- Do not change telemetry, analytics, or event logging.
- Do not introduce new dependencies or assets in this phase.

## 5) Exit criteria for Phase 2 Premium UX polish
- All release-path screens use AppTypography and design tokens for text, color, and surface styling.
- Consistent CTA hierarchy and button states across onboarding, theory, drills, and results.
- Branded empty/loading states for map, theory content load, and drill data load.
- Spacing and divider rhythm aligned to a single system (AppSpacing + tokenized radii).
- Visual polish improvements do not touch Modern Table SSOT or change onboarding logic.

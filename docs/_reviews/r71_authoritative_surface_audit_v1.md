# R71 Authoritative Surface Audit Closeout v1

## Milestone purpose/scope recap
- Determine whether weak visible delta came from fixing secondary seams instead of authoritative first-user surfaces.
- Audit first-user phases for authoritative vs duplicated presentation seams.
- Apply one bounded consolidation fix only if duplication root cause is proven.

## First-user phase map
1. Entry/map phase
- Screen: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
- State family: start-now / next-pack route entry.
- Dominant seams/helpers:
  - `_handleCampaignStartNowActionV1()`
  - `_openNextCampaignPackFromSsoT()`
  - `_resolveEarliestIncompleteWorld1PackIdV1()`

2. Act0 seat-quiz/guidance phase
- Screen: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- State family: seat-quiz prelude/intro/idle/header/table-instruction variants.
- Dominant seams/helpers:
  - `_seatQuizInstructionForTargetV1()` (per-target prompt family)
  - `_seatQuizIdleGuidanceLineV1()` (idle fallback family)
  - `_seatQuizPreviewTitleV1` / `_seatQuizFallbackGuidanceTitleV1`
  - `seatQuizHeaderInstructionTextV1` selection branch
  - `_step.instructionText` overlay branch and `instructionSourceV1` overrides

3. Early action-decision phase
- Screen: `world1_foundations_microtask_runner_screen.dart`
- State family: hand-loop/action-bar branch.
- Dominant seams/helpers:
  - `_buildCampaignActionChips(...)`
  - spine allowed-action filtering/label overrides
  - outcome line builders (`Expected/Correct/Why`)

4. Finish/result phase
- Screen: `lib/ui_v2/screens/session_result_screen.dart`
- State family: result CTA/why/focus/up-next.
- Dominant seams/helpers:
  - `_primaryCtaLabelV1(...)`
  - `_resultWhyLineV1()`
  - `_upNextFocusLineV1()`

5. Map/progression return phase
- Screens/services:
  - `session_result_screen.dart` -> map navigation
  - `lib/services/progress_service.dart` progression state
- Dominant seams/helpers:
  - next-pack progression decision APIs and world1 canonical ordering

## Authoritative vs duplicated classification
- Entry/map: **AUTHORITATIVE and CLEAN**
  - One deterministic start-now dispatcher and one next-pack resolver chain.
- Act0 seat-quiz/guidance: **DUPLICATED / PARALLEL** (proven)
  - Multiple guidance generators for the same phase family (target/idle/preview/header/overlay/override).
  - Prior R69 fixed one fallback seam, but dominant visible instruction could still come from parallel branch paths.
- Early action-decision: **AUTHORITATIVE and CLEAN**
  - Single dominant action-chip render path with deterministic contracts; no new duplication root-cause evidence.
- Finish/result: **AUTHORITATIVE and CLEAN**
  - One dominant CTA labeling seam with existing contracts; no new duplication evidence.
- Map/progression return: **AUTHORITATIVE and CLEAN**
  - Deterministic progression source; no parallel presentation root cause observed.

## Root-cause verdict
- **B) one bounded duplicated/parallel presentation root cause is proven.**
- Proven root cause:
  - Act0 seat-quiz guidance text family was assembled by multiple parallel branches; previous local fixes could hit secondary/fallback text while dominant branch text remained effectively unchanged.

## Bounded consolidation fix applied
- Exact seam fixed:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - Act0 seat-quiz guidance family now consolidated through one authoritative helper:
    - `_seatQuizGuidanceForTargetV1(...)`
- Consolidation behavior:
  - Target guidance, preview guidance, and idle guidance now share one wording family and no longer use command-style `This is ... Tap it.` phrasing.
  - Compatibility wrapper retained for old call sites without expanding scope across phases.
- Boundedness:
  - Single phase family (Act0 seat-quiz guidance only).
  - No action-bar/result/progression logic changes.

## Minimal proof
- Updated targeted contract:
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - `lock in stays disabled until a seat is selected` now asserts the authoritative highlighted-position guidance family and absence of old command-style phrase.
- Targeted verification runs:
  - `flutter test ... --plain-name "lock in stays disabled until a seat is selected"`
  - `flutter test ... --plain-name "world2 seat quiz loops clockwise for first 6 seats and instruction matches highlighted target"`
- Required gates:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
- All green.

## Open-risk list
- Additional non-seat-quiz instruction variants may still carry tone differences, but no parallel-root-cause evidence exceeded this selected seam.
- Fresh-install visual delta should be rechecked after this consolidation before selecting another implementation seam.

## Anti-drift note
- R71 changed one bounded root-cause cluster only:
  - Act0 seat-quiz guidance-family consolidation.
- No multi-phase refactor, no broad copy sweep, no architecture/progression/personalization drift.

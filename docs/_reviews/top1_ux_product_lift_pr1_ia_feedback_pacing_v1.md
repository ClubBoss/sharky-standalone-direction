# PR1 Review: De-duplicate IA + Clean Up Feedback Pacing

**Date:** 2026-06-24
**Commit:** feat: clean up repair IA and feedback pacing
**Scope:** act0_shell surfaces — Home, Practice, Review, Lesson Runner feedback card
**Risk level:** Low — removed duplication and restyled, no routing or data model changes

---

## What was done

### A. Home — remove duplicate repair CTA (`act0_home_shell_v1.dart`)

**Problem:** `_buildChecklistRows()` built 4 rows: Learn, Practice, Review, and Fix/Repair. The Fix row was independently tappable (`isRepairAction: true`) and launched the same repair flow as the hero card's primary CTA above it. Two tappable repair entry points on the same screen.

**Fix:** Removed `fixRow` from the `rows` list. The checklist now has 3 rows (Learn → Practice → Review) matching the session shape. The hero card owns the live repair/next action.

**Line changed:** [act0_home_shell_v1.dart:413](lib/ui_v2/act0_shell/act0_home_shell_v1.dart#L413) — removed `fixRow,` from the rows list.

---

### B. Practice — prevent repair group from becoming hero (`act0_play_shell_v1.dart`)

**Problem:** When `recommendedRepairGroup` was true (repair group recommended), the repair group (`weak_spots`) was promoted to `featuredGroup` and displayed as the `_DailyTrainingHeroV1` hero card. This duplicated Home's repair CTA and reframed Practice as a repair surface rather than a self-directed drill surface.

**Fix:** Changed `featuredGroup` logic so the daily drill group is always the hero. If no daily drill exists and repair is recommended, `featuredGroup = null` (no hero card shown) and the repair group stays in the Quick Reps section only.

Before:
```dart
final featuredGroup = recommendedRepairGroup
    ? recommendedGroup
    : quickDrillGroup ?? fallbackFeaturedGroup;
```

After:
```dart
final featuredGroup =
    quickDrillGroup ?? (recommendedRepairGroup ? null : fallbackFeaturedGroup);
```

**Line changed:** [act0_play_shell_v1.dart:251](lib/ui_v2/act0_shell/act0_play_shell_v1.dart#L251)

---

### C. Review — remove action button from repair coach card (`act0_review_shell_v1.dart`)

**Problem:** `_ReviewRepairCoachCardV1` rendered a `FilledButton` ("Repair this clue") calling `onFixMistake!(mistake)`. Review is meant to be mistake history and context — not a repair launcher. The CTA duplicated the one on Home.

**Fix:** Removed the `FilledButton` block from `_ReviewRepairCoachCardV1`. The coaching information (clue title, reason, next focus) remains as historical context. Only the action button was removed.

**Lines removed:** [act0_review_shell_v1.dart:485-495](lib/ui_v2/act0_shell/act0_review_shell_v1.dart#L485)

---

### D. Wrong-answer feedback — amber tone, suppress pre-stated receipt, primary repair CTA (`act0_lesson_runner_shell_v1.dart`)

**Problem (tone):** Wrong answers used `Act0ShellTokensV1.danger` (red) for `tone`, `sharkyTone`, and icon (`Icons.close_rounded`). Red/X styling frames normal learning mistakes as failures rather than coaching moments.

**Problem (receipt):** The receipt block was shown for wrong answers with `receiptTitle = 'Repair result'` and `receiptDetail = repairReceiptLine` — pre-announcing "Replay missed again" or similar before the user has processed the correction.

**Problem (CTA):** The primary button always said "Continue" regardless of quality. For wrong answers, the intent is to try again — a label like "Try one like this" better communicates the repair action.

**Fixes:**
1. Changed `tone`, `icon`, and `sharkyTone` for wrong answers from danger-red to gold/amber (`Act0ShellTokensV1.gold`, `Icons.trending_up_rounded`) — same as suboptimal/coaching.
2. Suppressed the receipt block (`!isWrong` guard) so wrong answers never show a pre-stated outcome.
3. Changed button label to `'Try one like this'` when `isWrong`, `'Continue'` otherwise. Routing is unchanged.

**Lines changed:** [act0_lesson_runner_shell_v1.dart:4362](lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart#L4362), [4712](lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart#L4712), [4810](lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart#L4810)

---

## Validation

- `graphify hook-check`: clean
- `flutter analyze --no-pub`: No issues found (14.9s)
- `git diff --check`: no whitespace issues
- 4 files modified, no new files, no output artifacts committed

## Hard non-goals confirmed not touched

- No route or progression changes
- No W11/W12 activation
- No telemetry schema changes
- No new data model for mistake history
- No Modern Table structural changes
- No broad refactor
- No `output/` artifacts committed

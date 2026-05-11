# Map Animation Gaps: Collapse & Scroll-to Analysis

**Date**: May 10, 2026  
**Scope**: Act0 Learn Path Shell (world map / learning path screen)  
**Status**: Code-backed investigation

---

## TL;DR

| Issue | Root Cause | Difficulty | Visual Impact | Worth Fixing |
|-------|-----------|------------|---------------|-------------|
| **Collapse jump** | `reverseDuration: Duration.zero` in AnimatedSize | **Very Easy** (1 line) | **High** — visible pop/jump every time you close | **YES** |
| **Scroll-to jump** | Race condition between collapse instant + scroll anima + expand | **Medium** (orchestration logic) | **High** — node target position shifts mid-animation | **YES** |

---

## Issue 1: Collapse Animation Jump (prыжок при закрытии)

### What Happens Now

When you tap a lesson to close it OR tap another lesson (which collapses the previous one):

1. **Phase 1 (Instant collapse)**: `_learnDetailLessonId` → `null` 
2. **Phase 1 Impact**: Render tree updates `_InlineLessonHubSlotV1.visible` → `false`
3. **AnimatedSize response**: `reverseDuration: Duration.zero` 🔴 → **NO ANIMATION**, instant size drop to 0
4. User sees: **JUMP/POP** instead of smooth collapse

### Code Evidence

**File**: `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart:1396–1433`

```dart
class _InlineLessonHubSlotV1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 580),
      reverseDuration: Duration.zero,  // ← PROBLEM: 0ms collapse, 580ms expand
      curve: Curves.easeInOutCubicEmphasized,
      alignment: Alignment.topCenter,
      child: visible
          ? Align(
              alignment: alignment,
              child: FractionallySizedBox(
                widthFactor: 0.92,
                child: Padding(...),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
```

### Why It's There

`reverseDuration: Duration.zero` was likely set to avoid animation delays during rapid expand-collapse cycles. But it creates visible jank.

### Fix Complexity

**1 line change**, 5 minutes:

```diff
  reverseDuration: Duration.zero,
+ reverseDuration: const Duration(milliseconds: 420),
```

**Alternative**: Use `reverseDuration: const Duration(milliseconds: 360)` to match the inner `AnimatedSwitcher` duration (360ms).

### Visual Impact

- **Before**: Instant pop/collapse + smooth expand = asymmetric feel
- **After**: Smooth collapse (420ms) + smooth expand (580ms) = calm, unified motion
- **Users notice**: YES, every time they interact with a lesson card

---

## Issue 2: Scroll-to Jump (прыжок при нажатии на узел)

### What Happens Now

When you tap a **new** lesson (not the currently open one):

#### Flow Sequence

**Step 1 (in `act0_shell_preview_screen_v1.dart:180–215`)**:
```dart
bool _handleLearnLessonSelectV1({
  required Act0LessonCardV1 lesson,
  required String lessonId,
}) {
  if (_learnDetailLessonId == lessonId) {
    // Toggle close: collapse immediately
    setState(() {
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
    });
    return false;
  }
  
  _learnLessonOpenSequenceV1++;
  setState(() {
    if (lesson.isSelectable) {
      _selectedLessonId = lessonId;
      _selectedTaskId = _firstIncompleteTask(lesson).taskId;
    }
    // ═════════════════════════════════════════════════════════════
    // PHASE 1: Collapse previous, set pending scroll target
    // ═════════════════════════════════════════════════════════════
    _learnDetailLessonId = null;           // Collapse instantly (reverseDuration: 0)
    _learnDetailWorldId = null;
    _learnPendingAutoOpenLessonIdV1 = lessonId;  // Mark "open after scroll"
  });
  return true;  // Signals: "yes, auto-open after scroll"
}
```

**Step 2 (in `act0_learn_path_shell_v1.dart:497–505`)**:
```dart
onSelectLesson: (lessonId) {
  final shouldAutoOpen = widget.onSelectLesson(lessonId);  // ← Calls parent Phase 1
  if (!shouldAutoOpen) {
    return;
  }
  unawaited(
    _scrollLessonHeaderToTopV1(
      lessonId,
    ).then((_) {
      if (!mounted) return;
      widget.onOpenLessonAfterScroll(lessonId);  // ← THEN call this
    }),
  );
},
```

**Step 3 (in `act0_learn_path_shell_v1.dart:161–243`)**:
```dart
Future<void> _scrollLessonHeaderToTopV1(
  String lessonId, {
  int settleFrames = 2,
  int maxDurationMs = 460,  // ← Smart dynamic duration
}) async {
  // ... compute target position, wait for layout settle ...
  
  final delta = (target - _learnScrollController.offset).abs();
  final durationMs = (180 + (delta * 0.22))
      .clamp(220, maxDurationMs)
      .round();
  
  // Scroll animates TO target position with easeInOutCubic curve
  await _learnScrollController.animateTo(
    target,
    duration: Duration(milliseconds: durationMs),
    curve: Curves.easeInOutCubic,
  );
}
```

**Step 4 (in `act0_shell_preview_screen_v1.dart:202–215`)**:
```dart
void _handleLearnLessonOpenAfterScrollV1(String lessonId) {
  if (!mounted || _learnPendingAutoOpenLessonIdV1 != lessonId) {
    return;
  }
  setState(() {
    // ═════════════════════════════════════════════════════════════
    // PHASE 2: Expand lesson AFTER scroll finishes
    // ═════════════════════════════════════════════════════════════
    _learnDetailLessonId = lessonId;  // Expand animates (580ms AnimatedSize)
    _learnPendingAutoOpenLessonIdV1 = null;
  });
}
```

### The Race Condition Problem

```
Timeline (milliseconds):
0ms   ← User taps lesson Z
│
├─ PHASE 1: setState
│  ├─ _learnDetailLessonId = null         (prev lesson collapses, 0ms reverseDuration)
│  └─ _learnPendingAutoOpenLessonIdV1 = "Z"
│
├─ Immediately: scroll controller starts animateTo(targetZ, duration: 280–460ms)
│  │
│  ├─ Lesson X card shrinks to 0 (0ms reverse) — JUMP visible
│  └─ Viewport scrolls smoothly to lesson Z (220–460ms)
│
└─ ~280–460ms: scroll settles, then onOpenLessonAfterScroll fires
   │
   └─ PHASE 2: setState
      └─ _learnDetailLessonId = "Z"       (lesson Z expands, 580ms expand)
         └─ At same time: lesson Z card and hub panel animate size growth
```

### The Visible Issue

**Timing mismatch**:
- Lesson X collapse: **0ms** (instant)
- Scroll animation: **220–460ms** (depends on distance)
- Lesson Z expand: **580ms** (fixed)

**Result**: 
1. **0–100ms**: Old lesson pops away (unreacted)
2. **0–460ms**: Viewport smoothly animates, BUT target position may shift as layout changes above it
3. **460–1040ms**: New lesson expands while scroll might still be settling

**User sees**: Target lesson doesn't reach final "comfortable" position until after expand finishes. If scroll placed it too low, expand makes it shift again.

### Why Scroll Position Shifts Mid-Animation

The scroll target is computed once at the start (line 173 in `_scrollLessonHeaderToTopV1`):

```dart
double? computeTargetOffset() {
  final lessonContext = _lessonKeys[lessonId]?.currentContext;
  final activeLessonContext = widget.detailLessonId == lessonId
      ? _activeLessonSlotKey.currentContext
      : null;
  final targetContext = activeLessonContext ?? lessonContext;
  // ... render position lookup ...
}

final target = computeTargetOffset();  // ← COMPUTED ONCE, locked
```

But during the 220–460ms scroll animation:
- Previous lesson's `_InlineLessonHubSlotV1` (0ms collapse) shrinks
- List items above reflow upward
- Layout height changes
- Scroll viewport height itself might change
- **Target offset becomes stale mid-animation** → scroll "overshoots" or "undershoots"

### Fix Complexity

**Medium difficulty**: Requires orchestration changes:

**Option A** (Simplest, 15–20 min):
- Set `reverseDuration` on collapse (fixes Issue 1)
- Delay scroll until collapse animation settles:
  ```dart
  setState(() {
    _learnDetailLessonId = null;
    _learnPendingAutoOpenLessonIdV1 = lessonId;
  });
  // Wait for collapse to finish before scrolling
  Future.delayed(Duration(milliseconds: 420), () {
    _scrollLessonHeaderToTopV1(lessonId);
  });
  ```
- This ensures layout is stable when scroll target is computed

**Option B** (Robust, 30–40 min):
- Recalculate target offset just before scroll animation ends
- Use `ScrollPosition.drag()` + manual `animateTo` recomputation
- Add per-frame scroll offset validation

**Option C** (Best, 45–60 min):
- Collapse + keep expanded section height reserved
- Scroll to "expected final position" accounting for expand height
- Only expand AFTER scroll reaches final position
- Smoothest but requires refactoring `_InlineLessonHubSlotV1` to emit size signals

### Visual Impact

- **Before**: Scroll arrives at lesson, but lesson expands below it; or lesson appears too far down initially
- **After (Option A)**: Collapse finishes (calm 420ms), then scroll animates to calm position
- **After (Option B/C)**: Collapse + scroll + expand all coordinate smoothly, no "jank" or re-positioning

**Users notice**: YES, on every lesson selection that requires scroll. Especially on longer lists or mobile (where layout reflow is slower).

---

## Recommendations

### Priority 1: Collapse Reverse Duration (Quick Win)

**Effort**: 5 minutes (1 line)  
**Impact**: Medium-High  
**Should do**: YES, zero risk

```diff
// lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart:1409
  AnimatedSize(
    duration: const Duration(milliseconds: 580),
-   reverseDuration: Duration.zero,
+   reverseDuration: const Duration(milliseconds: 420),
    curve: Curves.easeInOutCubicEmphasized,
```

### Priority 2: Scroll Timing Coordination (Medium Effort, High Payoff)

**Effort**: 20–30 minutes (Option A)  
**Impact**: High  
**Should do**: YES, improves feel significantly

Delay `_scrollLessonHeaderToTopV1` until collapse settles:

**File**: `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:180–220`

```dart
bool _handleLearnLessonSelectV1({
  required Act0LessonCardV1 lesson,
  required String lessonId,
}) {
  if (_learnDetailLessonId == lessonId) {
    setState(() {
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
      _learnPendingAutoOpenLessonIdV1 = null;
    });
    return false;
  }
  
  _learnLessonOpenSequenceV1++;
  setState(() {
    if (lesson.isSelectable) {
      _selectedLessonId = lessonId;
      _selectedTaskId = _firstIncompleteTask(lesson).taskId;
    }
    _learnDetailLessonId = null;
    _learnDetailWorldId = null;
    _learnPendingAutoOpenLessonIdV1 = lessonId;
  });
  
  // Wait for collapse animation to settle before scrolling
  Future.delayed(const Duration(milliseconds: 420), () {
    if (!mounted || _learnPendingAutoOpenLessonIdV1 != lessonId) {
      return;
    }
    // Now scroll to target with stable layout
    _scrollToAndOpenLessonV1(lessonId);
  });
  
  return true;
}

Future<void> _scrollToAndOpenLessonV1(String lessonId) async {
  final learnPathState = _learnPathShellStateV1;
  if (learnPathState == null) return;
  
  await learnPathState._scrollLessonHeaderToTopV1(lessonId);
  _handleLearnLessonOpenAfterScrollV1(lessonId);
}
```

---

## Testing Checklist

If you implement these fixes:

- [ ] Collapse a lesson → smooth 420ms shrink (not instant pop)
- [ ] Tap a new lesson → 420ms collapse of old + 220–460ms scroll + 580ms expand all coordinate smoothly
- [ ] Scroll distance doesn't matter → animation should feel calm at any scroll distance
- [ ] Rapid taps → no animation conflicts or double-collapsing
- [ ] Mobile 60Hz device → no frame drops during coordinated animations

---

## Summary

| Metric | Current | After Fix |
|--------|---------|-----------|
| **Collapse feel** | Instant jank | Smooth 420ms |
| **Scroll precision** | Layout-dependent, sometimes off-target | Stable, computed on settled layout |
| **User perception** | Lesion selection feels "jumpy" | Feels "calm" and orchestrated |
| **Total animation time** | 580ms (expand only, no collapse) | 420ms (collapse) + 280–460ms (scroll) + 580ms (expand) = 1.28–1.46s orchestrated |

**Worth implementing?** YES. Both fixes are proportional effort-to-impact and significantly improve the core learning path interaction feel.

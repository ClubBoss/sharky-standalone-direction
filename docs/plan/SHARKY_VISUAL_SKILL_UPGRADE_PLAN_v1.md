# Sharky Visual & Skill Upgrade — Master Plan v1

**Status:** READY FOR EXECUTION UNDER `SHARKY_IMPLEMENTATION_AND_SKILL_GROWTH_POLICY_v1.md`
**Author:** Product audit + AI synthesis, May 2026
**Scope:** Feedback card redesign · Sharky mascot image integration · Skill gain visibility · Sizing slider · Replay player

---

## 0. Why This Plan Exists

Two screenshots triggered this audit:

- **Screenshot A** (correct answer): Clean, focused, fast. Works well.
- **Screenshot B** (wrong answer): 4 simultaneous information layers — action error, table labels, red chip markers, follow-up advice. Cognitive overload. Student can't find the signal.

Separately: Sharky already exists as a coded widget using Material icons. The real cartoon character (blue baby shark — 6 emotion states) has never been wired in. And the skill growth system is fully functional but invisible — students only see their skill bars if they navigate to Profile, never in the moment of earning.

These three problems share one solution: **a redesigned Feedback Card where Sharky carries the emotional frame, announces skill growth, and reduces visual noise without replacing the product's instructional voice.**

---

## 1. What Already Exists (Do NOT rebuild)

### 1.1 Sharky State Architecture
File: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

```dart
enum Act0SharkyMoodV1 { neutral, happy, thinking, repair, celebrate }

class Act0SharkyCueV1 {
  final String preSessionLine;   // shown before drill starts
  final String correctReaction;  // shown on correct answer
  final String wrongReaction;    // shown on wrong answer
  final String repairLine;       // shown during repair flow
  final String summaryLine;      // shown at lesson end
  final Act0SharkyMoodV1 preSessionMood;
  final Act0SharkyMoodV1 correctMood;    // default: happy
  final Act0SharkyMoodV1 wrongMood;      // default: repair
  final Act0SharkyMoodV1 repairMood;
  final Act0SharkyMoodV1 summaryMood;    // default: celebrate
}
```

Default preset `Act0SharkyCueV1.beginner` is attached to every `Act0RunnerStateV1` via `this.sharky = Act0SharkyCueV1.beginner`.

### 1.2 Sharky Mascot Widget (Coded, NOT image-based)
File: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` → `Act0SharkyMascotV1`

Currently draws a circular gradient avatar with a **Material icon** inside (e.g. `Icons.sentiment_very_satisfied_rounded`). Uses `TweenAnimationBuilder` for entry scale + tilt animation per mood. Has `_SharkyCuePillV1` for the speech bubble.

**This widget is the replacement target** — swap the icon inside for the real image asset.

### 1.3 Sharky Already Shown in Two Places
1. **Pre-session** (theory phase, learning rail): `runner.sharky.preSessionLine` + `runner.sharky.preSessionMood`
2. **Post-answer review** (drill phase, feedback): `_SharkyCuePillV1` with `correctReaction`/`wrongReaction` + matching mood color

The pill is rendered ABOVE the `Act0FeedbackShellV1` card. **This is close to correct but not yet the redesigned card.**

### 1.4 Skill System
File: `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

Six tracked skills: `Table sense`, `Board reading`, `Hand reading`, `Betting decisions`, `Position play`, `Blind play`

- `_profileSkillValues`: in-memory `Map<String, int>` — persisted during session, lost on restart
- `_incrementSkillStatsForCorrectAnswer()` — called on every correct drill answer
- `_skillDeltaForTask()` — maps lesson IDs → skill deltas (only ~7 of ~60 lessons explicitly mapped, rest fallback)
- `_skillDeltaForAnswer()` — keyword-based bonus (+1/+2 on top of lesson map)
- Shown in Profile tab only — **never surfaced at moment of earning**

### 1.5 Sizing Config
File: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`

```dart
enum Act0SizingUiModeV1 { hidden, presetsOnly, presetsWithSlider }
```

`_SizingPresetsLaneV1` renders presets as chips. `presetsWithSlider` variant is defined but never rendered — no slider widget exists yet.

### 1.6 Replay
File: `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`

`onReplay` callback exists on mistake cards. Buttons "Run fix again" / "Replay fix" are rendered. Full sequential playback (step-by-step action trail replay with pot/street recalculation) is built in the runner via `_actionTrailFocusedIndex` and `_calculatePotAtTrailIndex`. The missing piece: no dedicated "Watch the full hand replay" mode that auto-steps through the trail automatically.

---

## 2. Current Problem Map

| Problem | Severity | Root Cause |
|---------|----------|------------|
| Wrong-answer feedback has 4 info layers | 🔴 High | `Act0FeedbackShellV1` always renders table read context regardless of answer quality |
| Sharky is a Material icon, not the real character | 🟡 Medium | No image assets wired in; widget uses coded avatar |
| Skill growth is invisible at moment of earning | 🔴 High | `_incrementSkillStatsForCorrectAnswer` has no UI event |
| Only 7/~60 lessons have explicit skill mapping | 🟡 Medium | `_skillDeltaForTask` switch is incomplete |
| Skill values lost on app restart | 🟡 Medium | `_profileSkillValues` is in-memory, not persisted |
| Slider not rendered (`presetsWithSlider` mode unused) | 🟡 Medium | No widget for slider track, only preset chips exist |
| No auto-replay mode for hand history | 🟠 Low-Medium | Trail stepping is manual (tap), no auto-advance timer |

---

## 3. The Real Sharky Character — Image Integration Plan

### 3.1 Assets Needed
The character has 6 emotional states. Map them to existing `Act0SharkyMoodV1`:

| `Act0SharkyMoodV1` | Character state | File name convention |
|---|---|---|
| `happy` | Smiling, waving | `sharky_happy.png` |
| `celebrate` | Arms up, excited | `sharky_celebrate.png` |
| `thinking` | Finger to chin, neutral-curious | `sharky_thinking.png` |
| `neutral` | Standing, mild smile | `sharky_neutral.png` |
| `repair` | Concerned, open mouth | `sharky_repair.png` |
| _(extra)_ | Sleeping / zzz | `sharky_sleeping.png` — for future idle hint |

### 3.2 Where to Put the Files
```
assets/
  images/
    mascot/
      sharky_happy.png
      sharky_celebrate.png
      sharky_thinking.png
      sharky_neutral.png
      sharky_repair.png
      sharky_sleeping.png
```

Register in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/mascot/
```

### 3.3 Widget Replacement Strategy

In `Act0SharkyMascotV1`, replace the coded Stack/Container with:

```dart
// BEFORE (coded icon):
Container(
  decoration: BoxDecoration(gradient: ..., shape: BoxShape.circle),
  child: Center(child: Icon(faceIcon, ...)),
)

// AFTER (real image):
Image.asset(
  _assetForMood(mood),
  key: Key('act0_shell_sharky_mascot_${mood.name}'),
  width: size,
  height: size,
  fit: BoxFit.contain,
)
```

Add helper:
```dart
String _assetForMood(Act0SharkyMoodV1 mood) => switch (mood) {
  Act0SharkyMoodV1.happy     => 'assets/images/mascot/sharky_happy.png',
  Act0SharkyMoodV1.celebrate => 'assets/images/mascot/sharky_celebrate.png',
  Act0SharkyMoodV1.thinking  => 'assets/images/mascot/sharky_thinking.png',
  Act0SharkyMoodV1.repair    => 'assets/images/mascot/sharky_repair.png',
  Act0SharkyMoodV1.neutral   => 'assets/images/mascot/sharky_neutral.png',
};
```

**Preserve the existing `TweenAnimationBuilder` wrapper** — scale + tilt animation still applies on top of the image.

### 3.4 Fallback During Development
Keep the coded icon as a fallback if the asset file doesn't exist:
```dart
child: AssetImage('assets/images/mascot/sharky_${mood.name}.png') is available
    ? Image.asset(...)
    : Icon(faceIcon, ...)  // existing coded fallback
```
Use `flutter pub run build_runner` or simply check with `File().existsSync()` during development. For production: always ship the assets.

---

## 4. Feedback Card Redesign — Information Hierarchy

### 4.1 Current Layout (Act0FeedbackShellV1)
```
_SharkyCuePillV1        ← speech bubble (correct/wrong line)
Act0FeedbackShellV1:
  ├─ title              ← "Nice read." / "Almost there."
  ├─ reason             ← explanation text
  ├─ betterLabel        ← "Better option: Three"
  ├─ nextCueLine        ← "Next cue: pause on position..."
  ├─ Table read section ← ALWAYS VISIBLE, red/green markers
  └─ [Continue]
```

### 4.2 Target Layout — "Sharky Edition"

**On correct answer:**
```
┌──────────────────────────────────────────┐
│  [🦈 image: happy]  Sharp read!          │
│                     Checking keeps the   │
│                     hand going when no   │
│                     one bet.             │
│                                          │
│  📈 +3 Table sense  [████████░░] 41      │  ← new: skill gain row
│                                          │
│  [See why ▼]        ← collapsed by default
└──────────────────────────────────────────┘
[Continue]
```

**On wrong answer:**
```
┌──────────────────────────────────────────┐
│  [🦈 image: repair] Not quite.           │
│                     You picked Five.     │
│                     On the flop we see   │
│                     three cards.         │
│                                          │
│  [See the rule ▼]   ← collapsed by default
└──────────────────────────────────────────┘
[Continue]
```

**Expanded section (same for both, optional):**
```
▼ Table read
  ✓ No bet yet    ✓ Pot 1.5 BB   ← existing context labels
  Better option: Check
  Next cue: same setup...
```

### 4.3 Implementation Changes

**Step 1: Add `showContextByDefault` parameter to `Act0FeedbackShellV1`**
```dart
// In Act0FeedbackShellV1 widget:
final bool showContextByDefault;  // default: false for drill review, true for repair
```

**Step 2: Add `skillGainLabel` and `skillGainValue` to the review render path**

In `act0_shell_preview_screen_v1.dart`, compute deltas before calling feedback:
```dart
// After _incrementSkillStatsForCorrectAnswer():
final deltas = _skillDeltaForAnswer(selectedLesson, selectedTask);
final primaryGain = deltas.entries
    .where((e) => e.value > 0)
    .reduce((a, b) => a.value >= b.value ? a : b);
// Pass to feedback: primaryGain.key (label) + primaryGain.value (amount)
```

**Step 3: Skill gain row widget inside feedback card**
```dart
class _SkillGainRowV1 extends StatefulWidget {
  // AnimatedContainer: width starts at 0, animates to progress fraction
  // Label: "+3 Table sense"
  // Bar: 0..99 range, current value visible
  // Appears with 400ms delay after card appears (let the answer sink in first)
}
```

**Step 4: Consolidate Sharky into the card header (not a separate pill)**

Currently: `_SharkyCuePillV1` (a separate chip above the card) + the card body.
Target: Sharky image + reaction line is the **card header**, not a floating pill.

```dart
// New card header structure:
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Act0SharkyMascotV1(mood: sharkyMood, tone: qualityColor, size: 44),
    SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sharkyReaction, style: titleStyle),  // "Sharp read."
          SizedBox(height: 4),
          Text(reason, style: bodyStyle),            // explanation
        ],
      ),
    ),
  ],
)
```

---

## 5. Skill System Completion

### 5.1 Expand Lesson→Skill Mapping

Current explicit mapping covers: `what_poker_is`, `your_first_hand`, `fold_check_call_raise`, `blinds_action_order`, `positions`, `hand_rankings_table`, `showdown_winning` (7 lessons).

Add mappings for all World 1–7 lessons. Pattern:

```dart
// World 1:
'actions'          => {'Betting decisions': 4, 'Table sense': 2},
'actions_check'    => {'Betting decisions': 4, 'Table sense': 1},
'board_cards'      => {'Board reading': 4},
'board_streets'    => {'Board reading': 4, 'Table sense': 1},

// World 2:
'hand_discipline'          => {'Betting decisions': 3, 'Hand reading': 2},
'hand_discipline_apply'    => {'Betting decisions': 4, 'Hand reading': 2},
'showdown_compare'         => {'Hand reading': 5},
'position_intro'           => {'Position play': 4},

// World 3+: continue pattern based on world theme
// World 3 = position → Position play primary
// World 4 = preflop framework → Betting decisions + Position play
// World 5 = bet purpose & sizing → Betting decisions primary
// World 6 = board & draws → Board reading primary
// World 7 = range thinking → Hand reading primary
```

### 5.2 Persist Skill Values

Add to `_seedProfileSkillStats()` and increment path:

```dart
// In shared_prefs_keys.dart:
static const String act0ProfileSkillValues = 'act0_profile_skill_values_v1';

// On each increment (in _incrementSkillStatsForCorrectAnswer):
final prefs = await SharedPreferences.getInstance();
final encoded = jsonEncode(_profileSkillValues);
await prefs.setString(SharedPrefsKeys.act0ProfileSkillValues, encoded);

// On init (in initState or first build):
final raw = prefs.getString(SharedPrefsKeys.act0ProfileSkillValues);
if (raw != null) {
  _profileSkillValues.addAll(Map<String, int>.from(jsonDecode(raw)));
}
```

### 5.3 Skill Gain Animation Spec

Timing sequence on correct answer:
```
t=0ms:   Answer selected, review card appears
t=0ms:   Sharky flips to happy mood (TweenAnimation begins)
t=400ms: Skill gain row fades in (AnimatedOpacity 0→1, 300ms)
t=500ms: Progress bar width animates to new value (AnimatedContainer, 600ms)
t=600ms: "+N label" counts up from 0 to N (TweenAnimationBuilder, 400ms)
```

On wrong answer: no skill gain row. Sharky shows `repair` mood. Context collapsed.

---

## 6. Sizing Slider — Implementation Plan

### 6.1 Current State
`Act0SizingUiModeV1.presetsWithSlider` exists as enum value but renders identically to `presetsOnly` — the slider branch is missing in `_SizingPresetsLaneV1`.

### 6.2 Target Behavior
When a task has `sizingConfig.mode == presetsWithSlider`:
1. Show preset chips as before (half-pot, pot, 2x pot etc.)
2. Below chips: a continuous `Slider` widget (range: 0.1 BB to some max based on stack)
3. Selecting a preset snaps the slider to that value
4. Moving the slider de-selects any preset (custom value)
5. Selected value shown as `"{value} BB"` label

### 6.3 State Changes Needed
Add to `Act0SizingConfigV1`:
```dart
final double? sliderMin;    // e.g. 0.5
final double? sliderMax;    // e.g. pot * 3 or stack size
final double? sliderStep;   // e.g. 0.5
final double? currentValue; // current slider position
```

Add callback in runner widget:
```dart
final ValueChanged<double>? onSizingValueChanged;
```

### 6.4 Widget Addition in `_SizingPresetsLaneV1`

```dart
if (mode == Act0SizingUiModeV1.presetsWithSlider) ...[
  const SizedBox(height: 8),
  Row(
    children: [
      Text('${sliderValue.toStringAsFixed(1)} BB', style: labelStyle),
      Expanded(
        child: Slider(
          value: sliderValue,
          min: config.sliderMin ?? 0.5,
          max: config.sliderMax ?? 10.0,
          divisions: ...,
          onChanged: onSizingValueChanged,
        ),
      ),
    ],
  ),
]
```

---

## 7. Replay Player — Completion Plan

### 7.1 Current State
- `_actionTrailFocusedIndex` in `_Act0LessonRunnerShellV1State` controls which trail step is "active"
- Pot/street recalculate dynamically via `_calculatePotAtTrailIndex`
- Bet chip override via `_deriveBetFromTrailStep`
- Users can **tap individual steps** manually — this is interactive replay
- Missing: **auto-play mode** that advances steps on a timer

### 7.2 Target: Auto-Play Mode

Add a play/pause button to the action trail header:

```dart
// In _ActionTrailV1 or its parent:
bool _isAutoPlaying = false;
Timer? _autoPlayTimer;

void _startAutoPlay() {
  _autoPlayTimer = Timer.periodic(Duration(milliseconds: 1200), (timer) {
    final next = (_actionTrailFocusedIndex ?? -1) + 1;
    if (next >= table.actionTrail.length) {
      timer.cancel();
      setState(() => _isAutoPlaying = false);
    } else {
      setState(() => _actionTrailFocusedIndex = next);
    }
  });
  setState(() => _isAutoPlaying = true);
}

void _stopAutoPlay() {
  _autoPlayTimer?.cancel();
  setState(() => _isAutoPlaying = false);
}
```

Add play/pause button in trail header:
```dart
IconButton(
  key: const Key('act0_shell_replay_play_pause'),
  icon: Icon(_isAutoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
  onPressed: _isAutoPlaying ? _stopAutoPlay : _startAutoPlay,
)
```

### 7.3 Speed Control (optional, v2)
Add a `1x / 2x` speed toggle. `_autoPlayTimer` interval: 1200ms at 1x, 600ms at 2x.

---

## 8. Priority Order — What to Build First

Ordered by impact-to-effort ratio:

### 🔴 Priority 1 — Sharky Image Integration (1–2 days)
**Why first:** Once the real character appears, the whole product feels different. This is a pure asset swap + one helper method. Zero risk of regression. Maximum visual impact.

**Steps:**
1. Add image files to `assets/images/mascot/`
2. Register in `pubspec.yaml`
3. Update `Act0SharkyMascotV1._assetForMood()` method (keep animation wrapper)
4. Run `flutter test` to confirm keys still match

**Risk:** Low. If assets are missing, the coded fallback still works.

---

### 🔴 Priority 2 — Skill Gain Toast in Feedback (2–3 days)
**Why second:** Highest retention impact. Student feels growth at the exact moment it happens. Sharky image (Priority 1) is needed first so the toast has the right character face.

**Steps:**
1. Extract `deltas` from `_incrementSkillStatsForCorrectAnswer` and expose to UI
2. Add `skillGainLabel`/`skillGainValue` params to the feedback render path
3. Build `_SkillGainRowV1` with animated progress bar
4. Wire into `Act0FeedbackShellV1`
5. Add tests: skill gain row appears on correct answer, absent on wrong

**Risk:** Medium. Requires threading data through widget tree. Keep it one-directional (state → widget, no callbacks).

---

### 🟡 Priority 3 — Feedback Card Information Hierarchy (2 days)
**Why third:** Reduces cognitive overload on wrong answers. Needs Priorities 1+2 done so Sharky is in the right place.

**Steps:**
1. Add `showContextByDefault: false` param to `Act0FeedbackShellV1`
2. Wrap the context section in `ExpansionTile` or custom collapsible
3. Move Sharky from separate pill into card header (Row layout)
4. On wrong answer: stol table labels dimmed (already handled by seat `isInHand`/`isFolded`)
5. Update tests: context section starts collapsed for drill review

**Risk:** Medium. Many tests check specific text/keys in feedback. Run full suite after.

---

### 🟡 Priority 4 — Complete Skill Lesson Mapping + Persistence (1–2 days)
**Why fourth:** Foundations work already. This just adds data coverage and durability.

**Steps:**
1. Extend `_skillDeltaForTask` switch for all World 1–7 lesson IDs
2. Add SharedPreferences load/save for `_profileSkillValues`
3. Test: values survive hot restart

**Risk:** Low. Pure data + one async read/write.

---

### 🟠 Priority 5 — Sizing Slider (2–3 days)
**Why fifth:** Feature is scoped and self-contained. Only needed for sizing-specific lessons.

**Steps:**
1. Add `sliderMin`/`sliderMax`/`currentValue` to `Act0SizingConfigV1`
2. Add `onSizingValueChanged` callback to runner widget
3. Build slider section in `_SizingPresetsLaneV1`
4. Wire state update in preview screen
5. Add at least one lesson that uses `presetsWithSlider` mode to validate

**Risk:** Low-medium. UI-only change, no data corruption risk.

---

### 🟠 Priority 6 — Auto-Replay Player (1–2 days)
**Why last:** Interactive replay (manual tap) already works. Auto-play is a quality-of-life feature, not blocking.

**Steps:**
1. Add `_isAutoPlaying`/`_autoPlayTimer` state to `_Act0LessonRunnerShellV1State`
2. Add play/pause button to action trail header
3. Timer: 1200ms per step, auto-stops at end
4. Test: auto-play advances `_actionTrailFocusedIndex` correctly

**Risk:** Low. Additive only.

---

## 9. Copy Strategy for Sharky Lines

### Correct answer (happy mood) — rotate through these:
```
"Sharp read."
"That's the move."
"Exactly right."
"I like how you think."
"Clean table read."
```

### Wrong answer — thinking (close miss):
```
"Not quite. Let me help."
"I'd play it different here."
"Close, but there's a better read."
"Let's look at this together."
```

### Wrong answer — repair (significant miss):
```
"Good spot to fix."
"That's a leak. Here's why."
"Let's rewind and look again."
```

### Consecutive wrongs (2+ in a row) — use repair mood with different text:
```
"I believe in you. Let's try once more."
"This is tricky. I'll point at the key clue."
```

### Skill gain announcement (inline in toast):
```
"+{N} {SkillLabel}" — no extra copy needed, the bar is the signal
```

### End of lesson (celebrate mood):
```
"You're reading the table with more control."
"Sharky approves. Keep that up."
"That's consistent. Real progress."
```

### Implementation: use a rotation index per lesson session
```dart
// In _skillGainToast or Sharky cue builder:
final _correctReactionPool = [
  'Sharp read.',
  "That's the move.",
  'Exactly right.',
  'I like how you think.',
  'Clean table read.',
];
int _correctReactionIndex = 0;

String _nextCorrectReaction() {
  final line = _correctReactionPool[_correctReactionIndex % _correctReactionPool.length];
  _correctReactionIndex++;
  return line;
}
```

---

## 10. Files to Touch — Summary

| File | Change |
|------|--------|
| `assets/images/mascot/*.png` | ADD — 5 emotion images |
| `pubspec.yaml` | ADD asset directory registration |
| `act0_lesson_runner_shell_v1.dart` | MODIFY — image-based mascot, auto-replay button |
| `act0_shell_state_v1.dart` | MODIFY — add `sliderMin/Max/step/currentValue` to sizing config |
| `act0_shell_preview_screen_v1.dart` | MODIFY — expose skill deltas, persist values, wire onSizingValueChanged |
| `act0_feedback_shell_v1.dart` | MODIFY — add collapsible context, Sharky header, skill gain row |
| `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | MODIFY — add/update tests for new feedback layout |

---

## 11. Tests to Add / Update

```dart
// Skill gain visible on correct answer:
test('Feedback card shows skill gain row on correct drill answer', ...)

// Skill gain hidden on wrong answer:
test('Feedback card has no skill gain row on wrong drill answer', ...)

// Context starts collapsed on drill review:
test('Table read context is collapsed by default in drill feedback', ...)

// Sharky image key present:
test('Sharky mascot renders correct asset key for happy mood', ...)

// Auto replay advances index:
test('Auto-play timer advances action trail focused index', ...)

// Slider renders when mode is presetsWithSlider:
test('Sizing panel renders slider when mode is presetsWithSlider', ...)
```

---

## 12. What NOT to Change

- `Act0SharkyMoodV1` enum values — do not add or reorder
- `Act0SharkyCueV1` field names — they are already used in tests
- `_SharkyCuePillV1` widget key names — `act0_shell_sharky_outcome_reaction`
- `act0_shell_sharky_mascot` key — used in tests
- The `beginner` preset in `Act0SharkyCueV1.beginner` — only extend, do not rename fields

---

## 13. Definition of Done

This plan is complete when:
- [ ] Real Sharky images render in at least theory + feedback phases
- [ ] Wrong-answer feedback shows context collapsed by default
- [ ] Correct-answer feedback shows skill gain row with animated bar
- [ ] Skill values survive hot restart (SharedPrefs)
- [ ] At least 20/60 lessons have explicit skill mapping (up from 7)
- [ ] `presetsWithSlider` mode renders a functional slider
- [ ] Action trail has play/pause button; auto-play steps through trail
- [ ] `dart analyze` passes with zero errors
- [ ] `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart` passes fully

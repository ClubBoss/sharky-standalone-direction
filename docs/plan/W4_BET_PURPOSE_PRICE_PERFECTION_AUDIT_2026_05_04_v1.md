# W4 Bet Purpose And Price Perfection Audit

Date: 2026-05-04
World: world_5 — Bet Purpose And Price
Pass standard: same `code + tests + audit + master-plan trace` loop as W0/W1/W2/W3.

---

## Gates checked

### 1. Lesson spine integrity

- 7 lessons present: Why bets happen, Value bets, Bluff pressure, Protection and denial,
  Call price, Small/half/pot, Price checkpoint.
- Each lesson: theory → drill(s) → review.
- Each task has a non-empty `teachingSteps` list.
- PASS.

### 2. Decision density

- 12 drill tasks with `options.length >= 2` across world_5.
- Threshold: 10.
- PASS.

### 3. Suboptimal literacy

- `_world4BluffPressureRunner` now carries `check` option with
  `quality: suboptimal` and `feedbackTitle: 'Playable move.'`.
- Framing: growth, not punishment.
- PASS.

### 4. Bridge to W5 (Board And Draws)

- `_world4CheckpointRunner` correct option `feedbackReason` now reads:
  `'A bet tells a purpose, creates a size, and gives the caller a price.
   Next, board texture tells you which bet purpose fits.'`
- Contains: `board`, `purpose`, `price`.
- PASS.

### 5. Forbidden-phrase guard

- Content does not contain: `solver`, `gto`, `equity formula`, `range construction`,
  `combo`, `minimum defense`, `draw`.
- PASS.

---

## Regression suite

flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart

Result: 118 tests passed, 0 failed.

---

## New contract tests added

- World 5 has enough true decision reps before World 6
- World 5 includes suboptimal literacy as non-punitive growth
- World 5 checkpoint bridges to board texture thinking

---

W4 perfection pass: PASS.

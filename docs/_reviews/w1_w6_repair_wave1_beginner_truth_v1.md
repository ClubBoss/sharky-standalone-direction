---
status: "w1_w6_repair_wave1_beginner_truth_closed"
status_source: "derived"
baseline: "ecddf8e15d95"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Repair Wave 1 - Beginner Vocabulary Order + First-Table Assessment Validity

Verdict: `w1_w6_repair_wave1_beginner_truth_closed`

Base HEAD: `ecddf8e15d95778faa464a900b134d1edf61ced3`

Implementation commit: `52f42938d689270416980f9dcdfd26fbab755cbf`

Branch: `codex/w1-w6-repair-wave1-beginner-truth-v1`

## Findings closed

- `W1W6-LT-001`: beginner first route no longer relies on undefined table vocabulary before W1.s01 source teaching.
- `W1W6-LT-002`: Act0 `first_table_guide_one_clear_choice` no longer exposes the answer through the absurd old postflop/no-board contradiction.
- `W1W6-LT-003`: `content/_meta/term_introduction_contract_v1.json` now owns the admitted beginner table terms and aliases.
- `W1W6-LT-014`, first-table-guide / W1.s01 slice only: changed rows now return clue-owned correct/incorrect feedback and aligned `why_v1` copy.

## Terms added to the beginner guard

The new `beginner_term_guard` covers:

- `HERO`
- `VILLAIN`
- `BUTTON` with `BTN` / `button`
- `CUTOFF` with `CO` / `cutoff`
- `SMALL_BLIND` with `SB` / `small blind`
- `BIG_BLIND` with `BB` / `big blind`
- `BLINDS`
- `PREFLOP`
- `POSTFLOP`
- `BOARD`
- `POT`
- `SIZING`
- `RANGE`

The older priority-term contract remains intact for `EQUITY`, `PROBE`, `BLOCKERS`, `OUTS`, `OOP`, `PAIRED`, `SPR`, `ICM`, `EV`, `EXPLOIT`, and `COMBO`.

## First appearance / explanation / assessment evidence

W1.s01 now starts with explicit beginner vocabulary before the first decision objective:

- `Hero` / `Villain`: `content/worlds/world1/v1/sessions/w1.s01/session.md:4`
- `BTN/button`: `content/worlds/world1/v1/sessions/w1.s01/session.md:5`
- `CO/cutoff`: `content/worlds/world1/v1/sessions/w1.s01/session.md:6`
- `board` / `pot`: `content/worlds/world1/v1/sessions/w1.s01/session.md:7`
- `SB/small blind`, `BB/big blind`, `blinds`: `content/worlds/world1/v1/sessions/w1.s01/session.md:8`
- `preflop` / `postflop`: `content/worlds/world1/v1/sessions/w1.s01/session.md:9`
- `sizing`: `content/worlds/world1/v1/sessions/w1.s01/session.md:10`
- `range`: `content/worlds/world1/v1/sessions/w1.s01/session.md:11`
- contextual demonstration: `content/worlds/world1/v1/sessions/w1.s01/session.md:12`

First W1.s01 assessments after teaching:

- Step 1 assesses `CO/cutoff`, `Hero`, `BTN/button`, and `Villain` only after the vocabulary block: `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json:10`
- Step 2 assesses `BTN/button`, `SB/small blind`, and `BB/big blind`: `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json:39`
- Steps 3-4 assess `postflop`, `board`, `sizing`, and `pot`: `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json:68`

Later reuse evidence is encoded in `content/_meta/term_introduction_contract_v1.json` for W1.s02 / W2 / W4 / W6 reuse.

## Act0 first-table before/after contract

Before:

- Correct answer: `Hero is BTN, blinds are posted, and no board is out yet`.
- Old distractor: `The flop is already out and this is postflop`.
- Weakness: the old distractor contradicted the no-board table state and allowed answer-by-elimination.

After:

- Correct answer: `Hero is BTN/button, blinds are posted, and no board is out yet`.
- Plausible distractor 1: `CO/cutoff already folded, so Hero on BTN/button acts next`.
- Plausible distractor 2: `Blinds are posted, but Hero on BTN/button has no cards`.
- Correct feedback cites the visible table clues: BTN/button, blinds, no board.
- Incorrect feedback cites the missed visible clues: CO/cutoff folded, Hero has cards, no board.
- The first-table guide still tests setup reading only; it does not become a strategic raise/call/fold decision.

## Exact W1.s01 rows changed

- `content/worlds/world1/v1/sessions/w1.s01/session.md`
  - Added the beginner vocabulary block and contextual demonstration before the objective/scenario copy.
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json`
  - Step 1 prompt/feedback now expands `CO/cutoff`, `Hero`, `BTN/button`, and `Villain` while preserving expected action `call`.
  - Step 2 prompt/feedback now expands `BTN/button`, `SB/small blind`, and `BB/big blind` while preserving expected action `fold`.
  - Step 3 prompt/feedback now uses postflop board/sizing/pot language after the W1.s01 vocabulary block while preserving expected preset `one_third_pot`.
  - Step 4 prompt/feedback now uses value sizing language while preserving expected preset `half_pot`.

No W2-W6 content rows were edited.

## Feedback changes

- Step 1 incorrect feedback now names QJs, Hero on BTN/button, CO/cutoff, and the position clue.
- Step 2 incorrect feedback now names T6o, Hero in SB/small blind, out-of-position pressure, BTN/button, and BB/big blind.
- Step 3 incorrect feedback now names One-third pot and the cheap-price clue.
- Step 4 incorrect feedback now names Half pot and the value-size clue.
- Act0 wrong-option feedback now explains the missed table clue instead of relying on an impossible postflop distractor.

## Tests and guards added or updated

- `tools/term_coverage_scanner.dart`
  - Parses `beginner_term_guard`.
  - Requires each beginner term to declare canonical form, aliases, first permitted appearance, first explanation, first contextual demonstration, first permitted assessment, and later reuse.
  - Fails abbreviation/context before explanation.
  - Fails assessment before explanation/context.
  - Fails blocked unowned early aliases such as `cut-off` and `dealer-button`.
- `test/tools/term_introduction_glossary_safety_v1_test.dart`
  - Verifies production beginner terms and BTN/CO aliases.
  - Red/green temp-root test proves abbreviation/context before explanation fails.
  - Verifies production scanner success and emitted beginner-term list.
- `test/tools/w1_s01_beginner_source_sequence_v1_test.dart`
  - Parses active W1.s01 source rows.
  - Proves expected actions/presets did not drift.
  - Proves W1.s01 teaching precedes the active chain vocabulary.
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - Rejects the old `The flop is already out and this is postflop` distractor.
  - Requires plausible first-table setup choices and clue-owned feedback.

## Regression proof

Commands run:

```bash
python3 -m json.tool content/_meta/term_introduction_contract_v1.json >/dev/null
dart run tools/term_coverage_scanner.dart --root /Users/elmarsalimzade/Sharky_1.0
flutter test test/tools/term_introduction_glossary_safety_v1_test.dart test/tools/w1_s01_beginner_source_sequence_v1_test.dart test/tools/stage1a_wave1_signposting_terminology_contract_test.dart test/tools/worlds1_3_gold_spine_preflop_chain_feedback_wave_test.dart
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "First table guide keeps one same-signal recheck before the preflop setup read"
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Explicit beginner placement branch skips live diagnostics and premium preview before first hand"
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Placement diagnostic route outcome stays diagnostic-driven for representative fixtures"
flutter analyze
git diff --check
graphify hook-check
```

Results:

- Contract JSON parsed.
- Term scanner: `term introduction safety: PASS`.
- Tool/content tests: 13 tests passed.
- Act0 first-table focused test passed.
- Placement beginner branch test passed.
- Placement diagnostic route test passed.
- `flutter analyze`: no issues found.
- `git diff --check`: passed.
- `graphify hook-check`: passed.

## Scope proof

Changed implementation/test files:

- `content/_meta/term_introduction_contract_v1.json`
- `content/worlds/world1/v1/sessions/w1.s01/session.md`
- `content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `tools/term_coverage_scanner.dart`
- `test/tools/term_introduction_glossary_safety_v1_test.dart`
- `test/tools/w1_s01_beginner_source_sequence_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

No route manifests, W2-W6 content rows, Home/Learn surfaces, telemetry, generated fixtures, or dependency files were changed.

## Deferred W1W6-LT-014 remainder

Only the first-table-guide / W1.s01 slice was admitted and repaired here. The broader feedback-closure work for other W1-W6 rows remains deferred to the accepted grouped repair sequence.

## Next grouped wave

Recommended next wave: Wave 2 from the grouped repair program, focused on the next highest-EV source-owned feedback/learner-truth family without reopening route admission or W2-W6-wide template rewrites.

## Token-efficiency report

Context acquisition stayed in the active lane:

- Used `docs/context/CONTEXT_ROUTER_v1.md` and lane capsules rather than broad-reading archives.
- Read the accepted grouped repair program and repair ledger as the controlling prompt-derived evidence.
- Inspected only admitted owner seams and adjacent focused tests.
- Avoided W2-W6 source edits; later reuse evidence was cited through the contract without modifying those rows.

# W1 Showdown Basics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a W1-owned, validator-backed beginner showdown-basics source slice and canonical fixture.

**Architecture:** Add one isolated `w1.s11` source session with six source tasks, then generate the canonical fixture through the existing content-factory exporter. Extend the explicit W1 fixture list and focused tests without changing runtime routes or bridge ownership.

**Tech Stack:** Markdown/JSON source content, Dart factory and validators, Flutter test.

---

### Task 1: Add Failing W1 Showdown Contract Tests

**Files:**
- Create: `test/tools/w1_showdown_basics_source_authorship_repair_v1_test.dart`
- Modify: `test/tools/content_schema_l2_l3_validator_v1_test.dart`

- [ ] **Step 1: Write the failing source/fixture contract test**

Assert that the new fixture exists, has six tasks, covers
`hand_rank_order_v1`, `best_five_selection_v1`, `showdown_winner_v1`,
`kicker_tiebreak_v1`, and `board_plays_tie_v1`, and excludes forbidden scope.

- [ ] **Step 2: Write the failing L2/L3 test**

Call `validateContentSchemaL2L3FixturePathsV1` with the expected fixture path
and assert six countable tasks, route-ready coverage, transfer readiness, and
repair readiness.

- [ ] **Step 3: Run tests and verify RED**

Run:

```bash
flutter test test/tools/w1_showdown_basics_source_authorship_repair_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart
```

Expected: failure because the fixture/source/export path does not exist.

### Task 2: Add The W1-Owned Source Slice

**Files:**
- Modify: `content/worlds/world1/v1/world.md`
- Modify: `content/worlds/world1/v1/sessions/index.md`
- Create: `content/worlds/world1/v1/sessions/w1.s11/session.md`
- Create: `content/worlds/world1/v1/sessions/w1.s11/notes.md`
- Create: `content/worlds/world1/v1/sessions/w1.s11/drills/index.md`
- Create: six JSON drill files under `content/worlds/world1/v1/sessions/w1.s11/drills/`

- [ ] **Step 1: Add source ownership text**

Extend W1 goals/completion criteria with bounded visible-card comparison and
add `w1.s11` to the session index.

- [ ] **Step 2: Add six beginner source tasks**

Use independent W1 IDs and examples for two hand-rank tasks, one best-five
task, one winner task, one kicker task, and one board-plays tie task.

- [ ] **Step 3: Keep source copy bounded**

Use visible cards and plain feedback only. Do not add strategy, odds, ranges,
advanced edge cases, or W2 metadata.

### Task 3: Generate The Canonical Fixture

**Files:**
- Modify: `tools/content_factory_import_export_mvp_v1.dart`
- Modify: `tools/content_schema_l2_l3_validator_v1.dart`
- Create: `test/fixtures/content_factory_mvp/w1_showdown_basics_source_authorship_repair_v1.json`

- [ ] **Step 1: Add the exporter function**

Add `exportW1ShowdownBasicsSourceAuthorshipRepairV1`, six source specs, W1
metadata, `showdown_basics`, `best_five_before_showdown_winner`, one shared
same-signal group, and bounded safe-claim fields.

- [ ] **Step 2: Add the fixture to factory output and W1 coverage list**

Append the exporter to `exportTinyContentFactorySamplesV1` and append the path
to `w1ContentFactoryCoverageFixturePathsV1`.

- [ ] **Step 3: Regenerate and verify GREEN**

Run:

```bash
dart run tools/content_factory_import_export_mvp_v1.dart
flutter test test/tools/w1_showdown_basics_source_authorship_repair_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart
```

Expected: factory succeeds and focused tests pass.

### Task 4: Record Evidence And Update Control Plane

**Files:**
- Create: `docs/_reviews/w1_showdown_basics_source_authorship_repair_v1.md`
- Modify: `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- Modify: `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`

- [ ] **Step 1: Write the 17-section review artifact**

Record Path B, coverage for all four required concepts, claim safety,
bridge/canonical separation, validation, score, route impact, blockers, and
next wave.

- [ ] **Step 2: Update ledger evidence and pointers**

Keep W1 at 8.5; move W1-W12 to 8.2 only after validation; keep overall top-1
at 6.6; select W1-W6 Outcome Repair Verification / Local Cleanup next.

### Task 5: Verify And Commit

**Files:** all touched files.

- [ ] **Step 1: Format and validate**

Run Dart format, W1 foundation validator, W1 L2/L3 validator, focused tests,
factory import/export, and Flutter analyze.

- [ ] **Step 2: Run hygiene checks**

Run graphify hook-check, both diff checks, direct/diff-only ASCII, trailing
whitespace, CRLF, and final-newline checks.

- [ ] **Step 3: Review scope and commit**

Stage only admitted files, leave `output/` untouched, and commit:

```bash
git commit -m "feat: repair w1 showdown basics"
```

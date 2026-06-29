# W1-W6 Outcome Repair Verification / Local Cleanup v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Verify the repaired W1-W6 prerequisite chain and close only directly evidenced, low-risk learner-copy leftovers before freezing W1-W6 until Human QA or new evidence.

**Architecture:** Keep accepted source ownership, canonical fixture metadata, bridge separation, and route locks unchanged. Add one focused regression test, make deterministic copy-only edits in existing W1/W2/W5 exporter or source seams, regenerate fixtures through the existing factory, and record the evidence in the review artifact and control-plane ledgers.

**Tech Stack:** Dart, Flutter test, JSON content source and fixtures, Markdown control-plane docs.

---

### Task 1: Pin the local cleanup contract

**Files:**
- Create: `test/tools/w1_w6_outcome_repair_verification_local_cleanup_v1_test.dart`

- [ ] **Step 1: Add failing tests**

Add tests that require role-specific W1 seat feedback, reject learner-facing `trigger` in the W2 approved-raise source/fixture, and reject `river closure` in W5 session 05 source/fixture copy.

- [ ] **Step 2: Verify RED**

Run:

```bash
flutter test test/tools/w1_w6_outcome_repair_verification_local_cleanup_v1_test.dart
```

Expected: FAIL on the current generic W1 feedback and the two evidenced jargon phrases.

### Task 2: Implement deterministic copy cleanup

**Files:**
- Modify: `tools/content_factory_import_export_mvp_v1.dart`
- Modify: `test/tools/content_factory_import_export_mvp_v1_test.dart`
- Modify: `content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_raise_to_facing_bet.json`
- Modify: `content/worlds/world5/v1/sessions/w5.s05/session.md`
- Modify: `content/worlds/world5/v1/sessions/w5.s05/drills/index.md`
- Modify: `content/worlds/world5/v1/sessions/w5.s05/drills/d.classify_river_closure_connected_call_v1.json`
- Modify: `content/worlds/world5/v1/sessions/w5.s05/drills/d.classify_river_closure_dry_fold_v1.json`
- Modify: `content/worlds/world5/v1/sessions/w5.s05/drills/d.classify_river_closure_wet_raise_v1.json`
- Modify: `content/worlds/world5/v1/sessions/w5.s05/drills/d.chain_world5_turn_river_checkpoint_v1.json`
- Regenerate: `test/fixtures/content_factory_mvp/w1_seat_role_orientation_migration_pr2_v1.json`
- Regenerate: `test/fixtures/content_factory_mvp/w2_approved_raise_discipline_canonical_pr3_v1.json`
- Regenerate: `test/fixtures/content_factory_mvp/w5_board_shift_awareness_canonical_pr2_v1.json`

- [ ] **Step 1: Make the minimum copy changes**

Emit role-specific BTN/SB/BB feedback, replace `clear aggression trigger` with `clear approved raise spot`, and describe W5 river outcomes as final river cards instead of closures. Preserve identifiers, source ownership, task order, actions, claim metadata, and routes.

Align the two stale factory assertions with the already accepted bet-size copy
and 25-export output count exposed by the focused suite.

- [ ] **Step 2: Regenerate fixtures**

Run:

```bash
dart run tools/content_factory_import_export_mvp_v1.dart
```

Expected: PASS and deterministic fixture updates only.

- [ ] **Step 3: Verify GREEN**

Run the new focused test and the existing prerequisite-chain and factory tests. Expected: PASS.

### Task 3: Record the verification verdict

**Files:**
- Create: `docs/_reviews/w1_w6_outcome_repair_verification_local_cleanup_v1.md`
- Modify: `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`
- Modify: `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`

- [ ] **Step 1: Write the 21-section review artifact**

Record the Tier A closure matrix, P2/P3 dispositions, bridge/canonical proof, W6 terminal gate, claim limits, validation evidence, and freeze recommendation.

- [ ] **Step 2: Move the control-plane pointer**

Mark this verification wave complete, keep world scores unchanged, and freeze W1-W6 until Human QA, regression failure, or concrete new evidence. Do not open W7-W12.

### Task 4: Validate and commit

**Files:**
- Verify all files changed by Tasks 1-3.

- [ ] **Step 1: Run required validators and tests**

Run relevant W1-W6 foundation and L2/L3 validators, mixed bridge negative controls, focused tests, W7-W10 route-lock guards, W4-W6 forbidden-strategy scan, Dart format, and Flutter analyze.

- [ ] **Step 2: Run repository hygiene checks**

Run `graphify hook-check`, tracked and cached diff checks, direct/diff-only ASCII, trailing-whitespace, CRLF, and final-newline checks.

- [ ] **Step 3: Commit the bounded wave**

```bash
git commit -m "docs: verify w1 w6 outcome repairs"
```

Expected: only admitted W1-W6 copy, fixture, test, review, plan, and ledger files are committed; existing `output/` directories remain untouched.

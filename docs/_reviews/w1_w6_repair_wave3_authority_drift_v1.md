# W1-W6 Repair Wave 3 Authority Drift Closure v1

## 1. Verdict

`w1_w6_repair_wave3_authority_drift_closed`

## 2. Base HEAD

- Parent branch: `codex/w1-w6-repair-wave2-feedback-completeness-v1`
- Required base HEAD: `013beb9b67955a8ad3cfdb87e93e5e69319deb4f`
- Wave branch: `claude/w1-w6-repair-wave3-authority-drift-v1`

## 3. W3.s10 Canonical Row Set

Canonical active W3.s10 rows, confirmed by all four owners after the manifest
repair below:

- `chain_preflop_final_checkpoint_v1` (hand-chain checkpoint, 3 preflop steps)
- `choose_raise_btn_clean_transfer_v1` (independent `action_choice`)
- `choose_call_btn_facing_open_transfer_v1` (independent `action_choice`)
- `choose_fold_bb_weak_facing_open_transfer_v1` (independent `action_choice`)

`content/worlds/world3/v1/sessions/w3.s10/drills/index.md` and the runtime
loader (`DrillRuntimeAdapterV1.loadSessionDrills`, which reads `index.md`
before ever consulting the drills manifest) already agreed on this set.

`content/_meta/world_drills_manifest_v1.json` initially disagreed: it listed
`chain_preflop_final_checkpoint_v1` plus a different, superseded drill,
`choose_fold_final_preflop_checkpoint_v1`, and omitted all three transfer
drills. Git history proves this was mechanical staleness, not a competing
editorial authority:

- `world_drills_manifest_v1.json` is generated output
  (`tools/export_world_drills_manifest_v1.dart`) with `index.md` as its sole
  per-session drill source.
- Commit `ce5d52f5` ("feat: strengthen Stage 1A feedback and independent
  transfer") added the three transfer drills to `index.md` but never
  regenerated the manifest for `w3.s10`.
- The manifest's stale `choose_fold_final_preflop_checkpoint_v1` entry
  predates that commit; its source JSON is untouched, unrouted by the
  runtime, and absent from `index.md`.

This is the same root cause as the accepted `W1W6-LT-005` finding (active
source/test authority drift), so the manifest entry was corrected to match
the proven source of truth (`index.md`) rather than treated as a fresh
authority conflict. No wholesale manifest regeneration was run — the fix
touches only the `w3.s10` entry (full-generator regeneration was tested in a
scratch run and reverted; it touches many unrelated W0-series sessions,
which is out of Wave 3 scope).

## 4. Stale Guard Expectation Repaired

`test/guards/world3_early_arc_runtime_truth_contract_test.dart`:

- the `w3.s10` block now expects all four active drills in `index.md` order;
- the hand-chain checkpoint assertions (kind, 3 preflop steps, first/last
  prompt) are preserved unchanged;
- the three transfer drills are asserted `DrillKindV1.actionChoice`, keeping
  them explicitly distinct from `DrillKindV1.handChain`;
- a new parity test, `W3.s10 active drill-manifest truth matches active
  drills index`, cross-checks `index.md` against
  `world_drills_manifest_v1.json` and asserts the superseded drill JSON file
  still exists on disk (preserved, inactive).

No learner row was added, removed, or rewritten.

## 5. W5 Active Session Range

Active W5 sessions: `w5.s01`-`w5.s10`. `w5.s11` source remains present
(`content/worlds/world5/v1/sessions/w5.s11/session.md`) but is not active and
not manifest-admitted.

## 6. W5.s11 Preserved-Only Proof

- `content/worlds/world5/v1/sessions/index.md` already ended at `w5.s10` and
  already excluded `w5.s11` (no change needed).
- `content/_meta/world_sessions_manifest_v1.json` and
  `content/_meta/world_drills_manifest_v1.json` already ended World 5 at
  `w5.s10` (no change needed).
- `content/worlds/world5/v1/index.md` — the one stale owner — previously
  listed `w5.s11: Basic Outs Awareness` as a plain active-looking row. It now
  reads: "Active W5 sessions end at w5.s10. `w5.s11` (Basic Outs Awareness)
  source is preserved but inactive and is not admitted by active manifests."
- `content/worlds/world5/v1/sessions/w5.s11/session.md` still exists;
  nothing under `w5.s11/` was deleted or activated.

## 7. Parity Protection

Extended two existing canonical guards rather than adding a new framework:

- `test/guards/world3_early_arc_runtime_truth_contract_test.dart` gained the
  W3.s10 index-vs-drill-manifest parity test described above (Section 4).
- `test/guards/world5_early_runtime_truth_contract_test.dart` gained
  assertions that the top-level `content/worlds/world5/v1/index.md` lists
  only `w5.s01`-`w5.s10` as active rows and still names `w5.s11` with the
  word "inactive" (catches both "index silently drops w5.s11" and "index
  re-admits w5.s11 as active" regressions). The existing session-index,
  drill-manifest, session-manifest, and preserved-source-file assertions for
  W5.s11 were already present and unchanged.

Failure output from both guards identifies the world, session, expected
active id list, and the actual index/manifest content via standard
`expect(..., reason: ...)` messages.

## 8. Semantic Diff Proof

Changed files: `content/_meta/world_drills_manifest_v1.json`,
`content/worlds/world5/v1/index.md`,
`test/guards/world3_early_arc_runtime_truth_contract_test.dart`,
`test/guards/world5_early_runtime_truth_contract_test.dart`.

- Zero changes to any drill JSON content (prompts, `expected`,
  `acceptable_actions`, `why_v1`, `feedback_*_v1`).
- Zero changes to `content/worlds/world3/v1/sessions/index.md` or any W3/W5
  session/world narrative copy other than the one W5 top-level index
  sentence above.
- Zero route changes. Zero UI changes.
- The manifest edit is a path/id list correction that mirrors already-active
  runtime truth (`index.md`); the runtime loader for `w3.s10` reads
  `index.md` first and never fell back to the manifest, so production
  behavior for W3.s10 is unchanged before and after this fix.
- The superseded `choose_fold_final_preflop_checkpoint_v1.json` source file
  was left in place, untouched, and unreferenced by any active owner.

## 9. Tests

- `flutter test test/guards/world3_early_arc_runtime_truth_contract_test.dart test/guards/world5_early_runtime_truth_contract_test.dart` — 4 passed.
- `flutter analyze` — no issues found.
- `git diff --check` — clean.
- `git diff --cached --check` — clean.
- `graphify hook-check` — exit 0.

## 10. Scope Proof

Changed implementation scope:

- one W3 drill-manifest entry (`w3.s10`) corrected to match its own
  generator's source of truth;
- one W5 top-level index sentence;
- one existing W3 guard file extended (row-set fix + parity test);
- one existing W5 guard file extended (top-level index parity assertions);
- this closure review.

Out-of-scope surfaces not touched: W4 actionability, W5 structured board
context, telemetry, Modern Table, W7+, dependencies, Human QA, any other
world's drill manifest entries, routes, or UI.

## 11. Next Wave

Proceed to Wave 4 (prompt/table structured-context and mobile actionability)
per the grouped repair program. Do not reopen Wave 3 without new evidence.

## 12. Token-Efficiency Report

- exact token usage: `token_usage_unavailable`
- files opened: required context capsules/router/AGENTS, grouped repair
  program, final repair ledger, Wave 2 closure review, W3/W5 session and
  drill index files, W3/W5 guard tests, drill JSON sources for W3.s10,
  `world_drills_manifest_v1.json` (targeted region), `export_world_drills_manifest_v1.dart`,
  `drill_runtime_adapter_v1.dart`, `drill_contract_v1.dart` (enum only)
- targeted searches: git log/show for `index.md`, the manifest file, and the
  superseded drill JSON to establish authority provenance; grep for `w3.s10`
  in the manifest; directory listing of W3.s10 drills
- broad searches: `0`; one full-generator dry run was executed to test scope
  size, diffed, and reverted after confirming it was too broad
- commands/tests run: branch/HEAD/status checks; focused guard tests (red
  then green); `flutter analyze`; `git diff --check` and
  `--cached --check`; `graphify hook-check`
- repeated investigation: one (the reverted full-generator run) — necessary
  to prove the scoped hand-edit was the correct bound, not avoidable in
  hindsight given the manifest disagreement was unexpected
- avoidable context work: none material
- another discovery pass required: no

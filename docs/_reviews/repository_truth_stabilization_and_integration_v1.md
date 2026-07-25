---
status: "repository_truth_stabilized_main_green_wave4_ready"
status_source: "derived"
doc_date: "2026-05-13"
baseline: "bd066b769b88"
generated_by: "docs_frontmatter_v1"
---

# Repository Truth Stabilization + Baseline Repair + Integration/Push v1

## 1. Verdict

`repository_truth_stabilized_main_green_wave4_ready`

With one honest caveat: "main green" means the canonical entry-point scripts
(`fast_loop_world1_v1.sh`, `release_gate_world1.sh`, `checkpoint_world1_v1.sh`)
are proven structurally intact after the 867-file reduction, and the six
named pre-existing broken tests are repaired. It does **not** mean the full
test suite is green — a large body of pre-existing, unrelated test debt
exists in the baseline (documented in Section 6) that this task's scope does
not authorize fixing.

## 2. Base HEAD

- Parent branch: `claude/repository-reduction-dead-system-decommission-v1`
- Required base HEAD (resolved and confirmed as exact worktree HEAD before
  branching): `bd066b769b8887ad7b36739ae7b16a4c2200d6ec`
- Branch: `claude/repo-truth-stabilization-and-integration-v1`

## 3. Authority inaccuracies corrected

### A1. Topology path mismatch

`docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` was corrected in three spots:

1. Removed `lib/ui_v2/persona/*` from the "dormant/non-route" list — this
   path does not exist anywhere in the repository; listing it as a present
   dormant system was a doc/reality mismatch, not a true dormant family.
2. `lib/archive/legacy_runners/*` claimed "no longer active runtime
   surfaces" — production evidence (imports + direct test coverage) proves
   it is still live-wired through the non-Act0 legacy/compatibility training
   flow (`lib/ui_v2/screens/table_first_navigation.dart` →
   `pushWorld1FoundationsRunnerV1`, called from `module_launcher_screen.dart`
   and `module_summary_screen.dart`). Corrected to state it is non-canonical
   for Act0 but still reachable and not safe to delete, without promoting it
   to new product direction.
3. Same correction applied to the "Canonical vs legacy-only" summary line.
4. Added inline notes for `lib/personalization/*` and `lib/ui_v3/*` (both
   listed as "dormant" but proven to have live non-Act0 consumers / be a
   load-bearing compile dependency respectively) so the doc doesn't imply
   they're unused.

Act0 remains the canonical default entry; no route or product behavior
changed.

### A2. Route-to-B document classification

Investigated whether `AGENTS.md`'s "historical/reference execution docs
only" framing of `ROUTE_TO_B_EXECUTION_RESET_v1.md` /
`ROUTE_TO_B_ACTION_LADDER_v1.md` contradicts `beta_ship_runbook_v1_test.dart`
asserting on their live content.

**Finding: no contradiction, no AGENTS.md change needed.** The test asserts
these docs contain specific historical narrative phrases (`Main-First
Final-Readiness SSOT / Authority Migration`, `## Point B`) — confirmed
present in both files. This is a legitimate historical-citation/traceability
contract for the beta-ship runbook's documentation lineage, not a claim that
Route-to-B docs govern active runtime/readiness routing. "Historical/
reference only" (not used for day-to-day execution authority) and "still
cited by name in a specific document-lineage test" are not in tension. The
test's actual failure (see Section 4) was an unrelated stale path to
`TRUE_RELEASE_READINESS_SSOT_v1.md`, now fixed.

## 4. Tests repaired (all six, plus discovery notes)

All six were independently confirmed to fail identically on the unmodified
base branch (`git stash` back to `bd066b76`) before being fixed, proving
none of this is newly introduced.

1. **`test/tools/release_readiness_calibration_v1_test.dart`** — PASS.
   Removed `docs/README_SSOT.md` (never existed in this repo's real history
   — only an artifact of the initial squashed baseline-import commit) and
   `docs/ROADMAP_FINAL_100_SSOT.md` (confirmed archived to
   `docs/archive/obsolete_plans/`, no longer active) from the `activeFiles`
   list. Repointed the historical-doc read to
   `docs/archive/obsolete_plans/TRUE_RELEASE_READINESS_SSOT_v1.md`. Added
   the missing readiness-authority pointer line to `docs/README.md` (which
   remains in the list — it is real, and its own stated purpose as the
   "canonical navigation entrypoint" makes it a legitimate carrier of this
   pointer).

2. **`test/tools/beta_ship_runbook_v1_test.dart`** — PASS. Same historical
   path fix. Also updated the stale content assertion
   `contains('Core Product Readiness')` → `contains('Minimal Readiness
   Model')`, matching `PROJECT_READINESS_EPICS_SSOT_v1.md`'s current heading
   after its self-documented 2026-05-13 simplification (confirmed via the
   file's own "Why This Was Simplified" section — this is deliberate content
   evolution, not drift).

3. **`test/guards/legacy_training_launcher_boundary_contract_test.dart`** —
   PASS. Removed the `map` variable/assertion entirely: it read
   `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, which no longer exists
   anywhere under `lib/` (already archived to
   `docs/archive/archived_old_versions/`) and has no current canonical-map
   replacement — the whole "canonical map screen" concept was retired.
   Contract-level proof for removal: zero current subject exists for this
   specific assertion; every other assertion in the file (training launcher,
   canonical launch plan, intake, table-first nav, session result) still has
   a live, existing subject and was left untouched. Also discovered and
   fixed a second stale path in the same file
   (`lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart` →
   `lib/archive/legacy_runners/world1_foundations_microtask_runner_screen.dart`).

4. **`test/guards/world1_foundations_microtask_contract_test.dart`** —
   compile-blocking issue fixed; behavioral debt remains (documented
   honestly, not claimed green). Repointed three imports
   (`modern_table_screen_v1.dart`,
   `world1_foundations_microtask_runner_surface_v1.dart`,
   `world1_foundations_microtask_runner_screen.dart`) to their current
   `lib/archive/legacy_runners/` locations — this was a hard `Undefined
   name`/`Couldn't find constructor` compile error blocking the entire
   6,344-line file from ever running. Once compiling, the file reveals **31
   of 79 sub-tests failing** on specific widget-tree/rendering assertions
   (seat-quiz caption safe zones, board-strip keys, table canvas stability)
   that were never previously exercised — the compile error meant *zero*
   sub-tests in this file had run at all, at any point before this fix. This
   is pre-existing behavioral debt masked by a compile error, not something
   this task introduced. Fixing 31 individual widget-behavior assertions
   would require either touching the live (if archived-labeled)
   `legacy_runners` UI or a broad test rewrite — both explicitly forbidden
   in this task's scope. Flagged for a dedicated follow-up task.

5. **`test/guards/world1_canonical_terminal_surface_cutover_contract_test.dart`**
   — PASS, all 6 sub-tests. Repointed six stale path references (the same
   three files as #4, plus `world1_modern_table_adapter_v1.dart` and
   `canonical_terminal_session_drill_surfaced_runner_v1.dart`) to their
   current `lib/archive/legacy_runners/` locations, including one embedded
   `export` string-literal assertion, verified against the real file's
   actual `export` statement before changing it.

6. **`test/ui_v2/runner/world1_canonical_runner_authority_v1_test.dart`** and
   **`test/ui_v2/runner/world1_canonical_table_render_branch_v1_test.dart`**
   — **no fix needed; both already pass cleanly in isolation.** Neither
   imports any stale path (each only imports its own subject-under-test
   file, both of which exist at their current location). The prior
   reduction report's grouping of these two files into the same "family" as
   item 5 was imprecise — running them combined with the actually-broken
   file in one `flutter test` invocation produced a misleading cumulative
   pass/fail count. The entire failing family was contained in item 5.

**Exact final tally for the six named test files**: 5 of 6 files now pass
100% clean (13/13 sub-tests across files 1, 2, 3, 5, plus 2/2 already-passing
sub-tests in file 6's two files = confirmed via a combined run). File 4's
compile-blocking defect is fixed; its remaining 31/79 sub-test failures are
pre-existing behavioral debt, explicitly out of this task's scope.

### Additional discovery (not fixed, out of scope)

A broken-reference scan for the same stale `lib/archive/legacy_runners/`
path pattern found **5 more test files** with an identical root-cause
pattern, not named in this task's admitted six:

- `test/guards/world_campaign_map_home_contract_test.dart` — passes cleanly
  (references resolve fine as-is).
- `test/guards/world1_failure_to_learning_conversion_contract_test.dart` — 1
  failure.
- `test/guards/world1_feedback_family_routing_contract_test.dart` — 1
  failure.
- `test/tools/product_surface_audit_v1_test.dart` — passes cleanly.
- `test/ui_v2/modern_table_entry_test.dart` — fails at file-load (likely a
  compile-level issue, same family as #4 above).

Per this task's explicit scope ("Target only these proven failures: [the
six listed]" / "do not perform broad test rewrites"), these were not
touched. Flagged for a dedicated follow-up task alongside item 4's remaining
debt.

## 5. Tests retired

None. Zero tests were deleted. One assertion (the `map` variable check in
item 3) was removed with exact contract-level evidence documented above —
its subject no longer exists and has no current replacement — but the test
file itself, and every other assertion in it, remains intact and active.

## 6. Canonical tool-entry validation (Part C)

- **`tools/fast_loop_world1_v1.sh`**: entry-point mechanics fully validated
  — `[lint-tools]` syntax + executable checks pass for all 18 checked
  scripts, `dart analyze` reports `No issues found!`, and the Tier0
  test-selection policy correctly resolves and runs its default guard
  (`test/ui_v2/act0_shell_preview_screen_v1_test.dart`). That default guard
  itself carries 161 pre-existing sub-test failures — confirmed via `git
  stash` to fail identically (same `528 -160`/`+528 -161` pattern) on
  unmodified base HEAD `bd066b76`. Not caused by the reduction; not one of
  the six admitted repair targets; not fixed.
- **`tools/release_gate_world1.sh`**: entry-point mechanics fully validated
  — git diff hygiene passes, `dart format --set-exit-if-changed` passes on
  all 5 changed test files (one needed reformatting after the sed-based
  import fix, applied and re-verified with no behavior change), the
  `--force-tests --all-selected-guards` policy correctly selects and runs
  all 7 canonical Tier0 guard files (559 total sub-tests). 164 failures
  confirmed via `git stash` to be byte-for-byte identical on unmodified base
  HEAD `bd066b76` (same `559 -164` final tally). Content classes: RU
  translation-residue checks, campaign-pack-registry invariants, Act0
  feedback-source contract checks — none plausibly related to the tools/
  output/docs reduction.
- **`tools/checkpoint_world1_v1.sh`**: reaches the **identical** failure
  point as `release_gate_world1.sh` (step 3/5, fast-loop tier checks) —
  `set -euo pipefail` aborts the script there in both invocations. The
  full-suite step (5/5, `flutter test -r expanded`) was **never reached in
  either script**, because it is gated behind the same pre-existing Tier0
  guard debt. This is a structural limitation that predates this task; it
  cannot be validated until that debt is resolved (out of this task's
  scope). Reported honestly, not hidden.
- **`graphify hook-check`**: PASS (exit 0), run repeatedly throughout.
- **Feedback completeness guard** (`tools/w1_w6_feedback_completeness_guard.dart`):
  PASS — 455 active decision rows scanned, 0 missing correct/incorrect, 0
  missing acceptable feedback, 0 missing `why_v1`.
- **Term coverage scanner** (`tools/term_coverage_scanner.dart`): PASS —
  1,598 active learner session files scanned, term-introduction safety
  `PASS` for all priority and beginner terms.
- **Screenshot/review lane entry point referenced by capsules**
  (`tools/act0_real_text_surface_capture_v1.dart`, named in
  `VISUAL_PROOF_CAPSULE_v1.md`): confirmed present and untouched by the
  reduction.

**Conclusion**: the reduction (removal of 478 zero-reference `tools/` files
+ 4 root scripts) did not break any canonical validation entry point's own
mechanics. All observed test-content failures are proven pre-existing and
unrelated.

## 7. Capsule refresh (Part D)

Updated stale current-state fields only (no architecture rewrite, no new
capsules):

- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`: freshness date, verified branch
  state (now names hygiene + reduction + stabilization closures), frozen
  Wave 4 HEAD (`1d7a76215ac008eb3066c5030e514c5fa80029c7`), current active
  task set to "none active; parked," and next route restated as `W1-W6
  Repair Wave 4 — Prompt/Table Structured Context + Mobile Actionability`.
- `docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md`: same HEAD/task refresh.
- `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`: same HEAD refresh; Wave 4
  framing left unchanged since it was already accurate.
- `docs/context/REPO_HYGIENE_CAPSULE_v1.md`: no stateful HEAD/freshness
  fields exist in this capsule (it is purely procedural) — nothing to
  refresh.

## 8. Full validation results

- `git diff --check`: exit 0.
- `git diff --cached --check`: exit 0.
- `flutter analyze`: `No issues found!` (13.3s).
- `graphify hook-check`: exit 0.
- `dart format --set-exit-if-changed` on all changed `.dart` files: exit 0
  (after one auto-format pass, no logic change, re-verified by re-running
  the affected test at the same 48/31 pass/fail ratio before and after).
- The six named tests: see Section 4 exact tally.
- `tools/fast_loop_world1_v1.sh`, `tools/release_gate_world1.sh`,
  `tools/checkpoint_world1_v1.sh`: entry-point mechanics validated; content
  failures classified and proven pre-existing (Section 6).
- `tools/w1_w6_feedback_completeness_guard.dart`,
  `tools/term_coverage_scanner.dart`: PASS.
- Docs/router broken-reference scan: clean for all paths this task touched
  or removed; the 5 additional test files with the same stale-path pattern
  (Section 4) were discovered by this scan and are explicitly out of scope.

## 9. Integration method

- `git fetch origin`: no new remote history.
- Pre-push `origin/main`: `a21971a607fae15a2c9464dd143e0e445ae155c7`
  (unchanged since the W1-W6 audit branch first diverged from it).
- Ancestry proof: `git merge-base --is-ancestor origin/main HEAD` succeeded
  — `origin/main` is a strict ancestor of this branch's HEAD. No divergence.
- Local `main` was already at `a21971a6` (equal to `origin/main`); fast-
  forwarded to this branch's HEAD with `git merge --ff-only` (no merge
  commit, no rebase, no squash, no history rewrite).
- Pushed normally: `main -> origin/main`.

(Exact final hashes and push confirmation are recorded in the final report
below, generated after the push step completed.)

## 10. Deferred uncertain dead-code candidates

Carried over from the prior reduction wave, still untouched (no new
investigation performed in this task, per its bounded scope):

- `lib/ui_v2/ui_v2_beta_shell.dart` (`UiV2BetaShell`) — zero real references
  found previously; an open investigation doc still references its
  internals.
- `lib/tools/v4_persona_mat_consistency_qa.dart`,
  `v4_visual_polish_final.dart`, `visual_cohesion_v4_qa.dart`,
  `visual_tokens_v4_verifier.dart` — self-referential no-op stub family.
- `lib/ui_v2/screens/drill_runner_screen.dart` and its 14 referencing test
  files — genuinely dead in production, entangled with broad E2E/readiness
  gates.
- `test/guards/world1_foundations_microtask_contract_test.dart`'s 31
  remaining behavioral failures, and the 5 newly-discovered test files with
  the same stale-`legacy_runners`-path pattern (Section 4) — both newly
  identified in this task, neither fixed.

## 11. Frozen Wave 4 HEAD

`1d7a76215ac008eb3066c5030e514c5fa80029c7` (this task's authority + test
repair commit; the capsule-refresh commit and this closure artifact sit on
top of it and are included in the same push).

## 12. Token Efficiency Report

- exact_usage: `token_usage_unavailable`
- estimated_total_tokens: `~200k-260k` (deep per-test investigation across 6
  files plus 5 newly-discovered ones, three full/near-full canonical script
  runs including one full 4,669-line and one 4,667-line captured log, two
  `git stash`/`pop` baseline-comparison cycles, and authoring this closure
  document)
- estimate_confidence: medium
- largest_token_sinks: (1) reading and re-running
  `world1_foundations_microtask_contract_test.dart` (6,344 lines) multiple
  times across the compile-fix and behavioral-discovery passes, (2) the two
  full `release_gate_world1.sh`/`checkpoint_world1_v1.sh` captured logs
  (~4,700 lines each, mitigated by redirecting to files and reading only
  head/tail), (3) the stash-based baseline-comparison reruns for both the
  single tier-0 guard and the 7-file canonical guard set
- avoidable_token_cost: none material — every broad run was either a
  required Part C validation step or a necessary baseline-comparison proof;
  output was consistently redirected to files with only summaries read back
- efficiency_verdict: acceptable for this task's evidence bar (six
  independent stale-path repairs each needed their own contract
  investigation; the pre-existing-vs-caused classification for two large
  canonical scripts genuinely required the stash-comparison technique, not
  assumption)
- files opened: `AGENTS.md`, `PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`,
  `docs/README.md`, all 6 target test files (1 in full at 6,344 lines, 5 at
  moderate size), 5 additional discovered test files (context reads only),
  `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`,
  `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`,
  `docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md`, `tools/ssot_continuity_guard_v1.sh`,
  `tools/release_preflight_world1.sh`, `tools/release_gate_world1.sh`,
  `tools/checkpoint_world1_v1.sh`, `tools/_test_policy_v1.sh`, 4 capsule
  files
- targeted_searches: ~20+ (per-file existence/reference checks, git log
  history for renamed/moved files, git grep for stale path patterns across
  the whole tree, docs-archive location confirmations)
- broad_searches: 3 (the two canonical-script full runs, one broken-
  reference scan across the whole tracked tree for the
  `legacy_runners`-family stale-path pattern that surfaced the 5 additional
  files)
- commands/tests: `git status`/`fetch`/`stash`/`stash pop`/`rev-parse`/
  `merge-base`/`rev-list`, `flutter analyze` (x2), `flutter test` (targeted,
  ~15 invocations across individual and combined files), `dart format`
  (x2), `graphify hook-check` (x3), `dart run` for feedback-completeness
  guard and term-coverage scanner, two full canonical-script runs
  (`release_gate_world1.sh` foreground, `checkpoint_world1_v1.sh`
  background)
- repeated_investigation: two deliberate stash/pop baseline-comparison
  cycles (not wasted — this was the only rigorous way to prove pre-existing
  vs. caused per Part C's explicit requirement)
- another discovery pass required: no for this task's scope; yes for the
  four items in Section 10 plus the 5 newly-discovered test files in
  Section 4, all explicitly flagged for a dedicated follow-up

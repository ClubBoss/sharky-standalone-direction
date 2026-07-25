---
status: "repository_hygiene_context_cost_reduction_closed_push_ready"
status_source: "derived"
doc_date: "2026-05-25"
baseline: "fbe670f06fed"
generated_by: "docs_frontmatter_v1"
---

# Repository Hygiene + Context Cost Reduction v1

## 1. Verdict

`repository_hygiene_context_cost_reduction_closed_push_ready`

## 2. Base HEAD

- Parent branch: `claude/w1-w6-repair-wave3-authority-drift-v1`
- Required base HEAD: `fbe670f06fedc3fcb7a5e9f76144bf84edd20f87`
- Branch: `claude/repo-hygiene-context-cost-reduction-v1`

## 3. Git reachability proof

- Worktree was clean at start (`git status --short` empty) and HEAD exactly
  matched the required base HEAD.
- `a21971a607fae15a2c9464dd143e0e445ae155c7` (origin/main) is an ancestor of
  HEAD; the 8 commits from the W1-W6 final learner-truth audit through Wave 3
  closure (`78692594` .. `fbe670f0`) are reachable from this branch.
- `origin/main` = `a21971a607fae15a2c9464dd143e0e445ae155c7`. This branch is 8
  commits ahead, 0 behind `origin/main`.
- No important commits exist only on orphaned/local branches for this repair
  lane; `codex/w1-w6-repair-wave1-beginner-truth-v1`,
  `codex/w1-w6-repair-wave2-feedback-completeness-v1`,
  `codex/w1-w6-final-learner-truth-audit-v1` etc. are all ancestors of this
  branch's history. No branches were deleted in this task (default: preserve).
- No staged or untracked *important* files existed pre-task; all untracked
  content was already git-ignored build/tooling drift.

## 4. Classification summary

Evidence-based inventory, not age-based:

- `active_ssot` / `active_capsule` / protected families: left untouched
  (`AGENTS.md`, `MASTER_PLAN_v3.0.md`, `PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`,
  `CONTEXT_ROUTER_v1.md`, all active capsules, W1-W6 manifests/content, active
  runtime/tests).
- `safe_delete` (3 root generated dumps + 240 Playwright CLI debug snapshots
  = 243 tracked files): see Section 5.
- `local_only_generated`, not touched (see Section 12): `output/` (1006
  tracked evidence files + ~219MB of already-gitignored local capture output)
  and root `.playwright-cli/` local dir (already gitignored, deleted from
  disk only, no git impact).
- `historical_keep`: `docs/_reviews/` (635 files) and `docs/archive/` +
  `docs/_archive/` (472 files) — an md5 duplicate scan across all of
  `docs/` found **zero** exact-duplicate files, so no bulk archive/delete
  action is justified there. Root-level baseline-snapshot docs
  (`edge_cases.md`, `good_bad_examples.md`, `_TEMPLATE_v2.txt`,
  `PROMPT_HARD_RULES`, `spotkinds.md`,
  `texas_holdem_trainer_gpt_bootstrap.md`) have zero cross-references but are
  original authored reference docs, not generated artifacts; kept.
- `uncertain_do_not_touch`: root dev scripts unmodified since the initial
  snapshot with 0-1 cross references (`fix_expected_paren.sh`,
  `test-analyze.sh`, `diagnose_tests.sh`, `verify_and_log.sh`) — plausibly
  still-used manual tools, no proof of obsolescence.

## 5. Files deleted

1. `home_diff.txt`, `profile_diff.txt` — raw `git diff` text dumps of
   `act0_home_shell_v1.dart` / `act0_profile_shell_v1.dart` accidentally
   committed under a `WIP: all changes` commit (2026-05-25). Zero references
   anywhere; the patched symbol (`_HomeDashboardRowV1`) does not exist in
   current source, confirming this was an abandoned/unapplied diff snapshot,
   not documentation. Fully recoverable from git history if ever needed.
2. `fast_loop_out.txt` — raw test-loop console output committed in the
   initial baseline snapshot (2026-05-09). Zero references.
3. 240 tracked `.playwright-cli/` files across 46 directories (root
   `.playwright-cli/` plus 45 subdirectories under `output/playwright/*/`) —
   Playwright's own internal debug snapshots (timestamp-named accessibility-
   tree `.yml` dumps and incidental `.png` captures), distinct from the
   deliberately-named evidence screenshots (e.g.
   `output/device_audit/act0_product_100/compact_phone.home.png`) that remain
   tracked untouched. Zero references in tests/tools/docs/.gitignore.

Total: 243 tracked files, ~2.11 MB removed from the active tree.

## 6. Files archived/moved

None. No exact duplicates or explicitly-superseded artifacts with a canonical
successor were found that warranted an archive move; the bar for
`archive_candidate` (Phase B evidence requirements) was not met by anything
inspected.

## 7. Files retained despite appearing old and why

- `docs/_reviews/*` (635 files) and `docs/archive/`, `docs/_archive/` (472
  files): no exact duplicates found; each closure/audit review is a unique
  evidence artifact and multiple are still-cited reopen conditions. Bulk
  reclassification was explicitly out of scope for this bounded wave.
- Root baseline-snapshot docs and scripts listed in Section 4
  (`uncertain_do_not_touch` / `historical_keep`): no generated/duplicate/
  superseded evidence found; left in place.
- `output/` (1006 tracked screenshot/manifest files): this is committed
  visual evidence, not accidental pollution — retained in full per the
  `Output Folder Rule` in `docs/context/REPO_HYGIENE_CAPSULE_v1.md` ("Do not
  delete `output/`").

## 8. `.gitignore` changes

Added to the existing "Session/CLI logs and snapshots" block:

```
fast_loop_out.txt
*_diff.txt

# Playwright CLI internal debug snapshots (accessibility-tree yml/png dumps);
# proven repeated pollution: 240 tracked files across 46 dirs removed in
# repository_hygiene_context_cost_reduction_v1.
.playwright-cli/
```

Each rule maps to a concrete observed example removed in this same wave
(Section 5). No canonical assets, goldens, active docs, source, tests, or
manifests were touched by these rules.

## 9. Router/capsule changes

Three capsules had a stale header (`Freshness date: 2026-07-06`, `Verified
product HEAD: e467090960d41e2f128655c417f56ff33fe19d70`, i.e. the pre-audit
Stage 1B integration point) that predates the entire W1-W6 final
learner-truth audit and its Wave 1-3 repair closures already committed on
this branch's history:

- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`: freshness/HEAD updated to
  `fbe670f0...`; "Current Active Phase" rewritten from "the gate has not
  started" (false — audit is closed, Waves 1-3 are closed) to name the audit
  verdict and the three closed waves with their review paths, and to state
  the exact next route (hygiene completion -> integration/push -> Wave 4,
  not opened).
- `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`: same header refresh; the
  stale sentence "The next admitted task is `W1-W6 Final Learner-Truth Audit
  + AI-Simulated QA Gate`; it has not started" replaced with the actual
  closed-waves state and Wave 4 as next.
- `docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md`: header freshness/HEAD/task
  descriptor refreshed to this hygiene wave; historical "Current Integration
  Evidence" section (a past-event record of the Stage 1B integration) was
  left untouched since it correctly describes a past event, not current
  state.

No capsule architecture was rewritten, no new capsules were created, and
`CONTEXT_ROUTER_v1.md` needed no change (its capsule table names files, not
HEADs, and required no gap-filling).

## 10. Broken-reference proof

- `git grep` for the three deleted root files and `.playwright-cli` across
  the tracked tree (excluding `.gitignore` itself): zero hits.
- `git grep` for the stale HEAD hash / stale capsule phrases: the only
  remaining hits are (a) `docs/_reviews/stage_1b_integration_and_capsule_refresh_v1.md`,
  a historical closure record correctly describing that past integration, and
  (b) the historical "Current Integration Evidence" section inside
  `WORKTREE_EVIDENCE_CAPSULE_v1.md` (Section 9) — both are legitimate
  past-event records, not active-state claims, so no repair was needed there.
- No test or runtime source references any deleted path.

## 11. Validation

- `git status --short`: clean after commit (see Section 15).
- `git diff --check`: exit 0.
- `git diff --cached --check`: exit 0.
- `flutter analyze`: `No issues found!` (14.5s).
- `graphify hook-check`: exit 0, no output.
- Targeted docs-reference scan: clean (Section 10).
- No focused tests were required; no test/tool path referenced a
  moved/removed file.

## 12. Before/after metrics

| Metric | Before | After |
| --- | --- | --- |
| Tracked file count | 13,269 | 13,026 |
| docs/_reviews count | 635 | 635 |
| docs/plan count | 107 | 107 |
| docs/context (capsule) count | 10 | 10 |
| docs/archive + docs/_archive count | 472 | 472 |
| Tracked output/screenshot-family files | 1,246 (1,006 evidence + 240 Playwright debug) | 1,006 (evidence only) |
| Untracked/ignored local files (`git status --ignored=matching`) | 416 | ~337 (root `.playwright-cli/`, 78 files, deleted from disk) |
| Duplicate-file count (md5, whole `docs/` tree) | 0 exact duplicates found | 0 |
| Total bytes removed from active tracked tree | — | ~2.11 MB (158,894 + 378,848 + 1,674,069 bytes) |

Local-only, already-ignored `output/` (219 MB, screenshots dated as recent as
2026-07-03) was intentionally left untouched — it is outside the tracked
repository, already excluded from default agent reads by
`CONTEXT_ROUTER_v1.md` ("Do not read by default: `output/**`"), and too close
to active work to bulk-delete safely in a bounded wave. Recommend a manual
`rm -rf output/` pass by the owner if disk space is a priority; it has zero
effect on this branch's push-readiness or tracked-repo context cost.

## 13. Remaining uncertain candidates

- Root dev scripts unmodified since the 2026-05-09 baseline snapshot
  (`fix_expected_paren.sh`, `test-analyze.sh`, `diagnose_tests.sh`,
  `verify_and_log.sh`): 0-1 cross-references, no proof of obsolescence.
  Classified `uncertain_do_not_touch`.
- `docs/_reviews/` (635) and `docs/archive/`+`docs/_archive/` (472): not
  reclassified file-by-file in this bounded wave; no exact duplicates or
  superseded-with-explicit-marker artifacts were found via the scans run, but
  a full one-by-one classification pass was out of scope
  ("do not mass-move all old reviews").
- `output/` local disk usage (219 MB, already git-ignored): left for owner's
  manual decision (Section 12).

## 14. Exact push readiness

`repo_hygiene_push_ready`. Do not push until the owner explicitly authorizes
it in a follow-up.

## 15. Next route

Repository hygiene is closed. Recommended next step: integration/push of
this branch, then Wave 4 (prompt/table structured-context and mobile
actionability) per `docs/_reviews/w1_w6_grouped_repair_program_v1.md`. Wave 4
is explicitly not opened by this task.

## 16. Token Efficiency Report

- exact_usage: `token_usage_unavailable`
- estimated_total_tokens: `~90k-120k` (broad but bounded inventory pass:
  branch/reachability checks, 4 required-reading docs, 9 W1-W6 closure/audit
  reviews at full or targeted read, 4 capsules read in full, one aborted
  whole-repo md5 dedup scan, one scoped docs-only md5 dedup scan, several
  targeted `git grep`/`git ls-files` passes)
- estimate_confidence: medium
- estimated_input_context: majority of the cost; the largest single sink was
  reading `w1_w6_final_learner_truth_audit_v1.md` and
  `w1_w6_grouped_repair_program_v1.md` in full plus the four capsules
- estimated_reasoning_and_output: small relative to input reads
- estimate_basis: file line counts and number of tool calls in this session,
  not an exact token meter
- largest_token_sinks: (1) the two W1-W6 audit/program review files, (2)
  `LEARNING_REPAIR_CAPSULE_v1.md` + `ACTIVE_ROUTE_CAPSULE_v1.md` full reads,
  (3) the whole-repo md5 dedup attempt that was abandoned after it started
  matching legitimate authored content-pack duplication and timed out
- avoidable_token_cost: the whole-repo md5 dedup scan (aborted/timed out) was
  avoidable in hindsight — a docs-scoped-only scan would have been the
  correct first move given the router's warning against broad content-tree
  reads
- efficiency_verdict: acceptable; one avoidable broad pass occurred and was
  cut short once it proved unproductive, no repeat of that mistake
- files opened: `AGENTS.md`, `CONTEXT_ROUTER_v1.md`, `.gitignore`,
  `PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`, `MASTER_PLAN_v3.0.md` (headers +
  one section), `w1_w6_final_learner_truth_audit_v1.md`,
  `w1_w6_grouped_repair_program_v1.md`, `w1_w6_final_repair_ledger_v1.md`,
  `w1_w6_repair_wave1_beginner_truth_v1.md`,
  `w1_w6_repair_wave2_feedback_completeness_v1.md`,
  `w1_w6_repair_wave3_authority_drift_v1.md`, all 10 `docs/context/*` capsule
  files (4 read in full, 6 header-grepped), `stage_1b_integration_and_capsule_refresh_v1.md`
  (grep only)
- targeted_searches: reference counts for 12 root files, `.playwright-cli`
  reference scan, stale-HEAD-phrase scan, duplicate-copy-naming scan,
  root-script reference counts
- broad_searches: 1 (whole-repo md5 dedup, aborted)
- commands/tests_run: `git status`/`log`/`branch`/`rev-parse`/`merge-base`/
  `rev-list`, `git diff --check` (working + cached), `graphify hook-check`,
  `flutter analyze`
- repeated_investigation: none beyond the one aborted broad dedup pass
- another discovery pass required: no

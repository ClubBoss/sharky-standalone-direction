# Sharky - exact-candidate handoff pilot (optional, no new queue)

Status: process-only pilot. Master Plan v5, live campaign dispatch, AGENTS.md,
existing Issues/PRs and the owner-admitted DoD remain authoritative.
This is NOT a new roadmap, CI gate, task state machine or scorecard.
No automatic merge, worker dispatch, owner assignment or credit is allowed.

## 1. Intake in the EXISTING PR / Issue

Before touching a candidate, read the live dispatch and verify the existing
PR/Issue and current owner. Silence, inactivity and missing comments do NOT
release a file, branch, simulator, test lane or source-owned contract.

Record a short handoff in the current PR, not in a separate tracking system:

- Original DoD: exact requirement and source URL / applicable gate.
- Candidate: PR, immutable base SHA, HEAD SHA, TREE SHA; expected merge base.
- Writer/lease: affirmative ownership receipt and explicitly permitted files.
- Exclusions: unowned files, neighboring active PRs and no-touch contracts.
- Next action: exactly one authorized action and named executor.
- Independent reviewer: named person/agent, evidence requirement, permission.
- Blocker: exact failure, missing proof or owner decision; UNKNOWN if unknown.

A Draft is not rejected or accepted solely for age/CI color. Reuse existing
Autopilot/PR tracking. Keep only one writer per overlapping file/contract;
read-only reviews may run in parallel on the same frozen candidate.

## 2. Exact-commit preflight (optional on an OWNED isolated worktree)

The repository already provides tools/sharky_compact_evidence_v1.sh,
tools/fast_loop_world1_v1.sh, tools/release_gate_world1.sh,
tools/checkpoint_world1_v1.sh and the existing CI workflows.
Do not duplicate their acceptance authority or edit their thresholds.

The new helper only pins SHA/TREE and optionally runs EARLY static checks.
It does not launch tests, trigger Actions, modify code, select a DoD verdict,
touch another worktree, assign ownership, or write the scorecard.

With actual immutable 40-hex values from the permitted existing PR:

```bash
# Read-only inspection. May be used on a detached historical checkout.
bash tools/sharky_candidate_preflight_v1.sh --base "$BASE_SHA" --head "$HEAD_SHA"

# Only the current sole writer, in their clean non-main isolated worktree:
bash tools/sharky_candidate_preflight_v1.sh --base "$BASE_SHA" --head "$HEAD_SHA" --run-static
```

--run-static fails closed on wrong SHA, non-ancestor base, dirty checkout,
main/detached branch, incomplete sparse checkout or missing existing evidence
wrapper. PLAN_ONLY reports missing changed Dart files without calling SDK.
Deleted Dart paths count as changes requiring analysis, but are excluded from
the formatter's existing-file list. The opt-in run performs:
1. git diff --check BASE HEAD
2. dart format --output=none --set-exit-if-changed on existing changed Dart paths
3. flutter analyze whenever any Dart path changed, INCLUDING deletion-only changes

Every opt-in run receives a unique attempt directory under
output/context-economy/preflight-<HEAD12>-<unique-id>/.
The existing wrapper writes each command's .raw.log and .summary.log there.
The identity.txt inside the same directory records full HEAD, TREE, BASE,
branch and UTC start time. An earlier failure is never overwritten by a
subsequent attempt on the same HEAD. Keep the directory and raw logs alongside
the acceptance receipt when required; do not count a later PASS as erasing RED.
An earlier local SDK version does not prove a hosted formatter pass on another
version. "No Dart changes" means SKIPPED, not PASS.
It is valid to use the helper PLAN_ONLY without executing any SDK.

Once static checks pass, the authorized writer selects the actual affected
tests and canonical gates. Example (replace with real DoD paths, do not run
arbitrary tests on another writer's branch):

```bash
bash tools/sharky_compact_evidence_v1.sh --id <unique-receipt> -- \
  flutter test <exact-applicable-test-paths> -r compact
./tools/fast_loop_world1_v1.sh
./tools/release_gate_world1.sh
# Required checkpoint, when the applicable policy requires it:
./tools/checkpoint_world1_v1.sh
```

Some existing gate scripts can format or clean test output. Run them only in
the assigned worktree, after checking script scope and resource ownership.
Do not infer an applicable gate from workflow name alone; inspect actual jobs
and skips. Recheck and rerun affected proof on any new HEAD; no stale PASS.
Do not synthesize a historical RED by changing baseline source or assertions.

## 3. One acceptance receipt, appended to the SAME PR

Copy below only after a real independent decision; unknown fields stay unknown:

```text
SHARKY_ACCEPTANCE_RECEIPT (non-authoritative template)
DoD_ID / source / gate:
PR / base SHA / candidate HEAD / TREE / merge commit, if any:
Writer + affirmative lease / affected files / exclusions:
Independent reviewer + actual review URL / timestamp (UTC):
Static: exact command, version, SHA, exit, raw log, timestamp:
Source: real baseline RED / candidate GREEN / missing context / exclusions:
CI: applicable workflow run URLs, source SHA, concluded PASS/FAIL/SKIP,
    pending jobs, source/merge identity:
Native: build/kernel hash, device, actual scenario, persisted receipt,
    failed attempts; or NOT_VERIFIED:
Unresolved P0/P1/P2, source unknowns and skipped gates:
Decision: actual owner/independent verdict, scope, timestamp, evidence URL:
After merge: new main SHA/TREE, push CI links and exact limitations:
Original DoD accepted? YES only with independent original-criteria proof;
    otherwise NO / NOT_VERIFIED:
SHARKY_100 credit: only authorized scorecard operator; date and receipt,
    otherwise +0 / NOT_AWARDED:
Next single action / blocker:
```

SOURCE, MACHINE_NATIVE, HUMAN, LONGITUDINAL, REAL_POKER and MARKET are
distinct evidence classes. A PASS_SCOPED source/native integration is not a
full original DoD PASS or a Human/retention/release verdict. A skipped job is
not a passing job. Preservation and full artifact hashes matter; a URL to an
expired artifact alone does not preserve the bytes.

## 4. Retrospective real candidate: completed PR #369

Historical demonstration only; it does not claim fresh native execution.
- PR: https://github.com/ClubBoss/sharky-standalone-direction/pull/369
- Issue: https://github.com/ClubBoss/sharky-standalone-direction/issues/333
- Base: fa079b6c5880814e231981a7bd5ed97df192d215
- Final HEAD: 01ec851ca8b25b0dc6c7fd7012a3ef412c627fbf
- Final TREE: 8c92952a8532b42b3e6bf83110c9f7db6ef74489
- Actual merged main: bfacae875da9d9dcbea314d1de56a4563a07fc1c
- Native record: 20 XCTest executions: 14 PASS, 6 retained FAIL;
  eight targeted acceptance executions passed, real process restart.
- Source: targeted 60 PASS, canonical Tier A 563 executions, Tier B 40.
  Catalog includes 2,668 NEEDS_SOURCE_CONTEXT and 451 explicit exceptions.
- Decision: ACCEPT_SCOPE_OF_TABLE_TRUTH_#369; merge and accepted main-push
  CI verified by existing director receipts in PR comments.
- Two P2 presentation issues survived scoped integration.
- Original SHARKY_100 full DoD credit: +0 for this scoped merge.
  P02/Human/whole release: NOT_VERIFIED.

Do not reuse these 2026-11-03 receipts for a later head or another DoD.

## 5. Evaluation and rollback

For the next few owner-selected, non-overlapping candidates, the existing
integrator may record freeze-to-independent-decision time, static failures
caught before CI, repeated CI runs, evidence omissions, and acceptance quality.
Compare with similar earlier work before claiming acceleration. Do not create
a mandatory new scorecard metric or a second tracking board.

Rollback: stop calling the optional helper and revert this doc/helper/test
files in a normal reviewed PR. No workflow, branch protection, shared
configuration, product code, schemas or automatic score handling is changed.


## 6. Single explicit custody handoff (existing PR / Issue #364)

This is a procedure, NOT a new task tracker, owner registry or automatic
transfer. Use the existing [#364 coordination decision](https://github.com/ClubBoss/sharky-standalone-direction/issues/364#issuecomment-6781439170)
and the [infra-only coordination notice](https://github.com/ClubBoss/sharky-standalone-direction/issues/364#issuecomment-6785857623).
Issue #364 remains a research issue: comments coordinate existing owners only.

For any owner-admitted handoff, record ONE compact entry in the relevant PR:
- PREDECESSOR: actual writer/task/job identity; affirmative STOP/RELEASE or
  RETAIN; exact branch, HEAD/TREE, pending dirty patch and test/native artifacts.
- SOURCE CUSTODY: exact file allowlist, exclusions and overlapping live PRs.
  Shared ClubBoss login, inactive branch, silence or disconnected bot is NOT
  a source release or actual writer identity.
- ENVIRONMENT CUSTODY: independent current owner of SDK, CI run, Mac, simulator,
  app/binary, test worktree and native evidence. Source release never frees
  runtime, and an idle runner never transfers source rights.
- SUCCESSOR: one actual acknowledged writer/task ID, new base+HEAD, allowed
  paths and next bounded step; independent reviewer and stop/acceptance criteria.
- BLOCKER: original author/job unknown or not demonstrably stopped means
  NO_TRANSFER; coordinator recovers/halts original job or obtains explicit
  separate arbitration. Never silently assume free.

#442 State, #443 Store/Settings/Preview, #444 PKR Runner/Street, and stacked
#445 retain their own ownership. None was transferred in this process wave.
Batch related owner decisions into one exact request with source refs, the
conflicting file, preserved patches, current task, proposed single recipient
and yes/no decision. A failed hypothesis triggers source-based method change;
no mechanical two-attempt stop when corrective work is demonstrably progressing.

## 7. CI comparison of existing proof, not a new CI authority

Added stdlib-only helper: tools/test_authority/compare_existing_ci_v1.py.
Its inputs are two previously captured JSON CI snapshots. It does not call
GitHub, run tests, trigger workflows, waive checks, merge or update scores.

Example command (already obtained JSON files, never an unowned live checkout):

    python3 tools/test_authority/compare_existing_ci_v1.py \
      --base path/to/base.json --candidate path/to/candidate.json \
      --out-root output/ci-comparisons

Test command:

    python3 -m unittest discover -s test/tools \
      -p test_compare_existing_ci_v1.py -v

The schema SHARKY_EXISTING_CI_SNAPSHOT_V1 contains:
- repo, source.role = pr_head | synthetic_merge | merged_main,
  source.sha (full 40-digit) and source.tree if independently known;
- gates with exact gate key, explicitly selected [run_id, run_attempt], and
  EVERY historical attempt (including RED/SKIP/cancel/rerun);
- per attempt: run URL, source SHA, actual checkout SHA+TREE from a genuine
  job/OBS04 receipt (Actions head_sha alone is NOT checkout proof), exact
  workflow Git blob SHA40, independently verified environment/SDK SHA256 and
  command/test-manifest SHA256 fingerprints, plus actual
  event/log completeness, conclusion, and optional existing Test Authority
  tier-a/tier-b machine summary from build/test_authority.
  The result list uses the original run_lane_v1.py name/cmd/status fields.

Only if source/checkout and environments, versions, command inventories,
complete logs and matched original machine results are proven does the tool
classify command-level NEW, PERSISTENT or RESOLVED non-green outcomes.
Identical command failure is not necessarily identical CAUSE.
Otherwise the case-lineage verdict is UNVERIFIED. Skipped is not success.
It never permits merge, original DoD acceptance or scorecard mutation.
Output creates a unique directory for each run, preserving attempts; command
argument vectors are hashed rather than copied to the output.

## 8. Three real read-only candidate observations

These exact HEADs and GitHub runs were read on 2026-11-11. Times measure only
the earliest observed CI trigger to latest checked workflow conclusion,
NOT code-ready/freeze to independent original DoD acceptance.

| Existing PR | Exact HEAD | Observed hosted CI window (UTC) | Proof / blocker |
| --- | --- | --- | --- |
| DAT #443 | 2e0eb78d6571f5855a3f99a69cce17cdec3de2cd | Nov 10 03:22:09-03:29:05 = 6m56s | 7 executing PR workflows GREEN, conditional L2 SKIP; P1 risk/runtime+custody unresolved |
| PKR #444 | 9a553673d6c91200f4a136ac3193b7b24c71fc11 | Nov 10 13:20:44-13:28:00 = 7m16s | Canonical, Learner Trust, Web QA RED; no proven inherited/new failure classification |
| CNT #445 | 3aa7e00a9f85de08c459c1a7c33f2871112f84c5 | Nov 11 02:51:38-03:00:58 = 9m20s | 7 PR workflows GREEN, L2 SKIP; stacked on unmerged #443 |

Original runs: [#443 canonical](https://github.com/ClubBoss/sharky-standalone-direction/actions/runs/42748977239),
[#444 canonical](https://github.com/ClubBoss/sharky-standalone-direction/actions/runs/42823669248),
[#445 canonical](https://github.com/ClubBoss/sharky-standalone-direction/actions/runs/42948855653).

Actual previously published GitHub-run metadata compared against former
main with the helper yielded UNVERIFIED at command/cause level: exact
checkout SHA/TREE, machine case inventories and SDK/version provenance were
not fully available from run-list summaries. No inherited failure was
invented. All selected L2 cases were correctly recorded SKIPPED.

IMPORTANT measurement gaps: authorized writers have NOT confirmed use of
#446 preflight on these exact HEADs; do not label it APPLIED. Candidate
freeze-to-independent-DoD elapsed, pre-CI defects prevented, repeated-run
root causes, source/environment lease wait and real throughput uplift remain
UNKNOWN. No extra CI, native, full test, SDK or author action was launched
merely to collect pilot statistics. The NEXT authorized handoff should append
freeze timestamp, preflight attempt/identity, final review timestamp and any
repeat-reason to the existing PR receipt. Evaluate a few comparable complete
candidates before claiming a gain.

## 9. Risk-based extra depth without weakening mandatory gates

HIGH: poker rules, grading/EV, source fingerprints, persistence, XP, due,
repair and stacked cross-owner PRs. Require matched source negative controls,
stable IDs, actual persisted restart/native proof when the original DoD
requires it; freeze a parent SHA before child integration.
MEDIUM: presentation within an explicitly admitted EN iPhone 14 Pro scope.
LOW: standalone docs/stdlib diagnosis with source tests and independent
review. All still require applicable existing Test Authority/CI gates.
Never allow score, Human, native, original-DoD or merge permission from green
CI alone. Risk changes ADDITIONAL evidence, not deletion of protected tests.

## 10. Deferred original improvement ideas; triggers and small pilots

All are optional hypotheses, not roadmap changes. KEEP/DO NOTHING valid.

| Deferred opportunity | Problem | Reason to wait; admission trigger | Reversible falsifier |
| --- | --- | --- | --- |
| WIP cap / integration factory | Draft queue stalls | Dot already directs critical path; avoid dual director | One bounded serialized handoff with actual wait measurement |
| Cloud macOS runner | Local Mac native shortage | $0, privacy, machine/native rights not confirmed | One admitted native 14 Pro binary parity |
| Protect main / merge queue | Unreviewed integrations | Security owner gate and repo type | Owner-reviewed settings plan with full revert |
| Golden learner journey | Fragmented end-to-end proof | Native and P02 gate HOLD | One admitted first-use to persisted recheck |
| Poker invariant guards | Wrong state/grade classes | Existing guards; no duplicate solver | One real RED/green counterexample |
| Stable native selectors | Brittle harness | No authorized new native writer | One real flaky selector before/after |
| Visual North Star | Fragmented aesthetic | S12.V owner gate pending | One accepted Home to Learn slice |
| Expert poker source oracle | Numeric-context unknowns | Source provenance missing | 5-10 true authored histories reviewed |
| PR dependency graph | Stacked-PR mistakes | Risk of stale topology | Read-only graph of 10 live PR parent edges |
| W1-W4 alpha trial | Breadth hides novice friction | Cannot replace W1-W12/Human requirements | Owner-admitted novice pilot at proper gate |
| DoD acceptance mapping | Evidence recollection | Existing receipts mostly sufficient | One real source/native/CI/reviewer mapping |
| Cost-aware model tiers | Model quota waste | AGENTS routing already exists | Bounded equal-quality cheaper-tier comparison |
| CI optimization | Duplicated expensive jobs | Existing gates protected | Read-only per accepted-DoD cost census |
| Property/metamorphic poker tests | Rule regressions | Missing real falsifier | One existing-owner legal-hand invariant |
| Human novice observation | Assumed comprehension | P02/Human not admitted | One consented first-session study |
| Monetization evidence | Premium without demand | Market gate not admitted | Bounded willingness-to-pay probe |
| Maestro | External black-box smoke | XCTest currently owner; no dependency proof | One optional smoke versus existing XCTest |
| Patrol | Native integration tests | No proven existing stack failure | One small route case and independent parity |
| Codemagic/Xcode Cloud | Fallback build capacity | Cost/credentials/provenance require owner | One zero-spend exact-build reproduction |
| Small modularization | Shared Act0 file conflicts | Refactor risk, lease conflicts | One narrow stable seam with observed benefit |

Explicit NON-OPTIMIZATIONS, not deferred backlogs: uncoordinated extra writers,
new Flutter/poker-engine rewrite, moving to an org solely for Merge Queue,
auto-merging green CI, weakening mandatory checks or bypassing security.

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

## 7. Existing CI comparison: full provenance or UNVERIFIED

The opt-in stdlib helper tools/test_authority/compare_existing_ci_v1.py
reads already captured CI metadata and Test Authority machine receipts. It
never launches tests, queries GitHub, changes gates or authorizes a merge.
Every historical run/attempt remains visible. Source pr_head, GitHub
synthetic_merge and actual merged_main are distinct. The Actions head_sha
alone is NOT evidence of actual job checkout SHA/TREE.

With only current genuine CI run-list / OBS04 evidence:

    python3 tools/test_authority/compare_existing_ci_v1.py       --base path/to/base.json --candidate path/to/candidate.json       --out-root output/ci-comparisons

This MUST report UNVERIFIED for per-command NEW/PERSISTENT/RESOLVED because
the original producer has not supplied an independently witnessed complete
effective-test inventory. Workflow PASS/FAIL/SKIPPED and previous attempts
remain visible but do not prove candidate-only defects or repairs.

### Required sources for a trustworthy command comparison

1. Exact original run ID/attempt/job, source/event SHA, actual checkout SHA
   and TREE, workflow Git blob and runner Git blob, independently checked
   against immutable job/repository evidence. GITHUB_WORKFLOW_SHA is not
   automatically the workflow-file Git blob.
2. Original run_lane_v1.py produces lane, blocking, smoke, files_attempted
   and ordered name/cmd/status results. It does NOT produce complete,
   commands_sha, test_manifest_sha, or independently certified effective
   test coverage. Never inject complete=True from files_attempted=count.
3. Independently frozen original ordered command inventory: 24 Tier-A
   outer commands are source-defined; B/C/D use manifests and may have
   overrides. Equal truncated subsets never prove the full expected set.
4. Separately verified expanded effective test/harness inventory including
   test/poker directories, fast-loop/release nested selectors, manifest
   overrides, feature flags and source blobs. OBS04 captures a smaller
   diagnostics subset and is NOT a full Test Authority witness.
5. Independent provenance of the frozen inventory (obtained outside
   untrusted run summaries), captured *before* results, an externally
   verified digest, source/runner/workflow blobs, selector inputs and
   full original selected job artifact. The offline helper checks
   consistency, NOT who originally issued the external hash.

The original producer and current CI artifacts do not establish that
independent source now. The production CLI therefore deliberately DOES NOT
accept a witness override; it always withholds per-command failure-lineage
claims (UNVERIFIED), even when a caller can fabricate matching digest strings.
A test-only synthetic witness exercises the comparison algorithm without
granting production evidence authority.

The SHARKY_FROZEN_EFFECTIVE_COMMAND_WITNESS_V1 contract carries exact
run/attempt/job, source SHA/TREE, runner/workflow Git blob references,
complete ordered name+argv, effective tests with file blob IDs, and
all selection inputs. A newly defined sorted compact JSON SHA-256 is
used for this proposed adapter; it is NOT a hash that today's lane runner
already emits. A witness built from a shortened report is invalid, even
if its digest matches itself. Reviewer must authenticate original
provenance; this standalone offline tool cannot do so.

Until an owner-admitted original producer + independent reviewer can
authenticate that entire witness, the production CLI always returns
UNVERIFIED with empty NEW/PERSISTENT/RESOLVED arrays. This is intentionally
more conservative than treating a self-signed JSON digest as proof. SKIP is
never PASS. When valid, a comparison is still command-level diagnostic:
identical non-green status does not prove identical failure cause.
No scorecard, original DoD, Human/native or merge authority is inferred.

Offline contract tests (no Flutter/native):

    python3 -m unittest discover -s test/tools       -p test_compare_existing_ci_v1.py -v

### Current producer gap / next minimal trigger

The actual canonical lane runs Tier A then Tier B under set-e, so
failure in A may prevent execution of B. Current workflow uploads OBS04,
not full certified command/nested-test lists. No shared run_lane producer,
CI workflow, gate or security setting is changed by #447. If owner
authorizes a later limited test, capture and independently verify one
full effective inventory for ONE accepted existing CI attempt, with
no new test suite or automatic acceptance action.

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

### Actual GitHub evidence falsifier: source HEAD is not checked-out merge

Read-only validation of two existing canonical Test Authority runs confirmed
the difference between the displayed PR HEAD and the actual checkout:
- Existing merged main canonical run 42916277101: source/checkout
  a883d1db8abe4de671bd315feaecebf510b262fe, TREE
  4d408770e30c4d5798ac1ca5a864b5e0560340bf,
  GitHub conclusion SUCCESS. OBS04 ZIP artifact 13809852763 SHA256
  7c18ca6667e008bae13ca2a5009f76d78e6613793d4c682b13b818a9c59e18ae.
- Existing #444 canonical run 42823669248: PR source HEAD
  9a553673d6c91200f4a136ac3193b7b24c71fc11, but the
  GitHub pull_request merge checkout/event SHA is
  8ddf3b767ef6bfc6b341fd8fbc991b9c043a88ae with TREE
  e126830c830f1292e63c35e518a6ba6cde8ed0de;
  conclusion FAILURE. OBS04 ZIP artifact 13768446393 SHA256
  706f2491dd35760a310169f8729d365495d904a861f6a9a4066e4026437eb97b.

Both ZIP hashes matched actual GitHub artifact digests; both identities
matched git commit TREE readback and original OBS04 job manifests. Those
receipts prove execution ID and two OBS04 diagnostic windows, NOT the
complete Test Authority command or nested test inventory. Comparing
these two genuine selected attempts with the updated tool returned:
UNVERIFIED / 0 NEW / 0 PERSISTENT / 0 RESOLVED. This is the correct
result; success versus failure at workflow level is observable, but
case-level attribution is unsupported. No new test run was triggered,
no inherited-failure label was issued and no score was changed.

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

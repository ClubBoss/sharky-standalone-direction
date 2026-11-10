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
wrapper. PLAN_ONLY reports missing changed Dart files without calling SDK. It runs:
1. git diff --check BASE HEAD
2. dart format --output=none --set-exit-if-changed on changed Dart paths
3. flutter analyze when changed Dart paths exist

The wrapper preserves raw/compact logs at output/context-economy with a
candidate-derived ID. An earlier local SDK version does not prove a hosted
formatter pass on another version. "No Dart changes" means SKIPPED, not PASS.
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

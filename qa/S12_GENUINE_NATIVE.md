# S12.V genuine native learning QA

Single QA writer; base product f99da096dcfda7d001c24003c052b1f3f314362a,
tree ecc202a3ebc08a14f8f4d95a984186056e44d46a. No product edits.

`qa-s12-genuine-native.yml` runs ONE fresh product build and ONE XCTest on
GitHub `macos-latest`. The first run used the registered `native-visual-delta.yml`
dispatch carrier on frozen QA commit 9f67a16f68fc94d9eba21162d30da14d11bdb689.
The final PR restores the original visual workflow unchanged and relocates the
identical E2E workflow body to its dedicated filename.
It does not repeat the accepted visual delta or its injected-state captures.
`HNP_TELEMETRY=true` enables the existing app-owned observer;
`SHARKY_VISUAL_AUDIT` remains false. No new dependency or test engine.

Reused infrastructure provenance: `qa/s11-hosted-native-20261013` at
69199e06762aa716a10c79e8a9ed91ca730938a9. The S11 marker protocol is retained
for its proven read-only screenshot/preference collector. Generated project is
an independent UI-test bundle, never a modified product application.

Route: first-use casual Placement with three real diagnostic choices → authored
recommendation → ungraded Welcome → Actions lesson → intentional Fold when no
bet is faced → negative feedback → mapped Check repair with Quick hint → Review
with debt still open → real Practice-this-spot CTA → distinct unassisted Check
attempt → actual forward destination → Summary if genuinely offered → Review,
You, Home → ordinary `XCUIApplication.terminate()/launch()` → You and Home.
The verifier requires Summary; absence is HOLD, not a passed session closure.
An immediate same-spot independent attempt is neither unseen transfer nor
retention. Placement skips never count as earned lesson completion.

Run once after source and ownership verification:

```sh
gh workflow run qa-s12-genuine-native.yml --ref qa/s12v-genuine-native-e2e-20261019
```

A newly named workflow must first be registered by GitHub on the default branch
before `gh workflow run` can dispatch it. No merge is authorized in this mission.
Before registration, reproduce the commands in the workflow on a compatible Mac,
or use the preserved original run execution. No second hosted run is launched here.

Reproduce receipt checks after downloading the run artifact to `output/s12`:

```sh
python3 tools/qa_s12_verify_evidence.py --screens output/s12/native-tests.log output/s12/checkpoints
python3 tools/qa_s12_verify_integrated.py output/s12/checkpoints repair
```

Retain Runner.zip, runner-files.sha256, kernel SHA, product/QA HEAD+TREE,
Xcode/macOS/Flutter/runtime inventories, original PNGs, timed capture receipts,
AX trees and tap log, exact preference plists, app-owned telemetry snapshots,
xcresult and evidence.sha256. To verify the full evidence manifest, extract
Runner.zip in the artifact root first (Runner.app is excluded as a duplicate).
GitHub artifact retention is 30 days, not permanent archival.

SE3 is always UNVERIFIED unless a separate genuine SE3 geometry/native receipt
exists; an available device type or nominal compact profile is insufficient.
No full S12.V, physical-table trust, Human/P02 or retention PASS is authorized.

## S12.V-09 closure continuation (2026-10-19)

The closure lane now starts on a fresh supported simulator and repeats only the
proven Placement/Welcome entry. It returns through Home → Learn, earns all six
First Table Guide tasks via authored teaching and five real graded answers, then
opens the first incomplete Actions task (Legal actions). No preferences, earned
completion, unlock, grading, clock or telemetry are injected.

Frozen source route: legal-context Fold → Try same clue → mapped Check without
new help → **Check original read** → original legal-context Check → Continue →
remaining Check/Fold/Call/Raise/recap tasks → source-owned wrap-up Check → Actions
Session Summary → Home → ordinary terminate/relaunch. Targeted repair guidance is
not claimed as a new quickHint-assisted attempt. The previously accepted assisted
repair evidence remains attached to run 39182086567.

`qa_s12_verify_integrated.py CHECKPOINTS closure` requires exact original-source
run/review/start provenance, per-record event cardinality, single linked original
recheck start/result, real prerequisites, Actions task completion, truthful skipped
Actions theory (not an earned lesson), source-owned session completion, authored
XP and unchanged saved state across restart. Native Summary metrics still require
inspection against saved history and the source-owned lesson evidence boundary.
One new hosted dispatch only; fail/partial evidence must be preserved, not retried
without a proven cause and new authorization. Product remains pinned to f99da096;
SE3_UNVERIFIED, Human/retention/transfer unproven, S12.V HOLD_VISUAL_TRUST.

Dispatch note: GitHub returns 404 for the dedicated workflow because its path is
not on the default branch. On this QA branch only, the existing registered
`native-visual-delta.yml` path carries the exact closure lane for the single
workflow_dispatch. This changes no main workflow and repeats no visual audit.
The rejected dedicated-path dispatch created no hosted run.

## Closure attempt disposition — STOP, no second run

**S12V_09_PARTIAL_SOURCE_OR_ROUTE_BLOCKER.** Sole new run
[39212792510](https://github.com/ClubBoss/sharky-standalone-direction/actions/runs/39212792510)
failed XCTest `NO_UNIQUE_NATIVE_TAB_Home` at executed Swift line 71, before
`C9_before_prerequisites`. The actual test executed once and failed in 191.261 s.
Three original native PNGs passed; no timed persisted learner/telemetry snapshots
were reached, so this attempt adds no original-source recheck or Actions Summary
proof. Prior accepted V08/V10 scoped PASS and V09 PARTIAL remain unchanged.

Cause: the fresh Placement handoff was still inside the active runner, not the
previous run's saved Review/Home surface. The product intentionally hides bottom
navigation there (`act0_shell_preview_screen_v1.dart:6719`). The screenshot/AX tree
`missing_tab_Home` shows a unique upper-left Back button and no Home tab. Its
source-owned callback (`:6072`, normal branch `:6103`) returns to Learn; Placement
sets `returnToPlayHubOnBack=false` (`:9809`). This is a QA navigation omission,
not an established product routing defect. The unexecuted candidate now taps that
real, unique AX Back button before Home → Learn; it also preserves timed state if
a future tab lookup fails. No production accessibility or routing code changes.

The executed instrumentation also had a separate budget defect: reaching Summary
required 21 × 90-second checkpoint holds plus two 45-second screenshots = **33
minutes minimum**, before UI actions or XCTest startup. Native step started at
07:34:33 after build/Simulator setup, leaving under 32 minutes of the 70-minute
job. This was a QA preflight omission, not the cause of this early failure. The
candidate batches prerequisite/tail receipts at their real Summary checkpoints,
keeps per-record event cardinality, captures question frames without redundant
pre-answer state copies, and ends at Actions Summary rather than repeating V10.
Its seven persisted plus six screen-only checkpoints hold **15 minutes** in total.

**Candidate validation:** Python syntax and `git diff --check` only; the new Back
selection and shorter sequence have NOT been compiled/executed natively. One run
limit is consumed; no retry, production patch, merge, Human/retention/transfer or
S12.V PASS is authorized by this result. Next step is a separately authorized
native execution of this prepared QA-only candidate, including visual Summary
metrics versus saved history. SE3_UNVERIFIED; S12.V HOLD_VISUAL_TRUST.

Frozen attempted product: `f99da096dcfda7d001c24003c052b1f3f314362a`, tree
`ecc202a3ebc08a14f8f4d95a984186056e44d46a`. Executed QA:
`b9e60387fd8cb005d3af30584a51a6d9e2801e40`, tree
`5ef51505439995a487a492d8543d10239fc1fae1`.
Runner.zip SHA-256 `aad05c2aec6bf47c0d3021a7993a4c6002ce06a504e986c8699d1958b9c09005`;
kernel SHA-256 `f8802326078e2eb5f31e52a1e1aa6c56c5429c4cf95323a8116b38ac79f4b104`.
iPhone 17 Pro Simulator, iOS 26.4, PNG **1206×2622**, AX **402×874**;
macOS 26.6.2 / Xcode 26.6 / Flutter 3.35.0. SE3 was not booted or tested.

[Original artifact 12170610854](https://github.com/ClubBoss/sharky-standalone-direction/actions/runs/39212792510/artifacts/12170610854),
234030797 bytes; original ZIP SHA-256
`d35d3379dea590dd20d97a9b818adae52db7e6c73ed5b7bd9becd5fb8837934e`.
Downloaded bytes match GitHub digest. All 1982 Runner-file and 3373 evidence-file
hashes match after extracting Runner.zip; all three native screenshot receipts
reproduce PASS. On a copy of the original artifact, the executed verifier
`git show b9e60387:tools/qa_s12_verify_integrated.py` still yields
`FAIL_CLOSURE FileNotFoundError` for the unreached required checkpoint. Do not
reinterpret absent saved receipts as zero XP/debt/events or completion proof.

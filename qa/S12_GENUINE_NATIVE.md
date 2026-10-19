# S12.V genuine native learning QA

Single QA writer; base product f99da096dcfda7d001c24003c052b1f3f314362a,
tree ecc202a3ebc08a14f8f4d95a984186056e44d46a. No product edits.

The branch version of the existing `native-visual-delta.yml` dispatch carrier
runs ONE fresh product build and ONE XCTest on GitHub `macos-latest`.
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
gh workflow run native-visual-delta.yml --ref qa/s12v-genuine-native-e2e-20261019
```

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

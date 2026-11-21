# EN V1 — Native Remediation Recheck, exact Draft #326

**2026-10-29. Scoped native status: \`F1_F2_F3 = PASS_SCOPED_NATIVE\`.** This is **not** entire candidate, S12.V, P02/Human or release acceptance.

- **Original source:** Draft [PR #326](https://github.com/ClubBoss/sharky-standalone-direction/pull/326), exact \`68562ad6aab05dec80eed12e173fdc91220e1e29\`, tree \`27b51d6077b8ce2f66414d245cbfae49b1df627a\`. Stacked on #321.
- **Device:** reference English iPhone 14 Pro (393x852 pt, iOS 26.2); 10 SHARKY preview flags and HNP_TELEMETRY ON. Same source/flags across screenshots.
- **Independent build:** completed from QA-only isolated worktree. First build failed **only** because sparse checkout omitted required \`content/\` assets (not a Flutter source failure); adding the source-owned directory allowed an incremental successful build with no code change. New binary hashes in [MANIFEST.json](MANIFEST.json).
- **Execution:** 1 actual native XCTest scenario **PASS, 0 failures** in 53 seconds. One earlier *QA harness* attempt failed due a substring navigation selector for the You tab; corrected to exact \`You\` and fully reran to PASS. Both raw Xcode logs and \`.xcresult\` evidence remain in Mac QA output.

## Findings

| Finding | Native observed | Original proof |
|---|---|---|
| F1 earned-truth | Wrong + unsure + one independent correct diagnostic results in **1 earned: First correct read**, separately **1 spot to repair**, **0 XP**, **0 tasks completed**. No unearned \`Back to the spot\` or \`One miss to fix\`. | [You](F1_You_1earned_1repair.png) |
| F2 seat focus | All three diagnostic feedback phases lacked leaked opponent \`To act\` in accessibility tree; after correct Check the source-owned board-card clue remained visually highlighted. | [Diagnostic feedback](F2_Diagnostic_correct_board_clue.png) |
| F3 causal Welcome | Wrong Call selection explains that Call matches an existing bet, but no bet faces Hero; Check keeps the hand moving. Explicit **ungraded** disclosure, unchanged CTA. | [Welcome](F3_Welcome_wrong_call_causal_explanation.png) |
| Placement grading | Source outcome remains **1 of 3 correct**, no fake score. | [Placement result](Placement_1of3_source_count.png) |

## Limitations and STOP boundaries

- The **Runner still has major inherited visual art / overlay defects (F7)**; this wave did not change those assets, camera, seating, cards or Hero.
- **F4** legacy light-sheet restyle and **F5** practice repair Back-routing remain deferred/owner-gated. This native test does not independently qualify those surfaces.
- **F9** persistence of an open Placement diagnostic repair across a real cold restart **is not proved by this test**, since the restart capture did not navigate to Review/You. Requires a separate bounded owner-gated investigation of persisted source data.
- All-other flows, due/retention/Human efficacy, other devices and RU remain **unverified**.
- The original installed app bundle was backed up before QA. After test, original \`Runner\`/\`Runner.debug.dylib\` hashes and the original saved preference plist SHA256 were restored byte-identically; simulator returned to its prior app state. No writer or source PR modified.

All four committed PNGs are original unresized XCTest exports copied byte-identically from the retained local \`.xcresult\`. See manifest for SHA256, original export names and exact source binding.

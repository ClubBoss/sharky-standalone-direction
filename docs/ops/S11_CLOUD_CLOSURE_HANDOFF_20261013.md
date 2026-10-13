# S11 cloud closure wave — evidence reconciliation and morning Mac handoff (2026-10-13)

Status: `S11_CLOUD_RESULT = HOLD_MATERIAL` (one new native-confirmed defect of the same class as S11's third P1,
by the S11 severity precedent; see §4 F-C1 and §6 — the owner can downgrade it to P2 and return to the pending-native path).
Scope: issue #281 / Draft PR #282. No production change, no new PR, no merge. This file is an
operational handoff, not authority; the Master Plan §10A and the live issue ledger control.

## 1. Identities (verified live at wave end)

| Item | Value |
| --- | --- |
| Production `main` | `6610103fcd3007ab014dba988d6b206209c22c6a` (docs-only advance past `bfc6cbc4` via #283) |
| S11 candidate = PR #282 head | `f4a8a5110dc2b62220447e14df3bc392517bf8e1` (unchanged) |
| Candidate tree | `0b4b037afe2f9d951c31d2e07984bcbd10f0057a` (re-verified from the checked-out commit) |
| Diff vs `bfc6cbc4` | 7 files: 3 `lib/ui_v2/act0_shell/*` + 4 tests; no Modern Table renderer/geometry/asset file |
| **Frozen Mac-built app** (acceptance target) | manifest SHA256 `7d16dea625da15747381f216f258a8616aea49b3eb3ddee572228fb08a8d59a1`, kernel `1b136464dcf8b96360cad2ec589d6e00fe774364b1055d8957b894c90235c999`, local to owner Mac `/private/tmp/sharky_s11_frozen_20261013/output/s11-v2/frozen/Runner.app` |
| **Cloud-rebuilt audit app** (different binary, NOT the frozen app) | same source SHA; manifest SHA256 (same convention, 1,980 files incl. build log) `7033cb9ea7d23f630f31e352922fad6083c2a16e74bb1c75de9c6528783d6e2a`; kernel `8f38f8606cea06b402384938cbc8646bba22a8c578e379c92676e7ee1b3d7a68`; audit-enabled build on GitHub macOS runner |

The cloud app has a different identity from the frozen app. Nothing below is transferred to the frozen
binary; source-commit equality is not binary parity.

## 2. S11 DoD matrix

Legend: PASS = demonstrated at the stated SHA/binary; NOT_VERIFIED = not demonstrated; FAIL = defect shown.

| # | Requirement | Existing / new evidence | SHA / binary | Status | Remaining falsifier |
| --- | --- | --- | --- | --- | --- |
| 1 | Exact identity, scope, no Modern Table change | `git diff --name-only` 7 files; no table renderer/asset; tree hash re-derived | f4a8a51 | PASS | none |
| 2 | Source gate / lint | r5-release-gate 113 PASS (Codex, ledger) | f4a8a51 | PASS (not rerun) | none |
| 3 | Applicable GitHub CI | r5-release-gate, verify, health, Canonical authority, deploy SUCCESS; L2/Tier B/C/D skipped (checked live: runs 38310312527, 38310312497, 38310312518, 38310312566, 38310312572) | f4a8a51 | PASS | recheck before merge |
| 4 | Independent source reproduction | **new:** 16 tests (3 new S11 + 2 modified files) PASS on a Linux machine from a clean checkout | f4a8a51 | PASS | none |
| 5 | Independent source review | Codex + Claude `PASS_SOURCE_SCOPED` (ledger) | f4a8a51 | PASS (source only) | none |
| 6 | First use: onboarding → Home "Start first hand" → taught Step 1/6 | compact natural PASS; standard/large not rerun on final | frozen | PASS compact / NOT_VERIFIED standard,large | fresh install standard or large (optional per manager) |
| 7 | Mapped Cutoff repair, assisted → independent | standard + compact PASS (continuation owner); large independent reviewer ran the BTN repair only | frozen | PASS by non-independent executor; **independent CO NOT_VERIFIED** | independent CO repair on large (M1) |
| 8 | Summary honesty, XP, queue, IDs across real restart | large ×2 + standard + compact PASS; 8 attempt ids each exactly one `user_choice/decision_made/task_result` | frozen | PASS | none |
| 9 | Five tabs, Back, due vs not-due | PASS tabs/Back; copy inconsistencies are P2 (§4) | frozen | PASS | none |
| 10 | Retake both endings, earned work kept | compact zero PASS; standard "recommended PASS" is not a recorded proof | frozen | PARTIAL | one retake-ending pass if cheap (M3) |
| 11 | Viewports standard / compact / large | standard + compact + independent large natural; **new:** 54-row cloud capture on iPhone 17 Pro / 16e / 17 Pro Max | frozen + cloud app | PASS (natural) ; cloud rows are injected-state | none |
| 12 | Modern Table regression | source boundary PASS; **new:** candidate vs `main` production renderer, 52 of 54 cloud rows pixel-identical (§3) | cloud app (both) | PASS as differential vs `main`; **not** vs owner-accepted references | native view of frozen binary on one table route (M2) |
| 13 | Reduced motion | **new:** 6 reduced-motion rows identical to `main` (no regression); source: 6 of 9 motion test files fully green; 3 files hold RED tests that fail identically on `main` (incl. `Street Replay reduced motion is immediately complete`) | cloud app | NOT_VERIFIED as behavior; no-regression shown | one natural reduced-motion pass (M3) |
| 14 | Degraded / empty / bootstrap | source: bootstrap/launch-policy/empty tests green at exact head (§3); no natural native run | f4a8a51 source | NOT_VERIFIED natively | fresh-install empty tabs (M3); anything unreachable is recorded NOT_VERIFIED, not seeded |
| 15 | Inherited debts stay RED | TestSprite `No tests detected` FAIL (commit status, live); 9 legacy tests RED, **identical set on `main`** | f4a8a51 / main | RED, explicit | owner acceptance or fix |

## 3. What was executed in the cloud (new evidence)

1. Live reconciliation of issue #281 (5 comments), PR #282 (Draft, head/base verified), `main`, check runs, commit status.
2. Linux source reproduction at the exact tree (Flutter 3.35.0, matches CI pin):
   - 16 tests PASS: `act0_s11_graded_choice_trace_v1`, `act0_s11_mapped_repair_seat_truth_v1`, `act0_s10_fresh_and_return_truth_v1`, `alpha_journey_progression_truth_v1`.
   - 16 files covering reduced-motion, bootstrap/launch policy and empty states: 155 PASS, 9 FAIL; the same 9 fail on `main` `6610103` (`act0_controlled_runtime_entry_v1` ×5, `act0_session_summary_earned_moment_v1` ×1, `wave4_5_motion_evidence_repair_feel_v1` ×3). Candidate adds no failures there.
3. macOS runner capability confirmed: existing `native-visual-audit.yml` dispatched on candidate (run `38332094287`) and baseline `main` (run `38332096846`). Both succeeded, 54 rows each, canonical + compact + large + text-scale + reduced-motion, ~146 macOS runner minutes in total. Artifacts: final bundles `sharky-native-visual-audit-<sha>` expire 2026-10-27; the `native-audit-runner-<sha>` apps expire 2026-10-14 (download now if wanted).
4. Differential comparison (status-bar band masked, per-pixel threshold 24/255): 52 of 54 rows identical; the 2 others are capture noise, not product:
   - `theory.canonical.normal`: the candidate capture is a blank dark frame (readiness raced); the baseline frame is fine. **Candidate theory row NOT_VERIFIED.**
   - `vrt02.compact.normal`: the baseline frame has an iOS "Ready for Apple Intelligence" notification banner over the header; the candidate frame is clean.
5. Audit-harness truth finding: the manifest row `world3.canonical.normal` selector (`world_3/early_vs_late/early_pressure_choice`) does not resolve (real task id is `early_vs_late_early_pressure_choice`), so the app falls back to Home and the "world3" screenshot is the Home screen in both runs. World 3 scenes are not covered by the 54-row audit at all.
6. Delta captures of authored World 3 scenes — see §4 F-C1.

Not attempted, with reason: a natural-journey XCTest on a hosted runner. The repo has no UI-test target and no
`integration_test`; the S11 harness exists only on the owner Mac, so rebuilding it would be a new CI system.

## 4. Product-truth findings

### Material (P0/P1): one — F-C1 (severity by S11 precedent; owner may downgrade)

### F-C1 — sibling authored scenes still carry the inherited-seat defect class (P1 by precedent; native-confirmed)

S11 corrected only `w3_table_position_notice`. A deterministic probe over all 291 actionable authored runners at the
exact tree (source below) shows the same inheritance (BTN-scenario seat flags reused after hero reassignment) in:

| Task (world/lesson/task) | Hero | State shown |
| --- | --- | --- |
| `world_3/same_hand_different_seat/same_hand_different_seat_w3_same_hand_open` ("Folded to CO with AJo") and its position repair | CO | Hero `isFolded=true, isInHand=false, hasActed=true` → Hero seat rendered at 0.58 opacity; trail says "UTG folds > HJ folds > CO acts" but HJ renders live (1.0) |
| `same_hand_different_seat_same_hand_early_fold`, `position_checkpoint_position_checkpoint_early_fold` (seat flags dumped and rendered); probe also flags `position_apply_early_fold`, `hand_discipline_buckets_trash`, `fold_discipline_early_fold`, `apply_utg_fold` (Hero not in hand; occupancy not individually dumped) | UTG | Hero seat `isOccupied=false` → Hero rendered at 0.42 opacity (empty-seat dimming); CO shown folded although it has not acted |

Verified by widget render: seat `Opacity` in `act0_shell_seat_node_*` reads 0.58 / 0.42 for these scenes, and 1.0 for the corrected scene.
Grading, XP and evidence ids are not affected and the Hero label sits on the right seat, so this is not a false earned-progress
or assessment claim. It is a poker-truth contradiction on the scene a graded decision is asked about, which is the class
S11 itself ruled P1 (third defect), and it sits in the ordinary World 3 curriculum, not a rare route. Native pixel evidence
(§4a): in `w3_same_hand_open` the Hero "You / CO" seat is labelled **"Folded"** with greyed cards while the question asks
"What is the cleaner first-in action from CO?"; in the UTG early-fold scene the CO seat is labelled "Folded" before UTG has acted
and the Hero seat is dimmed. The corrected control scene renders Hero CO live with UTG/HJ "Folded".

Minimal cause: `_act0ReassignHeroSeatV1` moves the Hero identity/cards but copies the previous scene's `isFolded/isInHand/hasActed/isOccupied`
flags; only `_w3TablePositionNoticeRunner` was patched by S11. Bounded correction proposal (NOT applied; the frozen candidate is untouched,
and a prototype edit in a scratch tree was blocked by the environment's permission policy): in `_act0ReassignHeroSeatV1`, when the
Hero seat changes and the authored `actionTrail` names folds ("X folds"), set liveness from the trail (named seats folded/out/acted,
Hero and every other seat live/not-acted) and mark the Hero seat occupied; alternatively patch the CO/UTG runners individually with the
`_act0CopySeatStateV1(..., isInHand/isFolded/hasActed)` pattern S11 already used. Either needs a new candidate, a source test
per scene (extend the S11 seat-truth test with the probe in §5), the 291-runner probe clean for CO/UTG heroes, and exact-binary native
reproof of M1/M2 (this finding invalidates reuse of the current frozen binary for acceptance only if the owner requires the fix).

### F-C2 — Summary progress pill is unconditional (P2, wording; owner decision)

`_BlockXpProgressCardV1` (`act0_lesson_runner_shell_v1.dart` ~10663-10740) hard-codes the pill text `One clean read` and
`Local read saved` for every block summary; only the bar fill depends on `xpEarned`. A 4/5-with-1-error or 0-XP summary
therefore carries "One clean read" above the honest accuracy line (this is the recorded native "ambiguous Summary"
P2). Existing tests assert it only for the clean case (`wave4_2_premium_identity_claim_cleanup_v1_test`). The XP value
itself is not claimed and counts come from first-scored evidence, so progress/XP/queue claims stay truthful; the pill is
a hard-coded celebratory label. `4/5 correct · 1 with help` counts an assisted-correct task in both numbers, which is
the second half of the same ambiguity. Treat as P2 unless the owner wants it gated on `errorCount == 0 && assistedCount == 0`.

### Remaining recorded P2 (unchanged, not re-proven)

Home "Review now" vs Review "nothing due" after a fix (both derive from the same `reviewState`; native cause not isolated), You "One miss to fix" chip,
Practice "Practice repair" card, truncated feedback, `Replay for perfect` clipping, raw lesson id on Review, `Step n/7`
edge touch at 440 width, Home "Continue" needing a second tap, retake copy vs `what_poker_is` fallback.
`_world3CutoffOpenRunner` suspicion from the source review is **confirmed by F-C1** (it is the `w3_same_hand_open` runner).

### Audit-harness note (not product)

Row `world3.canonical.normal` is mislabeled (Home fallback) in the canonical manifest — fix before S12.V relies on that audit.

## 4a. Native pixels for F-C1 (cloud-built app, candidate SHA, injected-state captures)

Hosted macOS capture with the existing `native-visual-delta.yml`, candidate `f4a8a511`, cloud-built app, canonical iPhone 17 Pro, production
renderer on the real authored task (injected-state class, not a natural journey). Run `38340783583` (artifact `sharky-native-visual-delta-f4a8a5110dc2…`, expires 2026-10-27;
the runner app expires 2026-10-14). The three red `capture (compact/large/text-scale)` jobs in that run are unused matrix legs with no rows, not capture failures.

| Row | Result |
| --- | --- |
| `s11c1b.cutoff_open_ajo` | Hero "You CO" with a "Folded" label and greyed AJo cards; UTG empty ring; question asks the first-in action from CO — **defect visible** |
| `s11c1b.utg_early_fold_ato` | Hero "You UTG" dimmed; "Folded" label on CO although UTG has not acted — **defect visible** |
| `s11c1b.cutoff_notice_control` | Hero CO bright, UTG/HJ "Folded", BTN/SB/BB waiting — fixed S11 scene is correct |
| `s11c1b.world3_early_pressure` | blank dark frame (readiness race, same signature as the candidate `theory` row) — NOT_VERIFIED |

An earlier attempt (run `38337251146`) used short task ids that do not resolve; the app fell back to Home, so it is **invalid** and is not evidence.
Evidence class: cloud-built app, not the frozen binary; the scenes are source-owned authored data identical in the frozen build, but binary parity is not claimed.

## 5. Probe source (scratch, not committed as a test)

```dart
// Run from a candidate checkout: flutter test <this file>
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('probe: hero seat live in every authored actionable runner', () {
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          if (task.runner.options.length < 2) continue;
          final hero = task.runner.table.heroSeat;
          if (hero.isFolded || !hero.isInHand || hero.hasActed) {
            // ignore: avoid_print
            print('${world.worldId}/${lesson.lessonId}/${task.taskId} '
                'hero=${hero.seatId} folded=${hero.isFolded} '
                'inHand=${hero.isInHand} acted=${hero.hasActed} '
                'occupied=${hero.isOccupied}');
          }
        }
      }
    }
  });
}
```

(The full run also flagged "active seat != hero" on seat-identification tasks; those are by design and omitted above.)

## 6. Result and why

`HOLD_MATERIAL`. F-C1 is a native-visible poker-truth contradiction in graded World 3 scenes, the same class S11 treated as P1,
and it is not covered by the three S11 fixes. It is not a false earned-progress/assessment claim, so the owner may reasonably
classify it P2 and defer it to S12.V; if so the state reverts to `CLOUD_COMPLETE_NATIVE_PENDING` with M1–M3 below still required.
No cloud evidence is transferable to the frozen binary, and DoD rows 7 (independent CO), 13, 14 and parts of 6/10 still need
native execution. F-C2 stays P2. Not `PASS_VERIFIED`: the frozen binary has not been independently accepted.

## 7. Morning Mac session (one short session, no rebuild)

**Decision first (no Mac time needed): F-C1.** (a) Accept as P2 → run M1–M3 on the frozen binary as below. (b) Require the fix → a new
candidate is built from #282's branch (single writer, existing PR), M1–M3 are run on that new binary instead; running them on the
current frozen app would be wasted work.

Preconditions (stop on any failure): `git ls-remote origin refs/pull/282/head` = `f4a8a511…`; the frozen app manifest
recomputes to `7d16dea6…59a1` (convention: SHA256 of sorted `<sha256>␣␣<bundle-relative path>\n` lines) and kernel
`1b136464…c999`; `df -h` shows ≥ 8 GiB free (last recorded 5.6 GiB — do not delete `output/s10-*`, `s11-v1`, `s11-v2`
or any simulator; if short, stop and report); protected simulator `30593357-…` and dirty `~/Sharky_1.0` untouched.
Use the existing tester `output/s11-v1/harness/S08NativeUITests/S08FirstValueUITests.swift` and the invocation recorded in
`output/s11-v2/native/` xcresult logs (the exact `xcodebuild` lines are not reproducible from the cloud; do not invent new ones).

- **M1 (required, independent reviewer, large sim `8B7E4996-90F5-47A9-9FE6-16271402780B`, natural state kept):**
  reach an open mapped CO repair (`test04MappedAssistAndTabs` / `enterRepair`). Expect: scene Hero CO QJs, UTG/HJ folded,
  BTN/SB/BB waiting; assisted answer → "Correct with help", repair stays open, no XP; independent recheck → "Correct read",
  repair `fixed`, queue empty, no duplicate earned XP, `assistance_kind=none`; screenshot + copied
  `act0_hnp_trace_v1.jsonl`/preferences **before and after** relaunch. Artifacts: xcresult, two screenshots, state captures.
- **M2 (required, ~10 min):** on the frozen app capture the same view of one Modern Table route (W1 `positions_early_late`
  seat-selection) and compare with the cloud `vrt02.*` frame from the candidate audit bundle (§3) — same table composition expected.
- **M3 (optional, only if time):** fresh install on standard: five tabs empty states, one Reduce Motion pass
  (Settings → Accessibility → Motion → Reduce Motion) through one decision + Summary, one retake ending. Mark every state not
  naturally reachable `NOT_VERIFIED`; do not seed.
- **Stop immediately (`HOLD_MATERIAL`)** if an assisted answer earns XP or marks a repair fixed, XP is duplicated, a repair
  claims completion it did not earn, or the app hash does not match.

## 8. Merge conditions (unchanged DoD, restated)

Merge #282 only when: M1 passes with an independent non-implementing reviewer on the frozen binary; M2 recorded; rows 13–14
are either demonstrated or explicitly recorded NOT_VERIFIED with owner acceptance; F-C1/F-C2 receive an explicit owner
disposition (F-C1: accept as P2 for S12.V, or fix in a new candidate with reproof; until then #282 is on HOLD_MATERIAL); CI is rechecked at the exact head with
TestSprite and the legacy suite named RED; `main` ancestry verified (docs-only advance); PR marked ready by the delegated
authority; resulting `main` verified. No merge on source review or on any cloud-app evidence alone.

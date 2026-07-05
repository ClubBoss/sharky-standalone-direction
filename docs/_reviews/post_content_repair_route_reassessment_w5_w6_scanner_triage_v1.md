# Post-Content-Repair Route Reassessment + W5/W6 Scanner Debt Triage v1

## 1. Verdict

`mixed_w5_w6_reconciliation_required`

The 53 scanner lines are baseline debt, but they are not harmless historical
noise. They combine stale broad-validator expectations, incomplete source and
metadata migration, and real failures in the secondary session-drill runtime.
They do not prove a defect in the canonical Act0 W5/W6 lesson owners, and they
do not justify reopening the accepted W4-W7 ownership decomposition.

## 2. Canonical state

- Canonical base: `main` at
  `b6f7674789b2f57ffcfe4de17a507a44b1a88fee`.
- `origin/main` matched that commit with ahead/behind `0 0` and a clean
  worktree before the audit branch was created.
- Audit branch:
  `codex/post-content-route-reassessment-w5-w6-triage-v1`.
- Canonical curriculum jobs remain W5 Board Awareness and W6 Range Thinking.
- Canonical Act0 owners remain `_boardDrawsLessons` for W5 and
  `_rangeThinkingFoundationLessons` for W6.

## 3. Recently closed waves

1. Act0 W4-W7 owner-contract decomposition aligned W5 to board/draw lessons
   and W6 to range-thinking foundations without changing learner-facing card
   copy.
2. W11/W12 metadata-only source-proof bridging added metadata without changing
   runtime or W5/W6 content.

Neither closed wave created this scanner debt. The accepted integration proof
recorded 53 W5/W6 lines both before and after the W11/W12 bridge, with
byte-identical output.

## 4. Scanner reproduction

Command:

```text
dart run tools/validate_world_content_v1.dart
```

Current-main result: exit code `1`, with exactly `53` W5/W6 error lines:

- W5: 22 lines.
- W6: 31 lines.
- Missing content: 0.
- Stale title/world-ID errors: 0.
- Unreachable-reference errors: 0.
- Duplicate-ID errors: 0.
- Legacy/dormant-path errors: 0.

The 53 symptoms reduce to five root-cause classes. Repeated per-file messages
are not counted as separate causes.

## 5. Error-class matrix

| Error class | Count | Affected paths/IDs | Active runtime? | Current SSOT aligned? | Learner impact | Required action |
| --- | ---: | --- | --- | --- | --- | --- |
| W5 `why_v1` exceeds the shared 140-character contract | 11 | `content/worlds/world5/v1/sessions/w5.s01`, `s03`, `s04`, `s05`, and `s10`; 11 `board_texture_classifier_v1` drills | Secondary session-drill runtime loads the files but silently drops these explanations; canonical Act0 W5 does not use them | Concept family is W5-aligned; field length is not contract-aligned | A learner entering the secondary drill path can lose the explanatory why | Preserve the poker meaning while reconciling source copy with the existing shared length contract; do not relax the limit without cross-runtime evidence |
| W5 `s11` session admission/format is incomplete | 5 | `w5.s11/session.md`: four missing required headings; `w5.s11`: outside scanner's `s01..s10` role assumption | Active authored source, but absent from canonical truth-map/session manifests; not canonical Act0 | Basic outs is an accepted W5 prerequisite family, but route/admission proof is incomplete | No proven canonical-route impact; direct/manual session launch truth is ambiguous | Decide and prove whether `w5.s11` is runtime-admitted or source-only, then align headings and bounded session-role policy accordingly |
| W5 `s11` classifier metadata/runtime contract is incomplete | 6 | Three `outs_count_classifier_v1` drills: three missing `intent_v1`, three `expected must be an object` | Direct adapter loading fails earlier because required `error_class` is absent; the kind is also unsupported | Family is accepted; source/runtime/validator schema is not aligned | No canonical Act0 defect; a direct secondary launch cannot parse these drills | Reconcile source schema, intent vocabulary, runtime admission, and scanner behavior as one decision; do not invent new outs strategy |
| W6 normalized classifier migration stopped before downstream contracts | 30 | Six `w6.s01` `range_bucket_board_fit_classifier_v1` drills and six `w6.s02` `range_width_classifier_v1` drills: 12 filename/internal-ID mismatches, 12 expected-object errors, 6 disallowed `position_and_range_width` intents | Yes in the secondary session-drill path: both sessions are in canonical truth/manifests, but `DrillSpecV1` rejects both new kinds; identity mismatch would also break ID-equality-dependent repair proof | The new W6 families and semantic IDs match accepted Range Thinking fixtures; runtime, manifest/index, intent, scanner, and stale focused tests do not | W6 session-drill launch fails when it reaches either normalized kind; canonical Act0 W6 remains unaffected | Preserve accepted semantic IDs/families, choose explicit runtime-admitted versus source-only status, and align all downstream contracts without reverting to action-named legacy semantics |
| W6 `s01` pacing threshold is stale or unproven | 1 | `w6.s01`: 14 drills versus broad scanner maximum 12 | Runtime can enumerate 14; failure is policy-only | Accepted source intentionally contains six range-bucket additions, but no updated broad pacing rule is recorded | No direct learner correctness failure proven | Establish a source-backed session-density rule; do not delete accepted reps merely to satisfy the old numeric ceiling |

Total: `11 + 5 + 6 + 30 + 1 = 53`.

## 6. Active ownership classification

`content/worlds/world*/v1/` is active authored content under
`ACTIVE_CONTENT_SSOT_INDEX_v1.md`; none of the 53 lines belongs to a legacy or
dormant content shelf. Filename age is not ownership proof.

There are two distinct learner paths:

- Canonical Act0 W5/W6 is inline Dart-owned. The affected JSON and Markdown do
  not own the Act0 world cards or their lesson lists.
- The secondary session-drill stack reads `content/worlds/.../drills` through
  `DrillRuntimeAdapterV1`. W6 `s01`/`s02` are registered in truth/manifests;
  W5 `s11` is active authored and indexed locally but is not registered in the
  canonical truth-map/session manifests.

The W4-W7 decomposition changed Act0 lesson-owner binding. It did not authorize
the incompatible schema changes identified here and must not be reversed as a
scanner fix.

## 7. Runtime impact assessment

Canonical Act0 impact is `0` proven errors. The accepted W5 and W6 inline
lesson owners remain intact.

Secondary runtime impact is concrete:

- 11 W5 board-texture files parse with `why_v1 == null` because their
  explanations exceed the shared 140-character runtime limit.
- Three W5 `s11` files cannot parse on direct adapter load because required
  runtime fields are absent and the new kind is unsupported, although `s11` is
  not registered in the canonical truth map.
- Twelve W6 normalized classifier files cannot parse because their two new
  kinds are absent from `DrillKindV1` and `_parseDrillKindV1`.
- The 12 W6 filename/internal-ID mismatches conflict with manifest/index
  identity and with repair-receipt code that requires `drillId == spec.id`.

Thus 38 scanner lines across 26 active-authored drill files have direct
runtime-contract significance: 11 invalid explanations, 3 W5 schema failures,
12 W6 unsupported-schema failures, and 12 W6 identity mismatches. This count
does not imply 38 independent defects. The remaining 15 lines are
format/pacing/intent-policy evidence within the same mixed migration problem.

A focused current-main test confirms the W6 failure:
`test/tools/same_signal_drill_expansion_v1_test.dart` exits nonzero, still
expects the superseded `range_bucket_classifier_v1` kind, and then receives
`Unknown drill kind: range_bucket_board_fit_classifier_v1` from the live
adapter.

## 8. Validator currency assessment

The broad scanner is partly stale, not safely ignorable:

- It knows only the older classifier exceptions and therefore reports
  `expected must be an object` instead of naming unsupported normalized kinds.
- Its W6 intent allowlist lacks the accepted range-width family vocabulary.
- Its fixed session-role and 12-drill ceiling predate W5 `s11` and the W6
  normalized additions.
- It correctly identifies explanations that the runtime will drop and ID
  mismatches that undermine manifest/repair identity.

Blindly weakening the scanner would hide real runtime disagreement. Blindly
rewriting source back to legacy kinds/IDs would undo accepted W6 semantic
normalization. Validator work is safe only after runtime-admission and stable-ID
decisions are explicit.

## 9. W5 normalized-contract assessment

W5 remains Board Awareness, and `_boardDrawsLessons` remains its canonical
Act0 owner. The 11 board-texture explanations are W5-aligned but violate the
existing shared runtime length contract. Their action framing also retains the
known correctness sensitivity that board texture alone must not become an
automatic action rule; any shortening must preserve the stated assumptions and
anti-automatic-rule guard.

`w5.s11` Basic Outs Awareness is an accepted prerequisite family, but its
source addition did not complete session-manifest, runtime-schema, intent,
error-class, or broad-validator admission. This is incomplete migration proof,
not evidence that W5 should own another world's job.

## 10. W6 normalized-contract assessment

W6 remains Range Thinking, and `_rangeThinkingFoundationLessons` remains its
canonical Act0 owner. The accepted source fixtures explicitly use
`range_bucket_board_fit_classifier_v1` and `range_width_classifier_v1`, with
semantic task IDs and `launch_coverage_claimed: false`.

The active content files, however, sit in runtime-enumerated session indexes
and manifests. The runtime supports neither kind, while an older focused test
still requires the superseded runtime kind and legacy action-named IDs. This is
a cross-layer contract decomposition failure. The correct repair direction is
to decide whether each accepted family is runtime-admitted or source-only and
then make source, index, manifest, parser/runner, validator, and proof agree.
Reverting W6 to Board Awareness or action-named range semantics is forbidden.

## 11. Regression vs baseline proof

The accepted W11/W12 integration evidence compared the previous base with
current main and found:

- 53 W5/W6 lines before;
- 53 W5/W6 lines after;
- byte-identical scanner output.

Current reproduction again returns the same 53-line W5/W6 set. The W11/W12
metadata bridge is therefore excluded as a cause. Git history places the
relevant W5/W6 source changes in earlier prerequisite/range normalization
waves.

## 12. Candidate next-bottleneck comparison

| Candidate | Current evidence | Product/user EV | Decision |
| --- | --- | --- | --- |
| A. W5/W6 scanner reconciliation | Direct W6 launch failure, lost W5 explanations, stale focused proof, and contradictory source/runtime admission | High: restores trustworthy practice behavior and makes the content gate meaningful without changing canonical Act0 | Select, as a bounded mixed contract reconciliation |
| B. Human novice QA | Master Plan identifies human novice proof as a real gate | Highest epistemic value when participants are available, but not executable from repository work alone | Preserve as the next human gate; do not simulate it |
| C. Learning transfer / deterministic session identity | Important measurement and proof maturity work, but no evidence here that it precedes a known launch failure | High after the affected session contract is coherent | Defer behind the selected repair |
| D. Review pattern coaching | Explicit maturity direction; Lite behavior already exists | Medium-high, but it should accumulate trustworthy session evidence | Defer behind correctness/contract alignment |
| E. Telemetry/observability truth | Known to be less mature than the learner route | Medium; broad telemetry is not the narrow cause of these failures | Defer; no telemetry expansion in this wave |
| F. Preserve freeze | Appropriate when W1-W6 has no concrete regression evidence | Low now because current focused proof demonstrates a live secondary runtime failure | Reject narrowly; keep canonical ownership/content-expansion freeze intact |

## 13. Recommended next bounded wave

**W5/W6 authored-session runtime and validator contract reconciliation v1**

Product/user EV: restore executable W5/W6 session-drill explanations and
normalized classifiers, or explicitly remove non-launch families from runtime
admission, while keeping canonical Act0 curriculum truth unchanged. The wave
also restores a broad scanner whose green/red result corresponds to actual
runtime admission.

Smallest safe scope:

1. Record runtime-admitted versus source-only status for W5 `s11`, W6
   range-bucket-by-board-fit, and W6 range-width families.
2. For admitted families, align source fields, stable IDs, index/manifest
   identity, runtime parser/runner behavior, validator kinds/intents/pacing,
   and focused tests.
3. For source-only families, remove contradictory runtime admission claims and
   prove they cannot be selected through the session-drill launcher.
4. Reconcile the 11 W5 explanations with the existing runtime limit without
   weakening poker correctness or automatic-action safeguards.

Likely files involved:

- `lib/services/drill_contract_v1.dart` and only the existing narrow
  session-drill runner/repair seams proven necessary by the admission decision;
- `tools/validate_world_content_v1.dart` and
  `tools/world_intents_ssot_v1.dart`;
- the directly affected W5/W6 session indexes, manifests, and 26 drill files
  only where the chosen contract requires source changes;
- focused W5/W6 session-runtime, validator, identity, and repair-receipt tests.

Required evidence:

- exact 53-line baseline mapped to zero unexplained W5/W6 scanner lines;
- direct adapter load proof for every runtime-admitted affected session;
- source-only non-reachability proof for every non-admitted family;
- stable-ID equality across source, index, manifest, adapter, and repair proof;
- W5 explanation visibility and anti-automatic-action correctness checks;
- canonical Act0 W5/W6 owner/route regression tests;
- `flutter analyze`, `git diff --check`, and `graphify hook-check`.

Exact stop conditions:

- stop if the wave requires changing W5/W6 canonical Act0 lesson owners,
  titles, world IDs, or unlock behavior;
- stop if accepted W6 semantic IDs must be reverted to action-named legacy IDs;
- stop if runtime admission cannot be proven from an active owner instead of
  inferred from filenames;
- stop if W5 copy cannot be shortened without changing poker meaning;
- stop if the change expands beyond the named W5/W6 session-drill contract,
  scanner, manifests, and focused proofs;
- stop if the proposed fix merely suppresses scanner errors while adapter-load
  or stable-ID proof remains red.

Must not change: W4-W7 ownership, W11/W12, canonical Act0 lesson content,
Master Plan, monetization, mascot, Modern Table, telemetry architecture,
screenshots, or W13+.

## 14. Explicitly deferred work

- Human novice QA remains required when participants are available.
- Learning-transfer measurement and deterministic session identity follow
  after the session contract is trustworthy.
- Review pattern coaching and repeated mistake-family accumulation remain a
  later maturity wave.
- App-wide telemetry/observability remains separate.
- W11/W12 source proof remains closed and unrelated.
- W13+, monetization, mascot, Modern Table, and broad content expansion remain
  out of scope.

## 15. Non-goals

This audit does not implement a parser, choose final learner copy, weaken a
validator, rename source IDs, update manifests, alter tests, reopen curriculum
ownership, or claim that canonical Act0 W5/W6 is broken.

## 16. Validation

- Exact scanner reproduced: exit `1`, 53 W5/W6 lines.
- Root-cause grouping reconciles exactly to 53.
- Focused W6 session-runtime proof reproduced the unsupported-kind failure.
- Accepted base/current comparison proves no W11/W12 regression.
- Authority, active content index, runtime parser, manifests, and focused tests
  were inspected only for the affected W5/W6 contract.
- Final repository checks are recorded with the commit closeout.

## 17. Final route recommendation

Run **W5/W6 authored-session runtime and validator contract reconciliation
v1** as the next executable bounded wave. It is justified by direct runtime
and stale-proof evidence, not by scanner redness alone. Preserve the canonical
Act0 W5 Board Awareness and W6 Range Thinking owners. After this bounded
reconciliation, return to Human novice QA when participants are available;
otherwise reassess learning-transfer/session-identity work against the then
green, trustworthy content contract.

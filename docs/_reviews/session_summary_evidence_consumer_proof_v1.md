# Session Summary Evidence Consumer Proof v1

## 1. Verdict

`session_summary_adapter_ready`

Grouped Act0 learning evidence can now support a bounded, current-run session
summary adapter. This wave deliberately stops before visible UI consumption.

## 2. Consumer owner map

- Evidence fact owner: `Act0CompletedDecisionV1`.
- Durable write owner: `Act0LearningEvidenceHistoryV1`.
- Run grouping owner: `Act0ShellPreviewScreenV1`.
- Current-run query owner: `Act0LearningEvidenceHistoryV1.latestRunSummary`.
- Consumer adapter owner: `Act0SessionSummaryEvidenceViewModelV1`.
- Visible UI owner: not opened in this wave.

Existing visible summary-like surfaces exist in the lesson runner, but they also
carry broader completion, XP, repair-mix, and route ceremony semantics. Reusing
them directly would risk broad copy and UI scope. The safe slice is therefore a
data-only adapter.

## 3. Evidence claims admitted

The adapter admits only current/latest grouped-run claims:

- `This run`
- `You played X spot(s).`
- `X correct / Y to review.`
- `Main repair focus: <safe label>.`

Repair focus copy is emitted only when the caller provides a safe
evidence-backed label for the stored repair-focus id. Raw ids are not exposed as
learner-facing copy.

## 4. Evidence claims forbidden

The adapter does not emit:

- long-term trend claims;
- biggest leak / weakest area claims;
- mastery claims;
- AI / solver / GTO claims;
- Profile-like ranking;
- Review backlog claims;
- Practice recommendation claims;
- history claims beyond the latest grouped run.

## 5. Implemented consumer slice, if any

Implemented:

- `Act0SessionSummaryEvidenceViewModelV1.fromHistory`.
- Safe empty state when no grouped latest run exists.
- Latest-run-only summary lines.
- Repair/practice/lesson runs remain separated by run id.
- Optional safe repair-focus label mapping.

Not implemented:

- no visible summary card;
- no Profile/Review/Practice consumer;
- no session-summary route;
- no new persistence field;
- no telemetry change.

## 6. Empty/missing evidence behavior

When history has no grouped latest run, the adapter returns:

- `hasEvidence: false`;
- title `This run`;
- empty claim lines;
- no repair-focus line.

Old ungrouped records remain parse-safe but do not produce current-run summary
claims.

## 7. What Session Summary can now/cannot claim

Can claim:

- current grouped run spot count;
- current grouped run correct and review counts;
- safe repair-focus label when supplied by an evidence-backed owner.

Cannot claim:

- all-time progress;
- multi-run trend;
- largest leak;
- skill ranking;
- mastery;
- AI/persona interpretation;
- Review backlog state.

## 8. What Profile/Review/Practice still cannot claim

Profile, Review, and Practice cannot consume this adapter yet. They still need a
separately scoped owner decision before showing grouped-run evidence.

## 9. Telemetry compatibility

No telemetry payloads were changed. The adapter consumes durable local evidence
records and does not reuse telemetry event keys.

## 10. Route/progression boundary proof

No route, progression, W11/W12 activation, W13 frontier, or ProgressService
behavior changed. The adapter is read-only over existing history.

## 11. UI/screenshot proof, if visible UI changed

No visible UI changed. Screenshot proof was not required or run.

## 12. Baseline residue, if observed

No baseline failure was encountered in this wave. The known
`act0_telemetry_sink_v1_test.dart:565` residue was not part of this validation
slice.

## 13. Tests / validation

Focused tests cover:

- latest-run-only adapter reads;
- old ungrouped records excluded;
- lesson/practice/repair run separation;
- empty evidence fallback;
- forbidden copy claim avoidance through adapter output;
- existing grouping/write, completed-decision, repair intent, and feedback
  rhythm compatibility.

## 14. Next recommended wave

`Session Summary Visible Consumer v1`

Scope it only after choosing the exact existing visible owner. The default
candidate is a small existing session/result summary seam, not Profile, Review,
Practice, or Home.

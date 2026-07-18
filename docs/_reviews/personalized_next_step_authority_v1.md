# Personalized Next-Step Authority v1

Status: PUBLISHED FOR ADMISSION

Baseline: `ae51ae5f87ccffd0713a82494129d43e134b3eec`

## Ownership matrix

| Concern | Canonical owner | Use |
| --- | --- | --- |
| Decision | `act0_personalized_return_reason_v1.dart` | One deterministic priority contract |
| Home | `act0_home_shell_v1.dart` | Existing support line and CTA |
| Review | `act0_review_shell_v1.dart` | Existing surface plus why-now card |
| Repairs | multi-repair queue | Highest-priority actionable evidence |
| State/transfer/due | existing Act0 contracts | Retry, transfer, and retention evidence |
| Persistence | Act0 progress snapshot | Source evidence only; no decision state |
| Telemetry | `Act0TelemetrySinkV1` | Safe selected/opened projection |

## Previous behavior and contract

Home had a deterministic return line but omitted due review. Review independently
showed repairs and due cards without a shared hierarchy. The existing
`Act0PersonalizedReturnReasonV1` now owns one ordered decision:

1. active unresolved repair;
2. repair not yet successful;
3. actionable due spaced review;
4. real same-family improved or held transfer evidence;
5. most recent valid focus;
6. generic fallback.

Malformed/incomplete evidence degrades to the next valid class. Ties are stable
by evidence order, severity where present, then stable identifiers. Internal
identifiers remain internal; copy receives only a safe label where available.

## Home, Review, telemetry, and persistence

Home keeps its existing support slot and CTA. Selection is projected only from
targets that can resolve now: active/retry repair evidence requires its exact
current repair card, due evidence requires its selected due item, and otherwise
the contract deterministically degrades to Learn evidence or ordinary Home
continuation. Tap recomputes once before routing, so stale repair/due evidence
cannot emit an opened event for an action that was not opened.

Review adds a compact `WHY THIS, WHY NOW` explanation in its existing queue
slot. Existing repair and due cards retain the one primary CTA for their
selected target; the explanation owns a CTA only for Learn destinations.
Distinct session rechecks remain separate. Empty safe labels use neutral,
class-specific copy rather than self-repeating `notice the clue` wording.

Message families cover unfinished repair, failed retry, due review, real
transfer reinforcement, recent focus, and a deliberately non-personal generic
fallback. Visible copy excludes IDs, system language, mastery, guarantees, and
unsupported transfer claims.

Exposure telemetry is scheduled post-frame, never from `build()`. Its internal
fingerprint includes the surface and raw evidence reference so a changed due
item is measurable while ordinary rebuilds are deduped. The external safe
projection contains only reason type, evidence kind, priority, destination, and
action: no copy, task IDs, concept IDs, raw evidence, or session payload.
Generic fallback emits no personalized event, and sink failure remains
non-fatal.

No schema migration or duplicate decision persistence was added. Existing
schema-17 source evidence round-trips; the recommendation recomputes after
restart and malformed source evidence falls back safely.

## Focused proof

- Focused decision, Review, telemetry, repair lifecycle, transfer, due-review,
  compact, and large-text coverage: PASS.
- Telemetry sink suite: PASS, including ordinary repair ordering and bounded
  next-step selection.
- Targeted `flutter analyze`: PASS.
- Existing compact shell and Review widget coverage preserved CTA reachability
  and found no overflow. No visual redesign or screenshot pack was introduced.

## Changed-file matrix

| File | Change |
| --- | --- |
| `act0_personalized_return_reason_v1.dart` | Due class, priority/action/why-now, safe telemetry projection |
| `act0_review_shell_v1.dart` | Existing-surface explanation, single-CTA rule, safe fallback copy |
| `act0_shell_preview_screen_v1.dart` | Shared Home/Review owner, truthful routing, post-frame telemetry |
| focused tests | Priority, copy, CTA, and telemetry regression proof |

## Explicit non-claims

No Human learning effect, durable-retention effectiveness, Top-1 superiority,
AI/ML, remote inference, chatbot/persona engine, or macro-wave closure is
claimed. No Modern Table, curriculum-depth, W11/W12, release, or Human QA work
is included.

## Repository state

Branch: `codex/personalized-next-step-authority-v1`. The immutable
`act0-final-deterministic-candidate-v1` tag is unchanged. This artifact is for
one bounded draft PR; it is not an admission or merge record.

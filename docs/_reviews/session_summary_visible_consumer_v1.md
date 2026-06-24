# Session Summary Visible Consumer v1

## 1. Verdict

`session_summary_visible_consumer_ready`

The first visible consumer for grouped Act0 learning evidence is admitted in the
existing block-completion shell.

## 2. Visible owner audit

| Candidate | Result |
| --- | --- |
| Block / lesson completion surface | Safe owner. It is already a completion moment, can hide when evidence is absent, and does not require new navigation. |
| Repair result surface | Not chosen. It is repair-specific and would risk mixing single-decision repair proof with run-level evidence. |
| Session repair surface | Not chosen. It is repair-only and not a general session summary owner. |
| Profile / Review / Practice / Home | Not chosen. These would broaden scope into identity, backlog, recommendations, or next-action ownership. |

## 3. Chosen owner

`Act0BlockCompletionShellV1`

This owner is already the post-run completion moment for lesson/world closure.
It receives an optional `Act0SessionSummaryEvidenceViewModelV1` and renders a
compact proof card only when grouped latest-run evidence exists.

## 4. Evidence copy admitted

- `This run`
- `You played X spot(s).`
- `X correct / Y to review.`
- `Main repair focus: <safe label>.`

## 5. Evidence copy forbidden

The visible consumer does not emit:

- `Based on your last N decisions`
- `Your biggest leak`
- `Your weakest area`
- `Mastered`
- `AI detected`
- `GTO mistake`
- `Long-term trend`
- `Best/worst skill`
- Profile-like identity or ranking claims

## 6. Implemented visible slice, if any

Implemented:

- optional `evidenceSummary` field on `Act0BlockCompletionShellV1`;
- compact `This run` evidence card inside the existing block summary;
- Act0 shell wiring from persisted grouped evidence via
  `Act0SessionSummaryEvidenceViewModelV1.fromHistory`;
- small id-to-safe-label map for known repair-focus ids.

Not implemented:

- no new screen;
- no Profile/Review/Practice/Home consumer;
- no new CTA;
- no animation;
- no new route or progression behavior.

## 7. Empty/missing evidence behavior

If the adapter reports `hasEvidence == false`, the block summary silently hides
the evidence card. Old ungrouped records do not produce visible session summary
claims.

## 8. What Session Summary can now/cannot claim

Can claim:

- current grouped-run spot count;
- current grouped-run correct/review count;
- safe repair-focus label when a known evidence id maps to safe copy.

Cannot claim:

- long-term history;
- trend;
- leak;
- mastery;
- AI/persona interpretation;
- skill ranking;
- Review backlog state.

## 9. What Profile/Review/Practice/Home still cannot claim

Profile, Review, Practice, and Home still cannot consume grouped evidence in
this wave. Each needs a separate owner decision before using this data.

## 10. Telemetry compatibility

No telemetry schema or payload changed. The visible consumer reads local durable
evidence only and does not use telemetry event keys.

## 11. Route/progression boundary proof

No route, progression, W11/W12 activation, W13 frontier, or ProgressService
behavior changed. The existing block-completion flow still owns navigation and
progression.

## 12. UI/screenshot proof, if visible UI changed

Visible UI changed in the block-completion surface.

Fast deterministic packet run:

- `./tools/screen_review_fast_v1.sh first_week compact`
- Contact sheet:
  `output/screen_review/current/first_week_fast/contact_sheet.png`
- Zip:
  `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Current first-week packet does not include the block-completion summary owner as
a named capture state, so the direct proof for this wave is the focused
block-summary widget test plus the shell-flow completion test.

## 13. Baseline residue, if observed

No baseline failure was observed during this wave. The known
`act0_telemetry_sink_v1_test.dart:565` residue was not part of this slice and
was not touched.

## 14. Tests / validation

Focused tests cover:

- visible block summary renders grouped evidence lines;
- empty evidence hides the card;
- repair-focus line is omitted when no safe label exists;
- actual shell completion consumes grouped latest-run evidence;
- adapter/write/grouping compatibility;
- repair intent and feedback rhythm compatibility.
- fast first-week packet still generates successfully; generated artifacts are
  local-only.

## 15. Next recommended wave

`Session Summary Copy/Visual Acceptance v1`

Run it only if the deterministic packet shows the block summary needs copy or
spacing tuning. Do not expand to Profile, Review, Practice, or Home without a
separate owner decision.

---
status: "undeclared"
status_source: "absent"
baseline: "05940500e1d1"
generated_by: "docs_frontmatter_v1"
---

# Real-Text Evidence Integrity — Wave A v1

Terminal verdict: `real_text_evidence_integrity_wave_a_revalidated_existing_pipeline_no_product_or_tool_source_change`

## Scope and branch state

- Step 0 accepted audit push: `05940500e1d19c4d2c3ece779c24ea531cc71b2b`
  (`docs: add full static surface re-audit queue`) was pushed to
  `origin/claude/hub-surface-coherence-audit-plan-v1` before this Wave A work.
- Step 1 branch / HEAD before this artifact: `claude/hub-surface-coherence-audit-plan-v1` /
  `05940500e1d19c4d2c3ece779c24ea531cc71b2b`.
- Step 1 source changes: none. The existing real-text capture tool and its
  post-capture repair helper are sufficient when used as one pipeline.
- This artifact is the sole committed Wave A file. `output/**` is local,
  untracked evidence and is not part of the commit.

This is capture/evidence work only. It changes no product UI/layout/copy,
route/progression, telemetry, W13 policy, Sharky, motion, tablet, or Human QA
behavior.

## Diagnosis

### W12 payoff, no-W13 terminal, and wrong-feedback CTA rectangles

**Classification: capture-pipeline lifecycle defect; not a product rendering
defect.**

The affected CTAs are ordinary `FilledButton` consumers of the existing
`Act0ShellTokensV1.premiumActionButtonStyle`. In the Flutter widget-test raster
step, Ahem glyph blocks appear where a local font family is absent from the
effective text style. The capture generator correctly discovers the affected
labels and emits sidecars with their exact strings and bounds:

- `Next hand` for W12 payoff and terminal;
- `Try same clue` for wrong feedback.

The existing `screen_review_fast_text_repair_v1.py` consumes those sidecars,
clears the temporary Ahem blocks, redraws the actual label with a local font,
and removes the sidecar. The black-rectangle audit inputs were raw images from
before this repair was applied (or stale local equivalents), not output of the
complete `screen_review_fast_v1.sh` lifecycle. A direct raw capture reproduced
the blocks; applying the existing helper produced literal readable CTAs. The
widget capture itself passed for each group, and the discovered labels prove
that the widget tree contains the intended product text.

No product source-rendering failure was observed. No helper implementation
change is needed: the repair seam already covers these labels.

### Profile lower proof area

**Classification: same capture-pipeline lifecycle defect; not a Profile UI
defect.**

Raw Profile evidence contained Ahem blocks for `View week` and `View all
skills`. The existing discovery step emitted both labels; the repair helper
replaced both blocks with literal text. The visible lower proof tiles retain
their source-backed labels (`Table sense`, `Board reading`, route-proof and
source lines). There is no evidence that the product omitted a tile label.

The earlier profile raster concern remains a provenance/process rule: do not
use a raw sidecar-bearing PNG for final visual judgment. Use only the repaired,
packaged packet below.

## Exact repair and verification

No source patch was made. The smallest valid repair was operational:

1. regenerate only `runner`, `profile_evidence`, and
   `active_route_w7_w12` in compact mode;
2. run the existing text-repair helper over each packet;
3. package the repaired packets and create a four-image Wave A ZIP;
4. confirm the new manifests identify `05940500` and
   `matches_current_head: true`.

An isolated helper check created a synthetic cyan CTA, repaired its
`Next hand` overlay, and verified both a repaired label and preserved cyan
background. It passed.

## Validation

- Raw compact capture generation: `runner`, `profile_evidence`, and
  `active_route_w7_w12` — passed (one capture test per group).
- Widget text discovery: sidecars contained `Try same clue`, both `Next hand`
  states, `View week`, and `View all skills` before repair — passed.
- Existing repair helper: 2 runner labels, 2 Profile labels, and 8 active-route
  labels repaired — passed.
- Isolated Python repair-helper CTA check — passed.
- `graphify hook-check` — passed.
- `git diff --check` / staged diff check — required at commit time.
- `flutter analyze` — not required: Dart tooling and product source are
  unchanged.

## Fresh literal compact evidence

All paths are local-only and uncommitted:

- Wrong feedback / missed clue:
  `output/screen_review/current/runner_fast/compact.wrong_feedback.png`
- W12 payoff / Volume I completion:
  `output/screen_review/current/active_route_w7_w12_fast/compact.w12_payoff_completion_copy_detail.png`
- Volume I review / no-W13 terminal:
  `output/screen_review/current/active_route_w7_w12_fast/compact.terminal_no_w13_copy_detail.png`
- Profile lower proof area:
  `output/screen_review/current/profile_evidence_fast/compact.profile_evidence.png`
- Contact sheets:
  `output/screen_review/current/runner_fast/contact_sheet.png`,
  `output/screen_review/current/active_route_w7_w12_fast/contact_sheet.png`,
  and `output/screen_review/current/profile_evidence_fast/contact_sheet.png`.
- Focused four-image ZIP:
  `output/screen_review/current/real_text_evidence_integrity_wave_a_v1_compact.zip`.

Open commands:

```bash
open output/screen_review/current/runner_fast/compact.wrong_feedback.png
open output/screen_review/current/active_route_w7_w12_fast/compact.w12_payoff_completion_copy_detail.png
open output/screen_review/current/active_route_w7_w12_fast/compact.terminal_no_w13_copy_detail.png
open output/screen_review/current/profile_evidence_fast/compact.profile_evidence.png
```

Wave B/C/D may now use these four compact screenshots literally for static
copy, CTA, composition, density, and hierarchy review within the known
Flutter-widget-test (not native-device) boundary.

## Remaining debt and explicit non-scope

- The wrong-feedback view still has candidate product debt: table dominance
  after an error, a secondary-feeling feedback card, and weak lower-space use.
  It is recorded for Wave C; this Wave A intentionally does not alter it.
- Feedback/repair/session-closure hierarchy remains a Wave C candidate.
- Evidence remains compact-phone Flutter widget-test output. It is not a
  tablet or native-device quality verdict.
- The full fast-capture command remains required whenever a fresh packet is
  requested; raw direct-capture output must not be treated as literal evidence
  until its sidecars have been repaired and removed.

No 10/10 claim, public-readiness claim, Human-QA-readiness claim, or tablet
quality claim is made.

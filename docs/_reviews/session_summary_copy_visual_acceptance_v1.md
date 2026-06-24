# Session Summary Copy/Visual Acceptance v1

## 1. Verdict

`session_summary_named_capture_ready`

The existing Session Summary evidence card is acceptable as a first bounded, data-backed learning moment. The implementation slice for this wave is named deterministic capture proof only.

## 2. Summary card owner

- Visible owner: `Act0BlockCompletionShellV1`.
- Runtime source: the block-completion shell receives `Act0SessionSummaryEvidenceViewModelV1.fromHistory(...)`.
- Data source: latest grouped Act0 learning evidence run.
- Scope: current-run summary only.

## 3. Copy acceptance

Accepted copy remains factual and beginner-safe:

- `This run`
- `You played X spot(s).`
- `X correct / Y to review.`
- Optional `Main repair focus: <safe label>.`

No copy tuning was required. The current language avoids long-term profile claims, trend claims, leak/mastery language, AI claims, solver/GTO language, and skill ranking.

## 4. Visual acceptance

The summary sits inside the existing block-completion shell and reads as a learning summary rather than decoration. It fits the current card hierarchy without requiring a redesign, new animation, or new design-system element.

The summary card remains intentionally compact. It does not become a Profile, Review, Practice, or Home surface.

## 5. Screenshot/capture proof decision

Before this wave, focused tests proved the visible consumer, but the `first_week` packet did not include a named block-completion summary capture state.

This wave adds a deterministic `session_summary` first-week capture entry so the accepted card can be reviewed in the standard fast screenshot packet:

```bash
./tools/screen_review_fast_v1.sh first_week compact
```

Expected local-only proof artifacts:

- `output/screen_review/current/first_week_fast/compact.session_summary.png`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

Generated screenshot artifacts remain uncommitted.

## 6. Implemented slice, if any

Implemented slice: Option 2, named screenshot capture only.

Changes:

- added `Act0ControlledDemoCaptureSurfaceV1.sessionSummary`;
- added query parsing for `?act0_capture=session_summary`;
- seeded deterministic latest-run evidence and block-completion summary for capture;
- added `session_summary` to the `first_week` fast capture group;
- added `session_summary` to the first-week contact sheet / zip package order;
- updated focused capture contract expectations.

No summary-card copy, layout, route, progression, telemetry, persistence, content, or Modern Table behavior changed.

## 7. Claims allowed/forbidden

Allowed claims remain current-run, fact-only learning evidence:

- current run;
- spots played;
- correct / to-review count;
- safe repair-focus label.

Forbidden claims remain out of scope:

- based on last N decisions;
- biggest leak / weakest area;
- mastered;
- AI detected;
- GTO mistake;
- solver/optimal claims;
- long-term trend;
- best/worst skill;
- Profile-like ranking or identity claims.

## 8. Boundary proof

Preserved:

- Profile unchanged;
- Review unchanged;
- Practice unchanged;
- Home unchanged;
- routes/progression unchanged;
- telemetry schema unchanged;
- durable evidence write/read behavior unchanged;
- W11/W12 remain planned/proof-backed only;
- W13+ remains frontier-only;
- Modern Table unchanged;
- no generated output committed.

## 9. Tests / validation

Required validation for this wave:

- focused capture contract tests;
- focused block-summary / shell-flow tests;
- `./tools/screen_review_fast_v1.sh first_week compact`;
- `graphify hook-check`;
- `python3 -m py_compile tools/package_screen_review_v1.py`;
- `flutter analyze`;
- `dart format --set-exit-if-changed` on touched Dart/test/tool files;
- `git diff --check`;
- `git status --short`.

Known baseline residue remains out of scope unless directly affected:

- `act0_telemetry_sink_v1_test.dart:565` / `Bad state: No element`.

## 10. Next recommended wave

Proceed to the next bounded learning-evidence layer only after this capture proof is accepted. Do not expand Session Summary into Profile, Review, Practice, or Home until explicitly scoped.

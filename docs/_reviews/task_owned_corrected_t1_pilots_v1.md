# Task-owned corrected-T1 pilots v1

## Terminal verdict

The task-owned layouts are layout-admitted: the canonical Act0 runner, focused
automated regression set, and required local visual packet all pass their
bounded layout checks. Full identity-evidence admission remains blocked only
because learner-only and dealer-order have no source-owned learner-reachable
production state to capture; no fixture was substituted for that evidence.

## Commits and forwarding path

- `4910260f` — task `tablePresentation` -> preview selected task ->
  `Act0LessonRunnerShellV1.tablePresentation`.
- `91f85d91` — `spatialTheory` selects the fixed corrected-T1 theory layout.
- `ade4ade0` — `stablePractice` selects the fixed practice-table slot.

## Pilot result

`actions_theory` alone uses the full production table above a non-scrolling,
content-sized theory panel (12px separation; title/body line caps are 2/4).
The sole real theory beat has bounds `x=26.796, y=4, w=321.408, h=558`; the
panel is 91.6% of the lower region, and its bottom blank band is 9px.

`actions_check_drill` alone uses a table slot that is allocated before its
decision or review panel. Decision, correct-feedback, and wrong-feedback all
measure `x=55.020, y=4, w=264.960, h=460`: zero logical-pixel movement.
Unannotated tasks retain the generic legacy runner path.

## Reachability and preservation

The source task is learner-reachable through the canonical W1 lesson. Its
bounded runner state inventory is decision and feedback/review; repair and
recheck are shell-owned routes and were not fabricated as task states. There
is no claim of cross-task same-hand continuity. One bounded inspection found
no reusable same-hand sequence owner: the preview shell owns task selection,
while each task owns a separate runner state. Sequence continuity remains
future Learning Flow work.

## Regression result

Focused presentation, identity semantic/marker, W7-W12 repair/recheck, and
learning-evidence contract tests passed; focused analysis and `graphify
hook-check` passed. Typed identity policy remains production-owned, including
the one-dealer-disc rule.

## Evidence and admission

Local-only evidence is at
`/Users/elmarsalimzade/Sharky_1.0/output/evidence/task_owned_corrected_t1_pilots_v1/`:

- `theory_contact_sheet.png` and `practice_contact_sheet.png`
- `geometry_metrics.json` and `panel_occupancy.json`
- `reachable_state_inventory.md` and `visual_admission_report.md`

The task has one real theory beat, which is therefore truthfully first,
longest, and final. Its current source contains three practice options; no
four-option state, localized/long-copy state, or task-owned repair/recheck
state was manufactured. Raw Flutter test screenshots are geometry evidence,
not copy-readability evidence.

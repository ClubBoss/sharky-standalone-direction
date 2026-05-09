# Auxiliary Entry Seam Audit v1

Purpose:

- audit auxiliary consumers that can open training surfaces outside the primary map flow
- identify at most one highest-EV shared launch seam that can be centralized without broad IA or navigation redesign

## Candidate Seams

| Seam | Current source locations | Shared intent | Current duplication / drift risk | Best canonical source seam | EV / priority | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| auxiliary World 1 pack target -> foundations-check runner launch | `module_summary_screen.dart` | shared | medium; auxiliary module entry still rebuilds the same `World1FoundationsMicroTaskRunnerScreen` launch locally instead of consuming the canonical World 1 runner helper | `pushWorld1FoundationsRunnerV1` in `table_first_navigation.dart` | high | centralize now |
| theory session -> table-practice runner launch | `theory_session_screen.dart` | partially shared | medium; still tied to theory-only instruction injection and table-practice mode | none yet without broadening the runner launch contract | medium | later |
| dev shortcut -> debug runner launch | `ui_v2_beta_shell.dart` | partially shared | low inside production scope; debug-only shortcuts intentionally carry bespoke bootstrap state | none in current bounded production scope | low | leave as-is |
| auxiliary start / continue -> map shell routing | `universal_intake_plan_screen.dart`, `home_screen.dart` | shared | medium, but these flows are map/shell routing rather than direct training-surface launch seams | none yet without broader auxiliary entry routing work | medium | later |

## R292 Selection

- selected seam:
  - auxiliary World 1 pack target -> foundations-check runner launch
- why:
  - it is the smallest production launch seam still bypassing an already-canonical route helper
  - it uses the same pack-target payload as the shared push-style foundations runner seam
  - centralizing it does not redesign auxiliary flow ownership or screen IA

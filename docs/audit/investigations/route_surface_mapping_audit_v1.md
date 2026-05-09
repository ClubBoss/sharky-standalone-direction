# Route Surface Mapping Audit v1

Purpose:

- audit the boundary where canonical progression targets are turned into concrete screen launches
- identify at most one highest-EV mapping seam that can be centralized without broad navigation redesign

## Candidate Seams

| Seam | Current source locations | Shared intent | Current duplication / drift risk | Best canonical source seam | EV / priority | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| World 1 pack target -> foundations runner launch | `ui_v2_progress_map_screen_v2.dart`, `ui_v2_beta_shell.dart`, `module_launcher_screen.dart` | shared | medium; the same pack target is converted into `World1FoundationsMicroTaskRunnerScreen` through repeated local `MaterialPageRoute` builders | shared World 1 runner launch helper in `table_first_navigation.dart` | high | centralize now |
| World 1 pack target -> replacement-style foundations runner launch | `universal_intake_plan_screen.dart`, `session_result_screen.dart` | shared | medium; campaign-spine and review-queue continuation flows still rebuild the same runner route locally before replacing the current surface | shared replacement launch helper in `table_first_navigation.dart` | high | centralize now |
| theory module target -> theory surface launch | `table_first_navigation.dart`, callers that already use `navigateToTheorySession` | shared | low; already bounded and canonical enough | existing `navigateToTheorySession` seam | medium | leave as-is |
| session target -> session drill player launch | `SessionDrillPlayerV1Screen.route`, targeted callers | shared | low; already has a route helper | existing `SessionDrillPlayerV1Screen.route` seam | medium | leave as-is |
| broad pack target -> any host surface mapping | map, beta shell, module summary, dev hub, table-first navigation | partially shared | high, but mode/surface ownership still differs by context | none yet without broader navigation redesign | medium | later |

## R288 Selection

- selected seam:
  - World 1 pack target -> foundations runner launch
- why:
  - it is the smallest shared launch mapping still duplicated across multiple active consumers
  - it is source-driven from an already-canonical pack target
  - centralizing it does not redesign route ownership or app IA

## R289 Selection

- selected seam:
  - World 1 pack target -> replacement-style foundations runner launch
- why:
  - it is the next highest-EV launch seam still duplicated across active progression consumers
  - it reuses the same canonical runner route while preserving local replacement timing
  - centralizing it does not redesign navigation ownership or route shells

## Post-R291 Alignment

- active in-scope residue:
  - none
- intentionally deferred:
  - beta-shell dev shortcut runner launches
- too broad for later:
  - broad pack target -> any host surface mapping

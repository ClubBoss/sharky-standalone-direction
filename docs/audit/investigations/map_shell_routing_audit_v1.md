# Map Shell Routing Audit v1

Purpose:

- audit the layer where canonical start or continue targets are routed into map shells or flow containers
- identify at most one highest-EV shell-routing seam that can be centralized without broad navigation redesign

## Candidate Seams

| Seam | Current source locations | Shared intent | Current duplication / drift risk | Best canonical source seam | EV / priority | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| start / continue target -> progress-map shell route choice | `universal_intake_plan_screen.dart`, `session_result_screen.dart` | shared | resolved; production flows now reuse the shared default map route and the review-queue auto-open variant | shared progress-map route helper in `ui_v2_progress_map_screen_v2.dart` | high | already canonical |
| app-level entry gate -> default progress-map shell | `app_root.dart`, other top-level entry surfaces | shared | low; already simple and not the highest-EV drift point after production flow cleanup | existing direct map route is compatible enough for now | medium | leave as-is |
| debug shortcut -> debug auto-open map shells | `ui_v2_beta_shell.dart` | partially shared | low in production scope; debug-only and explicitly coupled to debug auto-open surfaces | none in current bounded production scope | low | leave as-is |
| start / continue target -> non-map shell/container choice | `universal_intake_plan_screen.dart`, `session_result_screen.dart` | shared | medium, but this broadens quickly into general shell/app-flow routing | none yet without broader navigation redesign | medium | later |

## Current Reconciliation Status

- already centralized seam:
  - start / continue target -> progress-map shell route choice
- current result:
  - the bounded production seam is already canonical via `progressMapRouteV1(...)`
  - no additional clean production shell-routing seam is currently separable without broadening into app-entry routing or debug-only shell behavior
- current stop point:
  - `app_root.dart` default map entry remains compatible enough for now
  - `ui_v2_beta_shell.dart` map opens remain debug-only and intentionally outside the bounded production seam
  - broader non-map shell/container choice still belongs to later shell/app-flow work

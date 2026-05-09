# Non-Map Shell Routing Audit v1

Purpose:

- audit the layer where canonical start or continue targets are routed into non-map shells or containers
- identify at most one highest-EV routing seam that can be centralized without broad navigation or app-flow redesign

## Candidate Seams

| Seam | Current source locations | Shared intent | Current duplication / drift risk | Best canonical source seam | EV / priority | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| app entry gate -> intake shell vs beta-shell path | `app_root.dart` | shared | medium product importance, but not duplicated; current choice is owned in one place and is closer to app-entry flow control than a missing shared source seam | none yet without broader entry-flow redesign | medium | later |
| session result back action -> intake shell vs progress-map vs local pop | `session_result_screen.dart` | partially shared | medium, but the choice depends on local session state (`_isCampaignSpineSession`, `_campaignComplete`, `intakeFlowActiveInSession`) rather than a reusable canonical progression target seam | none yet without broader flow-state contract | high | later |
| canonical module target -> module summary shell | `ui_v2_progress_map_screen_v2.dart`, `session_result_screen.dart`, `saga_map_screen.dart` | partially shared | medium, but this is a module-summary/container routing layer, not a bounded start/continue shell seam; current callers own different flow timing and payload shapes | possible future shared module-summary route helper | medium | later |
| debug shortcut -> non-map debug shell/container opens | `ui_v2_beta_shell.dart` | partially shared | low in production scope; debug-only and intentionally coupled to bespoke bootstrap behavior | none in current bounded production scope | low | leave as-is |
| home/onboarding entry -> non-map training shell | `home_screen.dart` and onboarding widgets | low | low; not a canonical start/continue progression seam and still tied to legacy/demo entry intent | none in current bounded scope | low | leave as-is |

## R299 Result

- selected seam:
  - none
- why no seam was selected:
  - no remaining candidate is both truly shared and cleanly separable at this layer
  - the highest-EV remaining choices depend on local flow ownership or broader app-entry state rather than a missing canonical target router
  - centralizing any of them now would broaden into app-flow redesign or force per-surface exceptions

## Current Boundary

- already canonical below this layer:
  - production start / continue target -> progress-map shell route choice via `progressMapRouteV1(...)`
- deferred above this layer:
  - broader app-entry shell choice
  - broader session-completion return-shell choice
  - broader module-summary/container routing

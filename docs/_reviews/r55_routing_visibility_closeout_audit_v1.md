# R55 Routing Visibility Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: expose existing routing value through one bounded "Why are you here?" presentation seam.
- Selected seam scope: map pinned START NOW surface reason line (`today_plan_focus_line_v1`) only.
- Out of scope held: routing policy/scoring changes, profile dashboard expansion, multi-surface rollout, schema/ML/dependency changes.

## Candidate seam recap and why selected seam won
- Include now: pinned map START NOW seam (single CTA-adjacent line, highest visibility, lowest UI sprawl).
- Maybe later: result-to-next transition explanation line.
- Exclude from R55: broad map detail/profile dashboard reason surfaces.
- Winner rationale: highest user-visible EV with one bounded insertion point and existing routing outputs.

## Exact visibility rule and closure evidence
- Visibility rule:
  - reuse existing routing outputs/signals only:
    - map rhythm decision reason (`Review required` / `Missed spots ready` / `Continue`),
    - routed next pack id (`..._spine_followup_v1_b0`, `..._spine_followup_v1_b2`, or other).
  - deterministic mapping:
    - review-gated + non-empty rhythm reason -> `Why: <reason>.`
    - followup `b0` -> to-call reinforcement reason.
    - followup `b2` -> expected-action reinforcement reason.
    - empty target -> safe fallback (`No next campaign pack is available yet.`).
    - else -> safe progression fallback (`Continue your next campaign pack.`).
- Closure evidence:
  - [ui_v2_progress_map_screen_v2.dart](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart): added deterministic reason mapper (`todayPlanRoutingReasonLineV1`) and bound the selected seam line to it.
  - compat-hidden CTA branch now preserves deterministic reason visibility on the same seam key.

## Proof recap (gates + targeted test)
- Targeted proof:
  - [today_plan_routing_reason_contract_test.dart](/Users/elmarsalimzade/poker_ai_analyzer/Poker_Analyzer/test/ui_v2/today_plan_routing_reason_contract_test.dart)
    - review-gated reason mapping,
    - followup b0/b2 mapping,
    - absent target safe fallback + repeatability.
- Required gates:
  - `flutter analyze` PASS
  - `./tools/fast_loop_world1_v1.sh` PASS
  - `flutter test test/ui_v2/today_plan_routing_reason_contract_test.dart` PASS

## Open-risk list
- Reason-copy phrasing breadth for additional followup families remains deferred.
- Multi-surface visibility rollout remains deferred by design.

## Explicit defer list
- Any routing precedence/scoring refinement.
- Profile/dashboard visibility expansion.
- Result-screen or onboarding-wide explanation system.

## Anti-drift note
- R55 closed exactly one bounded presentation seam.
- No drift into routing-logic expansion beyond exposing existing signal outputs.

## Ambiguous P0 status
- No ambiguous P0 remains for selected R55 scope.

## Transition note (next focus only)
- Move to R56 planning/execution only after `# Milestone R56` is explicitly defined in SSOT.

# Pack Target Host Surface Audit v1

Purpose:

- audit the broader layer where canonical pack or module targets are converted into host-surface choices
- identify at most one highest-EV host-selection seam that can be centralized without broad navigation redesign

## Candidate Seams

| Seam | Current source locations | Shared intent | Current duplication / drift risk | Best canonical source seam | EV / priority | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| module target -> theory host surface choice | `table_first_navigation.dart`, `home_screen.dart` | shared | medium; table-first capable modules are already resolved canonically in one place, but home still rebuilt the host choice locally by deciding between table-first theory and plain theory | shared module host route helper in `table_first_navigation.dart` | high | centralize now |
| module target -> practice host choice after theory | `theory_session_screen.dart` | partially shared | medium; host choice is still coupled to theory-local instruction injection and practice-mode payload | none yet without broadening the practice launch contract | medium | later |
| dev shortcut target -> debug host choice | `ui_v2_beta_shell.dart` | partially shared | low in production scope; choices are explicitly debug-only and carry bespoke bootstrap state | none in current bounded production scope | low | leave as-is |
| start / continue target -> map shell choice | `home_screen.dart`, `universal_intake_plan_screen.dart` | shared | medium, but this is a shell-routing layer rather than a bounded pack-target host mapping seam | none yet without broader navigation/app-flow redesign | medium | later |

## R294 Selection

- selected seam:
  - module target -> theory host surface choice
- why:
  - it is the smallest shared host-selection seam still split between a canonical helper and a consumer-local fallback rule
  - it keeps the target canonical and only centralizes which host surface should receive that target
  - centralizing it does not redesign flow ownership or route framework behavior

## Post-R294 Re-audit

- already canonical:
  - module target -> theory host surface choice
  - World 1 pack target -> foundations runner host choice
  - session target -> session drill player host choice
- partial but intentionally deferred:
  - theory session -> table-practice runner host choice
  - dev shortcut target -> debug host choice
- too broad for now:
  - start / continue target -> map shell choice
- next bounded seam:
  - none cleanly separable after R294
- reason:
  - the remaining candidates are either single-surface theory-local behavior, debug-only bootstrap behavior, or broader shell-routing decisions rather than another shared canonical target -> host-surface seam

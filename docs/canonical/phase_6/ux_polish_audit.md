# UX Polish Audit - SSOT (Phase 6.3)

## 1) Scope and principles
- Audit only: identify UX friction and flow quality across core journey.
- No changes to UI, visuals, content, or telemetry are defined here.
- Use existing screens, services, and flow contracts from Phase 6.1 and 6.2.

## 2) Critical flows audited
- Entry: `main_navigation_screen.dart` / `main_menu_screen.dart` -> pack list (`training_pack_screen.dart` or `training_pack_template_list_screen.dart` or `module_catalog_screen.dart`).
- Session: `training_session_screen.dart` main loop and in-session navigation.
- Result: `training_session_completion_screen.dart` / `session_result_screen.dart`.
- Return: retry same pack, choose another pack, or return home.

## 3) Friction inventory (no solutions)
Entry
- Multiple entry surfaces to training packs may split user focus. [Medium]
- Pack selection context may be unclear between list surfaces. [Medium]

Session
- Exit confirmation may interrupt flow when used frequently. [Low]
- Session completion path differs for endless vs pack-based flow. [Medium]
- In-session navigation (next/prev) can create uncertainty about progress. [Medium]

Result
- Result surfaces differ between completion and session result screens. [Medium]
- Retry mistakes prompt may divert from the completion moment. [Low]

Return
- Multiple return targets (retry, choose pack, home) may dilute the default path. [Low]

## 4) Severity and priority
- High: none identified in current audit scope.
- Medium: pack entry surface split; session completion path variance; progress clarity; result surface variance.
- Low: exit confirmation friction; retry mistakes prompt timing; return target multiplicity.

## 5) Fatigue and overload checks
- Cognitive load increases when the user must choose among multiple training entry surfaces.
- Decision fatigue risk if the user is repeatedly asked to confirm exits or choose next actions after completion.
- Visual/context switching risk between different result screens in a single journey.

## 6) Guardrails
- No new screens or navigation paths.
- No visual redesign or component changes (handled in Phase 6.2 only).
- No content or pedagogy changes (handled in Phase 6.4+).
- No new telemetry or behavioral logic.

## 7) Exit criteria
- Friction inventory is complete and tied to existing screens/states.
- Severity tags are assigned for each listed item.
- The audit is sufficient for a scoped implementation plan without adding new features.

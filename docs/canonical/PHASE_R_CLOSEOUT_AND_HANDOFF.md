# Phase R Closeout, Freeze, and Handoff

## 1) Phase R scope
- Responsible for stabilizing foundational systems for the 0.1 App Store release (app bootstrap wiring, onboarding stability, bounded release-gate smoke tests, non-blocking localization tooling, and crash hardening).<br>
- Out of scope: new features, new services/managers, AI/ML work, gameplay logic changes, or release-track refactors beyond direct blockers.

## 2) Completed items
- Onboarding crash fix (providers + AppBootstrap init in `lib/main.dart`, `lib/onboarding/onboarding_flow_manager.dart`) ensures training sessions can launch without ProviderNotFound/registry issues.<br>
- Firebase macOS guard: `lib/main.dart` only calls `Firebase.initializeApp` on iOS/Android/web and logs failures, so unsupported platforms no longer crash hard when `GoogleService-Info.plist` is missing.<br>
- Localization gating: `l10n.yaml` now writes `l10n_untranslated_report.txt` plus `.gitignore` ignores that report, preventing interactive prompts and workspace pollution during `flutter gen-l10n`.<br>
- Bounded smoke runner `tool/dev/run_flutter_tests.sh` (via `./run_flutter_tests.sh`) defines deterministic smoke list (two UI_v2 simulation tests) and is now the default gate across scripts (`verify_and_log.sh`, `diagnose_tests.sh`).<br>
- Game-feel + UI polish contained in `lib/ui_v2/screens/*` + `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` + `lib/ui_v2/session/ui_v2_session_result_screen.dart` + `lib/module_summary...` etc. (see `docs/canonical/phase_r/VISUAL_LIFT_AUDIT_R2.md`).

## 3) Canonical verification commands
- Default release gate: `./verify_and_log.sh` (internally runs `./run_flutter_tests.sh` bounded smoke suite plus format/analyze).<br>
- Manual deep verification: `flutter test` (full suite) only when manually required; not part of automated gate, call explicitly when investigating new tests or golden updates.

## 4) Known open issues
- OPEN: reported app crashes (details unknown) — needs repro + stacktrace before Phase R can reopen; logging hooks now capture stacktraces (`lib/main.dart`).

## 5) Phase Freeze Rules
- No new runtime systems (services, managers, gameplay logic, AI) may be merged while Phase R is closed.<br>
- Gate scripts must continue using the bounded smoke runner; any gate flake reopens Phase R for investigation.<br>
- Crash regressions with stacktraces or unreproed gates require reopening Phase R for triage (stacktrace recorded by new handlers in `lib/main.dart`).

## 6) Handoff to Phase 3 — Campaign & Progression
- Next goal: verify/reuse the progress map and campaign surfaces as the Phase 3 World Map entrypoint with unlock gating and refreshed visuals.<br>
- Entry criteria: Phase R closeout doc approved + bounded gate stable (`./verify_and_log.sh` working).<br>
- Guardrails: feature freeze remains; do not introduce new games, systems, or backend flows beyond the approved Phase 3 scope.

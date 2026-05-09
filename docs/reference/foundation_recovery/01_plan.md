# Recovery Plan

1. P0 – Clean up `glass_player_seat.dart` so the unmatched parenthesis is fixed and the widget tree compiles.
2. P0 – Gate or finish `tier_b_preflight_merged_v1.dart` so its syntax errors no longer block compilation while keeping unfinished features isolated.
3. P0 – Replace the Firebase dependency in `firebase_lite_telemetry_service.dart` with a `NullTelemetry` fallback/conditional import to regain a pure Dart build path.
4. P0 – Verify that `lib/main.dart` and `lib/ui_v2/app_root.dart` compile now that the preceding blockers are resolved, ensuring `flutter run` can launch.
5. P1 – Once the runtime path is restored, run `flutter analyze` and the specified `flutter test` suites, addressing any remaining critical issues surfaced.

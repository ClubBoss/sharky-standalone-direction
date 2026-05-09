# Current Blockers

1. (P0) Syntax error in `lib/ui_v2/widgets/visual/glass_player_seat.dart` due to an unmatched `)` that prevents the build from parsing.
2. (P0) Syntax issues in `lib/ui_v2/persona/tier_b_preflight_merged_v1.dart` cause Dart analysis/build failures; gate the incomplete feature to restore compilation.
3. (P0) `lib/services/firebase_lite_telemetry_service.dart` hard-depends on `firebase_analytics`, which is unavailable—needs a null telemetry stub or conditional import so the app can compile without Firebase.
4. (P0) `lib/main.dart` + `lib/ui_v2/app_root.dart` cannot materialize a runnable Flutter app until the above blockers are cleared.

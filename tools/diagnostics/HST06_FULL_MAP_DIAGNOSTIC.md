# Preserved HST full-map diagnostic

This never-accepted diagnostic was included in the first draft of PR #450. The independently verified paired control on the same composition shows four progress envelope additions in BOTH no-HST and HST arms. Therefore the universal full-map equality assertion is not a valid HST-specific acceptance criterion. It remains reproducible here, unchanged except its fixture import path; this is not a claimed product fix or a waived gate.

Run explicitly when admitted: `flutter test --no-pub --concurrency=1 test/diagnostics/hst06_full_map_diagnostic.dart`. Expect the historical full-map RED.

The normal paired regression remains `test/ui_v2/hst06_approot_remount_control_test.dart`; its assertions are unchanged. Its shared helper method bodies were copied byte-for-byte into `test/support/hst06_approot_journey_helpers.dart`. No accepted test, CI configuration, scorecard, or protected gate was changed.

Original diagnostic SHA-256: 72432e09d5f114f213acfcab0353890e00d3af262c70073e8398a034dd6de5d5

The diagnostic is retained under test/diagnostics (without the _test.dart discovery suffix) so test-only SharedPreferences APIs remain within their declared scope.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'session drill player hosts world1 campaign packs through the canonical world1 host adapter',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'world1_spine_campaign_v1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SessionDrillPlayerV1Screen), findsOneWidget);
      expect(find.byType(World1CanonicalHostAdapterV1), findsOneWidget);
      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 200));
    },
  );
}

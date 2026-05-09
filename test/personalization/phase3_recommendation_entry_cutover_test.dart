import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/home/personalization_next_action_hint.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('phase3 recommendation enters canonical launcher API', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(
            loader: () async => const PersonalizationNextActionData(
              action: 'run_phase3',
              reason: 'phase3 cutover test',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Run recommended next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(CanonicalLauncherV1), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

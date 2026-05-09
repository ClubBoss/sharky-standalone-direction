import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/home/personalization_next_action_hint.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('phase1 recommendation enters canonical launcher API', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(
            loader: () async => const PersonalizationNextActionData(
              action: 'run_phase1',
              reason: 'test',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Run recommended next'));
    await tester.pumpAndSettle();

    expect(find.byType(CanonicalLauncherV1), findsOneWidget);
  });
}

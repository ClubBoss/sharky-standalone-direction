// Run with: flutter test test/personalization/personalization_next_action_hint_test.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/home/personalization_next_action_hint.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows bootstrap CTA when loader returns null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(loader: _nullLoader),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Run recommended next'), findsOneWidget);
    expect(
      find.textContaining('bootstrap default path for cold start'),
      findsOneWidget,
    );
  });

  testWidgets('uses loader data when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(loader: _customLoader),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Repeat Phase 2'), findsOneWidget);
    expect(find.textContaining('custom reason'), findsOneWidget);
  });

  testWidgets('invalid artifact falls back to phase2 fallback reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(loader: _invalidLoader),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Run recommended next'), findsOneWidget);
    expect(find.textContaining('phase2 safety net fallback'), findsOneWidget);
  });

  testWidgets('focus label biases recommendation once', (tester) async {
    SharedPreferences.setMockInitialValues({'lesson_focus_label_v1': 'sizing'});
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(
            key: UniqueKey(),
            loader: _phase3Loader,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Repeat Phase 2'), findsOneWidget);
    expect(find.textContaining('focus signal'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('lesson_focus_label_v1'), isNull);
    final state =
        tester.state(find.byType(PersonalizationNextActionHint)) as dynamic;
    expect(state.debugFocusConsumed, isTrue);
    expect(state.debugFocusMappingHit, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(loader: _phase3Loader),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('focus signal'), findsNothing);
    expect(find.textContaining('baseline'), findsOneWidget);
    final stateSecond =
        tester.state(find.byType(PersonalizationNextActionHint)) as dynamic;
    expect(stateSecond.debugFocusConsumed, isFalse);
    expect(stateSecond.debugFocusMappingHit, isFalse);
  });

  testWidgets('unknown focus label keeps baseline', (tester) async {
    SharedPreferences.setMockInitialValues({
      'lesson_focus_label_v1': 'unknown',
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PersonalizationNextActionHint(loader: _phase3Loader),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Run Phase 3'), findsOneWidget);
    final state =
        tester.state(find.byType(PersonalizationNextActionHint)) as dynamic;
    expect(state.debugFocusConsumed, isTrue);
    expect(state.debugFocusMappingHit, isFalse);
  });

  test('lesson focus bridge close marker present', () {
    final source = File(
      'lib/ui_v2/home/personalization_next_action_hint.dart',
    ).readAsStringSync();
    expect(
      source.contains(
        'Lesson Focus Bridge v1: closed (changes require new phase decision).',
      ),
      isTrue,
    );
  });
}

Future<PersonalizationNextActionData?> _nullLoader() async => null;

Future<PersonalizationNextActionData?> _customLoader() async =>
    const PersonalizationNextActionData(
      action: 'run_phase2',
      reason: 'custom reason',
    );

Future<PersonalizationNextActionData?> _invalidLoader() async =>
    const PersonalizationNextActionData(
      action: 'unknown_action',
      reason: 'invalid artifact',
    );

Future<PersonalizationNextActionData?> _phase3Loader() async =>
    const PersonalizationNextActionData(
      action: 'run_phase3',
      reason: 'baseline',
    );

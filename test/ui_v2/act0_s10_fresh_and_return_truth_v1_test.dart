import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// S10: real boot path (no seeded sample), real persisted snapshot. A brand-new
// learner sees one honest first action and zero earned proof; a returning
// learner sees only what the saved record supports after a cold remount.
void main() {
  const progressKey = 'act0_shell_progress_v1';

  Future<void> size(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openYou(WidgetTester tester) async {
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
  }

  testWidgets('brand-new learner: one honest action, no earned proof', (
    tester,
  ) async {
    await size(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          showPlacementOnStart: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final key in const [
      'act0_shell_placement_intro_cta',
      'act0_shell_placement_option_new',
      'act0_shell_placement_next_cta',
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }
    final welcomeCta = find.byKey(const Key('act0_shell_welcome_primary_cta'));
    await tester.tap(welcomeCta);
    await tester.pumpAndSettle();
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final correct = runner.runner.options.firstWhere((o) => o.isCorrect);
    await tester.tap(find.byKey(Key('act0_shell_option_${correct.id}')));
    await tester.pumpAndSettle();
    await tester.tap(welcomeCta);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_main_cta')), findsOneWidget);
    expect(find.text('Start first hand'), findsOneWidget);
    expect(find.text('0 of 9 lessons complete'), findsOneWidget);
    expect(find.textContaining('Route proof is active'), findsNothing);

    await openYou(tester);
    expect(find.text('0 tasks complete'), findsOneWidget);
    expect(find.textContaining('Recent proof'), findsNothing);
    expect(find.textContaining('Account'), findsNothing);
  });

  testWidgets('returning learner: saved facts survive cold remount, no mastery '
      'claim', (tester) async {
    await size(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{
      progressKey: jsonEncode(<String, Object?>{
        'schemaVersion': 17,
        'completedTaskIds': <String>[
          'what_poker_is_find_hero',
          'what_poker_is_theory',
        ],
        'skippedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'what_poker_is',
        'selectedTaskId': 'what_poker_is_find_hero',
        'earnedXp': 30,
        'profileSkillValues': <String, int>{'Table sense': 41},
        'recentSkillGains': <Object>[
          <String, Object>{
            'label': 'Table sense',
            'gain': 3,
            'source': 'Find the hero',
          },
        ],
        'dailyCompletedRepCount': 0,
        'retentionMemory': <Object>[],
        'openRepairIntents': <Object>[],
        'repairOutcomeProjection': <Object>[],
        'reviewResolutionReceipts': <Object>[],
        'reviewMistakeHistory': <Object>[],
        'learningEvidenceHistory': <Object>[],
      }),
    });
    for (var launch = 0; launch < 2; launch++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            key: UniqueKey(),
            showPlacementOnStart: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('0 of 9 lessons complete'), findsOneWidget);
      await openYou(tester);
      expect(find.text('2 tasks complete'), findsOneWidget);
      expect(find.text('1 growing'), findsOneWidget);
      expect(find.text('From Find the hero'), findsOneWidget);
      expect(find.textContaining('master'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }
  });
}

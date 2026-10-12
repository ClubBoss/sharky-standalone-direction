import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// S10: the You-tab "Intro & placement" entry must only promise what retake
// actually preserves. Real preview screen + real persisted snapshot.
void main() {
  const progressKey = 'act0_shell_progress_v1';

  testWidgets('retake placement keeps lessons/XP, re-measures skill meters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

    await tester.pumpWidget(
      const MaterialApp(
        home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('You'));
    await tester.pumpAndSettle();
    final tools = find.byKey(
      const Key('act0_shell_profile_first_start_tools_button'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      tools,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(tools);
    await tester.pumpAndSettle();
    await tester.tap(tools);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('act0_shell_profile_retake_placement')),
    );
    await tester.pumpAndSettle();

    final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
    state.debugPersistProgressV1();
    await tester.pump(const Duration(milliseconds: 250));
    final prefs = await SharedPreferences.getInstance();
    final persisted =
        jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;

    // Survives retake.
    expect(
      persisted['completedTaskIds'],
      containsAll(<String>['what_poker_is_find_hero', 'what_poker_is_theory']),
    );
    expect(persisted['earnedXp'], 30);
    // Documented behavior: skill meters are cleared until placement re-seeds.
    expect(persisted['profileSkillValues'], isEmpty);
    expect(persisted['recentSkillGains'], isEmpty);
  });
}

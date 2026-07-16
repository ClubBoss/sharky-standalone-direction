import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  const progressKey = 'act0_shell_progress_v1';

  Widget host() => const MaterialApp(
    home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
  );

  testWidgets('Act0 persistence restores a deterministic current snapshot', (
    tester,
  ) async {
    final snapshot = <String, Object>{
      'schemaVersion': 16,
      'completedTaskIds': <String>['actions_terms_intro'],
      'skippedTaskIds': <String>[],
      'completedLessonIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': 'fold_check_call_raise',
      'selectedTaskId': 'actions_check_drill',
      'earnedXp': 10,
      'sessionIdentityState': <String, Object>{
        'schemaVersion': 1,
        'nextSessionOrdinal': 3,
        'currentSession': <String, Object>{
          'schemaVersion': 1,
          'sessionId': 'session_v1|2',
          'startedAtOrder': 4,
          'startedWorldId': 'world_1',
          'startedLessonId': 'fold_check_call_raise',
          'status': 'active',
        },
      },
      'reviewMistakeHistory': <Object>[],
      'reviewResolutionReceipts': <Object>[],
      'learningEvidenceHistory': <Object>[],
      'conceptFamilyStateHistory': <Object>[],
      'repairOutcomeProjection': <String, Object>{'schemaVersion': 1},
      'openRepairIntents': <Object>[],
      'multiRepairQueue': <String, Object>{
        'schemaVersion': 1,
        'items': <Object>[],
      },
    };
    SharedPreferences.setMockInitialValues(<String, Object>{
      progressKey: jsonEncode(snapshot),
    });

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final firstLoad =
        jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
    expect(firstLoad['selectedWorldId'], 'world_1');
    expect(firstLoad['selectedLessonId'], 'fold_check_call_raise');
    expect(firstLoad['selectedTaskId'], 'actions_check_drill');
    expect(
      firstLoad['sessionIdentityState']['currentSession']['sessionId'],
      'session_v1|2',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    final secondLoad =
        jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
    expect(secondLoad['selectedWorldId'], firstLoad['selectedWorldId']);
    expect(secondLoad['selectedLessonId'], firstLoad['selectedLessonId']);
    expect(secondLoad['selectedTaskId'], firstLoad['selectedTaskId']);
    expect(
      secondLoad['sessionIdentityState']['currentSession']['sessionId'],
      firstLoad['sessionIdentityState']['currentSession']['sessionId'],
      reason: 'a repeated load must not replace the active session identity',
    );
  });

  testWidgets('Act0 ignores corrupt or unsupported persistence safely', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      progressKey: '{bad',
    });
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);

    SharedPreferences.setMockInitialValues(<String, Object>{
      progressKey: jsonEncode(<String, Object>{'schemaVersion': 999}),
    });
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
  });
}

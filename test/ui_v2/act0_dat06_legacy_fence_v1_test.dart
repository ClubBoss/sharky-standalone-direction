import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';

const _key = 'act0_shell_progress_v1';
// Same supported queue fixture as the existing Review consumer controls.
const _item = SessionDrillRecheckLaunchQueueItemV1(
  queueKind: 'session_drill_recheck',
  jobId: 'session_drill_recheck:w6.s01:classify_missed_low_cards_no_draw',
  launchSessionId: 'w6.s01',
  sourceWorldId: 'world_6',
  sourceSessionId: 'w6.s01',
  sourceDrillId: 'classify_missed_overcards_no_draw',
  drillFamilyId: 'range_bucket_board_fit_classifier_v1',
  missedSignalId: 'range_bucket_missed',
  missedSignalLabel: 'Missed range bucket',
  chosenActionId: 'strong',
  expectedActionId: 'missed',
  targetSessionId: 'w6.s01',
  targetDrillId: 'classify_missed_low_cards_no_draw',
  targetKind: 'same_signal_recheck',
  errorClass: 'range_bucket_mismatch',
);
Act0ProgressStoreV1 _store() =>
    Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await _store().flush();
  });
}

Widget _host(
  Future<List<SessionDrillRecheckLaunchQueueItemV1>> Function() loader,
) => MaterialApp(
  home: Act0ShellPreviewScreenV1(
    initialTab: Act0ShellTabV1.review,
    showPlacementOnStart: false,
    debugLoadSessionDrillRecheckQueueItemsV1: loader,
  ),
);
void main() {
  testWidgets(
    'DAT06 positive legacy fixture is visible before a recovery boundary',
    (tester) async {
      _phone(tester);
      final world = Act0ShellStateV1.sample.worlds.first;
      final lesson = world.lessons.first;
      SharedPreferences.setMockInitialValues({
        _key: jsonEncode({
          'schemaVersion': 18,
          'completedTaskIds': [],
          'skippedTaskIds': [],
          'completedLessonIds': [],
          'selectedWorldId': world.worldId,
          'selectedLessonId': lesson.lessonId,
          'selectedTaskId': lesson.taskList.first.taskId,
          'earnedXp': 0,
        }),
      });
      await tester.pumpWidget(_host(() async => [_item]));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Act0ReviewShellV1>(find.byType(Act0ReviewShellV1))
            .sessionDrillRecheckQueueItems
            .single
            .jobId,
        _item.jobId,
      );
    },
  );
  testWidgets(
    'DAT06 late legacy queue and deleted archive cannot resurrect old projection on cold boot',
    (tester) async {
      _phone(tester);
      SharedPreferences.setMockInitialValues({
        _key: 'damaged',
        '${_key}_head': '{invalid',
        '${_key}_recovery': false,
        '${_key}_backup': 41,
        'unrelated': 'keep',
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
      });
      final lateQueue = Completer<List<SessionDrillRecheckLaunchQueueItemV1>>();
      await tester.pumpWidget(_host(() => lateQueue.future));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_recovery_confirm')));
      await tester.pumpAndSettle();
      lateQueue.complete([_item]);
      await tester.pumpAndSettle();
      final nav = find.byKey(const Key('act0_shell_bottom_nav'));
      await tester.tap(find.descendant(of: nav, matching: find.text('Review')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Act0ReviewShellV1>(find.byType(Act0ReviewShellV1))
            .sessionDrillRecheckQueueItems,
        isEmpty,
      );
      final dynamic runtime = tester.state(
        find.byType(Act0ShellPreviewScreenV1),
      );
      runtime.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 300));
      await _store().flush();
      final beforeDelete = jsonDecode((await _store().load())!) as Map;
      expect(beforeDelete['suppressLegacyRecheckAfterRecovery'], true);
      expect(beforeDelete['earnedXp'], 0);
      expect(
        await _store().deleteRecoveryCopy(await _store().inspectRecoveryCopy()),
        true,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await _store().flush();
      await tester.pumpWidget(_host(() async => [_item]));
      await tester.pumpAndSettle();
      final review = tester.widget<Act0ReviewShellV1>(
        find.byType(Act0ReviewShellV1),
      );
      expect(review.sessionDrillRecheckQueueItems, isEmpty);
      final cold = jsonDecode((await _store().load())!) as Map;
      expect(cold['suppressLegacyRecheckAfterRecovery'], true);
      expect(cold['completedTaskIds'], isEmpty);
      expect(
        (await SharedPreferences.getInstance()).getString('unrelated'),
        'keep',
      );
    },
  );
}

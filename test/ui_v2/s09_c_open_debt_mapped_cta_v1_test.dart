import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Native QA learner C finished W1 with the original W1 miss already repaired
/// (retention `fixedRecent`) while the W1->W3 repair intent stayed persisted.
/// The fixture is that learner's exact saved state (disposable QA simulator).
const _fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';

enum _Debt { fixedSourceMappedOwed, sourceStillOpen, mappedResolved }

Future<dynamic> _pumpRoot(
  WidgetTester tester, {
  required _Debt debt,
  DateTime? now,
  String? encodedProgress,
}) async {
  final raw =
      jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
  final progress =
      jsonDecode(encodedProgress ?? raw['act0_shell_progress_v1'] as String)
          as Map<String, dynamic>;
  if (encodedProgress == null) {
    if (debt == _Debt.sourceStillOpen) {
      for (final entry
          in (progress['retentionMemory'] as List)
              .cast<Map<String, dynamic>>()) {
        entry['status'] = 'openRepair';
      }
    } else if (debt == _Debt.mappedResolved) {
      progress['openRepairIntents'] = <Object>[];
      (progress['multiRepairQueue'] as Map<String, dynamic>)['entries'] =
          <Object>[];
    } else {
      final unrelatedIntent = <String, Object>{
        'schemaVersion': 1,
        'sourceWorldId': 'world_1',
        'sourceLessonId': 'what_poker_is',
        'sourceTaskId': 'what_poker_is_table_read_recheck',
        'choiceId': 'two_three_four',
        'result': 'incorrect',
        'errorType': 'confused_table_identity',
        'missedSignalId': 'hero_cards_board_pot',
        'missedSignalLabel': 'Cards, board, and pot',
        'skillAtomId': 'table_read',
        'skillLabel': 'Table read',
        'targetWorldId': 'world_1',
        'targetLessonId': 'what_poker_is',
        'targetTaskId': 'what_poker_is_table_read_transfer',
        'mappingType': 'repair',
        'reasonCode': 'same_signal_table_read_hero_cards_board_pot',
      };
      (progress['openRepairIntents'] as List).add(unrelatedIntent);
      progress['multiRepairQueue'] = null;
    }
  }
  raw['act0_shell_progress_v1'] = encodedProgress ?? jsonEncode(progress);
  SharedPreferences.setMockInitialValues(<String, Object>{
    for (final e in raw.entries) e.key: e.value as Object,
  });
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: false,
        clock: now == null
            ? const Act0SystemUtcClockV1()
            : Act0FixedUtcClockV1(now),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.state(find.byType(Act0ShellPreviewScreenV1));
}

Future<List<String>> _tabTexts(WidgetTester tester, String tab) async {
  final tabFinder = find.text(tab).last;
  await tester.ensureVisible(tabFinder);
  await tester.tap(tabFinder);
  await tester.pumpAndSettle();
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data)
      .whereType<String>()
      .toList();
}

const _target = 'position_six_seats_position_repair_seat_id_btn';

Map<String, dynamic> _queueEntry(String encodedProgress, String sourceTaskId) {
  final progress = jsonDecode(encodedProgress) as Map<String, dynamic>;
  final queue = progress['multiRepairQueue'] as Map<String, dynamic>;
  return (queue['entries'] as List).cast<Map<String, dynamic>>().singleWhere(
    (entry) => entry['sourceTaskId'] == sourceTaskId,
  );
}

void _expectRestoredW1AndUnrelatedDebt(dynamic root) {
  expect(root.debugOpenRepairIntentCountV1(), 2);
  final w1 =
      root.debugOpenRepairIntentPayloadForSourceTaskV1(
            'what_poker_is_find_hero',
          )
          as Map<String, Object?>?;
  expect(w1, isNotNull);
  expect(w1?['sourceWorldId'], 'world_1');
  expect(w1?['sourceLessonId'], 'what_poker_is');
  expect(w1?['sourceTaskId'], 'what_poker_is_find_hero');
  expect(w1?['choiceId'], 'top');
  expect(w1?['result'], 'incorrect');
  expect(w1?['errorType'], 'confused_table_identity');
  expect(w1?['missedSignalId'], 'hero_button');
  expect(w1?['missedSignalLabel'], 'Hero on the Button');
  expect(w1?['skillAtomId'], 'table_position_read');
  expect(w1?['targetWorldId'], 'world_3');
  expect(w1?['targetLessonId'], 'position_six_seats');
  expect(w1?['targetTaskId'], _target);
  expect(w1?['mappingType'], 'repair');
  expect(w1?['reasonCode'], 'same_signal_table_position_read_hero_button');
  final unrelated =
      root.debugOpenRepairIntentPayloadForSourceTaskV1(
            'what_poker_is_table_read_recheck',
          )
          as Map<String, Object?>?;
  expect(unrelated?['sourceTaskId'], 'what_poker_is_table_read_recheck');
  expect(unrelated?['missedSignalId'], 'hero_cards_board_pot');
  expect(unrelated?['targetTaskId'], 'what_poker_is_table_read_transfer');
}

void main() {
  testWidgets(
    'fixedRecent source + owed mapped W3: Home/Review/Practice agree',
    (tester) async {
      var root = await _pumpRoot(tester, debt: _Debt.fixedSourceMappedOwed);
      final handoff =
          root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      expect(handoff['selectionSource'], 'repair_intent_mapped');
      expect(handoff['sourceTaskId'], 'what_poker_is_find_hero');
      expect(handoff['targetWorldId'], 'world_3');
      expect(handoff['targetLessonId'], 'position_six_seats');
      expect(handoff['targetTaskId'], _target);
      _expectRestoredW1AndUnrelatedDebt(root);

      root.debugPersistProgressV1();
      await tester.pumpAndSettle();
      var persistedProgress = (await SharedPreferences.getInstance()).getString(
        'act0_shell_progress_v1',
      )!;
      final firstW1QueueEntry = _queueEntry(
        persistedProgress,
        'what_poker_is_find_hero',
      );
      expect(firstW1QueueEntry['repairIntent']['targetTaskId'], _target);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      root = await _pumpRoot(
        tester,
        debt: _Debt.fixedSourceMappedOwed,
        encodedProgress: persistedProgress,
      );
      _expectRestoredW1AndUnrelatedDebt(root);
      root.debugPersistProgressV1();
      await tester.pumpAndSettle();
      persistedProgress = (await SharedPreferences.getInstance()).getString(
        'act0_shell_progress_v1',
      )!;
      final secondW1QueueEntry = _queueEntry(
        persistedProgress,
        'what_poker_is_find_hero',
      );
      for (final key in [
        'queueItemId',
        'sourceRepairIdentity',
        'createdAtOrder',
        'attemptCount',
      ]) {
        expect(secondW1QueueEntry[key], firstW1QueueEntry[key], reason: key);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      root = await _pumpRoot(
        tester,
        debt: _Debt.fixedSourceMappedOwed,
        encodedProgress: persistedProgress,
      );
      _expectRestoredW1AndUnrelatedDebt(root);
      final home =
          root.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>;
      for (final key in [
        'sourceTaskId',
        'targetTaskId',
        'selectionSource',
        'reasonCode',
      ]) {
        expect(handoff[key], home[key]);
      }
      expect(root.debugHomeNextUsefulHandReasonLineV1(), isNotNull);

      final practice = await _tabTexts(tester, 'Practice');
      expect(practice, contains('Active repair first'));
      final review = await _tabTexts(tester, 'Review');
      expect(review, contains('SAME CLUE, NEW SPOT STILL OWED'));
      expect(review, isNot(contains('MISS TO REPAIR')));
      expect(
        find.byKey(const Key('act0_shell_review_source_retried_note')),
        findsOneWidget,
      );
      // The repaired source is never presented as an uncorrected miss.
      expect(review, isNot(contains('You chose')));
      final practiceCta = find.byKey(
        const Key('act0_shell_review_practice_cta'),
      );
      await tester.ensureVisible(practiceCta);
      await tester.pumpAndSettle();
      await tester.tap(practiceCta);
      await tester.pumpAndSettle();
      expect(root.debugSelectedTaskIdV1(), _target);
    },
  );

  testWidgets(
    'same learner with the mapped W3 resolved: nothing pending after restart',
    (tester) async {
      final root = await _pumpRoot(
        tester,
        debt: _Debt.mappedResolved,
        now: DateTime.utc(2026, 10, 12, 13),
      );
      final handoff =
          root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      expect(handoff['selectionSource'], 'existing_fallback');
      expect(root.debugHomeNextUsefulHandReasonLineV1(), isNull);
      final practice = await _tabTexts(tester, 'Practice');
      expect(practice, isNot(contains('Active repair first')));
      final review = await _tabTexts(tester, 'Review');
      expect(review, isNot(contains('SAME CLUE, NEW SPOT STILL OWED')));
      expect(
        review,
        contains(
          'Nothing else is due. Misses land here the moment they happen.',
        ),
      );
    },
  );

  testWidgets('same learner with the debt still open gets the BTN repair CTA', (
    tester,
  ) async {
    final root = await _pumpRoot(tester, debt: _Debt.sourceStillOpen);
    final handoff =
        root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
    expect(handoff['selectionSource'], 'repair_intent_mapped');
    expect(handoff['sourceTaskId'], 'what_poker_is_find_hero');
    expect(handoff['targetWorldId'], 'world_3');
    expect(handoff['targetLessonId'], 'position_six_seats');
    expect(handoff['targetTaskId'], _target);
    final home =
        root.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>;
    for (final key in [
      'sourceTaskId',
      'targetWorldId',
      'targetLessonId',
      'targetTaskId',
      'selectionSource',
      'reasonCode',
    ]) {
      expect(handoff[key], home[key], reason: 'Summary/Home differ at $key');
    }
  });
}

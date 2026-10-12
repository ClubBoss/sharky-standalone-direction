import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Native QA learner C finished W1 with the original W1 miss already repaired
/// (retention `fixedRecent`) while the W1->W3 repair intent stayed persisted.
/// The fixture is that learner's exact saved state (disposable QA simulator).
const _fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';

enum _Debt { fixedSourceMappedOwed, sourceStillOpen, mappedResolved }

Future<dynamic> _pumpRoot(WidgetTester tester, {required _Debt debt}) async {
  final raw =
      jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
  final progress =
      jsonDecode(raw['act0_shell_progress_v1'] as String)
          as Map<String, dynamic>;
  if (debt == _Debt.sourceStillOpen) {
    for (final entry
        in (progress['retentionMemory'] as List).cast<Map<String, dynamic>>()) {
      entry['status'] = 'openRepair';
    }
  } else if (debt == _Debt.mappedResolved) {
    progress['openRepairIntents'] = <Object>[];
    (progress['multiRepairQueue'] as Map<String, dynamic>)['entries'] =
        <Object>[];
  }
  raw['act0_shell_progress_v1'] = jsonEncode(progress);
  SharedPreferences.setMockInitialValues(<String, Object>{
    for (final e in raw.entries) e.key: e.value as Object,
  });
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.state(find.byType(Act0ShellPreviewScreenV1));
}

Future<List<String>> _tabTexts(WidgetTester tester, String tab) async {
  await tester.tap(find.text(tab).last);
  await tester.pumpAndSettle();
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data)
      .whereType<String>()
      .toList();
}

const _target = 'position_checkpoint_position_checkpoint_table_notice';

void main() {
  testWidgets(
    'fixedRecent source + owed mapped W3: Home/Review/Practice agree',
    (tester) async {
      final root = await _pumpRoot(tester, debt: _Debt.fixedSourceMappedOwed);
      final handoff =
          root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      expect(handoff['selectionSource'], 'repair_intent_mapped');
      expect(handoff['sourceTaskId'], 'what_poker_is_find_hero');
      expect(handoff['targetWorldId'], 'world_3');
      expect(handoff['targetLessonId'], 'position_checkpoint');
      expect(handoff['targetTaskId'], _target);
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
      await tester.tap(find.byKey(const Key('act0_shell_review_practice_cta')));
      await tester.pumpAndSettle();
      expect(root.debugSelectedTaskIdV1(), _target);
    },
  );

  testWidgets(
    'same learner with the mapped W3 resolved: nothing pending after restart',
    (tester) async {
      final root = await _pumpRoot(tester, debt: _Debt.mappedResolved);
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

  testWidgets('same learner with the debt still open gets the mapped W3 CTA', (
    tester,
  ) async {
    final root = await _pumpRoot(tester, debt: _Debt.sourceStillOpen);
    final handoff =
        root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
    expect(handoff['selectionSource'], 'repair_intent_mapped');
    expect(handoff['sourceTaskId'], 'what_poker_is_find_hero');
    expect(handoff['targetWorldId'], 'world_3');
    expect(handoff['targetLessonId'], 'position_checkpoint');
    expect(
      handoff['targetTaskId'],
      'position_checkpoint_position_checkpoint_table_notice',
    );
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

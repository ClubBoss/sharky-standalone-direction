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

Future<dynamic> _pumpRoot(
  WidgetTester tester, {
  required bool debtStillOpen,
}) async {
  final raw =
      jsonDecode(File(_fixture).readAsStringSync()) as Map<String, dynamic>;
  if (debtStillOpen) {
    final progress =
        jsonDecode(raw['act0_shell_progress_v1'] as String)
            as Map<String, dynamic>;
    final memory = (progress['retentionMemory'] as List)
        .cast<Map<String, dynamic>>();
    for (final entry in memory) {
      entry['status'] = 'openRepair';
    }
    raw['act0_shell_progress_v1'] = jsonEncode(progress);
  }
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

void main() {
  testWidgets('same learner with the debt still open gets the mapped W3 CTA', (
    tester,
  ) async {
    final root = await _pumpRoot(tester, debtStillOpen: true);
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

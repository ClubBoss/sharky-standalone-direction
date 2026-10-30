// #338 learner trust: the lesson wrap-up ("One last check") revisits misses
// that are still owed. A miss the learner already corrected through an
// unassisted original-source recheck must not be revisited again, while an
// assisted recheck and a failed recheck keep the wrap-up. Historical mistake
// records and evidence stay intact either way.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'act0_teaching_integrity_harness_v1.dart';

const _source = 'your_first_hand_private_cards_recheck';
const _lastTask = 'your_first_hand_recap';

void main() {
  testWidgets('unassisted original-source recheck resolves the wrap-up', (
    tester,
  ) async {
    await _missThenReachSourceRecheck(tester);
    expect(_wrapUpOwed(tester), [_source]);
    await _answerOption(tester, 'ace_king');
    await _continueFeedback(tester);
    expect(_wrapUpOwed(tester), isEmpty);

    expect(await _playToLessonEnd(tester), isFalse);
    expect(find.text('One last check'), findsNothing);
    expect(_activeTaskId(tester), isNot(_source));

    final progress = await _progress();
    final records = (progress['learningEvidenceHistory'] as List)
        .cast<Map<String, dynamic>>()
        .where((r) => r['taskId'] == _source)
        .toList();
    // The historical miss and the independent recheck are both kept.
    expect(records.map((r) => r['choiceId']), ['queen_queen', 'ace_king']);
    expect(records.last['reviewKind'], 'originalSourceRecheck');
    expect(records.last['assistanceKind'], 'none');
    expect(
      (progress['reviewMistakeHistory'] as List).any(
        (m) => (m as Map)['sourceTaskId'] == _source,
      ),
      isTrue,
    );
    expect(progress['openRepairIntents'], isEmpty);
    expect(
      (progress['completedTaskIds'] as List).where((id) => id == _source),
      hasLength(1),
    );

    // Provenance: answers after the recheck share its run (runKind=recheck)
    // but are unseen transfers. Only the one original-source record counts as
    // a source recheck, and only repair-run answers earn repair credit.
    final all = (progress['learningEvidenceHistory'] as List)
        .cast<Map<String, dynamic>>();
    expect(
      all.where((r) => r['reviewKind'] == 'originalSourceRecheck'),
      hasLength(1),
    );
    final recheckRun = all.where((r) => r['runKind'] == 'recheck').toList();
    expect(recheckRun.length, greaterThan(1));
    expect(recheckRun.skip(1).map((r) => r['reviewKind']).toSet(), {
      'unseenTransfer',
    });
    final state =
        tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
    final families = (state.debugConceptFamilyStatePayloadV1() as List)
        .cast<Map<String, Object?>>();
    final repairCredit = families.fold<int>(
      0,
      (sum, f) => sum + (f['successfulRepairCount'] as int? ?? 0),
    );
    expect(repairCredit, greaterThan(0));
    expect(
      repairCredit,
      all
          .where(
            (r) =>
                r['runKind'] == 'repair' &&
                r['isCorrect'] == true &&
                r['assistanceKind'] == 'none',
          )
          .length,
    );
  });

  testWidgets('failed original-source recheck keeps the wrap-up owed', (
    tester,
  ) async {
    await _missThenReachSourceRecheck(tester);
    await _answerOption(tester, 'queen_queen');
    await _continueFeedback(tester);
    expect(_wrapUpOwed(tester), [_source]);
    final progress = await _progress();
    expect(
      (progress['learningEvidenceHistory'] as List)
          .cast<Map<String, dynamic>>()
          .where((r) => r['taskId'] == _source)
          .map((r) => r['choiceId']),
      ['queen_queen', 'queen_queen'],
    );
  });

  testWidgets('assisted original-source recheck keeps the wrap-up owed', (
    tester,
  ) async {
    await _missThenReachSourceRecheck(tester);
    final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
    expect(hint, findsOneWidget);
    await tester.ensureVisible(hint);
    await tester.tap(hint);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_hint_body')), findsOneWidget);
    final close = find.byKey(const Key('act0_shell_theory_recall_close_cta'));
    if (close.evaluate().isNotEmpty) {
      await tester.tap(close);
      await tester.pumpAndSettle();
    }
    await _answerOption(tester, 'ace_king');
    await _continueFeedback(tester);
    expect(_wrapUpOwed(tester), [_source]);
    final progress = await _progress();
    final assisted = (progress['learningEvidenceHistory'] as List)
        .cast<Map<String, dynamic>>()
        .where((r) => r['taskId'] == _source && r['choiceId'] == 'ace_king');
    expect(assisted.single['assistanceKind'], isNot('none'));
  });
}

List<String> _wrapUpOwed(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return (state.debugLessonWrapUpOwedTaskIdsV1() as List).cast<String>();
}

/// The genuine first-hand route through the real preview flow: miss the
/// private-card read, complete the mapped same-signal repair, then return to
/// the original source question.
Future<void> _missThenReachSourceRecheck(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ref = act0TeachingTaskByIdV1(_source);
  // Test-only resume seed: the catalog before this task is complete.
  SharedPreferences.setMockInitialValues(<String, Object>{
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    'act0_shell_progress_v1': jsonEncode(<String, Object>{
      'schemaVersion': 18,
      'completedTaskIds': act0TeachingCatalogV1()
          .takeWhile((r) => r.task.taskId != _source)
          .map((r) => r.task.taskId)
          .toList(),
      'completedLessonIds': <String>[],
      'selectedWorldId': ref.worldId,
      'selectedLessonId': ref.lessonId,
      'selectedTaskId': _source,
      'earnedXp': 0,
      'resumeInRunner': true,
      'resumePhase': 'drill',
      'resumeTeachingStepIndex': 0,
    }),
  });
  await tester.pumpWidget(
    const MaterialApp(
      locale: Locale('en'),
      supportedLocales: <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(_activeTaskId(tester), _source);
  await _advanceToAnswer(tester);
  await _answerOption(tester, 'queen_queen');
  // A card-recognition miss states the true cards; it is not a "better play",
  // and the support line names the cards that were wrongly chosen.
  expect(find.text("Hero's private cards are A and K."), findsOneWidget);
  expect(find.textContaining('better play'), findsNothing);
  expect(find.textContaining("Q and Q are not Hero's cards"), findsOneWidget);
  expect(find.textContaining("Those are not Hero's cards"), findsNothing);
  await _continueFeedback(tester);
  expect(_activeTaskId(tester), 'cards_ranks_suits_private_board');
  await _advanceToAnswer(tester);
  await _answerCorrectly(tester);
  await _continueFeedback(tester);
  expect(_activeTaskId(tester), _source);
  expect(find.byKey(const Key('act0_shell_option_ace_king')), findsOneWidget);
}

Future<void> _advanceToAnswer(WidgetTester tester) async {
  for (var i = 0; i < 8 && !_hasVisibleAnswer(); i++) {
    final cta = find.byKey(const Key('act0_shell_continue_cta'));
    if (cta.evaluate().isEmpty) {
      await tester.pump(const Duration(seconds: 1));
      continue;
    }
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

/// Answers the remaining lesson tasks correctly. Returns whether the lesson
/// wrap-up revisit appeared after the last task.
Future<bool> _playToLessonEnd(WidgetTester tester) async {
  for (var guard = 0; guard < 40; guard++) {
    if (find.text('One last check').evaluate().isNotEmpty) {
      return true;
    }
    final taskId = _activeTaskId(tester);
    if (_hasVisibleAnswer()) {
      await _answerCorrectly(tester);
      await _continueFeedback(tester);
      if (taskId == _lastTask) {
        return find.text('One last check').evaluate().isNotEmpty;
      }
      continue;
    }
    final cta = find.byKey(const Key('act0_shell_continue_cta'));
    if (cta.evaluate().isNotEmpty) {
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(cta);
      await tester.pumpAndSettle();
      continue;
    }
    await tester.pump(const Duration(seconds: 1));
  }
  fail('Lesson did not reach its end.');
}

bool _hasVisibleAnswer() => find
    .byWidgetPredicate((widget) {
      final key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('act0_shell_option_');
    })
    .evaluate()
    .isNotEmpty;

Future<void> _answerOption(WidgetTester tester, String optionId) async {
  final option = find.byKey(Key('act0_shell_option_$optionId'));
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _answerCorrectly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere((option) => option.isCorrect);
  await _answerOption(tester, option.id);
}

Future<void> _continueFeedback(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    if (cta.evaluate().isEmpty) {
      return;
    }
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

String _activeTaskId(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugSelectedTaskIdV1() as String;
}

Future<Map<String, dynamic>> _progress() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString('act0_shell_progress_v1')!)
      as Map<String, dynamic>;
}

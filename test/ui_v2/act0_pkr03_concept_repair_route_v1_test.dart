// Deterministic persisted-root harness; NOT native or natural reachability.
// Only the initial prerequisite/route fixture is controlled. All task records,
// cards, choices, grading and repair/recheck transitions are actual source.
// NOT_RUN by the author: sole integrator owns the serial SDK window.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
final _store = Act0ProgressStoreV1(
  key: _progressKey,
  isValidPayload: (_) => true,
);

void main() {
  for (final route in const [
    (
      world: 'world_12',
      lesson: 'decision_over_outcome',
      source: 'asm05_new_known_holes_turn_call_10',
      wrong: 'fold',
      signal: 'process_over_outcome',
      skill: 'mindset_process_discipline',
      targetWorld: 'world_12',
      targetLesson: 'decision_over_outcome',
      target: 'asm05_new_known_holes_turn_call_40',
    ),
    (
      world: 'world_12',
      lesson: 'decision_over_outcome',
      source: 'asm05_new_known_holes_turn_call_40',
      wrong: 'call',
      signal: 'process_over_outcome',
      skill: 'mindset_process_discipline',
      targetWorld: 'world_12',
      targetLesson: 'decision_over_outcome',
      target: 'asm05_new_known_holes_turn_call_10',
    ),
    (
      world: 'world_6',
      lesson: 'range_board_fit',
      source: 'w6_turn_shift_bucket',
      wrong: 'always_value',
      signal: 'range_bucket_shift',
      skill: 'range_bucket_reasoning',
      targetWorld: 'world_6',
      targetLesson: 'range_pressure_lines',
      target: 'w6_turn_pressure_shift_transfer',
    ),
    (
      world: 'world_6',
      lesson: 'range_pressure_lines',
      source: 'w6_wet_board_repair',
      wrong: 'nothing_changed',
      signal: 'board_texture_change',
      skill: 'board_texture_reasoning',
      targetWorld: 'world_5',
      targetLesson: 'turn_river_changes',
      target: 'turn_river_changes_w5_turn_texture_shift_transfer',
    ),
    (
      world: 'world_12',
      lesson: 'decision_over_outcome',
      source: 'w12_bad_call_good_result',
      wrong: 'celebrate_only',
      signal: 'process_over_outcome',
      skill: 'mindset_process_discipline',
      targetWorld: 'world_12',
      targetLesson: 'mindset_bridge_checkpoint',
      target: 'w12_checkpoint_process_line',
    ),
    (
      world: 'world_6',
      lesson: 'range_pressure_lines',
      source: 'w6_turn_pressure_shift_transfer',
      wrong: 'bet_value',
      signal: 'range_bucket_shift',
      skill: 'range_bucket_reasoning',
      targetWorld: 'world_6',
      targetLesson: 'range_board_fit',
      target: 'w6_turn_shift_bucket',
    ),
    (
      world: 'world_5',
      lesson: 'turn_river_changes',
      source: 'turn_river_changes_w5_turn_texture_shift_transfer',
      wrong: 'nothing_changed',
      signal: 'board_texture_change',
      skill: 'board_texture_reasoning',
      targetWorld: 'world_6',
      targetLesson: 'range_pressure_lines',
      target: 'w6_wet_board_repair',
    ),
    (
      world: 'world_12',
      lesson: 'mindset_bridge_checkpoint',
      source: 'w12_checkpoint_process_line',
      wrong: 'outcome_only',
      signal: 'process_over_outcome',
      skill: 'mindset_process_discipline',
      targetWorld: 'world_12',
      targetLesson: 'decision_over_outcome',
      target: 'w12_bad_call_good_result',
    ),
  ]) {
    testWidgets(
      '${route.source}: actual miss -> mapped repair -> recheck -> reload',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await _store.flush();
        });
        final sink = Act0InMemoryTelemetrySinkV1();
        final source = _task(route.source);
        final target = _task(route.target);
        final isAsm05 = route.source.startsWith(
          'asm05_new_known_holes_turn_call_',
        );
        final sourceFingerprint = isAsm05
            ? act0CurrentAuthoredSourceFingerprintForIdentityV1(
                worldId: route.world,
                lessonId: route.lesson,
                taskId: route.source,
              )
            : null;
        final targetFingerprint = isAsm05
            ? act0CurrentAuthoredSourceFingerprintForIdentityV1(
                worldId: route.targetWorld,
                lessonId: route.targetLesson,
                taskId: route.target,
              )
            : null;
        if (isAsm05) {
          expect(sourceFingerprint, isNotNull);
          expect(targetFingerprint, isNotNull);
        }
        SharedPreferences.setMockInitialValues({
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          _progressKey: jsonEncode(
            _initialRoute(route.world, route.lesson, route.source),
          ),
        });
        await _mount(tester, sink);
        await _startActualLearnTask(tester, route.lesson, route.source);
        await _ready(tester, route.wrong);
        expect(_runner(tester).selectedTaskId, source.taskId);
        expect(_runner(tester).runner.question, source.runner.question);
        expect(find.text(source.runner.question), findsWidgets);
        expect(_host(tester).debugOpenRepairIntentCountV1(), 0);
        await _tap(tester, 'act0_shell_option_${route.wrong}');
        expect(_runner(tester).runner.selectedOptionId, route.wrong);
        expect(_host(tester).debugOpenRepairIntentCountV1(), 1);
        final intent = Map<String, Object?>.from(
          _host(
                tester,
              ).debugOpenRepairIntentPayloadForSourceTaskV1(route.source)
              as Map,
        );
        expect(intent['sourceWorldId'], route.world);
        expect(intent['sourceLessonId'], route.lesson);
        expect(intent['sourceTaskId'], route.source);
        expect(intent['choiceId'], route.wrong);
        expect(intent['result'], 'incorrect');
        expect(intent['missedSignalId'], route.signal);
        expect(intent['skillAtomId'], route.skill);
        expect(intent['targetWorldId'], route.targetWorld);
        expect(intent['targetLessonId'], route.targetLesson);
        expect(intent['targetTaskId'], route.target);
        expect(intent['mappingType'], 'repair');
        final missed = await _saved(tester);
        expect(missed['earnedXp'], 0);
        final original = _records(missed, route.source).single;
        expect(original['choiceId'], route.wrong);
        expect(original['isCorrect'], false);
        expect(original['authoredSourceFingerprint'], isNotEmpty);
        if (isAsm05) {
          expect(original['authoredSourceFingerprint'], sourceFingerprint);
        }

        // The actual feedback CTA, not a direct mapped-state injection.
        await _tap(tester, 'act0_shell_feedback_continue_cta');
        await _ready(
          tester,
          target.runner.options.singleWhere((o) => o.isCorrect).id,
        );
        expect(_runner(tester).selectedWorldId, route.targetWorld);
        expect(_runner(tester).selectedLessonId, route.targetLesson);
        expect(_runner(tester).selectedTaskId, route.target);
        expect(_runner(tester).runner.question, target.runner.question);
        expect(find.text(target.runner.question), findsWidgets);
        await _tap(
          tester,
          'act0_shell_option_${target.runner.options.singleWhere((o) => o.isCorrect).id}',
        );
        final repairAnswered = await _saved(tester);
        final targetRecords = _records(repairAnswered, route.target);
        expect(
          targetRecords,
          hasLength(1),
          reason:
              'Actual target answer must persist exactly one canonical decision',
        );
        final repairRecord = targetRecords.single;
        expect(repairRecord['isCorrect'], true);
        expect(repairRecord['assistanceKind'], 'none');
        expect(repairRecord['authoredSourceFingerprint'], isNotEmpty);
        if (isAsm05) {
          expect(repairRecord['authoredSourceFingerprint'], targetFingerprint);
        }
        await _tap(tester, 'act0_shell_feedback_continue_cta');
        expect(_host(tester).debugOpenRepairIntentCountV1(), 0);
        expect(
          _host(
            tester,
          ).debugOpenRepairIntentPayloadForSourceTaskV1(route.source),
          isNull,
        );
        expect(_runner(tester).selectedTaskId, route.source);
        final repaired = await _saved(tester);
        expect(_records(repaired, route.source).single, original);

        final sourceCorrect = source.runner.options
            .singleWhere((o) => o.isCorrect)
            .id;
        await _ready(tester, sourceCorrect);
        expect(find.text(source.runner.question), findsWidgets);
        await _tap(tester, 'act0_shell_option_$sourceCorrect');
        await _tap(tester, 'act0_shell_feedback_continue_cta');
        final after = await _saved(tester);
        final sourceRecords = _records(after, route.source);
        expect(sourceRecords, hasLength(2));
        expect(
          sourceRecords.first,
          original,
          reason: 'retain the original miss unchanged',
        );
        expect(sourceRecords.last['isCorrect'], true);
        expect(sourceRecords.last['assistanceKind'], 'none');
        expect(sourceRecords.last['runKind'], 'recheck');
        expect(
          (after['completedTaskIds'] as List).where((id) => id == route.source),
          hasLength(1),
        );
        final completed = (after['completedTaskIds'] as List)
            .cast<String>()
            .toSet();
        expect(completed.difference({route.source, route.target}), isEmpty);
        expect(
          after['earnedXp'],
          source.rewardXp +
              (completed.contains(route.target) ? target.rewardXp : 0),
        );
        expect(_host(tester).debugOpenRepairIntentCountV1(), 0);
        expect(
          sink.events.where(
            (e) =>
                e.name == 'repair_completed' &&
                e.fields['sourceTaskId'] == route.source &&
                e.fields['repairTaskId'] == route.target &&
                e.fields['result'] == 'correct',
          ),
          hasLength(1),
        );
        expect(
          sink.events.where(
            (e) =>
                e.name == 'recheck_completed' &&
                e.fields['taskId'] == route.source &&
                e.fields['result'] == 'correct',
          ),
          hasLength(1),
        );

        // Host remount reads product autosaves; no second seeded snapshot.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _store.flush();
        await _mount(tester, sink);
        final restored = await _saved(tester);
        for (final key in [
          'earnedXp',
          'completedTaskIds',
          'openRepairIntents',
          'learningEvidenceHistory',
          'reviewResolutionReceipts',
        ]) {
          expect(restored[key], after[key], reason: 'remount preserves $key');
        }
        expect(_host(tester).debugOpenRepairIntentCountV1(), 0);
        if (isAsm05) {
          expect(
            _records(restored, route.source).first['authoredSourceFingerprint'],
            sourceFingerprint,
          );
          expect(
            _records(
              restored,
              route.target,
            ).single['authoredSourceFingerprint'],
            targetFingerprint,
          );
        }

        // Replaying the real source correctly must not pay its XP twice.
        await _startActualLearnTask(tester, route.lesson, route.source);
        await _ready(tester, sourceCorrect);
        await _tap(tester, 'act0_shell_option_$sourceCorrect');
        await _tap(tester, 'act0_shell_feedback_continue_cta');
        final replayed = await _saved(tester);
        expect(replayed['earnedXp'], after['earnedXp']);
        expect(
          (replayed['completedTaskIds'] as List).where(
            (id) => id == route.source,
          ),
          hasLength(1),
        );
        expect(
          _records(replayed, route.source).take(2).toList(),
          sourceRecords,
        );
        expect(_host(tester).debugOpenRepairIntentCountV1(), 0);
      },
    );
  }
}

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample.worlds
    .expand((w) => w.lessons)
    .expand((l) => l.taskList)
    .singleWhere((t) => t.taskId == id);

Map<String, Object?> _initialRoute(String world, String lesson, String source) {
  // Prerequisites are navigation-only skips, never earned task completions.
  final preceding = <String>[];
  outer:
  for (final w in Act0ShellStateV1.sample.worlds) {
    for (final l in w.lessons) {
      for (final t in l.taskList) {
        if (t.taskId == source) break outer;
        preceding.add(t.taskId);
      }
    }
  }
  return {
    'schemaVersion': 18,
    'completedTaskIds': <String>[],
    'completedLessonIds': <String>[],
    'skippedTaskIds': preceding,
    'selectedWorldId': world,
    'selectedLessonId': lesson,
    'selectedTaskId': source,
    'earnedXp': 0,
    'learningEvidenceHistory': <Object>[],
  };
}

Future<void> _mount(
  WidgetTester tester,
  Act0InMemoryTelemetrySinkV1 sink,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: Act0ShellTabV1.learn,
        showPlacementOnStart: false,
        telemetrySink: sink,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

dynamic _host(WidgetTester tester) =>
    tester.state(find.byType(Act0ShellPreviewScreenV1));
Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<void> _startActualLearnTask(
  WidgetTester tester,
  String lesson,
  String task,
) async {
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) await _tap(tester, 'act0_shell_runner_back');
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Learn'),
  );
  if (tab.evaluate().isNotEmpty) {
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }
  expect(find.byType(Act0LearnPathShellV1), findsOneWidget);
  // Public route callback only; task records, choices and runtime proof stay actual.
  tester
      .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
      .onStartTask(lesson, task);
  await tester.pumpAndSettle();
  expect(_runner(tester).selectedTaskId, task);
}

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget, reason: key);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _ready(WidgetTester tester, String choice) async {
  final option = find.byKey(Key('act0_shell_option_$choice'));
  for (var i = 0; i < 15 && option.evaluate().isEmpty; i++) {
    var advanced = false;
    for (final key in [
      'act0_shell_theory_continue_cta',
      'act0_shell_continue_cta',
      'act0_shell_runner_primary_cta',
    ]) {
      if (find.byKey(Key(key)).evaluate().isNotEmpty) {
        await _tap(tester, key);
        advanced = true;
        break;
      }
    }
    expect(
      advanced,
      true,
      reason: 'authored teaching must reach option $choice',
    );
  }
  expect(option, findsOneWidget);
  // Mounted controls precede the normal runtime hero-ready timer. Let the
  // actual plan finish; never force state, settled mode or reduced motion.
  final plan = act0TableChoreographyPlanForTableV1(
    _runner(tester).runner.table,
  );
  if (plan != null) {
    for (var i = 0; i <= plan.beats.length; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }
  }
  await tester.ensureVisible(option);
  expect(option.hitTestable(), findsOneWidget);
}

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await _store.flush();
  final value = await _store.load();
  expect(value, isNotNull, reason: 'product autosave must exist');
  return jsonDecode(value!) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _records(Map<String, dynamic> saved, String task) =>
    (saved['learningEvidenceHistory'] as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .where((r) => r['taskId'] == task)
        .toList();

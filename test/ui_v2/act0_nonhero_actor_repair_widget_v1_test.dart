// CONTROLLED WIDGET FIXTURE: prerequisite-only skipped tasks, zero earned XP,
// no injected source miss/history/repair. Public UI produces the observed miss
// and repair; mock preferences and host remount are not native/restart/Human proof.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_authored_repair_goal_fixture_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';

const _key = 'act0_shell_progress_v1';
const _subjects = [
  (lesson: 'blinds_action_order', task: 'blinds_first_actor', wrong: 'btn'),
  (lesson: 'blinds_action_order', task: 'blinds_last_actor', wrong: 'sb'),
  (lesson: 'blinds_action_order', task: 'blinds_review', wrong: 'btn'),
  (lesson: 'positions', task: 'positions_utg', wrong: 'hj'),
];

Act0LessonRunnerShellV1 _runner(WidgetTester t) =>
    t.widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));
Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  expect(f, findsOneWidget, reason: key);
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

Future<void> _tab(WidgetTester t, String label) async {
  final f = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  expect(f, findsOneWidget);
  await t.tap(f);
  await t.pumpAndSettle();
}

Future<void> _mount(WidgetTester t) async {
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: false,
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  await t.pumpAndSettle();
  await t.runAsync(
    () => Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true).flush(),
  );
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_key)!) as Map<String, dynamic>;
}

Future<void> _choice(WidgetTester t, String id, String taskId) async {
  for (var step = 0; step < 24; step++) {
    final r = _runner(t);
    expect(r.selectedTaskId, taskId);
    if (r.runner.phase == Act0LessonPhaseV1.drill &&
        r.runner.activeTeachingStep == null) {
      expect(r.runner.selectedOptionId, isNull);
      await pumpSourceChoreographyToDecisionV1(t, r.runner.table);
      final option = r.runner.options.singleWhere((o) => o.id == id);
      final seat = find.byKey(Key('act0_shell_seat_tap_${option.seatId}'));
      await _tap(
        t,
        seat.evaluate().isNotEmpty
            ? 'act0_shell_seat_tap_${option.seatId}'
            : 'act0_shell_option_$id',
      );
      expect(
        _runner(t).runner.selectedOptionId,
        id,
        reason: 'One real submitted decision is required.',
      );
      return;
    }
    await t.pump(const Duration(seconds: 1));
    await _tap(
      t,
      find
              .byKey(const Key('act0_shell_theory_continue_cta'))
              .evaluate()
              .isNotEmpty
          ? 'act0_shell_theory_continue_cta'
          : 'act0_shell_continue_cta',
    );
  }
  fail('No ordinary decision offered for $taskId');
}

void main() {
  final observations = <String, Object?>{};
  for (final subject in _subjects) {
    testWidgets(
      '${subject.task}: real wrong callback persists a typed familiar repair across host remount',
      (t) async {
        t.view.physicalSize = const Size(393, 852);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        addTearDown(() async {
          await t.pumpWidget(const SizedBox.shrink());
          await t.pumpAndSettle();
          await t.runAsync(
            () => Act0ProgressStoreV1(
              key: _key,
              isValidPayload: (_) => true,
            ).flush(),
          );
        });
        final all = [
          for (final lesson
              in Act0ShellStateV1.sample.worldById('world_1').lessons)
            for (final task in lesson.taskList) task,
        ];
        SharedPreferences.setMockInitialValues({
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          _key: jsonEncode({
            'schemaVersion': 18,
            'completedTaskIds': <String>[], 'completedLessonIds': <String>[],
            // Only fixture prerequisites: no claimed earned completion or skill.
            'skippedTaskIds': [
              for (final task in all.takeWhile(
                (task) => task.taskId != subject.task,
              ))
                task.taskId,
            ],
            'selectedWorldId': 'world_1', 'selectedLessonId': subject.lesson,
            'selectedTaskId': subject.task, 'earnedXp': 0,
          }),
        });
        await _mount(t);
        await _tab(t, 'Learn');
        await _tap(t, 'act0_shell_current_mission_cta');
        await _choice(t, subject.wrong, subject.task);
        final saved = await _saved(t);
        final records = (saved['learningEvidenceHistory'] as List)
            .map(Act0LearningEvidenceRecordV1.tryParse)
            .whereType<Act0LearningEvidenceRecordV1>()
            .toList();
        final miss = records.singleWhere(
          (r) => r.taskId == subject.task && !r.isCorrect,
        );
        final intents = (saved['openRepairIntents'] as List)
            .map(Act0RepairIntentV1.tryParse)
            .whereType<Act0RepairIntentV1>()
            .toList();
        final intent = intents.singleWhere(
          (i) => i.sourceTaskId == subject.task,
        );
        expect(intent.repairOccurrenceId, miss.recordId);
        expect(intent.goalId, isNotEmpty);
        expect(intent.relationRevision, 1);
        expect(intent.sourceFingerprint, intent.targetFingerprint);
        expect(intent.targetTaskId, subject.task);
        expect(intent.mappingType, 'intentional_exact');
        expect(saved['earnedXp'], 0);
        final missBytes = jsonEncode(miss.toPayload());
        final intentBytes = jsonEncode(intent.toPayload());
        expect(
          act0RepairGoalResolutionForIntentV1(
            intent,
            learningEvidence: Act0LearningEvidenceHistoryV1(records: records),
            currentFingerprintForIdentity:
                act0AuthoredRepairFixtureFingerprintV1,
          ).canLaunch,
          isTrue,
        );
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await _mount(t);
        final restored = await _saved(t);
        final restoredIntent = (restored['openRepairIntents'] as List)
            .map(Act0RepairIntentV1.tryParse)
            .whereType<Act0RepairIntentV1>()
            .singleWhere((i) => i.sourceTaskId == subject.task);
        expect(jsonEncode(restoredIntent.toPayload()), intentBytes);
        await _tab(t, 'Review');
        await _tap(
          t,
          act0AcademyReviewPreviewV1
              ? 'act0_academy_review_leaf_repair_cta'
              : 'act0_shell_review_practice_cta',
        );
        expect(_runner(t).selectedTaskId, subject.task);
        expect(_runner(t).reviewKindId, 'exactReplay');
        final correct = act0AuthoredRepairFixtureTaskV1(
          'world_1',
          subject.lesson,
          subject.task,
        ).runner.options.singleWhere((o) => o.isCorrect);
        await _choice(t, correct.id, subject.task);
        await _tap(t, 'act0_shell_feedback_continue_cta');
        final finalSaved = await _saved(t);
        final parsedHistory = Act0LearningEvidenceHistoryV1.tryParse(
          finalSaved['learningEvidenceHistory'],
        );
        expect(parsedHistory, isNotNull);
        final history = parsedHistory!;
        final preserved = history.records.singleWhere(
          (r) => r.recordId == miss.recordId,
        );
        expect(jsonEncode(preserved.toPayload()), missBytes);
        final outcome = (finalSaved['repairOutcomeProjection'] as List)
            .map(Act0RepairOutcomeV1.tryParse)
            .whereType<Act0RepairOutcomeV1>()
            .singleWhere((o) => o.repairOccurrenceId == miss.recordId);
        final attempt = history.records.singleWhere(
          (r) => r.recordId == outcome.repairAttemptId,
        );
        expect(attempt.reviewKind, Act0ReviewKindV1.exactReplay);
        expect(attempt.runKind, 'repair');
        expect(attempt.isCorrect, isTrue);
        expect(
          act0RepairGoalOutcomeIsEligibleV1(
            intent: intent,
            outcome: outcome,
            learningEvidence: history,
            currentFingerprintForIdentity:
                act0AuthoredRepairFixtureFingerprintV1,
          ),
          isTrue,
        );
        expect(finalSaved['earnedXp'], 0);
        observations[subject.task] = {
          'fixture':
              'prerequisite-only skipped, zero XP; no injected miss/history/repair',
          'actual_miss': miss.toPayload(),
          'actual_intent': intent.toPayload(),
          'host_remount_intent_equal': true,
          'actual_familiar_attempt': attempt.toPayload(),
          'actual_outcome': outcome.toPayload(),
          'first_miss_unchanged': true,
          'final_xp': finalSaved['earnedXp'],
          'not_proved': [
            'native_restart',
            'Human',
            'independent_application',
            'matched_recheck',
            'unseen_transfer',
            'mastery',
          ],
        };
        final output = Platform.environment['PKR03_OUTPUT'];
        if (output != null) {
          await t.runAsync(() async {
            await Directory(output).create(recursive: true);
            await File(
              '$output/nonhero-widget-observations.json',
            ).writeAsString(
              const JsonEncoder.withIndent('  ').convert(observations),
              flush: true,
            );
          });
        }
        expect(t.takeException(), isNull);
      },
    );
  }
}

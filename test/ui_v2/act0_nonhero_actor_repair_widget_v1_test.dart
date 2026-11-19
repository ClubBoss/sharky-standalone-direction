// CONTROLLED WIDGET FIXTURE: prerequisite-only skipped tasks, zero earned XP,
// no injected source miss/history/repair. Public UI produces the observed miss
// and repair; mock preferences and host remount are not native/restart/Human proof.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';

import '../support/act0_authored_repair_goal_fixture_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';

const _key = 'act0_shell_progress_v1';
final _decisionGeometry = <String, Object?>{};
var _frameSequence = 0;
const _subjects = [
  (lesson: 'blinds_action_order', task: 'blinds_first_actor', wrong: 'btn'),
  (lesson: 'blinds_action_order', task: 'blinds_last_actor', wrong: 'sb'),
  (lesson: 'blinds_action_order', task: 'blinds_review', wrong: 'btn'),
  (lesson: 'blinds_action_order', task: 'positions_utg', wrong: 'hj'),
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
      home: RepaintBoundary(
        key: const Key('nonhero-host-capture'),
        child: Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          initialTab: Act0ShellTabV1.home,
          showPlacementOnStart: false,
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  await t.pumpAndSettle();
  final raw = await t.runAsync(() async {
    final store = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);
    await store.flush();
    return store.load();
  });
  expect(raw, isNotNull);
  return jsonDecode(raw!) as Map<String, dynamic>;
}

Future<String> _choice(WidgetTester t, String id, String taskId) async {
  for (var step = 0; step < 24; step++) {
    final r = _runner(t);
    expect(r.selectedTaskId, taskId);
    if (r.runner.phase == Act0LessonPhaseV1.drill &&
        r.runner.activeTeachingStep == null) {
      expect(r.runner.selectedOptionId, isNull);
      await pumpSourceChoreographyToDecisionV1(t, r.runner.table);
      final option = r.runner.options.singleWhere((o) => o.id == id);
      final seatKey = 'act0_shell_seat_tap_${option.seatId}';
      final optionKey = 'act0_shell_option_$id';
      // A mounted seat can have a covered centre. Use only a public affordance
      // that actually receives a pointer; never force a callback or readiness.
      final seat = find.byKey(Key(seatKey));
      final seatLabel = find
          .descendant(
            of: seat,
            matching: find.text(option.seatId!.toUpperCase()),
          )
          .hitTestable();
      final optionButton = find.byKey(Key(optionKey));
      final registeredScene = find.byKey(const Key('act0_f7_registered_scene'));
      final isRegistered = registeredScene.evaluate().isNotEmpty;
      if (taskId == 'blinds_review') {
        expect(
          isRegistered,
          isTrue,
          reason: 'The actual obstructed branch must be re-proved.',
        );
      }
      if (isRegistered) {
        final guideShelf = find.byKey(
          const Key('act0_shell_seat_decision_guide_viewport'),
        );
        expect(guideShelf, findsOneWidget);
        expect(
          t.getRect(guideShelf).overlaps(t.getRect(seat)),
          isFalse,
          reason: 'The source premise guide must not cover an answer seat.',
        );
        final guide = t.widget<Act0LearningSceneGuideV3>(
          find.byType(Act0LearningSceneGuideV3),
        );
        expect(
          guide.support,
          act0LearnerFacingPremisesV1(_runner(t).runner.caption),
        );
        expect(guide.scrollSupport, isTrue);
        final supportText = t.widget<Text>(
          find.byKey(const Key('act0_learning_scene_v3_support')),
        );
        expect(
          supportText.data,
          act0LearnerFacingPremisesV1(_runner(t).runner.caption),
        );
        expect(supportText.maxLines, isNull);
        final seatRectBeforeRead = t.getRect(seat);
        final supportViewport = find.byKey(
          const Key('act0_learning_scene_v3_model_support_scroll'),
        );
        await t.ensureVisible(supportViewport);
        await t.pumpAndSettle();
        final supportScroll = t.state<ScrollableState>(
          find.descendant(
            of: supportViewport,
            matching: find.byType(Scrollable),
          ),
        );
        expect(supportScroll.position.pixels, 0);
        expect(supportScroll.position.maxScrollExtent, greaterThan(0));
        await t.drag(supportViewport, const Offset(0, -800));
        await t.pumpAndSettle();
        final actualEnd = supportScroll.position.pixels;
        expect(actualEnd, closeTo(supportScroll.position.maxScrollExtent, 0.1));
        await t.drag(supportViewport, const Offset(0, 800));
        await t.pumpAndSettle();
        expect(supportScroll.position.pixels, 0);
        await t.ensureVisible(
          find.byKey(const Key('act0_integrated_scene_prompt')),
        );
        await t.pumpAndSettle();
        expect(t.getRect(seat), seatRectBeforeRead);
        final frameName =
            '$taskId-$id-${_frameSequence++}-source-seat-decision.png';
        _decisionGeometry['$taskId/$id'] = {
          'seat_rect': seatRectBeforeRead.toString(),
          'guide_rect': t.getRect(guideShelf).toString(),
          'guide_overlaps_seat': false,
          'full_source_caption': guide.support,
          'support_scroll_observed_start': 0,
          'support_scroll_observed_end': actualEnd,
          'support_scroll_extent': supportScroll.position.maxScrollExtent,
          'support_scroll_observed_return': supportScroll.position.pixels,
          'table_seat_rect_unchanged_after_read': true,
          'widget_frame': frameName,
        };
        final output = Platform.environment['PKR03_OUTPUT'];
        if (output != null) {
          await t.runAsync(() async {
            final dir = Directory(output)..createSync(recursive: true);
            final boundary = t.renderObject<RenderRepaintBoundary>(
              find.byKey(const Key('nonhero-host-capture')),
            );
            final frame = await boundary.toImage(pixelRatio: 1);
            final bytes = await frame.toByteData(
              format: ui.ImageByteFormat.png,
            );
            File(
              '${dir.path}/$frameName',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            frame.dispose();
          });
        }
      } else {
        expect(
          find.byKey(const Key('act0_shell_seat_decision_guide_viewport')),
          findsNothing,
        );
        _decisionGeometry['$taskId/$id'] = {
          'layout':
              'existing non-registered presentation; new shelf not applicable',
          'seat_rect': t.getRect(seat).toString(),
          'source_caption': _runner(t).runner.caption,
          'new_registered_guide_scroll': 'NOT_APPLICABLE_NOT_CLAIMED',
        };
      }
      expect(
        seat.hitTestable(),
        findsOneWidget,
        reason: 'The actual seat centre must receive its ordinary pointer.',
      );
      late final String submittedKey;
      if (seat.hitTestable().evaluate().isNotEmpty) {
        submittedKey = seatKey;
        await _tap(t, seatKey);
      } else if (seatLabel.evaluate().length == 1) {
        // The visible seat name is inside the same public seat control. Its
        // actual hit-test must succeed; no synthetic callback or hidden tap.
        await t.ensureVisible(seatLabel);
        await t.pumpAndSettle();
        expect(seatLabel.hitTestable(), findsOneWidget);
        await t.tap(seatLabel);
        await t.pumpAndSettle();
        submittedKey = '$seatKey/visible-seat-label';
      } else if (optionButton.evaluate().isNotEmpty) {
        await t.ensureVisible(optionButton);
        await t.pumpAndSettle();
        expect(optionButton.hitTestable(), findsOneWidget);
        submittedKey = optionKey;
        await _tap(t, optionKey);
      } else {
        final output = Platform.environment['PKR03_OUTPUT'];
        if (output != null) {
          await t.runAsync(() async {
            final dir = Directory(output)..createSync(recursive: true);
            final boundary = t.renderObject<RenderRepaintBoundary>(
              find.byKey(const Key('nonhero-host-capture')),
            );
            final frame = await boundary.toImage(pixelRatio: 1);
            final bytes = await frame.toByteData(
              format: ui.ImageByteFormat.png,
            );
            File(
              '${dir.path}/$taskId-$id-unhittable.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            frame.dispose();
            File('${dir.path}/$taskId-$id-unhittable.json').writeAsStringSync(
              const JsonEncoder.withIndent('  ').convert({
                'task_id': taskId,
                'choice_id': id,
                'seat_rect': seat.evaluate().isEmpty
                    ? null
                    : t.getRect(seat).toString(),
                'seat_elements': seat.evaluate().length,
                'public_option_elements': optionButton.evaluate().length,
                'visible_text': [
                  for (final widget in t.widgetList<Text>(find.byType(Text)))
                    widget.data ?? widget.textSpan?.toPlainText(),
                ],
              }),
            );
          });
        }
        fail('No genuinely hittable public seat or option for $taskId/$id');
      }
      expect(
        _runner(t).runner.selectedOptionId,
        id,
        reason: 'One real submitted decision is required.',
      );
      return submittedKey;
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

void _seedPrerequisites(({String lesson, String task, String wrong}) subject) {
  final all = [
    for (final lesson in Act0ShellStateV1.sample.worldById('world_1').lessons)
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
        for (final task in all.takeWhile((task) => task.taskId != subject.task))
          task.taskId,
      ],
      'selectedWorldId': 'world_1', 'selectedLessonId': subject.lesson,
      'selectedTaskId': subject.task, 'earnedXp': 0,
    }),
  });
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
        _seedPrerequisites(subject);
        await _mount(t);
        await _tab(t, 'Learn');
        await _tap(t, 'act0_shell_current_mission_cta');
        final wrongAffordance = await _choice(t, subject.wrong, subject.task);
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
        final correctAffordance = await _choice(t, correct.id, subject.task);
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
        final sourceTask = act0AuthoredRepairFixtureTaskV1(
          'world_1',
          subject.lesson,
          subject.task,
        );
        expect(finalSaved['earnedXp'], sourceTask.rewardXp);
        expect(finalSaved['completedTaskIds'], contains(subject.task));
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await _mount(t);
        final afterFinalRemount = await _saved(t);
        expect(afterFinalRemount['earnedXp'], sourceTask.rewardXp);
        expect(afterFinalRemount['completedTaskIds'], contains(subject.task));
        observations[subject.task] = {
          'fixture':
              'prerequisite-only skipped, zero XP; no injected miss/history/repair',
          'actual_miss': miss.toPayload(),
          'wrong_public_affordance': wrongAffordance,
          'correct_public_affordance': correctAffordance,
          'source_seat_decision_checks': {
            'wrong': _decisionGeometry['${subject.task}/${subject.wrong}'],
            'correct': _decisionGeometry['${subject.task}/${correct.id}'],
          },
          'actual_intent': intent.toPayload(),
          'host_remount_intent_equal': true,
          'actual_familiar_attempt': attempt.toPayload(),
          'actual_outcome': outcome.toPayload(),
          'first_miss_unchanged': true,
          'final_xp': finalSaved['earnedXp'],
          'xp_basis': 'existing first eligible curriculum completion',
          'final_remount_xp_stable': true,
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
  testWidgets(
    'simulated old unwitnessed intent cannot acquire a goal on host remount',
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
      final subject = _subjects.first;
      _seedPrerequisites(subject);
      await _mount(t);
      await _tab(t, 'Learn');
      await _tap(t, 'act0_shell_current_mission_cta');
      await _choice(t, subject.wrong, subject.task);
      final saved = await _saved(t);
      final historyBytes = jsonEncode(saved['learningEvidenceHistory']);
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      // SIMULATED legacy intent only: recursively strip the five additive
      // witnesses from every copy of this source intent in the saved payload.
      var copies = 0;
      void stripWitness(Object? value) {
        if (value is Map) {
          if (value['sourceTaskId'] == subject.task &&
              value.containsKey('mappingType')) {
            for (final key in [
              'goalId',
              'relationId',
              'relationRevision',
              'sourceFingerprint',
              'targetFingerprint',
            ]) {
              value.remove(key);
            }
            copies++;
          }
          for (final child in value.values.toList()) {
            stripWitness(child);
          }
        } else if (value is List) {
          for (final child in value) {
            stripWitness(child);
          }
        }
      }

      stripWitness(saved);
      expect(copies, greaterThanOrEqualTo(1));
      expect(jsonEncode(saved['learningEvidenceHistory']), historyBytes);
      await t.runAsync(
        () =>
            Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true).flush(),
      );
      await t.runAsync(() async {
        final store = Act0ProgressStoreV1(
          key: _key,
          isValidPayload: (_) => true,
        );
        expect(await store.save(jsonEncode(saved)), isTrue);
        await store.flush();
        final committed =
            jsonDecode((await store.load())!) as Map<String, dynamic>;
        expect(jsonEncode(committed['learningEvidenceHistory']), historyBytes);
        final committedIntent = (committed['openRepairIntents'] as List)
            .map(Act0RepairIntentV1.tryParse)
            .whereType<Act0RepairIntentV1>()
            .singleWhere((i) => i.sourceTaskId == subject.task);
        expect(committedIntent.goalId, isEmpty);
        expect(committedIntent.relationId, isEmpty);
        expect(committedIntent.relationRevision, 0);
        expect(committedIntent.sourceFingerprint, isEmpty);
        expect(committedIntent.targetFingerprint, isEmpty);
      });
      await _mount(t);
      await _tab(t, 'Review');
      final diagnosticAfterMount = await _saved(t);
      final diagnosticOutput = Platform.environment['PKR03_OUTPUT'];
      if (diagnosticOutput != null) {
        await t.runAsync(() async {
          await Directory(diagnosticOutput).create(recursive: true);
          await File(
            '$diagnosticOutput/legacy-consumer-observation.json',
          ).writeAsString(
            const JsonEncoder.withIndent('  ').convert({
              'fixture':
                  'SIMULATED old format; actual fresh UI miss, then only five intent witnesses removed',
              'stripped_intent_copies': copies,
              'seeded_payload': saved,
              'actual_after_review_mount': diagnosticAfterMount,
              'actual_review_text': [
                for (final widget in t.widgetList<Text>(find.byType(Text)))
                  widget.data ?? widget.textSpan?.toPlainText(),
              ],
              'not_proved': [
                'native_restart',
                'old_real_user_data',
                'Human',
                'outcome_bank',
              ],
            }),
            flush: true,
          );
        });
      }
      expect(
        find.text('Matching repair not confirmed · miss saved'),
        findsWidgets,
      );
      await _tap(
        t,
        act0AcademyReviewPreviewV1
            ? 'act0_academy_review_leaf_repair_cta'
            : 'act0_shell_review_practice_cta',
      );
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
      expect(
        find.text('Matching repair not confirmed · miss saved'),
        findsWidgets,
      );
      final restored = await _saved(t);
      final oldIntent = (restored['openRepairIntents'] as List)
          .map(Act0RepairIntentV1.tryParse)
          .whereType<Act0RepairIntentV1>()
          .singleWhere((i) => i.sourceTaskId == subject.task);
      expect(oldIntent.goalId, isEmpty);
      expect(oldIntent.relationId, isEmpty);
      expect(oldIntent.relationRevision, 0);
      final history = Act0LearningEvidenceHistoryV1.tryParse(
        restored['learningEvidenceHistory'],
      );
      expect(history, isNotNull);
      final resolution = act0RepairGoalResolutionForIntentV1(
        oldIntent,
        learningEvidence: history!,
        currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
      );
      expect(resolution.canLaunch, isFalse);
      expect(resolution.reason, 'relation_capture_unconfirmed');
      expect(jsonEncode(restored['learningEvidenceHistory']), historyBytes);
      expect(restored['earnedXp'], 0);
      expect(restored['completedTaskIds'], isNot(contains(subject.task)));
      expect((restored['repairOutcomeProjection'] as List?) ?? [], isEmpty);
      expect(t.takeException(), isNull);
    },
  );
}

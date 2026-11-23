import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_leak_archive_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_leak_dashboard_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _world = 'world_4';
const _lesson = 'call_price';
const _task = 'w4_cheap_price_marginal_call';
const _oldRevision =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
final _now = DateTime.utc(2026, 11, 23);
final _worlds = Act0ShellStateV1.sample.worlds;
final _authored = _worlds
    .singleWhere((world) => world.worldId == _world)
    .lessons
    .singleWhere((lesson) => lesson.lessonId == _lesson)
    .taskList
    .singleWhere((task) => task.taskId == _task);
final _revision = act0AuthoredSourceFingerprintV1(
  worldId: _world,
  lessonId: _lesson,
  task: _authored,
)!;

Act0ArchivedAttemptV1 _attempt(
  int order, {
  bool correct = false,
  String? revision,
  String? tableRevision,
  Act0ReviewKindV1 reviewKind = Act0ReviewKindV1.initialAssessment,
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
}) => Act0ArchivedAttemptV1.fromRecordedDecision(
  Act0LearningEvidenceRecordV1(
    recordId: 'attempt-$order',
    createdOrder: order,
    worldId: _world,
    lessonId: _lesson,
    taskId: _task,
    sourceTaskId: _task,
    choiceId: correct ? 'call' : 'fold',
    expectedChoiceId: 'call',
    isCorrect: correct,
    errorType: correct ? 'none' : 'price',
    conceptFamilyId: 'call_price',
    repairFocusId: 'pot',
    skillAtomId: 'call_price',
    decisionTimeBucket: 'under_3s',
    resultKind: correct ? 'correct' : 'suboptimal',
    authoredSourceFingerprint: revision ?? _revision,
    recordedAtUtc: _now,
    assistanceKind: assistance,
    reviewKind: reviewKind,
  ),
  tableFingerprint:
      tableRevision ?? act0ReplayTableFingerprintV1(_authored.runner.table),
)!;

Act0LeakDashboardV1 _report(
  List<Act0ArchivedAttemptV1> attempts, {
  List<Act0LearningEvidenceRecordV1> history = const [],
  List<Act0LeakPracticeTargetV1> daily = const [],
  Iterable<Act0LeakPracticeTargetV1> Function(Act0LearningEvidenceRecordV1)?
  targets,
}) {
  var archive = const Act0AttemptArchiveV1.empty();
  for (final attempt in attempts) {
    archive = archive.add(attempt);
  }
  return act0LeakDashboardFromArchiveV1(
    archive: Act0AttemptArchiveV1.restore(archive.toPayload()),
    history: Act0LearningEvidenceHistoryV1(records: history),
    worlds: _worlds,
    nowUtc: _now,
    reviewRepairsForMiss: targets ?? (_) => const [],
    dailyPracticeTargets: () => daily,
    minimumAttempts: 1,
  );
}

void main() {
  testWidgets('Review only receives the mechanism with the flag enabled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.review,
          showPlacementOnStart: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final legacy = find.byType(Act0ReviewShellV1);
    final academy = find.byType(Act0AcademyReviewLeafV1);
    expect(legacy.evaluate().length + academy.evaluate().length, 1);
    final model = legacy.evaluate().isNotEmpty
        ? tester.widget<Act0ReviewShellV1>(legacy).leakDashboard
        : tester.widget<Act0AcademyReviewLeafV1>(academy).input.leakDashboard;
    expect(
      model?.state,
      leakDashboardV1 ? Act0LeakDashboardStateV1.empty : null,
    );
    expect(find.text(Act0LeakDashboardV1.title), findsNothing);
  });

  test('saved archive joins authored task, skill map, and repair source', () {
    const target = (
      kind: Act0LeakPracticeKindV1.reviewRepair,
      worldId: _world,
      lessonId: _lesson,
      taskId: 'w4_good_price_call',
      sourceTaskId: _task,
    );
    final first = _attempt(1);
    final report = _report(
      [_attempt(2, correct: true), first],
      targets: (miss) {
        expect(miss.recordId, first.id);
        return [target];
      },
    );
    expect(report.overall.accuracy, 0);
    expect(report.overall.repeats, 1);
    final table = _authored.runner.table;
    final buckets = [
      (Act0LeakDimensionV1.world, _world),
      (Act0LeakDimensionV1.concept, 'call_price'),
      (Act0LeakDimensionV1.skill, 'Betting decisions'),
      (Act0LeakDimensionV1.street, table.streetLabel.toLowerCase()),
      (Act0LeakDimensionV1.position, table.heroSeat.seatLabel.toUpperCase()),
    ];
    for (final bucket in buckets) {
      expect(report.breakdown[bucket]?.accuracy, 0, reason: '$bucket');
      expect(report.breakdown[bucket]?.repeats, 1);
    }
    expect(report.topLeaks.first.practiceTargets, [target]);
  });

  test(
    'Daily Practice targets use the eligible deck and exact source task',
    () {
      const eligible = (
        kind: Act0LeakPracticeKindV1.dailyPractice,
        worldId: _world,
        lessonId: _lesson,
        taskId: _task,
        sourceTaskId: _task,
      );
      const unrelated = (
        kind: Act0LeakPracticeKindV1.dailyPractice,
        worldId: _world,
        lessonId: _lesson,
        taskId: 'w4_bad_price_fold',
        sourceTaskId: 'w4_bad_price_fold',
      );
      final report = _report([_attempt(1)], daily: [unrelated, eligible]);
      expect(report.topLeaks.first.practiceTargets, [eligible]);
      expect(_report([_attempt(1)]).topLeaks.first.practiceTargets, isEmpty);
    },
  );

  test(
    'assisted, deleted, and older first answers cannot promote a repeat',
    () {
      final assisted = _attempt(
        1,
        assistance: Act0DecisionAssistanceV1.quickHint,
      );
      final retry = _attempt(
        2,
        correct: true,
        reviewKind: Act0ReviewKindV1.unseenTransfer,
      );
      final replay = _attempt(
        3,
        correct: true,
        reviewKind: Act0ReviewKindV1.exactReplay,
      );
      final report = _report([retry, replay], history: [assisted.evidence]);
      expect(report.state, Act0LeakDashboardStateV1.tooLittleData);
      expect(report.overall.accuracy, isNull);
      expect(report.overall.repeats, 2);
      expect(_report([replay]).overall.repeats, 1);
      expect(_report([assisted, retry]).overall.firstAttempts, 0);
      final legacy = _attempt(1, reviewKind: Act0ReviewKindV1.legacyUnspaced);
      expect(_report([legacy]).overall.accuracy, isNull);
    },
  );

  test(
    'stale source and mismatched table cannot relabel historical attempts',
    () {
      final stale = _report(
        [_attempt(1, revision: _oldRevision)],
        targets: (_) {
          fail('Stale catalogue sources must not become practice targets.');
        },
      );
      expect(
        stale.breakdown.keys.map((key) => key.$1),
        unorderedEquals([
          Act0LeakDimensionV1.world,
          Act0LeakDimensionV1.concept,
        ]),
      );
      final alteredTable = _report([_attempt(1, tableRevision: _oldRevision)]);
      expect(
        alteredTable.breakdown.keys.map((key) => key.$1),
        unorderedEquals([
          Act0LeakDimensionV1.world,
          Act0LeakDimensionV1.concept,
          Act0LeakDimensionV1.skill,
        ]),
      );
    },
  );
}

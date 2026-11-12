// Synthetic old evidence objects only; not personal history or migration proof.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import '../support/w4_new_record_projection.dart';
import '../support/w4_binding_registry_proposal.dart';

void main() {
  final records = projectNewW4Records();
  final rows = [
    for (final p in records)
      W4AuthoredBinding(
        p.worldId,
        p.lessonId,
        p.task.taskId,
        p.fingerprint,
        p.recordId,
        p.version,
        p.recordHash,
        p.decisionId.split(':').first,
        p.decisionId,
        '6f8a9eb4a83e02ea0e0c1d7d614f5b50971bfff8d33760d08d4af73df10c9b04',
        'b07eaeb89d78640cfe8c3d92cf8e7e5a83fed50cac1feb0ab66539ac42864d32',
      ),
  ];
  test(
    'immutable attribution is unique and failclosed on missing or conflicting versions',
    () {
      final registry = W4BindingRegistryProposal(rows);
      final a = rows.first;
      expect(
        registry.resolve(a.world, a.lesson, a.task, a.fingerprint),
        same(a),
      );
      expect(registry.resolve(a.world, a.lesson, a.task, ''), isNull);
      expect(
        registry.resolve(a.world, a.lesson, a.task, 'old-fingerprint'),
        isNull,
      );
      expect(() => registry.rows.add(a), throwsUnsupportedError);
      W4AuthoredBinding altered({
        String? hand,
        String? decision,
        String? source,
        String? binding,
      }) => W4AuthoredBinding(
        a.world,
        a.lesson,
        a.task,
        a.fingerprint,
        a.record,
        a.version,
        a.recordHash,
        hand ?? a.handId,
        decision ?? a.decisionId,
        source ?? a.sourceManifest,
        binding ?? a.bindingManifest,
      );
      for (final bad in [
        altered(hand: ''),
        altered(decision: ''),
        altered(source: ''),
        altered(binding: ''),
        altered(hand: 'different-hand'),
      ]) {
        expect(() => W4BindingRegistryProposal([bad]), throwsArgumentError);
      }
      for (final changed in [
        altered(decision: '${a.handId}:different'),
        altered(source: 'different-source'),
        altered(binding: 'different-binding'),
      ]) {
        expect(
          () => W4BindingRegistryProposal([a, changed]),
          throwsArgumentError,
        );
      }

      expect(
        () => W4BindingRegistryProposal([...rows, a]),
        throwsArgumentError,
      );
      expect(
        () => W4BindingRegistryProposal([
          ...rows,
          W4AuthoredBinding(
            a.world,
            a.lesson,
            a.task,
            a.fingerprint,
            a.record,
            'different-version',
            a.recordHash,
            a.handId,
            a.decisionId,
            a.sourceManifest,
            a.bindingManifest,
          ),
        ]),
        throwsArgumentError,
      );
      expect(
        () => W4BindingRegistryProposal([
          W4AuthoredBinding(
            a.world,
            a.lesson,
            a.task,
            '',
            a.record,
            a.version,
            a.recordHash,
            a.handId,
            a.decisionId,
            a.sourceManifest,
            a.bindingManifest,
          ),
        ]),
        throwsArgumentError,
      );
      expect(
        () => W4BindingRegistryProposal([
          ...rows,
          W4AuthoredBinding(
            a.world,
            a.lesson,
            a.task,
            'different-fingerprint',
            a.record,
            a.version,
            a.recordHash,
            a.handId,
            a.decisionId,
            a.sourceManifest,
            a.bindingManifest,
          ),
        ]),
        throwsArgumentError,
      );
    },
  );

  for (final projected in projectNewW4Records()) {
    test(
      'new record ${projected.recordId} cannot relabel old source evidence',
      () {
        final old = Act0ShellStateV1.sample
            .worldById(projected.worldId)
            .lessons
            .singleWhere((l) => l.lessonId == projected.lessonId)
            .taskList
            .singleWhere((t) => t.taskId == projected.task.taskId);
        final oldFingerprint = act0AuthoredSourceFingerprintV1(
          worldId: projected.worldId,
          lessonId: projected.lessonId,
          task: old,
        )!;
        final nextFingerprint = projected.fingerprint;
        expect(nextFingerprint, isNot(oldFingerprint));
        expect(nextFingerprint, projected.fingerprint);
        expect(projected.task.rewardXp, old.rewardXp);
        expect(projected.task.taskId, old.taskId);
        final option = old.runner.options.first;
        final record = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic-old-${old.taskId}',
          createdOrder: 1,
          worldId: projected.worldId,
          lessonId: projected.lessonId,
          taskId: old.taskId,
          sourceTaskId: old.taskId,
          choiceId: option.id,
          expectedChoiceId: option.id,
          isCorrect: false,
          errorType: 'synthetic_old_miss',
          repairFocusId: 'preserve-old-debt',
          skillAtomId: 'old-skill',
          decisionTimeBucket: 'unknown',
          resultKind: 'wrong',
          authoredSourceFingerprint: oldFingerprint,
        );
        final currentOption = projected.task.runner.options.firstWhere(
          (o) => o.isCorrect,
        );
        Act0LearningEvidenceRecordV1 control(String fingerprint) =>
            Act0LearningEvidenceRecordV1(
              recordId: 'synthetic-positive-attempt-${old.taskId}',
              createdOrder: 2,
              worldId: projected.worldId,
              lessonId: projected.lessonId,
              taskId: old.taskId,
              sourceTaskId: old.taskId,
              choiceId: currentOption.id,
              expectedChoiceId: currentOption.id,
              isCorrect: true,
              errorType: '',
              repairFocusId: '',
              skillAtomId: 'synthetic-control',
              decisionTimeBucket: 'unknown',
              resultKind: 'correct',
              authoredSourceFingerprint: fingerprint,
            );
        final positive = control(nextFingerprint);
        expect(
          act0CurrentAuthoredSourceProofForTaskV1(
            record: positive,
            worldId: projected.worldId,
            lessonId: projected.lessonId,
            task: projected.task,
          ),
          isNotNull,
          reason: 'Positive current source control must establish nonvacuity.',
        );
        final stale = control(oldFingerprint);
        final positivePayload = positive.toPayload()
          ..remove('authoredSourceFingerprint');
        final stalePayload = stale.toPayload()
          ..remove('authoredSourceFingerprint');
        expect(stalePayload, positivePayload);
        expect(
          act0CurrentAuthoredSourceProofForTaskV1(
            record: stale,
            worldId: projected.worldId,
            lessonId: projected.lessonId,
            task: projected.task,
          ),
          isNull,
        );
        final before = record.toPayload();
        expect(
          act0CurrentAuthoredSourceProofForTaskV1(
            record: record,
            worldId: projected.worldId,
            lessonId: projected.lessonId,
            task: projected.task,
          ),
          isNull,
        );
        expect(record.toPayload(), before);
        expect(record.authoredSourceFingerprint, oldFingerprint);
        expect(record.recordId, 'synthetic-old-${old.taskId}');
      },
    );
  }
}

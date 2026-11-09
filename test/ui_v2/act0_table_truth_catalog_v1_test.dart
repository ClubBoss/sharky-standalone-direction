import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test('enumerates the live source and final runtime projections', () {
    final rows = auditTableTruth();
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons)
        .expand((l) => l.taskList)
        .toList();
    expect(tasks.map((t) => t.taskId).toSet().length, tasks.length);
    expect(
      rows.map((r) => r.taskId).toSet(),
      tasks.map((t) => t.taskId).toSet(),
    );
    final out = Directory(
      Platform.environment['TABLE_TRUTH_OUTPUT'] ?? 'output/table_truth',
    );
    out.createSync(recursive: true);
    File(
      '${out.path}/ledger.json',
    ).writeAsStringSync(jsonEncode(rows.map((r) => r.toJson()).toList()));
    final contract = {
      for (final t in tasks)
        t.taskId: {
          'rewardXp': t.rewardXp,
          'family': t.resolvedTaskFamily.name,
          'options': [
            for (final o in t.runner.options)
              {
                'id': o.id,
                'correct': o.isCorrect,
                'quality': o.quality.name,
                'seat': o.seatId,
                'repairSeats': o.repairFocusSeatIds,
                'repairCards': o.repairFocusCardIds,
                'repairLabels': o.repairFocusLabels,
              },
          ],
        },
    };
    File(
      '${out.path}/learning-contract.json',
    ).writeAsStringSync(jsonEncode(contract));
    const admittedAdditions = {
      'asm05_new_known_holes_turn_call_10',
      'asm05_new_known_holes_turn_call_40',
    };
    final baselineContract = Map<String, Object?>.from(
      jsonDecode(
            File(
              'test/ui_v2/fixtures/table_truth_learning_contract_v1.json',
            ).readAsStringSync(),
          )
          as Map,
    );
    final presentAdditions = contract.keys.toSet().intersection(
      admittedAdditions,
    );
    final historicalContract = Map<String, Object?>.from(contract)
      ..removeWhere((id, _) => admittedAdditions.contains(id));
    expect(
      historicalContract,
      baselineContract,
      reason:
          'Baseline source IDs, XP, family, correctness and repair identities must remain unchanged',
    );
    const expectedAsmContracts = {
      'asm05_new_known_holes_turn_call_10': {
        'rewardXp': 0,
        'family': 'decision',
        'options': [
          {
            'id': 'fold',
            'correct': false,
            'quality': 'wrong',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
          {
            'id': 'call',
            'correct': true,
            'quality': 'correct',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
        ],
      },
      'asm05_new_known_holes_turn_call_40': {
        'rewardXp': 0,
        'family': 'decision',
        'options': [
          {
            'id': 'fold',
            'correct': true,
            'quality': 'correct',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
          {
            'id': 'call',
            'correct': false,
            'quality': 'wrong',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
        ],
      },
    };
    if (presentAdditions.isNotEmpty) {
      expect(
        presentAdditions,
        admittedAdditions,
        reason: 'The candidate must contain both exact ASM05 additions',
      );
      for (final id in admittedAdditions) {
        expect(contract[id], expectedAsmContracts[id], reason: id);
      }
    }
    final fingerprints = <String, Object?>{};
    final choiceIdentity = <String, Object?>{};
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          final fingerprint = act0AuthoredSourceFingerprintV1(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            task: task,
          );
          expect(fingerprint, isNotNull, reason: task.taskId);
          fingerprints[task.taskId] = {
            'world_id': world.worldId,
            'lesson_id': lesson.lessonId,
            'fingerprint': fingerprint,
          };
          choiceIdentity[task.taskId] = [
            for (final option in task.runner.options)
              [
                option.id,
                option.label,
                option.isCorrect,
                option.quality.name,
                option.preferredLabel,
              ],
          ];
        }
      }
    }
    File(
      '${out.path}/source-fingerprints.json',
    ).writeAsStringSync(jsonEncode(fingerprints));
    File(
      '${out.path}/choice-identity.json',
    ).writeAsStringSync(jsonEncode(choiceIdentity));
    final snapshot = {
      for (final t in tasks)
        t.taskId: {
          'caption': t.runner.caption,
          'hint': t.runner.hint,
          'question': t.runner.question,
          'table': _table(t.runner.table),
          'teaching': [
            for (final step in t.runner.teachingSteps)
              {
                'title': step.title,
                'body': step.body,
                'table': step.table == null ? null : _table(step.table!),
                'seats': step.focusSeatIds,
                'cards': step.focusCardIds,
              },
          ],
          'options': [
            for (final o in t.runner.options)
              {
                'id': o.id,
                'label': o.label,
                'amount': o.amountLabel,
                'reason': o.feedbackReason,
                'preferred': o.preferredLabel,
              },
          ],
        },
    };
    File(
      '${out.path}/runtime-inputs.json',
    ).writeAsStringSync(jsonEncode(snapshot));
    final isCandidate = presentAdditions.isNotEmpty;
    final sourceReference = isCandidate
        ? const {
            'commit': '5b0dd2e300053e52b323e54df6c759ddb5f04b48',
            'state_sha256':
                'd9a78d57817c8eaef7dc1a376f53ade7774229be4a34063d5dc0cf152bb67221',
            'factory_sha256':
                'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
          }
        : const {
            'commit': 'fa079b6c5880814e231981a7bd5ed97df192d215',
            'state_sha256':
                'e9f87d4bf73b75d77bd7b04ddf111cbf6b64e796259ffe42adadea9bbb3270e2',
            'factory_sha256': null,
          };
    final factory = File(
      'lib/ui_v2/act0_shell/act0_asm05_authored_decision_truth_v1.dart',
    );
    final producerReceipt = {
      'head':
          (Process.runSync('git', ['rev-parse', 'HEAD']).stdout as String)
              .trim(),
      'state_sha256': sha256
          .convert(
            File(
              'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
            ).readAsBytesSync(),
          )
          .toString(),
      'factory_sha256': isCandidate && factory.existsSync()
          ? sha256.convert(factory.readAsBytesSync()).toString()
          : null,
    };
    final artifactRecords = {
      for (final id in admittedAdditions)
        if (presentAdditions.contains(id))
          id: [
            contract[id],
            fingerprints[id],
            choiceIdentity[id],
            snapshot[id],
          ],
    };
    File('${out.path}/typed-cohort-v2.json').writeAsStringSync(
      jsonEncode({
        'schema': 2,
        'role': isCandidate ? 'candidate' : 'historical_baseline',
        'admitted_source_reference': sourceReference,
        'producer_receipt': producerReceipt,
        'historical_ids': baselineContract.keys.toList()..sort(),
        'new_authoring': [
          for (final world in Act0ShellStateV1.sample.worlds)
            for (final lesson in world.lessons)
              for (final task in lesson.taskList)
                if (presentAdditions.contains(task.taskId))
                  {
                    'task_id': task.taskId,
                    'world_id': world.worldId,
                    'lesson_id': lesson.lessonId,
                    'provenance': 'NEW_AUTHORING_ASM05',
                    'artifact_sha256': sha256
                        .convert(
                          utf8.encode(
                            jsonEncode(artifactRecords[task.taskId]),
                          ),
                        )
                        .toString(),
                    'source_binding_sha256': sha256
                        .convert(
                          utf8.encode(
                            jsonEncode([
                              sourceReference,
                              task.taskId,
                              artifactRecords[task.taskId],
                            ]),
                          ),
                        )
                        .toString(),
                  },
        ],
      }),
    );
    final failures = rows.where((r) => r.result == 'FAIL').toList();
    final byInvariant = <String, Set<String>>{};
    for (final r in failures) {
      byInvariant.putIfAbsent(r.invariant, () => <String>{}).add(r.taskId);
    }
    stdout.writeln(
      'TABLE_TRUTH tasks=${tasks.length} variants=${rows.map((r) => '${r.taskId}|${r.variant}').toSet().length} rows=${rows.length}',
    );
    stdout.writeln(
      jsonEncode({
        for (final e in byInvariant.entries) e.key: e.value.toList()..sort(),
      }),
    );
    if (Platform.environment['TABLE_TRUTH_CENSUS_ONLY'] != '1') {
      expect(
        failures.map((r) => r.key),
        isEmpty,
        reason: 'Confirmed invariants must have exact disposition',
      );
    }
  });
}

Map<String, Object?> _table(Act0TableStateV1 t) => {
  'scope': t.scope.name,
  'hero': t.heroCards.map(cardIdentity).toList(),
  'board': t.boardCards.map(cardIdentity).toList(),
  'street': t.streetLabel,
  'pot': t.potLabel,
  'call': t.toCallLabel,
  'center': t.centerLabel,
  'actor': t.activeSeatId,
  'heroSeat': t.heroSeatId,
  'focusSeats': t.highlightedSeatIds,
  'focusCards': t.highlightedCardIds,
  'trail': [
    for (final a in t.actionTrail) {'kind': a.kind.name, 'label': a.label},
  ],
  'seats': [
    for (final s in t.seats)
      {
        'id': s.seatId,
        'hero': s.isHero,
        'active': s.isActive,
        'inHand': s.isInHand,
        'folded': s.isFolded,
        'occupied': s.isOccupied,
        'acted': s.hasActed,
        'mode': s.cardsVisibleMode.name,
        'cards': s.holeCards.map(cardIdentity).toList(),
        'blind': s.blindAmountLabel,
        'currentBet': s.currentBetLabel,
        'bet': s.bet == null
            ? null
            : {
                'kind': s.bet!.kind.name,
                'label': s.bet!.label,
                'amount': s.bet!.amountLabel,
              },
      },
  ],
};

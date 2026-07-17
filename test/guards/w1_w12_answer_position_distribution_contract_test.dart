import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _contractPath = 'tools/contracts/w1_w12_assessment_fingerprint_v1.json';

void main() {
  test('W1-W12 assessed tasks use stable non-exploitable authored order', () {
    final rows = _assessedRows();
    final contract = _fingerprintContract();
    final actualFingerprint = _contentFingerprint(rows);
    final status = _freshnessStatus(
      expectedFingerprint: contract.fingerprint,
      actualFingerprint: actualFingerprint,
      expectedInputHashes: contract.inputHashes,
      actualInputHashes: _inputHashes(contract.inputHashes.keys),
    );

    expect(rows, hasLength(contract.rowCount));
    expect(
      actualFingerprint,
      contract.fingerprint,
      reason: '$status: run the bounded W1-W12 adjudication before pinning.',
    );
    expect(status, _FingerprintFreshnessStatus.currentAndValid);
    expect(_positionSnapshot(_assessedRows()), _positionSnapshot(rows));
    expect(rows.map((row) => row.worldId).toSet(), <String>{
      'world_1',
      'world_2',
      'world_3',
      'world_4',
      'world_5',
      'world_6',
      'world_7',
      'world_8',
      'world_9',
      'world_10',
      'world_11',
      'world_12',
    });

    final byWorld = <String, List<int>>{};
    final checkpointByWorld = <String, List<int>>{};
    final repairTargetByWorld = <String, List<int>>{};
    final w10W12Indexes = <int>[];

    for (final row in rows) {
      final options = row.task.runner.options;
      final correctOptions = options.where((option) => option.isCorrect);

      expect(options, isNotEmpty, reason: row.task.taskId);
      expect(correctOptions, hasLength(1), reason: row.task.taskId);

      final correctIndex = options.indexWhere((option) => option.isCorrect);
      byWorld.putIfAbsent(row.worldId, () => <int>[]).add(correctIndex);
      if (row.isCheckpoint) {
        checkpointByWorld
            .putIfAbsent(row.worldId, () => <int>[])
            .add(correctIndex);
      }
      if (row.isRepairTarget) {
        repairTargetByWorld
            .putIfAbsent(row.worldId, () => <int>[])
            .add(correctIndex);
      }
      if (_w10W12.contains(row.worldId)) {
        w10W12Indexes.add(correctIndex);
      }
    }

    for (final worldId in _affectedWorldIds) {
      final indexes = byWorld[worldId]!;
      final distribution = _distribution(indexes);
      expect(
        _dominantShare(distribution, indexes.length),
        lessThanOrEqualTo(0.55),
        reason: '$worldId distribution=$distribution',
      );
      expect(_longestRun(indexes), lessThanOrEqualTo(2), reason: worldId);
      expect(
        distribution.keys,
        containsAll(<int>[0, 1]),
        reason: '$worldId must not teach one-position answering.',
      );
      if (_allRowsForWorld(
        rows,
        worldId,
      ).every((row) => row.optionCount >= 3)) {
        expect(
          distribution.keys,
          contains(2),
          reason: '$worldId has three-option assessments available.',
        );
      }
    }

    for (final entry in checkpointByWorld.entries) {
      if (entry.value.length > 1) {
        expect(
          entry.value.toSet(),
          hasLength(greaterThan(1)),
          reason: '${entry.key} checkpoint indexes=${entry.value}',
        );
        expect(
          _longestRun(entry.value),
          lessThanOrEqualTo(2),
          reason: '${entry.key} checkpoint indexes=${entry.value}',
        );
      }
    }

    for (final entry in repairTargetByWorld.entries) {
      if (entry.value.length > 1) {
        expect(
          entry.value.toSet(),
          hasLength(greaterThan(1)),
          reason: '${entry.key} repair-target indexes=${entry.value}',
        );
      }
    }

    expect(_distribution(w10W12Indexes), <int, int>{0: 14, 1: 14, 2: 14});
    expect(_longestRun(w10W12Indexes), lessThanOrEqualTo(2));

    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world13_')),
      isEmpty,
    );
    expect(kCampaignPackIdsV1, contains('volume_i_terminal_review_v1'));
  });

  test(
    'active Act0 assessment order is authored rather than runtime shuffled',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('.shuffle(')));
      expect(source, isNot(contains('Random(')));
    },
  );

  test('fingerprint freshness distinguishes source and generator drift', () {
    const expected = 'expected';
    const matchingInputs = <String, String>{'source.dart': 'same'};
    const changedInputs = <String, String>{'source.dart': 'changed'};

    expect(
      _freshnessStatus(
        expectedFingerprint: expected,
        actualFingerprint: expected,
        expectedInputHashes: matchingInputs,
        actualInputHashes: matchingInputs,
      ),
      _FingerprintFreshnessStatus.currentAndValid,
    );
    expect(
      _freshnessStatus(
        expectedFingerprint: expected,
        actualFingerprint: expected,
        expectedInputHashes: matchingInputs,
        actualInputHashes: changedInputs,
      ),
      _FingerprintFreshnessStatus.staleFingerprint,
    );
    expect(
      _freshnessStatus(
        expectedFingerprint: expected,
        actualFingerprint: 'changed',
        expectedInputHashes: matchingInputs,
        actualInputHashes: changedInputs,
      ),
      _FingerprintFreshnessStatus.contentDifferenceRequiresAdjudication,
    );
    expect(
      _freshnessStatus(
        expectedFingerprint: expected,
        actualFingerprint: 'changed',
        expectedInputHashes: matchingInputs,
        actualInputHashes: matchingInputs,
      ),
      _FingerprintFreshnessStatus.invalidFingerprint,
    );
  });
}

const _affectedWorldIds = <String>{
  'world_1',
  'world_2',
  'world_3',
  'world_4',
  'world_5',
  'world_6',
  'world_8',
  'world_9',
};

const _w10W12 = <String>{'world_10', 'world_11', 'world_12'};

List<_AssessedRow> _assessedRows() {
  final rows = <_AssessedRow>[];
  for (final world in Act0ShellStateV1.sample.worlds) {
    if (!RegExp(r'^world_([1-9]|1[0-2])$').hasMatch(world.worldId)) {
      continue;
    }
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        if (task.runner.options.isEmpty) {
          continue;
        }
        if (task.runner.options.where((option) => option.isCorrect).length !=
            1) {
          continue;
        }
        rows.add(
          _AssessedRow(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            task: task,
            optionCount: task.runner.options.length,
            isCheckpoint:
                lesson.lessonId.contains('checkpoint') ||
                task.taskId.contains('checkpoint'),
            isRepairTarget:
                task.stepKind == Act0LessonStepKindV1.fixMistakes ||
                task.resolvedTaskFamily == Act0TaskFamilyV1.repair ||
                task.taskId.contains('repair') ||
                task.runner.options.any(
                  (option) =>
                      option.repairFocusSeatIds.isNotEmpty ||
                      option.repairFocusCardIds.isNotEmpty ||
                      option.repairFocusLabels.isNotEmpty,
                ),
          ),
        );
      }
    }
  }
  return rows;
}

List<_AssessedRow> _allRowsForWorld(List<_AssessedRow> rows, String worldId) =>
    rows.where((row) => row.worldId == worldId).toList();

Map<int, int> _distribution(List<int> indexes) {
  final counts = <int, int>{};
  for (final index in indexes) {
    counts[index] = (counts[index] ?? 0) + 1;
  }
  return Map<int, int>.fromEntries(
    counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

double _dominantShare(Map<int, int> distribution, int total) =>
    distribution.values.reduce((a, b) => a > b ? a : b) / total;

String _contentFingerprint(List<_AssessedRow> rows) {
  final payload = rows
      .map((row) => jsonEncode(_fingerprintPayload(row)))
      .join('\n');
  return sha256.convert(utf8.encode(payload)).toString();
}

Map<String, Object?> _fingerprintPayload(_AssessedRow row) {
  final task = row.task;
  final options =
      task.runner.options
          .map(
            (option) => jsonEncode(<String, Object?>{
              'id': option.id,
              'label': option.label,
              'amountLabel': option.amountLabel,
              'seatId': option.seatId,
              'isCorrect': option.isCorrect,
              'preferredLabel': option.preferredLabel,
              'betterAnswerLabel': option.betterAnswerLabel,
              'quality': option.quality.name,
              'feedbackTitle': option.feedbackTitle,
              'feedbackReason': option.feedbackReason,
              'repairFocusSeatIds': option.repairFocusSeatIds,
              'repairFocusCardIds': option.repairFocusCardIds,
              'repairFocusLabels': option.repairFocusLabels,
            }),
          )
          .toList()
        ..sort();
  return <String, Object?>{
    'world': row.worldId,
    'lesson': row.lessonId,
    'task': task.taskId,
    'phase': task.phase.name,
    'stepKind': task.stepKind.name,
    'family': task.resolvedTaskFamily.name,
    'title': task.title,
    'summary': task.summary,
    'lockedSummary': task.lockedSummary,
    'caption': task.runner.caption,
    'hint': task.runner.hint,
    'question': task.runner.question,
    'feedbackTitle': task.runner.feedbackTitle,
    'feedbackReason': task.runner.feedbackReason,
    'options': options,
  };
}

List<String> _positionSnapshot(List<_AssessedRow> rows) {
  return rows
      .map(
        (row) =>
            '${row.worldId}/${row.lessonId}/${row.task.taskId}:'
            '${row.task.runner.options.indexWhere((option) => option.isCorrect)}',
      )
      .toList();
}

_FingerprintContract _fingerprintContract() {
  final decoded =
      jsonDecode(File(_contractPath).readAsStringSync())
          as Map<String, Object?>;
  final inputs = decoded['inputs']! as List<Object?>;
  return _FingerprintContract(
    baselineHead: decoded['baselineHead']! as String,
    fingerprint: decoded['fingerprint']! as String,
    rowCount: decoded['rowCount']! as int,
    inputHashes: Map<String, String>.fromEntries(
      inputs.map((input) {
        final item = input! as Map<String, Object?>;
        return MapEntry(item['path']! as String, item['sha256']! as String);
      }),
    ),
  );
}

Map<String, String> _inputHashes(Iterable<String> paths) =>
    Map<String, String>.fromEntries(
      paths.map(
        (path) => MapEntry(
          path,
          sha256.convert(File(path).readAsBytesSync()).toString(),
        ),
      ),
    );

_FingerprintFreshnessStatus _freshnessStatus({
  required String expectedFingerprint,
  required String actualFingerprint,
  required Map<String, String> expectedInputHashes,
  required Map<String, String> actualInputHashes,
}) {
  final inputsMatch =
      expectedInputHashes.length == actualInputHashes.length &&
      expectedInputHashes.entries.every(
        (entry) => actualInputHashes[entry.key] == entry.value,
      );
  if (inputsMatch && actualFingerprint == expectedFingerprint) {
    return _FingerprintFreshnessStatus.currentAndValid;
  }
  if (!inputsMatch && actualFingerprint == expectedFingerprint) {
    return _FingerprintFreshnessStatus.staleFingerprint;
  }
  if (!inputsMatch) {
    return _FingerprintFreshnessStatus.contentDifferenceRequiresAdjudication;
  }
  return _FingerprintFreshnessStatus.invalidFingerprint;
}

enum _FingerprintFreshnessStatus {
  staleFingerprint('STALE_FINGERPRINT'),
  invalidFingerprint('INVALID_FINGERPRINT'),
  contentDifferenceRequiresAdjudication(
    'CONTENT_DIFFERENCE_REQUIRES_ADJUDICATION',
  ),
  currentAndValid('CURRENT_AND_VALID');

  const _FingerprintFreshnessStatus(this.label);

  final String label;

  @override
  String toString() => label;
}

class _FingerprintContract {
  const _FingerprintContract({
    required this.baselineHead,
    required this.fingerprint,
    required this.rowCount,
    required this.inputHashes,
  });

  final String baselineHead;
  final String fingerprint;
  final int rowCount;
  final Map<String, String> inputHashes;
}

int _longestRun(List<int> indexes) {
  var longest = 0;
  var current = 0;
  int? previous;
  for (final index in indexes) {
    if (index == previous) {
      current += 1;
    } else {
      current = 1;
      previous = index;
    }
    if (current > longest) {
      longest = current;
    }
  }
  return longest;
}

class _AssessedRow {
  const _AssessedRow({
    required this.worldId,
    required this.lessonId,
    required this.task,
    required this.optionCount,
    required this.isCheckpoint,
    required this.isRepairTarget,
  });

  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;
  final int optionCount;
  final bool isCheckpoint;
  final bool isRepairTarget;
}

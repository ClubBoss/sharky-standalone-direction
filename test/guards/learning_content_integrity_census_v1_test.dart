import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// A deterministic, route-owned inventory. It deliberately distinguishes an
/// exact replay (available for every assessed row) from a mapped same-signal
/// target (available only when the canonical mapper returns another task).
void main() {
  test('canonical W1-W12 learning-content census remains adjudicated', () {
    final rows = _assessedRows();
    expect(rows, hasLength(291));

    final repairRows = rows.where((row) => row.incorrectOptions.isNotEmpty);
    final repair = repairRows.map(_repairRow).toList(growable: false);
    final incorrectOptions = <_IncorrectOptionRow>[
      for (final row in repairRows)
        for (final option in row.incorrectOptions)
          _incorrectOptionRow(row, option),
    ];
    final late = rows
        .where(
          (row) => const <String>{
            'world_9',
            'world_10',
            'world_11',
            'world_12',
          }.contains(row.worldId),
        )
        .map(_lateWorldRow)
        .toList(growable: false);

    final snapshot = <String, Object?>{
      'assessedRows': rows.length,
      'assessedByLesson': _countBy(
        rows,
        (row) => '${row.worldId}/${row.lessonId}',
      ),
      'optionCounts': _countBy(rows, (row) => '${row.optionCount}'),
      'optionCountsByWorld': _nestedCountBy(
        rows,
        outer: (row) => row.worldId,
        inner: (row) => '${row.optionCount}',
      ),
      'optionCountsCheckpoints': _countBy(
        rows.where((row) => row.isCheckpoint),
        (row) => '${row.optionCount}',
      ),
      'optionCountsRepairTargets': _countBy(
        rows.where((row) => row.isRepairTarget),
        (row) => '${row.optionCount}',
      ),
      'optionCountsW1W6': _countBy(
        rows.where((row) => row.worldNumber <= 6),
        (row) => '${row.optionCount}',
      ),
      'optionCountsW7W12': _countBy(
        rows.where((row) => row.worldNumber >= 7),
        (row) => '${row.optionCount}',
      ),
      'correctPositions': _countBy(rows, (row) => '${row.correctIndex}'),
      'longestCorrectPositionRun': _longestRun(
        rows.map((row) => row.correctIndex).toList(growable: false),
      ),
      'repair': <String, Object?>{
        'incorrectOptions': incorrectOptions.length,
        'currentErrorTypes': _countBy(
          incorrectOptions,
          (row) => row.currentErrorType,
        ),
        'worldsByErrorType': _groupedDistinctCount(
          incorrectOptions,
          outer: (row) => row.currentErrorType,
          value: (row) => row.row.worldId,
        ),
        'currentSourceSignals': _countBy(
          incorrectOptions,
          (row) => row.intent?.missedSignalId ?? 'UNCLASSIFIED',
        ),
        'incorrectCapable': repair.length,
        'exactReplayCovered': repair.where((row) => row.exactReplay).length,
        'sameSignalMapped': repair.where((row) => row.sameSignalMapped).length,
        'fallbackOnly': repair.where((row) => row.fallbackOnly).length,
        'intentionalExactReplay': repair
            .where((row) => row.mappingType == 'intentional_exact')
            .length,
        'unresolvedProductGap': repair
            .where((row) => row.mappingType == 'unresolved_product_gap')
            .length,
        'unrecordedFallback': repair
            .where((row) => row.mappingType == 'exact')
            .length,
        'unmapped': repair.where((row) => !row.intentAvailable).length,
        'byWorld': _countBy(repair, (row) => row.worldId),
        'mappedByWorld': _countBy(
          repair.where((row) => row.sameSignalMapped),
          (row) => row.worldId,
        ),
        'checkpointMapped': repair
            .where((row) => row.isCheckpoint && row.sameSignalMapped)
            .length,
        'checkpointTotal': repair.where((row) => row.isCheckpoint).length,
        'repairTargetMapped': repair
            .where((row) => row.isRepairTarget && row.sameSignalMapped)
            .length,
        'repairTargetTotal': repair.where((row) => row.isRepairTarget).length,
        'fallbackInventory': <Map<String, Object?>>[
          for (final row in repair.where((row) => row.fallbackOnly))
            row.toInventoryPayload(),
        ],
      },
      'lateWorldAuthenticity': _countBy(late, (row) => row.category),
      'lateWorldTableRequired': late.where((row) => row.tableRequired).length,
      'lateWorldActionConsequence': late
          .where((row) => row.actionConsequence)
          .length,
      'lateWorldTerminologyOnly': late
          .where((row) => row.terminologyOnly)
          .length,
    };
    // Kept in test output so the companion adjudication can record the full
    // machine-derived snapshot without maintaining a second source of truth.
    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(snapshot));

    expect(snapshot['optionCounts'], <String, int>{'2': 121, '3': 165, '4': 5});
    expect(snapshot['correctPositions'], <String, int>{
      '0': 112,
      '1': 115,
      '2': 62,
      '3': 2,
    });
    expect(snapshot['longestCorrectPositionRun'], 3);
    expect(snapshot['lateWorldAuthenticity'], <String, int>{
      'TABLE_ACTION_DECISION': 29,
      'TABLE_CLUE_OR_RANGE_INFERENCE': 29,
    });
    final repairSnapshot = snapshot['repair']! as Map<String, Object?>;
    expect(repairSnapshot['incorrectOptions'], 466);
    expect(repairSnapshot['exactReplayCovered'], 14);
    expect(repairSnapshot['sameSignalMapped'], 277);
    expect(repairSnapshot['fallbackOnly'], 14);
    expect(repairSnapshot['intentionalExactReplay'], 14);
    expect(repairSnapshot['unresolvedProductGap'], 0);
    expect(repairSnapshot['unrecordedFallback'], 0);
    expect(repairSnapshot['unmapped'], 0);
    expect(repairSnapshot['currentErrorTypes'], <String, int>{
      'confused_card_rank_suit': 5,
      'confused_chip_commitment_eligibility': 7,
      'confused_private_board_cards': 16,
      'confused_table_identity': 12,
      'misread_action_legality': 14,
      'misread_bet_price': 17,
      'misread_bet_purpose': 8,
      'misread_board_texture': 14,
      'misread_draw_outs': 21,
      'misread_mindset_discipline': 26,
      'misread_player_adjustment': 30,
      'misread_poker_win_condition': 8,
      'misread_position_action_order': 47,
      'misread_range_card_removal': 67,
      'misread_real_play_process': 28,
      'misread_showdown_hand_strength': 25,
      'misread_stack_depth_risk': 34,
      'misread_starting_hand_discipline': 37,
      'misread_table_position': 18,
      'misread_tournament_pressure': 32,
    });
    expect(act0ConceptErrorDefinitionsV1, hasLength(20));
    expect(act0RepairGapAdjudicationsV1, hasLength(34));

    final w7 = Act0ShellStateV1.sample.worldById('world_7');
    final w7Surface = w7.lessons
        .expand((lesson) => lesson.taskList)
        .map(
          (task) => <String>[
            task.title,
            task.runner.caption,
            task.runner.hint,
            task.runner.question,
            task.runner.feedbackTitle,
            task.runner.feedbackReason,
            for (final step in task.runner.teachingSteps) step.title,
            for (final step in task.runner.teachingSteps) step.body,
            for (final step in task.runner.teachingSteps) ...step.focusLabels,
          ].join(' '),
        )
        .join(' ')
        .toLowerCase();
    expect(w7Surface, isNot(contains('w7_combo_density_visible_card_removal')));

    final firstTable = rows.singleWhere(
      (row) => row.task.taskId == 'what_poker_is_theory',
    );
    expect(firstTable.task.runner.question, contains('have acted'));
    expect(firstTable.task.runner.question, isNot(contains('hero seat')));

    final value = rows.singleWhere(
      (row) => row.task.taskId == 'w4_value_missed',
    );
    expect(value.task.runner.question, startsWith('What action best'));
    expect(
      value.task.runner.options.singleWhere((option) => option.isCorrect).id,
      'bet_half',
    );
  });
}

List<_Row> _assessedRows() => <_Row>[
  for (final world in Act0ShellStateV1.sample.worlds)
    if (RegExp(r'^world_([1-9]|1[0-2])$').hasMatch(world.worldId))
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          if (task.runner.options.length >= 2 &&
              task.runner.options.where((option) => option.isCorrect).length ==
                  1)
            _Row(world.worldId, lesson.lessonId, task),
];

_RepairRow _repairRow(_Row row) {
  final intents = row.incorrectOptions
      .map(
        (option) => buildAct0RepairIntentV1(
          sourceWorldId: row.worldId,
          sourceLessonId: row.lessonId,
          sourceTaskId: row.task.taskId,
          runner: row.task.runner,
          selectedOption: option,
          mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
        ),
      )
      .whereType<Act0RepairIntentV1>()
      .toList(growable: false);
  final sameSignal = intents.any(
    (intent) =>
        intent.mappingType != 'exact' && intent.targetTaskId != row.task.taskId,
  );
  return _RepairRow(
    row,
    intents,
    row.worldId,
    isCheckpoint: row.isCheckpoint,
    isRepairTarget: row.isRepairTarget,
    exactReplay: intents.any(
      (intent) => intent.mappingType == 'intentional_exact',
    ),
    sameSignalMapped: sameSignal,
  );
}

_IncorrectOptionRow _incorrectOptionRow(_Row row, Act0RunnerOptionV1 option) {
  final intent = buildAct0RepairIntentV1(
    sourceWorldId: row.worldId,
    sourceLessonId: row.lessonId,
    sourceTaskId: row.task.taskId,
    runner: row.task.runner,
    selectedOption: option,
    mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
  );
  return _IncorrectOptionRow(row, option, intent);
}

_LateWorldRow _lateWorldRow(_Row row) {
  final copy = <String>[
    row.task.title,
    row.task.runner.caption,
    row.task.runner.hint,
    row.task.runner.question,
    for (final option in row.task.runner.options) option.label,
  ].join(' ').toLowerCase();
  final action = RegExp(r'\b(fold|call|check|bet|raise|jam)\b').hasMatch(copy);
  final table =
      row.task.runner.table.boardCards.isNotEmpty ||
      row.task.runner.table.heroCards.isNotEmpty ||
      row.task.runner.table.actionTrail.isNotEmpty;
  final category = action
      ? 'TABLE_ACTION_DECISION'
      : table
      ? 'TABLE_CLUE_OR_RANGE_INFERENCE'
      : 'CONCEPTUAL_OR_VERBAL_RECALL';
  return _LateWorldRow(
    category,
    tableRequired: table,
    actionConsequence: action,
    terminologyOnly: !table && !action,
  );
}

Map<String, int> _countBy<T>(Iterable<T> values, String Function(T) key) {
  final result = <String, int>{};
  for (final value in values) {
    result.update(key(value), (count) => count + 1, ifAbsent: () => 1);
  }
  return Map<String, int>.fromEntries(
    result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

Map<String, Map<String, int>> _nestedCountBy<T>(
  Iterable<T> values, {
  required String Function(T) outer,
  required String Function(T) inner,
}) {
  final grouped = <String, List<T>>{};
  for (final value in values) {
    grouped.putIfAbsent(outer(value), () => <T>[]).add(value);
  }
  return Map<String, Map<String, int>>.fromEntries(
    grouped.entries.map(
      (entry) => MapEntry(entry.key, _countBy(entry.value, inner)),
    ),
  );
}

Map<String, int> _groupedDistinctCount<T>(
  Iterable<T> values, {
  required String Function(T) outer,
  required String Function(T) value,
}) {
  final grouped = <String, Set<String>>{};
  for (final item in values) {
    grouped.putIfAbsent(outer(item), () => <String>{}).add(value(item));
  }
  return Map<String, int>.fromEntries(
    grouped.entries.map((entry) => MapEntry(entry.key, entry.value.length)),
  );
}

int _longestRun(List<int> values) {
  var longest = 0;
  var current = 0;
  int? previous;
  for (final value in values) {
    current = value == previous ? current + 1 : 1;
    previous = value;
    if (current > longest) longest = current;
  }
  return longest;
}

class _Row {
  const _Row(this.worldId, this.lessonId, this.task);
  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;
  int get optionCount => task.runner.options.length;
  int get correctIndex =>
      task.runner.options.indexWhere((option) => option.isCorrect);
  int get worldNumber => int.parse(worldId.substring('world_'.length));
  bool get isCheckpoint =>
      lessonId.contains('checkpoint') || task.taskId.contains('checkpoint');
  bool get isRepairTarget =>
      task.stepKind == Act0LessonStepKindV1.fixMistakes ||
      task.resolvedTaskFamily == Act0TaskFamilyV1.repair ||
      task.taskId.contains('repair') ||
      task.runner.options.any(
        (option) =>
            option.repairFocusSeatIds.isNotEmpty ||
            option.repairFocusCardIds.isNotEmpty ||
            option.repairFocusLabels.isNotEmpty,
      );
  Iterable<Act0RunnerOptionV1> get incorrectOptions =>
      task.runner.options.where((option) => !option.isCorrect);
}

class _RepairRow {
  const _RepairRow(
    this.row,
    this.intents,
    this.worldId, {
    required this.isCheckpoint,
    required this.isRepairTarget,
    required this.exactReplay,
    required this.sameSignalMapped,
  });
  final _Row row;
  final List<Act0RepairIntentV1> intents;
  final String worldId;
  final bool isCheckpoint;
  final bool isRepairTarget;
  final bool exactReplay;
  final bool sameSignalMapped;
  bool get fallbackOnly => !sameSignalMapped;
  bool get intentAvailable => intents.length == row.incorrectOptions.length;
  String get mappingType =>
      intents.isEmpty ? 'unclassified' : intents.first.mappingType;

  Map<String, Object?> toInventoryPayload() => <String, Object?>{
    'world': row.worldId,
    'lesson': row.lessonId,
    'task': row.task.taskId,
    'taskFamily': row.task.resolvedTaskFamily.name,
    'incorrectOptions': <Map<String, Object?>>[
      for (final incorrect in row.incorrectOptions.map(
        (option) => _incorrectOptionRow(row, option),
      ))
        <String, Object?>{
          'optionId': incorrect.option.id,
          'result': incorrect.intent?.result ?? 'unclassified',
          'errorType': incorrect.currentErrorType,
          'skillAtomId': incorrect.intent?.skillAtomId ?? '',
          'missedSignalId': incorrect.intent?.missedSignalId ?? '',
          'repairFocusLabels': incorrect.option.repairFocusLabels,
        },
    ],
    'currentFallback': intents.isEmpty
        ? 'unclassified'
        : intents.first.mappingType,
  };
}

class _IncorrectOptionRow {
  const _IncorrectOptionRow(this.row, this.option, this.intent);

  final _Row row;
  final Act0RunnerOptionV1 option;
  final Act0RepairIntentV1? intent;

  String get currentErrorType =>
      intent?.errorType ?? 'UNCLASSIFIED_NO_REPAIR_INTENT';
}

class _LateWorldRow {
  const _LateWorldRow(
    this.category, {
    required this.tableRequired,
    required this.actionConsequence,
    required this.terminologyOnly,
  });
  final String category;
  final bool tableRequired;
  final bool actionConsequence;
  final bool terminologyOnly;
}

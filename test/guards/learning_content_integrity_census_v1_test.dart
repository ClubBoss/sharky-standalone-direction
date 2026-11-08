import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _asm05NewTaskIds = <String>{
  'asm05_new_known_holes_turn_call_10',
  'asm05_new_known_holes_turn_call_40',
};

/// A deterministic, route-owned inventory. It deliberately distinguishes an
/// exact replay (available for every assessed row) from a mapped same-signal
/// target (available only when the canonical mapper returns another task).
void main() {
  test('canonical W1-W12 learning-content census remains adjudicated', () {
    final allRows = _assessedRows();
    expect(allRows, hasLength(293));
    expect(
      allRows
          .where((row) => _asm05NewTaskIds.contains(row.task.taskId))
          .map((row) => row.task.taskId),
      _asm05NewTaskIds,
    );
    // Preserve every historical cohort assertion below. The separate ASM05
    // test covers the entire extension and retains the zero-gap repair gate.
    final rows = allRows
        .where((row) => !_asm05NewTaskIds.contains(row.task.taskId))
        .toList(growable: false);
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
    print('LEGACY_291_CENSUS');
    print(const JsonEncoder.withIndent('  ').convert(snapshot));

    expect(snapshot['optionCounts'], <String, int>{'2': 121, '3': 169, '4': 1});
    expect(snapshot['correctPositions'], <String, int>{
      '0': 112,
      '1': 116,
      '2': 63,
    });
    expect(snapshot['longestCorrectPositionRun'], 4);
    expect(snapshot['lateWorldAuthenticity'], <String, int>{
      'TABLE_ACTION_DECISION': 29,
      'TABLE_CLUE_OR_RANGE_INFERENCE': 29,
    });
    final repairSnapshot = snapshot['repair']! as Map<String, Object?>;
    expect(repairSnapshot['incorrectOptions'], 462);
    expect(repairSnapshot['exactReplayCovered'], 15);
    expect(repairSnapshot['sameSignalMapped'], 276);
    expect(repairSnapshot['fallbackOnly'], 15);
    expect(repairSnapshot['intentionalExactReplay'], 15);
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
      'misread_range_card_removal': 63,
      'misread_real_play_process': 28,
      'misread_showdown_hand_strength': 25,
      'misread_stack_depth_risk': 34,
      'misread_starting_hand_discipline': 37,
      'misread_table_position': 18,
      'misread_tournament_pressure': 32,
    });
    expect(act0ConceptErrorDefinitionsV1, hasLength(20));
    expect(act0RepairGapAdjudicationsV1, hasLength(36));
    final fallbackInventory = (repairSnapshot['fallbackInventory'] as List)
        .cast<Map<String, Object?>>();
    final coPlayersBehindFallback = fallbackInventory.singleWhere(
      (row) =>
          row['task'] == 'position_checkpoint_position_checkpoint_table_notice',
    );
    expect(coPlayersBehindFallback['lesson'], 'position_checkpoint');
    expect(coPlayersBehindFallback['currentFallback'], 'intentional_exact');
    expect(
      (coPlayersBehindFallback['incorrectOptions'] as List)
          .cast<Map<String, Object?>>()
          .map((row) => row['optionId']),
      <String>['acts_last', 'late_free_pass'],
    );
    for (final option
        in (coPlayersBehindFallback['incorrectOptions'] as List)
            .cast<Map<String, Object?>>()) {
      expect(option['errorType'], 'misread_position_action_order');
      expect(option['skillAtomId'], 'table_position_read');
      expect(option['missedSignalId'], 'players_behind');
      expect(option['missedSignalId'], isNot('hero_button'));
      expect(option['missedSignalId'], isNot('pot_to_call'));
    }

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

  test('two ASM05 rows retain full census and require admitted repair', () {
    final rows = _assessedRows();
    final additions = rows
        .where((row) => _asm05NewTaskIds.contains(row.task.taskId))
        .toList(growable: false);
    expect(rows, hasLength(293));
    expect(additions.map((row) => row.task.taskId), _asm05NewTaskIds);
    expect(rows.map((row) => row.task.taskId).toSet(), hasLength(293));
    expect(_countBy(rows, (row) => '${row.optionCount}'), <String, int>{
      '2': 123,
      '3': 169,
      '4': 1,
    });
    expect(_countBy(rows, (row) => '${row.correctIndex}'), <String, int>{
      '0': 113,
      '1': 117,
      '2': 63,
    });
    expect(_longestRun(rows.map((row) => row.correctIndex).toList()), 4);
    final late = rows.where((row) => row.worldNumber >= 9).map(_lateWorldRow);
    expect(_countBy(late, (row) => row.category), <String, int>{
      'TABLE_ACTION_DECISION': 31,
      'TABLE_CLUE_OR_RANGE_INFERENCE': 29,
    });

    final extensionRepair = <_RepairRow>[];
    for (final row in additions) {
      final price = row.task.taskId.endsWith('_10') ? 10 : 40;
      expect(row.worldId, 'world_12');
      expect(row.lessonId, 'decision_over_outcome');
      expect(row.task.phase, Act0LessonPhaseV1.drill);
      expect(row.task.stepKind, Act0LessonStepKindV1.practice);
      expect(row.task.resolvedTaskFamily, Act0TaskFamilyV1.decision);
      expect(row.task.rewardXp, 0);
      expect(row.isCheckpoint, isFalse);
      expect(row.isRepairTarget, isFalse);
      expect(row.optionCount, 2);
      expect(row.correctIndex, price == 10 ? 1 : 0);
      expect(row.task.runner.options.map((option) => option.id), [
        'fold',
        'call',
      ]);
      expect(row.task.runner.options.map((option) => option.label), [
        'Fold',
        'Call',
      ]);
      expect(row.task.runner.options.map((option) => option.amountLabel), [
        '',
        '$price BB',
      ]);
      for (final option in row.task.runner.options) {
        expect(option.isCorrect, option.id == (price == 10 ? 'call' : 'fold'));
        expect(
          option.quality,
          option.isCorrect
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
        );
        expect(option.preferredLabel, price == 10 ? 'Call' : 'Fold');
      }
      final authenticity = _lateWorldRow(row);
      expect(authenticity.category, 'TABLE_ACTION_DECISION');
      expect(authenticity.tableRequired, isTrue);
      expect(authenticity.actionConsequence, isTrue);
      expect(authenticity.terminologyOnly, isFalse);
      expect(row.incorrectOptions, hasLength(1));
      final wrong = row.incorrectOptions.single;
      expect(wrong.id, price == 10 ? 'fold' : 'call');
      final incorrect = _incorrectOptionRow(row, wrong);
      expect(incorrect.currentErrorType, 'misread_mindset_discipline');
      final repair = _repairRow(row);
      expect(repair.intentAvailable, isTrue);
      expect(repair.intents, hasLength(1));
      final intent = repair.intents.single;
      expect(intent.sourceWorldId, 'world_12');
      expect(intent.sourceLessonId, 'decision_over_outcome');
      expect(intent.sourceTaskId, row.task.taskId);
      expect(intent.choiceId, wrong.id);
      expect(intent.result, 'incorrect');
      expect(intent.errorType, 'misread_mindset_discipline');
      expect(intent.skillAtomId, 'mindset_process_discipline');
      expect(intent.missedSignalId, 'process_over_outcome');
      expect(intent.mappingType, 'repair');
      expect(intent.targetWorldId, 'world_12');
      expect(intent.targetLessonId, 'decision_over_outcome');
      expect(
        intent.targetTaskId,
        price == 10
            ? 'asm05_new_known_holes_turn_call_40'
            : 'asm05_new_known_holes_turn_call_10',
      );
      expect(repair.sameSignalMapped, isTrue);
      expect(repair.fallbackOnly, isFalse);
      expect(repair.exactReplay, isFalse);
      extensionRepair.add(repair);
    }

    final allRepair = rows.map(_repairRow).toList(growable: false);
    final incorrect = <_IncorrectOptionRow>[
      for (final row in rows)
        for (final option in row.incorrectOptions)
          _incorrectOptionRow(row, option),
    ];
    expect(incorrect, hasLength(464));
    expect(allRepair.where((row) => row.sameSignalMapped), hasLength(278));
    expect(allRepair.where((row) => row.fallbackOnly), hasLength(15));
    expect(allRepair.where((row) => row.exactReplay), hasLength(15));
    expect(
      incorrect.where(
        (row) => row.currentErrorType == 'misread_mindset_discipline',
      ),
      hasLength(28),
    );
    // Preserve actual route output for a bounded probe before the admission
    // assertion. A raw 'exact' fallback is not an accepted repair disposition.
    print(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'cohort': 'ASM05_EXTENSION_2_WITH_AGGREGATE_293',
        'sameSignalMapped': allRepair
            .where((row) => row.sameSignalMapped)
            .length,
        'fallbackOnly': allRepair.where((row) => row.fallbackOnly).length,
        'intentionalExactReplay': allRepair
            .where((row) => row.exactReplay)
            .length,
        'unrecordedFallback': allRepair
            .where((row) => row.mappingType == 'exact')
            .length,
        'newRows': <Map<String, Object?>>[
          for (final repair in extensionRepair)
            <String, Object?>{
              ...repair.toInventoryPayload(),
              'targetWorld': repair.intents.single.targetWorldId,
              'targetLesson': repair.intents.single.targetLessonId,
              'targetTask': repair.intents.single.targetTaskId,
            },
        ],
      }),
    );
    expect(
      allRepair.where((row) => row.mappingType == 'exact'),
      isEmpty,
      reason:
          'Both new ASM05 rows require explicit repair admission; '
          'do not accept two new unrecorded exact fallbacks.',
    );
    expect(
      allRepair.where((row) => row.mappingType == 'unresolved_product_gap'),
      isEmpty,
    );
    expect(allRepair.where((row) => !row.intentAvailable), isEmpty);
    for (final repair in extensionRepair) {
      expect(repair.sameSignalMapped || repair.exactReplay, isTrue);
    }
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

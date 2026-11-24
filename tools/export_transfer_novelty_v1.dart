// Flutter catalog adapter. The comparison and report run on the Dart VM.
// Run through export_catalog_v1_test.dart with TRANSFER_NOVELTY=true or invoke
// main with the Flutter engine.
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_ids_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_chart_v1.dart';

import '../test/support/act0_catalog_poker_facts_v1.dart';
import '../test/support/act0_practice_generator_v1.dart';
import 'export_answer_positions_v1.dart' show act0AuthoredRepeatPairsV1;

typedef _Task = ({
  int world,
  String worldId,
  String lessonId,
  Act0LessonTaskV1 task,
});

const _batchSize = 8;
const _sourceSeed = 1;
const _siblingSeed = 2;
const _firstDailyDay = 20781;

Map<String, Object?> _snapshot(
  Act0LessonTaskV1 task, [
  Map<String, Object?> metadata = const {},
]) {
  final runner = task.runner;
  final table = runner.table;
  final ledger = table.handContributions;
  final seats = [...table.seats]..sort((a, b) => a.seatId.compareTo(b.seatId));
  final hero =
      table.heroSeatId ??
      seats.where((seat) => seat.isHero).singleOrNull?.seatId;
  final actor = table.decisionSeatId ?? hero;
  double? price;
  double? pot;
  double? decisionPot;
  if (ledger != null && actor != null) {
    try {
      final amounts = ledger.amounts(
        seatIds: seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: actor,
      );
      price = amounts.toCallBb;
      decisionPot = amounts.potBb;
      if (ledger.fromStreet == PokerStreet.preflop) pot = amounts.potBb;
    } on FormatException {
      // Invalid ledger data cannot supply the price or pot.
    }
  }
  final options = runner.options;
  final preferred = options.where(act0RunnerOptionIsPreferredV1).toList();
  final hasStableChoices =
      options.isNotEmpty &&
      !runner.sizingConfig.isEnabled &&
      options.every(
        (option) =>
            option.id.isNotEmpty &&
            option.amountLabel.isEmpty &&
            !RegExp(r'^(choice|wrong|option)_?\d+$').hasMatch(option.id),
      );
  String action(Act0RunnerOptionV1 option) =>
      jsonEncode([option.id, option.seatId]);
  final facts = CatalogPokerFacts(table);
  final handCode = facts.code;
  final rank = facts.rank;
  final handBucket =
      metadata['draw_kind'] ??
      metadata['chart_group'] ??
      (ledger?.throughStreet == PokerStreet.preflop &&
              act0ChartHandsV1.contains(handCode)
          ? act0ChartGroupV1(handCode!).name
          : rank == null
          ? null
          : [
              rank,
              facts.pairType,
              facts.flushSuits.isNotEmpty,
              facts.openEnded,
              facts.gutshot,
              facts.backdoorFlush,
              facts.backdoorStraight,
            ]);

  final equity = metadata['win_pct'];
  final threshold = metadata['req_pct'];
  final callEv = metadata['call_ev_bb'];
  final betEv = metadata['bet_ev_bb'];
  final checkEv = metadata['check_ev_bb'];
  final effectiveStack = metadata['effective_stack_bb'];
  final requiredStack = metadata['required_stack_bb'];
  final thresholdBucket = switch ((
    equity,
    threshold,
    callEv,
    betEv,
    checkEv,
    effectiveStack,
    requiredStack,
  )) {
    (num share, num required, _, _, _, _, _) => [
      'equity',
      (share - required).sign,
    ],
    (_, _, num ev, _, _, _, _) => ['equity', ev.sign],
    (_, _, _, num bet, num check, _, _) => ['bet', (bet - check).sign],
    (_, _, _, _, _, num depth, num required) => [
      'stack',
      (depth - required).sign,
    ],
    _ when price == 0 && !table.showDecisionPremise => ['no_call'],
    _ => null,
  };
  List<List<String>> cards(List<Act0CardStateV1> values) => [
    for (final card in values) [card.rank, card.suit],
  ];

  return {
    'id': task.taskId,
    'position': hero == null || actor == null ? null : [hero, actor],
    'price': price,
    'decisionPotBb': decisionPot,
    'equityPct': equity,
    'thresholdBucket': thresholdBucket,
    'handBucket': handBucket,
    'actionSet': hasStableChoices ? options.map(action).toList() : null,
    'answer': hasStableChoices && preferred.isNotEmpty
        ? preferred.map(action).toList()
        : null,
    'spot': ledger == null || pot == null
        ? null
        : jsonEncode([
            table.scope.name,
            table.tableFormat.name,
            table.playerCount,
            ledger.throughStreet.name,
            pot,
            facts.boardTone,
            facts.pairedBoard,
            facts.consecutiveBoard,
            metadata['bet_bb'],
            requiredStack,
            effectiveStack,
            for (final entry in ledger.entries)
              [
                entry.street.name,
                entry.seatId,
                entry.kind.name,
                entry.amountBb,
              ],
            for (final seat in seats)
              [
                seat.seatId,
                seat.isOccupied,
                seat.isInHand,
                seat.isFolded,
                seat.isLastAggressor,
                ledger.startingStackBbBySeat[seat.seatId],
                ledger.minimumStartingStackBbBySeat[seat.seatId],
              ],
          ]),
    'cosmetics': jsonEncode([
      cards(table.heroCards),
      cards(table.boardCards),
      for (final seat in seats)
        [
          seat.seatId,
          seat.displayName,
          if (seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
            cards(seat.holeCards),
        ],
    ]),
  };
}

bool _reviewable(Act0LessonTaskV1 task) =>
    task.multiStreet == null &&
    task.phase != Act0LessonPhaseV1.theory &&
    task.runner.options.isNotEmpty;

// Mirror the source family precedence of the completion receipt and durable
// retention contract. Any compatible unseen target can be chosen after earlier
// targets have been exposed. The actual due item depends on learner history.
Set<String> _reviewFamilies(_Task source) {
  final task = source.task;
  final concept = act0ConceptErrorDefinitionForTaskV1(
    worldId: source.worldId,
    lessonId: source.lessonId,
    taskId: task.taskId,
  );
  final reviewFamily = act0NewReviewConceptFamilyV1(
    source.worldId,
    source.lessonId,
    task.taskId,
  );
  final families = <String>{};
  for (final option in task.runner.options) {
    final receipt = act0FirstValueSkillReceiptForRunnerV1(
      runner: task.runner,
      option: option,
      taskFamily: task.resolvedTaskFamily,
    );
    final family =
        reviewFamily ??
        receipt?.sourceSignalId ??
        concept?.id ??
        receipt?.skillAtomId ??
        (option.isCorrect
            ? 'none'
            : act0CanonicalErrorTypeForDecisionV1(
                result: option.quality == Act0FeedbackQualityV1.suboptimal
                    ? 'suboptimal'
                    : 'incorrect',
                skillAtomId: concept?.eligibleRepairFamily ?? 'unknown',
                sourceTaskId: task.taskId,
                sourceWorldId: source.worldId,
                sourceLessonId: source.lessonId,
              ));
    if (family.trim().isNotEmpty && family != 'none') {
      families.add(
        act0Day7FamilyForSourceV1(
          worldId: source.worldId,
          lessonId: source.lessonId,
          taskId: task.taskId,
          family: family,
        ),
      );
    }
  }
  return families;
}

void main() {
  const out = String.fromEnvironment(
    'OUT',
    defaultValue: 'output/b44/catalog.json',
  );
  final worlds = Act0ShellStateV1.sample.worlds.where(
    (w) => w.worldNumber <= 12,
  );
  final authored = <_Task>[
    for (final world in worlds)
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          (
            world: world.worldNumber,
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            task: task,
          ),
  ];
  final byId = {for (final source in authored) source.task.taskId: source};
  final pairs = <Map<String, Object?>>[];

  void add(
    int world,
    Act0LessonTaskV1 source,
    Act0LessonTaskV1 repeat,
    String kind, {
    String? family,
    Map<String, Object?> sourceMetadata = const {},
    Map<String, Object?> repeatMetadata = const {},
  }) {
    pairs.add({
      'world': world,
      'kind': kind,
      'generatorFamily': family,
      'source': _snapshot(source, sourceMetadata),
      'repeat': _snapshot(repeat, repeatMetadata),
    });
  }

  for (final ids in act0AuthoredRepeatPairsV1) {
    final source = byId[ids.first]!;
    add(source.world, source.task, byId[ids.last]!.task, 'authored');
  }
  final reviewSources = [
    ...authored.where((source) => _reviewable(source.task)),
    for (final entry in [...act0W1RulesReviewTasksV1, ...act0NewReviewTasksV1])
      if (authored.any(
        (source) =>
            source.worldId == entry.worldId &&
            source.lessonId == entry.lessonId,
      ))
        (
          world: int.parse(entry.worldId.substring('world_'.length)),
          worldId: entry.worldId,
          lessonId: entry.lessonId,
          task: entry.task,
        ),
  ];
  for (final source in reviewSources) {
    add(source.world, source.task, source.task, 'day2');
    add(source.world, source.task, source.task, 'day7');
    final families = _reviewFamilies(source);
    for (final target in act0NewReviewTasksV1) {
      if (target.worldId == source.worldId &&
          target.lessonId == source.lessonId &&
          families.contains(target.conceptFamilyId) &&
          target.task.taskId != source.task.taskId) {
        add(source.world, source.task, target.task, 'day7');
      }
    }
  }

  for (final source in authored.where(
    (source) =>
        !source.task.repairOnly &&
        source.task.entryPhase == Act0LessonPhaseV1.drill,
  )) {
    final template = act0DailyDealTemplateForSourceV1(source.task.taskId);
    if (template == null) continue;
    for (var day = _firstDailyDay; day < _firstDailyDay + _batchSize; day++) {
      final repeat = act0GenerateDailyDealV1(
        taskId: act0DailyDealIdV1((
          day: day,
          template: template,
          lessonId: source.lessonId,
          sourceTaskId: source.task.taskId,
        )),
        lessonId: source.lessonId,
        template: template,
        seed: day * 31 + template.index,
        sourceTaskId: source.task.taskId,
      );
      if (repeat != null) add(source.world, source.task, repeat, 'dailyDeal');
    }
  }

  void compareBatches(
    String family,
    List<GeneratedPracticeTaskV1> Function(int seed) generate,
  ) {
    final sources = generate(_sourceSeed);
    final repeats = generate(_siblingSeed);
    if (sources.length != repeats.length) {
      throw StateError('$family sibling batches have different lengths');
    }
    for (final (index, source) in sources.indexed) {
      final repeat = repeats[index];
      add(
        source.worldNumber,
        source.task,
        repeat.task,
        'generatedSibling',
        family: family,
        sourceMetadata: source.metadata,
        repeatMetadata: repeat.metadata,
      );
    }
  }

  // C1 is the open/turn generator suite. C2 is the seven postflop templates.
  compareBatches(
    'C1',
    (seed) => generateOpenFoldByChartTasksV1(count: _batchSize, seed: seed),
  );
  for (final mode in TurnOutsModeV1.values) {
    compareBatches(
      'C1',
      (seed) => generateTurnCallPriceWithOutsTasksV1(
        count: _batchSize,
        seed: seed,
        mode: mode,
      ),
    );
  }
  for (final skill in PostflopPracticeSkillV1.values) {
    compareBatches(
      'C2',
      (seed) =>
          generatePostflopPracticeV1(skill, count: _batchSize, seed: seed),
    );
  }

  File(out)
    ..createSync(recursive: true)
    ..writeAsStringSync(jsonEncode({'pairs': pairs}));
}

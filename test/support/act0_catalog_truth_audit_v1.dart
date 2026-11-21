import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_claims_v1.dart';
import 'act0_catalog_poker_facts_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_catalog_starting_chart_v1.dart';
import 'act0_pot_showdown_truth_v1.dart';

class CatalogAudit {
  final checks = <String, int>{};
  final ambiguous = <String, int>{};
  final findings = <String, Map<String, Object?>>{};
  final outsideChart = <String, String>{};
  final uncertainClaims = <String, String>{};

  void count(String rule, Map<String, int> counter) =>
      counter.update(rule, (n) => n + 1, ifAbsent: () => 1);

  void check(
    String rule,
    CatalogTask row,
    String anchor,
    bool? passes,
    String detail,
  ) {
    final world = row.world.worldNumber;
    final taskId = row.task.taskId;
    if (passes == null) {
      count(rule, ambiguous);
      uncertainClaims['$rule|$taskId|$anchor'] = detail;
      return;
    }
    count(rule, checks);
    if (passes) return;
    final id = '$rule|$taskId|$anchor';
    findings[id] = {
      'rule': rule,
      'world': world,
      'task_id': taskId,
      'target': world <= 4
          ? 'P8'
          : world <= 8
          ? 'L2'
          : 'после беты',
      'reason': detail,
    };
  }

  void dormant(String id, String owner) {
    count('4.reachability', checks);
    if (owner.isEmpty) return;
    findings['4.reachability|$id|$owner'] = {
      'rule': '4.reachability',
      'task_id': id,
      'target': 'после беты',
      'reason': 'Declared in $owner and unavailable from the W1–W12 catalog.',
    };
  }

  Map<String, Object?> toJson() => {
    'checks': checks,
    'ambiguous': ambiguous,
    'ambiguous_examples': uncertainClaims,
    'outside_starting_chart': outsideChart,
    'findings': findings,
  };
}

typedef _Copy = ({
  String surface,
  String text,
  Act0TableStateV1 table,
  bool label,
});

Iterable<_Copy> _copy(CatalogTask row) sync* {
  final task = row.task;
  final runner = task.runner;
  final table = runner.table;
  yield (surface: 'title', text: task.title, table: table, label: true);
  yield (surface: 'caption', text: runner.caption, table: table, label: false);
  yield (surface: 'Q', text: catalogQuestion(task), table: table, label: false);
  yield (surface: 'hint', text: runner.hint, table: table, label: false);
  yield (surface: 'center', text: table.centerLabel, table: table, label: true);
  yield (
    surface: 'callout',
    text: table.focusCalloutLabel,
    table: table,
    label: true,
  );
  yield (
    surface: 'feedback',
    text: runner.feedbackReason,
    table: table,
    label: false,
  );
  for (final (index, step) in runner.teachingSteps.indexed) {
    final shown = act0TeachingTableForRunnerV1(table, step);
    yield (
      surface: 'teach.$index.title',
      text: step.title,
      table: shown,
      label: true,
    );
    yield (
      surface: 'teach.$index',
      text: step.body,
      table: shown,
      label: false,
    );
    for (final (labelIndex, label) in step.focusLabels.indexed) {
      yield (
        surface: 'teach.$index.focus.$labelIndex',
        text: label,
        table: shown,
        label: true,
      );
    }
  }
  for (final o in runner.options) {
    final projected = act0FeedbackTableForRunnerV1(
      runner: runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: o.id,
        teachingStepIndex: runner.teachingSteps.length,
      ),
      taskFamily: task.resolvedTaskFamily,
    );
    yield (
      surface: 'feedback.' + o.id,
      text: o.feedbackReason,
      table: projected,
      label: false,
    );
    yield (
      surface: 'feedback.' + o.id + '.title',
      text: o.feedbackTitle,
      table: projected,
      label: false,
    );
  }
}

String _words(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

const _stopWords = {
  'a',
  'an',
  'the',
  'in',
  'on',
  'at',
  'is',
  'are',
  'should',
  'which',
  'what',
  'does',
  'do',
  'here',
  'this',
  'of',
  'you',
  'your',
  'to',
  'for',
  'can',
  'when',
  'how',
  'one',
  'best',
  'correct',
};
Set<String> _questionWords(String text) => _words(text)
    .split(' ')
    .where((word) => word.isNotEmpty && !_stopWords.contains(word))
    .toSet();

const _streets = {'Preflop': 0, 'Flop': 3, 'Turn': 4, 'River': 5};

final _seatOrder = RegExp(
  r'\b(?:act(?:s|ed|ing)?|is|go(?:es)?) (first|earliest|earlier|last|latest|later)\b'
  r'|\b(first|earliest|last|latest) to act\b',
);

final _sharedBoardQuestion = RegExp(
  r'\b(?:can (?:everyone|every player|all players) use|'
  r'(?:everyone|every player|all players) can use)\b',
);
final _sharedBoardAnswer = RegExp(
  r'\b(?:board cards|shared board|community cards)\b',
);

// A comparative seat question can be spoiled by naming the same ordering
// from either seat's perspective. Prose in the feedback is checked separately.
final _comparativeSeatQuestion = RegExp(
  r'\b(?:acts?|goes?) (?:earlier|later)\b',
);

bool revealsComparativeSeatOrder(CatalogTask row, String copy) {
  if (!_comparativeSeatQuestion.hasMatch(_words(catalogQuestion(row.task)))) {
    return false;
  }
  final options = row.task.runner.options;
  final answer = options.where(act0RunnerOptionIsAuthoredCorrectV1).firstOrNull;
  if (answer?.seatId == null) return false;

  String names(Act0RunnerOptionV1 option) => switch (option.seatId) {
    'btn' => '(?:btn|button|dealer button)',
    'co' => '(?:co|cutoff)',
    'sb' => '(?:sb|small blind)',
    'bb' => '(?:bb|big blind)',
    _ => RegExp.escape(_words(option.label)),
  };
  final text = _words(copy);
  final answerNames = names(answer!);
  const action = r' (?:still |always )?(?:acts?|goes?) ';
  final direct = RegExp(
    '\\b$answerNames$action(?:before|after|earlier|later|first|last)\\b',
  );
  if (direct.hasMatch(text)) return true;
  return options
      .where((option) => !option.isCorrect && option.seatId != null)
      .any(
        (option) => RegExp(
          '\\b${names(option)}$action(?:before|after|earlier than|later than) (?:the )?$answerNames\\b',
        ).hasMatch(text),
      );
}

String? _seatOrderSignature(CatalogTask row, Act0RunnerOptionV1 correct) {
  final seat = correct.seatId;
  if (seat == null) return null;
  final question = _words(catalogQuestion(row.task));
  final order = _seatOrder.firstMatch(question);
  if (order == null) return null;
  final direction = switch (order[1] ?? order[2]) {
    'first' || 'earliest' || 'earlier' => 'first',
    _ => 'last',
  };
  final street = switch (question) {
    _ when RegExp(r'\b(preflop|before the flop)\b').hasMatch(question) =>
      'Preflop',
    _
        when RegExp(
          r'\b(on|after) the (?:flop)\b|\bpostflop\b',
        ).hasMatch(question) =>
      'Flop',
    _ => row.task.runner.table.streetLabel,
  };
  return '$seat/$street/$direction';
}

bool _isAction(Act0RunnerOptionV1 option) =>
    startingChartActions.contains(option.id) ||
    RegExp(
      r'^(?:raise|open|fold|call|check|bet|limp|3-bet|all-in)\b',
      caseSensitive: false,
    ).hasMatch(option.label);

String _action(Act0RunnerOptionV1 option) {
  final label = _words(option.label);
  final match = RegExp(
    r'^(raise|open|fold|call|check|bet|limp)\b',
  ).firstMatch(label);
  return match?[1] == 'open' ? 'raise' : match?[1] ?? option.id;
}

const _deterministicSeatAndBetTaskIds = {
  'position_checkpoint_position_checkpoint_table_notice',
  'same_hand_different_seat_position_repair_same_hand_different_seat',
  'w4_bluff_pressure',
  'w4_checkpoint_table_purpose_price',
};

// The catalog review freezes the exact wrong choices while checking the whole
// question. These ask for a table fact or an action under an explicit rule.
const fixedDrawRangeAndStackChoicesV1 = {
  'flush_draws_w5_flush_draw_find': 'straight_draw',
  'flush_draws_w5_made_hand_vs_flush_draw_transfer':
      'draw_means_pair_does_not_count',
  'flush_draws_w5_flush_draw_recheck_transfer': 'no_flush_pressure',
  'straight_draws_w5_gutshot_draw': 'open_ended',
  'straight_draws_w5_gutshot_contrast_transfer': 'gutshot',
  'outs_improvement_w5_clean_vs_risky_out_transfer': 'five_hearts_riskier',
  'turn_river_changes_w5_turn_texture_shift_transfer': 'size_only_changed',
  'turn_river_changes_w5_river_draw_story_transfer': 'draw_hit_anyway',
  'turn_river_changes_w5_street_repair': 'small_same_story',
  'w6_wrong_board': 'bluff',
  'w6_turn_shift_bucket': 'never_changes',
  'w6_value_range_action': 'check',
  'w6_table_value_line_transfer': 'check_back',
  'range_checkpoint_value': 'bluff',
  'range_checkpoint_board_fit': 'bluff',
  'w6_suited_offsuit_weight_compare': 'same_weight',
  'w6_pair_vs_suited_weight_compare': 'same_weight',
  'w6_checkpoint_table_combo_weight': 'pair_nines',
  'w6_board_pair_strength_compare': 'hero_aj',
  'w6_wet_board_repair': 'smaller_same_story',
  'w7_effective_stack_30bb': '115',
  'w7_effective_stack_100bb': '50',
  'w7_20bb_wider': '100bb',
  'w7_100bb_tighter': 'forced_jam',
  'w7_40bb_middle': 'same_100',
  'w7_ajs_btn_25bb_transfer': 'too_fragile_now',
  'w7_ajs_btn_100bb_transfer': 'same_clean_call',
  'w7_low_spr_commit': 'same',
  'w7_high_spr_room': 'none',
  'w7_spr4_middle': 'same_as_eight',
  'what_poker_is_side_pot_intro': 'side_pot_is_penalty',
  'w7_6max_wider': 'same',
  'w7_fullring_tighter': 'depth',
  'w7_stack_checkpoint': 'range_only',
};

const _fixedTournamentComparisonTaskIds = {
  'w9_survival_stack_tradeoff',
  'w9_checkpoint_zone_line',
};

final _actualRankQuestion = RegExp(
  r'\b(?:who wins|who (?:takes|gets) the pot|which (?:shown )?hand wins|'
  r'what happens to the pot|which (?:hand|rank) (?:is stronger|ranks higher)|'
  r'what (?:hand|rank) (?:do|does) .+ have|how many .{0,24}(?:cards|outs)|'
  r'which (?:seat|player) (?:acts|acted|posts)|'
  r'what (?:is|was) the (?:pot|price)|what (?:size|amount) is|'
  r'how much .{0,28}(?:call|pot))\b',
  caseSensitive: false,
);

// Each of these W1 prompts has a single factual table read or rule answer.
const _w1FactualGradeTaskIds = {
  'what_poker_is_table_read_transfer',
  'what_poker_is_table_read_recheck',
  'your_first_hand_private_cards_recheck',
  'what_poker_is_all_in_meaning',
  'what_poker_is_matched_chips_transfer',
  'what_poker_is_win_ways',
  'what_poker_is_showdown_win',
  'what_poker_is_live_win_transfer',
};

CatalogAudit runCatalogAudit({Iterable<CatalogTask>? rows}) {
  final tasks = rows ?? catalogTasks;
  final audit = CatalogAudit();
  final chart = CatalogStartingChart.foundation();
  final orderByTask = {for (final row in tasks) row.task.taskId: row};
  final knownRepairGoals = <String, Set<String>>{};
  for (final contract in act0RepairGoalContractsV1) {
    knownRepairGoals
        .putIfAbsent(contract.sourceTaskId, () => {})
        .add(contract.goalId);
    if (contract.hasValidatedTarget) {
      knownRepairGoals
          .putIfAbsent(contract.targetTaskId, () => {})
          .add(contract.goalId);
    }
  }
  final repeatKeys = <(int, String), List<CatalogTask>>{};
  final knowledge = <({CatalogTask row, String answer, Set<String> words})>[];
  final inherited = <(String, String), CatalogTask>{};

  for (final row in tasks) {
    final task = row.task;
    final r = task.runner;
    final t = r.table;
    final facts = CatalogPokerFacts(t);
    final correct = r.options
        .where(act0RunnerOptionIsAuthoredCorrectV1)
        .firstOrNull;
    final preflop = t.streetLabel == 'Preflop';
    final heroSeat = t.seats.where((s) => s.isHero).firstOrNull;
    final raisers = chartRaisers(t);

    for (final field in _copy(row)) {
      final claims = catalogClaims(
        field.text,
        field.table,
        titleOrLabel: field.label,
      );
      for (final (i, claim) in claims.indexed) {
        audit.check(
          '1.' + claim.rule,
          row,
          field.surface + ':' + i.toString(),
          claim.matches,
          field.surface +
              ': "' +
              claim.value +
              '" · ' +
              catalogTableLine(field.table),
        );
      }
    }

    if (correct != null && facts.complete) {
      final question = _words(catalogQuestion(task));
      final answer = _words(correct.label);
      if (RegExp(
        r'^what draw is visible$|^which draw do you have$|^which draw do you see$',
      ).hasMatch(question)) {
        final expected = switch (answer) {
          'flush draw' => facts.flushSuits.isNotEmpty,
          'straight draw' => facts.straightRanks.isNotEmpty,
          'gutshot straight draw' || 'gutshot' => facts.gutshot,
          'open ended straight draw' || 'open ended' => facts.openEnded,
          'no draw' => facts.completionCards.isEmpty,
          _ => null,
        };
        audit.check(
          '1.draw.grade',
          row,
          correct.id,
          expected,
          'Question asks for the current draw; grades "' +
              correct.label +
              '"; the table facts are ' +
              facts.description +
              '.',
        );
      }
    }

    final namesChart = referencesStartingChart(r);
    if (correct != null && (preflop || namesChart)) {
      final group = startingChartGroups.contains(correct.id);
      final decision = _isAction(correct);
      final foundation =
          row.world.worldNumber == 2 || row.world.worldNumber == 3;
      if (namesChart || foundation && (group || decision)) {
        final narrowThreeBet = row.lesson.lessonId == 'w2_narrow_three_bet';
        final expected = chart.expected(
          t,
          groupOnly: group,
          narrowThreeBet: narrowThreeBet,
        );
        final actual = startingChartActual(correct, expected);
        if (expected == null) {
          audit.outsideChart[task.taskId] =
              'The combination of earlier actions, hand and seat is outside the Foundation chart.';
        }
        audit.check(
          '2.starting_chart',
          row,
          correct.id,
          expected == null && !narrowThreeBet ? null : expected == actual,
          'Hand ${facts.code ?? '?'}, seat ${heroSeat?.seatId ?? '?'}, '
              'raises $raisers. Chart: $expected, grade: $actual.',
        );
      } else {
        audit.outsideChart[task.taskId] = switch (row.world.worldNumber) {
          1 => 'W1 teaches table mechanics before the Sharky starting chart.',
          >= 5 =>
            'This question uses a later world’s premise and does not invoke the Foundation chart.',
          _ =>
            'This question has no opening, calling, folding, or classification grade.',
        };
      }
    }

    if (facts.hero.length == 2 && heroSeat != null) {
      final seatCards = physicalCards(heroSeat.holeCards);
      audit.check(
        '4.hero_cards',
        row,
        'table',
        seatCards.length == 2 && seatCards.toSet().containsAll(facts.hero),
        'Main hand ' + facts.hero.join(' ') + ', seat ' + seatCards.join(' '),
      );
    }
    if (correct != null &&
        (r.options.every((o) => o.seatId != null) ||
            const {
              'recognition',
              'counting',
            }.contains(task.resolvedTaskFamily.name) ||
            _w1FactualGradeTaskIds.contains(task.taskId) ||
            task.taskId.startsWith('hand_discipline_buckets_') ||
            _deterministicSeatAndBetTaskIds.contains(task.taskId) ||
            fixedDrawRangeAndStackChoicesV1.containsKey(task.taskId) ||
            _fixedTournamentComparisonTaskIds.contains(task.taskId) ||
            _actualRankQuestion.hasMatch(catalogQuestion(task)))) {
      for (final o in r.options.where((o) => !o.isCorrect)) {
        audit.check(
          '4.factual_grade',
          row,
          o.id,
          o.quality == Act0FeedbackQualityV1.wrong,
          'Deterministic question grades "' +
              o.label +
              '" as ' +
              o.quality.name,
        );
      }
    }

    if (correct != null && !task.repairOnly) {
      final seatOrder = _seatOrderSignature(row, correct);
      if (seatOrder != null) {
        final group = repeatKeys.putIfAbsent((
          row.world.worldNumber,
          seatOrder,
        ), () => []);
        _checkRepeat(audit, row, group, seatOrder);
        group.add(row);
      } else if (_isAction(correct) && facts.code != null && heroSeat != null) {
        // Price differences do not make the same Foundation first-in / facing
        // one open exercise a different skill. Postflop keeps the board ranks.
        final context = preflop
            ? (raisers.isEmpty ? 'first in' : raisers.join('/'))
            : [
                t.streetLabel,
                facts.board.map((c) => c[0]).join(),
                ...t.actionTrail.map(
                  (item) => _words(
                    item.label,
                  ).replaceAll(RegExp(r'\b[0-9]+(?: [0-9]+)? bb\b'), ''),
                ),
              ].join(':');
        final key = [
          facts.code!,
          heroSeat.seatId,
          context,
          _action(correct),
        ].join('/');
        final group = repeatKeys.putIfAbsent((
          row.world.worldNumber,
          key,
        ), () => []);
        _checkRepeat(audit, row, group, key);
        group.add(row);
      } else if (!_isAction(correct)) {
        final answer = (correct.seatId ?? _words(correct.label));
        final words = _questionWords(catalogQuestion(task));
        final comparable = words.length >= 2;
        if (comparable) {
          final matches = [
            for (final other in knowledge)
              if (other.row.world.worldNumber == row.world.worldNumber &&
                  other.answer == answer &&
                  (words.difference(other.words).isEmpty &&
                          other.words.difference(words).isEmpty ||
                      words.length >= 4 &&
                          other.words.length >= 4 &&
                          words.intersection(other.words).length /
                                  words.union(other.words).length >=
                              .8))
                other.row,
          ];
          _checkRepeat(audit, row, matches, words.join(' '));
          knowledge.add((row: row, answer: answer, words: words));
        }
      }
    }

    if (correct != null) {
      final answer = _words(correct.label);
      final question = _words(catalogQuestion(task));
      final answerTokens = answer.split(' ');
      final optionTokens = r.options
          .where((o) => !o.isCorrect)
          .map((o) => _words(o.label))
          .toSet();
      for (final field in _copy(row)) {
        if (field.surface != 'caption' &&
            field.surface != 'center' &&
            field.surface != 'callout' &&
            field.surface != 'hint' &&
            !field.surface.startsWith('teach.'))
          continue;
        if (field.text.trim().isEmpty || answer.isEmpty) continue;
        final text = _words(field.text);
        // A direct naming cue ("Tap BTN", "The answer is ...") is
        // separable from a term or amount that the actual question asks to read.
        final seatNames = correct.seatId == 'btn'
            ? '(?:btn|(?:the )?button)'
            : RegExp.escape(answer);
        final direct = RegExp(
          r'\b(?:tap|choose|select|answer is|correct choice is) ' +
              seatNames +
              r'\b',
        ).hasMatch(text);
        final explicitSeatAnswer =
            correct.seatId != null &&
            field.surface == 'hint' &&
            RegExp(
              r'\b' +
                  seatNames +
                  r' (?:is (?:the (?:best|clearest)|early|late)|acts (?:first|last))\b',
            ).hasMatch(text);
        final echoesAnswer =
            text == answer &&
            !optionTokens.contains(answer) &&
            (answerTokens.length > 1 ||
                field.surface == 'center' ||
                field.surface.contains('.focus.'));
        final revealsSharedBoard =
            answer == 'board cards' &&
            !task.repairOnly &&
            _sharedBoardQuestion.hasMatch(question) &&
            const {
              'caption',
              'center',
              'callout',
              'hint',
            }.contains(field.surface) &&
            _sharedBoardAnswer.hasMatch(text);
        final revealsSeatOrder =
            const {'caption', 'center', 'callout'}.contains(field.surface) &&
            revealsComparativeSeatOrder(row, field.text);
        audit.check(
          '6.answer_copy',
          row,
          field.surface,
          !direct &&
              !echoesAnswer &&
              !explicitSeatAnswer &&
              !revealsSharedBoard &&
              !revealsSeatOrder,
          field.surface +
              ': "' +
              field.text +
              '" discloses "' +
              correct.label +
              '".',
        );
      }
    }

    if (r.options.isNotEmpty && r.options.every((o) => o.seatId != null)) {
      final choices = r.options.map((o) => o.seatId!).toSet();
      final targets = t.selectableSeatIds.toSet();
      final seat = correct?.seatId;
      if (seat != null) {
        audit.check(
          '6.authored_seat_cue',
          row,
          seat,
          t.activeSeatId != seat && !t.highlightedSeatIds.contains(seat),
          'Answer seat $seat is active or highlighted in the source frame.',
        );
      }
      audit.check(
        '7.selectable_seats',
        row,
        'table',
        choices.length == targets.length && targets.containsAll(choices),
        'Options $choices, selectable $targets.',
      );
    }

    final expectedBoard = _streets[t.streetLabel];
    if (expectedBoard != null) {
      audit.check(
        '8.street_board_count',
        row,
        'table',
        expectedBoard == t.boardCards.length,
        t.streetLabel +
            ' expects $expectedBoard cards; displays ' +
            t.boardCards.length.toString(),
      );
    }
    if (t.boardCards.isNotEmpty) {
      audit.check(
        '8.empty_board_label',
        row,
        'table',
        t.emptyBoardLabel.trim().isEmpty,
        'Board is present with empty-board label "' + t.emptyBoardLabel + '".',
      );
    }
    final teachesNewCard =
        RegExp(
          r'\b(?:which|what) (?:new |next |latest )?card (?:was |is |gets )?(?:added|dealt|new)|'
          r'\b(?:what|which) (?:changed|card changed) (?:on|after) the (?:turn|river)\b',
          caseSensitive: false,
        ).hasMatch(catalogQuestion(task)) ||
        row.lesson.lessonId == 'turn_river_changes' ||
        const {
          'your_first_hand_turn',
          'your_first_hand_river',
        }.contains(task.taskId);
    final cardIds = {
      for (var i = 0; i < t.heroCards.length; i++) 'hero_$i',
      for (var i = 0; i < t.boardCards.length; i++) 'board_$i',
      for (final seat in t.seats.where((seat) => !seat.isHero))
        for (var i = 0; i < seat.holeCards.length; i++)
          if (seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
            seat.seatId + '_$i',
    };
    for (final id in t.highlightedCardIds) {
      audit.check(
        '8.card_focus_exists',
        row,
        id,
        cardIds.contains(id),
        'Highlight $id with only $cardIds.',
      );
      if (teachesNewCard &&
          (expectedBoard ?? 0) >= 4 &&
          id.startsWith('board_')) {
        final last = 'board_' + (t.boardCards.length - 1).toString();
        audit.check(
          '8.latest_board_focus',
          row,
          id,
          id == last,
          t.streetLabel + ' highlights $id; latest board card is $last.',
        );
      }
    }
    for (final seat in t.seats) {
      if (seat.bet != null &&
          potTruthBbV1(seat.stackLabel) == 0 &&
          (potTruthBbV1(seat.bet!.amountLabel) ?? 0) > 0) {
        audit.check(
          '8.all_in_kind',
          row,
          seat.seatId,
          seat.bet!.kind == Act0SeatBetKindV1.allIn,
          seat.seatId +
              ' has zero behind but its commitment is ' +
              seat.bet!.kind.name,
        );
      }
      if (seat.isActive || seat.seatId == t.activeSeatId) {
        audit.check(
          '8.active_folded',
          row,
          seat.seatId,
          !seat.isFolded,
          seat.seatId + ' is folded and still active.',
        );
        final last = t.actionTrail.where((item) => !item.isNote).lastOrNull;
        final action = last == null
            ? null
            : potTruthParseActionV1(t, last.label);
        if (action?.verb == 'call') {
          audit.check(
            '8.active_caller',
            row,
            seat.seatId,
            action!.actor != seat.seatLabel.toUpperCase(),
            'Last action is a call, and the same seat is still active: ' +
                last!.label,
          );
        }
      }
    }

    for (final (name, raw) in [
      ('title', task.title),
      ('caption', r.caption),
      ('center', t.centerLabel),
      ('feedback', r.feedbackReason),
    ]) {
      final text = _words(raw);
      // Keep generic headings out. Identical fact-bearing phrases reused on
      // different tables may be an inherited premise, not a glossary label.
      if (text.length < 20 ||
          facts.code == null ||
          !RegExp(
            r'\b(?:hand|pair|aces|queens|kings|cards|board|flop|turn|river|pot|open|calls|acts|checks)\b',
          ).hasMatch(text)) {
        continue;
      }
      final other = inherited.putIfAbsent((name, text), () => row);
      final otherFacts = CatalogPokerFacts(other.task.runner.table);
      final differs =
          facts.code != otherFacts.code ||
          facts.board.join() != otherFacts.board.join();
      audit.check(
        '9.inherited_copy',
        row,
        name,
        other.lesson.lessonId == row.lesson.lessonId || !differs,
        name +
            ' is identical to ' +
            other.task.taskId +
            ' on a different table: "$raw"',
      );
    }

    // Day 7 misses return through the spaced scheduler under the same
    // family. The due-review route test verifies that path independently.
    if (task.repairOnly ||
        act0NewReviewConceptFamilyV1(
              row.world.worldId,
              row.lesson.lessonId,
              task.taskId,
            ) !=
            null) {
      continue;
    }
    for (final o in r.options.where((o) => !o.isCorrect)) {
      final intent = buildAct0RepairIntentV1(
        sourceWorldId: row.world.worldId,
        sourceLessonId: row.lesson.lessonId,
        sourceTaskId: task.taskId,
        runner: r,
        selectedOption: o,
        sourceTask: task,
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );
      if (intent == null && row.world.worldNumber > 4) continue;
      final resolved =
          intent != null && intent.mappingType != 'unresolved_product_gap';
      audit.check(
        '10.repair_resolves',
        row,
        o.id,
        resolved,
        intent == null
            ? 'Wrong option "${o.label}" has no repair intent.'
            : 'Wrong option "${o.label}" creates a held repair obligation (${intent.missedSignalId}).',
      );
      if (intent == null || !resolved) continue;
      final target = orderByTask[intent.targetTaskId];
      final earlier =
          target != null &&
          (target.world.worldNumber < row.world.worldNumber ||
              target.world.worldNumber == row.world.worldNumber &&
                  target.lessonIndex <= row.lessonIndex);
      audit.check(
        '10.repair_order',
        row,
        o.id,
        earlier,
        'Repair points to a missing or later task ' + intent.targetTaskId,
      );
      final targetGoals = {
        ...?knownRepairGoals[intent.targetTaskId],
        if (target != null &&
            target.world.worldNumber <= act0SameGoalReplayThroughWorldV1)
          act0FoundationRepairGoalForTaskV1(intent.targetTaskId),
      };
      audit.check(
        '10.repair_goal',
        row,
        o.id,
        targetGoals.contains(intent.goalId),
        'Source goal ${intent.goalId}, target goals $targetGoals.',
      );
    }
  }
  return audit;
}

void _checkRepeat(
  CatalogAudit audit,
  CatalogTask row,
  List<CatalogTask> previous,
  String key,
) {
  final review =
      row.task.phase == Act0LessonPhaseV1.review ||
      row.lesson.lessonId.endsWith('_checkpoint');
  audit.check(
    '5.semantic_repeat',
    row,
    'question',
    previous.isEmpty || previous.length == 1 && review,
    'Signature "$key" already taught by ' +
        previous.map((old) => old.task.taskId).join(', '),
  );
}

/// Appended Q3 choices, with the existing two-option order preserved.
const q3AppendedChoicesV1 = <String, String>{
  'cards_ranks_suits_board_count': 'three',
  'your_first_hand_recap': 'preflop',
  'hand_discipline_buckets_premium': 'strong',
  'hand_discipline_buckets_trash': 'medium',
  'same_hand_different_seat_w3_same_hand_open': 'fold',
  'w4_small_bet': 'three',
  'w4_pot_bet': 'three',
  'outs_improvement_w5_flush_out': 'spade',
  'outs_improvement_w5_straight_out': 'ten',
};

const w4OpeningSeatsV1 = <String, String>{
  'w4_value_purpose': 'co',
  'w4_bluff_purpose': 'hj',
  'w4_purpose_recap': 'co',
  'w4_sizing_intro': 'hj',
  'w4_small_bet': 'co',
  'w4_half_pot_bet': 'hj',
  'w4_pot_bet': 'co',
  'w4_sizing_recap': 'hj',
  'w4_value_intro': 'co',
  'w4_value_bet': 'co',
  'w4_value_missed': 'hj',
  'w4_value_recap': 'co',
  'w4_bluff_intro': 'hj',
  'w4_bluff_pressure': 'co',
  'w4_bluff_recap': 'hj',
  'w4_protection_intro': 'co',
  'w4_checkpoint_intro': 'hj',
  'w4_checkpoint_review': 'co',
};

/// New W4 choices preserve task IDs and the original winning choice IDs.
const w4AddedOptionQualityV1 = <String, (String, String)>{
  'w4_value_purpose': ('same_pair', 'wrong'),
  'w4_bluff_purpose': ('better_calls', 'wrong'),
  'w4_good_price_call': ('call_ignore_price', 'suboptimal'),
  'w4_bad_price_fold': ('fold_ignore_price', 'suboptimal'),
  'w4_cheap_price_marginal_call': ('call_ignore_price', 'suboptimal'),
  'w4_big_price_marginal_fold': ('wrong_threshold', 'suboptimal'),
  'w4_value_bet': ('bet_pot', 'wrong'),
  'w4_value_missed': ('bet_pot', 'wrong'),
  'w4_bluff_pressure': ('bet_pot', 'wrong'),
  'w4_bad_bluff': ('bet_small', 'suboptimal'),
  'w4_protection_bet': ('bet_pot', 'suboptimal'),
  'w4_protection_check': ('got_fold', 'wrong'),
  'w4_checkpoint_value': ('same_pair', 'wrong'),
  'w4_checkpoint_price': ('call_ignore_price', 'suboptimal'),
  'w4_checkpoint_table_price': ('call_ignore_price', 'suboptimal'),
  'w4_checkpoint_review': ('size_only', 'suboptimal'),
};

/// Q7 extends the historical source census without replacing any legacy IDs.
const w7AppliedTaskIdsV1 = <String>{
  'w7_flop_bluff_one_player',
  'w7_flop_bluff_two_players',
  'w7_count_winning_rivers',
  'w7_clean_outs_lower_price',
  'w7_clean_outs_higher_price',
  'w7_river_one_bluff_of_six',
  'w7_river_two_bluffs_of_six',
  'w7_checkpoint_river_card_excludes_hand',
};

/// Q11 extends W4 sizing with minimum-raise tasks without replacing legacy IDs.
const w4MinRaiseTaskIdsV1 = <String>{
  'w4_min_raise_preflop',
  'w4_min_raise_postflop',
};

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_chart_audit_v1.dart';
import 'act0_catalog_concept_order_v1.dart';
import 'act0_catalog_decision_copy_v1.dart';
import 'act0_catalog_learner_copy_v1.dart';
import 'act0_catalog_outs_v1.dart';
import 'act0_catalog_quality_audit_v1.dart';
import 'act0_catalog_reasoning_audit_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_catalog_truth_audit_v1.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

List<CatalogConceptV1> _concepts() {
  final source = _fixture('act0_c5_concepts_v1');
  final exceptions = _fixture('act0_c5_exceptions_v1');
  final coverage = source['coverage_patterns'] as Map<String, dynamic>;
  final owner = (source['owner_concepts'] as List).cast<Map<String, dynamic>>();
  expect(owner.map((item) => item['n']).toSet(), hasLength(333));
  final patterns = <String, String>{
    ...coverage.cast<String, String>(),
    for (final item in owner)
      "${item['n']}":
          r'(?<![a-z0-9])(?:' +
          (item['aliases'] as List)
              .cast<String>()
              .map(RegExp.escape)
              .join('|') +
          r')(?![a-z0-9])',
  };
  // A chip amount is not a reference to the big-blind seat.
  patterns['143'] = r'(?<![a-z0-9])(?<![0-9] )(?<!half )BB(?![a-z0-9])';
  for (final exception in exceptions.entries) {
    expect(patterns.remove(exception.key), isNotNull);
    expect(exception.value, isNotEmpty);
  }
  return [
    for (final entry in patterns.entries)
      (id: entry.key, mention: RegExp(entry.value, caseSensitive: false)),
  ];
}

void _writeReport(
  String path,
  CatalogOutsAuditV1 outs,
  Map<String, String> concepts,
) {
  final rows = reasoningCatalogRowsV1;
  final truth = runCatalogAudit(rows: rows);
  final quality = runCatalogQualityAudit();
  final reasoning = [
    for (final row in rows)
      if (auditCatalogReasoningV1(row) case final result?) result,
  ];
  int rule(int rule) => reasoning.fold(
    0,
    (n, result) => n + (result.findings[rule]?.length ?? 0),
  );
  int truthFindings(String prefix) =>
      truth.findings.keys.where((key) => key.startsWith(prefix)).length;
  final lines = [
    '# Машинный атлас ошибок · W1–W12',
    '',
    'Числа получены из текущего каталога. Где указан отдельный тест, его результат проверяется в CI.',
    'Нулевой счётчик применимых нарушений не закрывает непроверенную часть класса.',
    '',
    '| ID | Класс | Проверка и результат |',
    '| --- | --- | --- |',
    '| E01 | Целостность строк чарта | G1·43; межформенная проверка — Lane A |',
    '| E02 | Оценка против чарта | G1·41 / catalog starting chart: ${truthFindings('2.starting_chart')} находок на ${truth.checks['2.starting_chart'] ?? 0} проверках |',
    '| E03 | Текст против чарта | Отдельная проверка G1·42 |',
    '| E04 | Место героя, действующее место и размер в разборе | G1·39–40: ${rows.expand(auditDecisionCopyV1).length} |',
    '| E05 | Относительное место | G1 relative seat copy: ${rows.expand((r) => catalogRelativeSeatFindingsV1(r.task)).length} |',
    '| E06 | Коды миров | G1 world codes: ${rows.expand((r) => catalogWorldCodeFindingsV1(r.task)).length} |',
    '| E07 | Числа банка и цены | Отдельная проверка G1 decision copy numbers |',
    '| E08 | Стеки и фишки | Отдельная проверка Table Truth D7 |',
    '| E09 | Повтор одного разбора | G1·21/49: ${quality.findings.where((key) => key.startsWith('21.') || key.startsWith('$catalogSharedFeedbackBodyRuleV1|')).length} |',
    '| E10 | Повтор раздачи | Каталог, semantic repeat: ${truthFindings('5.semantic_repeat')} находок; отдельный guard дубликатов |',
    '| E11 | Покерные термины | Claim audit: ${truthFindings('1.')} находок по фактам; C5: ${concepts.length} пар задание × понятие до объяснения |',
    '| E12 | Комбо как частота | Отдельный тест raw combo counts |',
    '| E13 | Ауты | ${outs.checked.length} заданий с проверенными численными утверждениями, ${outs.findings.length} расхождений, ${outs.unmodelled.length} с неподтверждённой моделью |',
    '| E14 | Допущенная эквити | G1·32 проверяет видимость оформленных допущений; числовой аудит — в журнале Lane B |',
    '| E15 | Оценка при равном EV | G1·33: ${rule(33)} находок; только задания с оформленной разницей EV |',
    '| E16 | Скрытая рука как факт | G1·34: ${rule(34)} |',
    '| E17 | Допущение после выбора | G1·32: ${rule(32)} |',
    '| E18 | Подсказка раскрывает ответ | G1·5/6 частично; нужна рубрика |',
    '| E19 | Смысл вариантов и оценка | Рубрика |',
    '| E20 | Пустой разбор | Рубрика |',
    '| E21 | Причина не следует из факта | Рубрика |',
    '| E22 | Ложное обобщение | Рубрика |',
    '| E23 | Один эффективный стек в мультипоте | Decision Ledger считает по соперникам; смысл текста проверяется рубрикой |',
    '| E24 | Ложный статус CI | Проверка фактических GitHub checks по SHA |',
    '| E25 | Карты перекрывает интерфейс | D8, визуальное доказательство отдельно |',
    '| E26 | Пороги M-ratio | Спека W9, проверка содержания |',
    '| E27 | Доступность скриптов ревью | Проверка рабочего окружения |',
    '| E28 | Младшие руки в диапазоне открытия | G1·44: ${rows.expand(auditOpeningRangeClaimsV1).length} находок в ${rows.expand(openingRangeClaimsV1).length} утверждениях в области стартового чарта |',
    '| E29 | Одинаковые метки вариантов одного задания | G1·45: ${quality.findings.where((key) => key.startsWith('$catalogDuplicateOptionLabelRuleV1|')).length} находок в ${quality.checks[catalogDuplicateOptionLabelRuleV1] ?? 0} заданиях |',
    '| E30 | Действия из вопроса среди вариантов | G1·46: ${quality.findings.where((key) => key.startsWith('$catalogActionQuestionRuleV1|')).length} находок на ${quality.checks[catalogActionQuestionRuleV1] ?? 0} проверках |',
    '| E31 | Порог банкролла в бай-инах | G1·48: ${quality.findings.where((key) => key.startsWith('$catalogBankrollThresholdRuleV1|')).length} находок на ${quality.checks[catalogBankrollThresholdRuleV1] ?? 0} проверках |',
    '| — | Длина верного разбора | G1·47: ${quality.correctFeedbackOverLimit.length} ответов длиннее $catalogCorrectFeedbackWordLimitV1 слов из ${quality.checks[catalogCorrectFeedbackLengthRuleV1] ?? 0} проверенных, исключения ограничены fixture |',
    '',
    '## E13 — расхождения',
    '',
    for (final entry in outs.findings.entries)
      '- `${entry.key}` · ${entry.value}',
    if (outs.findings.isEmpty) 'Расхождений в проверенном наборе нет.',
    '',
    '## E13 — задания без однозначно заданной модели для численного утверждения',
    '',
    for (final id in outs.unmodelled) '- `$id`',
    if (outs.unmodelled.isEmpty) 'Нет.',
  ];
  File(path).writeAsStringSync('${lines.join('\n')}\n');
}

CatalogTask _conceptProbe({
  required String question,
  String? teaching,
  List<Act0RunnerOptionV1> options = const [],
}) {
  final row = catalogTasks.first;
  return (
    world: row.world,
    lesson: row.lesson,
    lessonIndex: row.lessonIndex,
    task: Act0LessonTaskV1(
      taskId: 'c5_probe',
      title: 'Probe',
      phase: Act0LessonPhaseV1.drill,
      rewardXp: 0,
      runner: row.task.runner.copyWith(
        caption: '',
        question: question,
        hintPolicy: Act0HintPolicyV1.hidden,
        teachingSteps: [
          if (teaching != null)
            Act0TeachingStepV1(title: 'Read the term.', body: teaching),
        ],
        options: options,
      ),
    ),
  );
}

void _registerConceptOrderDefinitionTests() {
  late List<CatalogConceptV1> concepts;
  setUpAll(() => concepts = _concepts());
  const cases = <(List<String>, String, String)>[
    (['141', 'button'], 'BTN is Button.', 'Find BTN, the Button.'),
    (['139'], 'HJ is Hijack.', 'Tap HJ.'),
    (['140'], 'CO is Cutoff.', 'Tap CO.'),
    (
      ['14', '15', 'blinds'],
      'Blinds are forced contributions: the small blind puts in 0.5 BB and the big blind puts in 1 BB before anyone chooses.',
      'Find the small blind and big blind.',
    ),
    (
      ['31', '32', 'rules_hand_flow'],
      'The flop has three shared cards. The turn is the fourth.',
      'Compare flop and turn.',
    ),
    (
      ['action_order', '152'],
      'UTG acts first, right after the big blind.',
      'Who acts first? Find the first to act.',
    ),
    (
      ['39'],
      'From the flop on, the first player still in and able to act clockwise after the Button acts first. If the Button can still act, it goes after all the others on the first pass.',
      'Who acts last on the flop?',
    ),
    (['check'], 'Check passes for free.', 'BB checks.'),
    (
      ['starting_chart', 'starting_hand_groups'],
      'Sharky starting chart.\nPremium: AA.\nStrong: JJ.\nMedium: KQ.\nWeak: 72.',
      'Read the starting chart and choose the bucket.',
    ),
    (
      ['41'],
      'High card means no matching ranks or stronger combination.',
      'Choose high card.',
    ),
    (['42'], 'A pair means two cards of one rank.', 'Find the pair.'),
    (
      ['44'],
      'Three of a kind means three cards of one rank.',
      'Find three of a kind.',
    ),
    (
      ['43', 'two_pair'],
      'Two pair means two separate pairs.',
      'Find two pair.',
    ),
    (
      ['47'],
      'A full house has three of one rank and two of another.',
      'Find a full house.',
    ),
    (
      ['48'],
      'Four of a kind uses all four of one rank.',
      'Find four of a kind.',
    ),
    (
      ['49'],
      'A straight flush is five ranks in a row in one suit.',
      'Find a straight flush.',
    ),
    (
      ['one_in_n'],
      'One win returns 10 BB, so you break even at one in five.',
      'What is one in five?',
    ),
    (
      ['min_raise', 'min_bet_raise_sizes'],
      'A full raise must add at least the size of the last bet or full raise.',
      'For the minimum raise, you must raise to 5 BB.',
    ),
    (
      ['23', 'split_pot'],
      'A tie means the pot is split.',
      'When do you split the pot?',
    ),
    (
      ['13'],
      'BTN marks the Button. The dealer button shows the late seat.',
      'Find the dealer button.',
    ),
    (
      ['wheel', '57'],
      'A-2-3-4-5 is the five-high straight, called the wheel.',
      'Identify the wheel straight.',
    ),
    (
      ['pot_odds'],
      'To call X into a pot of Y after the bet, you need to win at least X ÷ (X + Y) of the time.',
      'Compare pot odds.',
    ),
    (
      ['pot_odds'],
      'A 1.5 BB call for 5.5 BB needs about 27%.',
      'Does the chance to win clear the price?',
    ),
    (
      ['hand_rankings'],
      'Ranking ladder. Learn the first four ranks in order: high card, a pair, two pair, and three of a kind.',
      'What do hand rankings compare?',
    ),
    (
      ['kicker'],
      'A kicker is a side card that can break a tie.',
      'Find the kicker.',
    ),
    (
      ['showdown', '11', '34'],
      'Showdown is when players compare their best five after revealing their cards.',
      'What happens at showdown?',
    ),
    (
      ['21', 'side_pot'],
      'A side pot is extra chips matched after someone goes all-in.',
      'Who can win the side pot?',
    ),
    (
      ['147', 'ip_oop'],
      'You are in position when you act after the other player.',
      'Who is in position?',
    ),
    (
      ['169', 'pocket_pair'],
      'The Strong row lists JJ and TT, which are pocket pairs.',
      'Find pocket pairs.',
    ),
    (
      ['71', 'top_pair'],
      'Top pair means a private card matches the highest rank on the board.',
      'Find top pair.',
    ),
    (
      ['59'],
      'Sometimes the board plays. You and CO both use the same A-K-Q-J-T straight from the board here, so private cards do not improve either player.',
      'When does the board play? The board plays.',
    ),
    (['33'], 'River adds the fifth.', 'What is the river?'),
    (
      ['broadway'],
      'Broadway ranks are ten, jack, queen, king, and ace.',
      'What is broadway?',
    ),
    (
      ['position_information'],
      'Acting later lets you see more moves before you decide.',
      'Which player has more information?',
    ),
    (
      ['protection'],
      'Protection makes the next card cost chips.',
      'What does a protection bet deny?',
    ),
    (
      ['set_trips'],
      'A set is three of a kind made from a pair in your private cards and one matching card on the board.',
      'Find a set.',
    ),
    (
      ['423'],
      'Protection bets make the next card cost something.',
      'What is a protection bet?',
    ),
  ];
  for (final (ids, teaching, question) in cases) {
    for (final id in ids) {
      test('C5 $id definition before: $question', () {
        final concept = concepts.singleWhere((concept) => concept.id == id);
        expect(
          catalogConceptOrderFindingsV1(
            [_conceptProbe(question: question, teaching: teaching)],
            [concept],
          ),
          isEmpty,
        );
        expect(
          catalogConceptOrderFindingsV1(
            [_conceptProbe(question: question, teaching: 'Read the example.')],
            [concept],
          ).values.single,
          startsWith('Q:'),
        );
      });
    }
  }
  const aliases = <(String, String, String)>[
    (
      'equity',
      'You have a chance to win the blinds.',
      'You have a 25% chance to win.',
    ),
    ('set_trips', 'Keep the two sets of cards apart.', 'Is this a set?'),
    (
      'equity',
      'You have a chance to win the blinds.',
      'Which hand has more chance to win?',
    ),
    (
      'set_trips',
      'Keep the two sets of cards apart.',
      'Which sets of aces are possible?',
    ),
    ('143', 'Count 2.5 BB and half BB.', 'Which seat is BB?'),
    ('button', 'Cards the dealer sets aside.', 'Who is the dealer?'),
    ('split_pot', 'The ranks tie.', 'How do they split the pot?'),
    ('pot_odds', 'Read the price to continue.', 'What are the pot odds?'),
    ('min_bet_raise_sizes', 'Raise to 7.5 BB.', 'You must raise to 5 BB.'),
  ];
  for (final (id, nonConcept, conceptQuestion) in aliases) {
    test('C5 $id alias keeps: $conceptQuestion', () {
      final concept = concepts.singleWhere((concept) => concept.id == id);
      expect(
        catalogConceptOrderFindingsV1(
          [_conceptProbe(question: nonConcept)],
          [concept],
        ),
        isEmpty,
      );
      expect(
        catalogConceptOrderFindingsV1(
          [_conceptProbe(question: conceptQuestion)],
          [concept],
        ).values.single,
        startsWith('Q:'),
      );
    });
  }
  test('C5 a numeric raise option still needs the legal-size rule', () {
    final concept = concepts.singleWhere(
      (concept) => concept.id == 'min_bet_raise_sizes',
    );
    const option = Act0RunnerOptionV1(
      id: 'raise',
      label: 'Raise to 5 BB',
      isCorrect: true,
      preferredLabel: 'Raise to 5 BB',
      quality: Act0FeedbackQualityV1.correct,
      feedbackTitle: '',
      feedbackReason: '',
    );
    expect(
      catalogConceptOrderFindingsV1(
        [
          _conceptProbe(question: 'Which raise is legal?', options: [option]),
        ],
        [concept],
      ).values.single,
      startsWith('OPTION:'),
    );
    expect(
      catalogConceptOrderFindingsV1(
        [
          _conceptProbe(
            question: 'Which action increases the pot?',
            options: [option],
          ),
        ],
        [concept],
      ),
      isEmpty,
    );
  });
}

void registerAct0ErrorAtlasV1() {
  _registerConceptOrderDefinitionTests();
  test('Y7 C5 and E13 catalog baselines admit no regressions', () {
    final route = catalogTasks.where((row) => !row.task.repairOnly);
    final concepts = catalogConceptOrderFindingsV1(route, _concepts());
    final outs = auditCatalogOutsV1(reasoningCatalogRowsV1);
    if (Platform.environment['ACT0_ERROR_ATLAS_REPORT'] case final path?) {
      _writeReport(path, outs, concepts);
    }

    final current = {
      'c5_concept_order_v1': concepts.keys.toList()..sort(),
      'e13_outs_v1': outs.findings.keys.toList()..sort(),
    };
    const name = 'act0_catalog_quality_baseline_v1';
    final baseline = _fixture(name);
    const reasonsKey = 'c5_w1_w4_reasons_v1';
    final earlyWorld = RegExp(r'^W[1-4]\|');
    final earlyWorldConcepts = concepts.keys.where(earlyWorld.hasMatch).toSet();
    final reasons = baseline[reasonsKey] as Map<String, dynamic>;
    final regenerate = Platform.environment['G1_UPDATE_Y7_BASELINE'] == '1';
    if (regenerate) {
      reasons.removeWhere((key, _) => !earlyWorldConcepts.contains(key));
    }
    expect(reasons.keys.toSet(), earlyWorldConcepts, reason: reasonsKey);
    for (final reason in reasons.entries) {
      expect((reason.value as String).trim(), isNotEmpty, reason: reason.key);
    }
    if (regenerate) {
      baseline.addAll(current);
      const json = JsonEncoder.withIndent('  ');
      File(
        'test/fixtures/$name.json',
      ).writeAsStringSync('${json.convert(baseline)}\n');
      return;
    }
    for (final entry in current.entries) {
      expect(entry.value, baseline[entry.key], reason: entry.key);
    }
  });

  test('Y7 counts only clean hearts against a set and a compatible range', () {
    const hero = ['9h', '8h'];
    const board = ['Ah', '6h', '2c', '4c'];
    const completion = {'Kh', 'Qh', 'Jh', 'Th', '7h', '5h', '4h', '3h', '2h'};
    Set<String> clean(List<List<String>> range) => catalogCleanOutsV1(
      hero: hero,
      board: board,
      completionCards: completion,
      opponentRange: range,
    );
    expect(
      clean([
        ['6s', '6d'],
      ]),
      completion.difference({'2h', '4h'}),
    );
    expect(
      clean([
        ['6s', '6d'],
        ['Kh', 'Qh'],
      ]),
      {'Kh', 'Qh'},
    );
  });

  test('Y7 records a question using an unexplained concept', () {
    final route = catalogTasks.where((row) => !row.task.repairOnly);
    final row = route.firstWhere((row) => catalogQuestion(row.task).isNotEmpty);
    final word = catalogQuestion(
      row.task,
    ).split(RegExp('[^a-zA-Z]+')).firstWhere((word) => word.isNotEmpty);
    final findings = catalogConceptOrderFindingsV1(
      [row],
      [(id: 'sample', mention: RegExp(RegExp.escape(word)))],
    );
    expect(findings.keys, contains(endsWith('|${row.task.taskId}|sample')));
  });
}

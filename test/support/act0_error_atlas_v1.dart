import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
    '| E09 | Повтор одного разбора | G1·21: ${quality.findings.where((key) => key.startsWith('21.')).length} |',
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

void registerAct0ErrorAtlasV1() {
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
    if (Platform.environment['G1_UPDATE_Y7_BASELINE'] == '1') {
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

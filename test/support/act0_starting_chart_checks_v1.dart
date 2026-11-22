import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_chart_v1.dart';

import 'act0_catalog_decision_v1.dart';
import 'act0_catalog_snapshot_v1.dart';
import 'act0_catalog_chart_audit_v1.dart';

int _chartActionOrder(Act0ChartActionV1 action) => switch (action) {
  Act0ChartActionV1.raise => 2,
  Act0ChartActionV1.call => 1,
  Act0ChartActionV1.fold => 0,
  _ => -1,
};

void registerAct0StartingChartChecksV1() {
  test('G1·41–42 starting chart findings are individually accounted for', () {
    final rows = [
      ...catalogTasks,
      ...rulesCheckCatalogTasks,
      ...day7CatalogTasks,
    ];
    final actual = chartCatalogFindingsV1(rows);
    final file = File('test/fixtures/act0_starting_chart_exceptions_v1.json');
    final baseline = jsonDecode(file.readAsStringSync()) as List;
    final expected = {
      for (final row in baseline)
        (
          rule: row['rule'] as String,
          id: row['id'] as String,
          detail: row['detail'] as String,
        ),
    };
    expect(expected, hasLength(baseline.length));
    for (final row in baseline) {
      expect(row['reason'], isNotEmpty, reason: row['id'] as String);
    }
    final reportPath = Platform.environment['G1_CHART_REPORT'];
    if (reportPath != null) {
      final coverage = <String, Map<String, int>>{};
      for (final row in rows) {
        if (decisionStreetV1(row.task.runner.table) != PokerStreet.preflop ||
            row.task.runner.options
                    .where((o) => catalogActionV1(o.label) != null)
                    .length <
                2) {
          continue;
        }
        final action = chartDecisionV1(row);
        final counts = coverage.putIfAbsent(
          row.world.worldId,
          () => {'covered': 0, 'notCovered': 0, 'priceDecision': 0},
        );
        final key = action == Act0ChartActionV1.notCovered
            ? 'notCovered'
            : 'covered';
        counts[key] = counts[key]! + 1;
        if (action == Act0ChartActionV1.priceDecision) {
          counts['priceDecision'] = counts['priceDecision']! + 1;
        }
      }
      File(reportPath).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'coverage': coverage,
          'findings': [
            for (final f in actual)
              {'rule': f.rule, 'id': f.id, 'detail': f.detail},
          ],
        }),
      );
    }
    expect(
      actual.difference(expected),
      isEmpty,
      reason: actual.difference(expected).join('\n'),
    );
    expect(
      expected.difference(actual),
      isEmpty,
      reason: 'Remove resolved chart exceptions',
    );
  });

  test('G1·43 all 169 hands have exactly one chart group', () {
    expect(act0ChartHandsV1, hasLength(169));
    final listed = act0ChartGroupsV1.values.expand((g) => g).toList();
    expect(listed.toSet(), hasLength(listed.length));
    expect(act0ChartHandsV1, containsAll(listed));
    for (final hand in act0ChartHandsV1) {
      final group = act0ChartGroupV1(hand);
      if (group == Act0ChartGroupV1.weak) {
        expect(listed, isNot(contains(hand)));
      } else {
        expect(act0ChartGroupsV1[group], contains(hand));
      }
    }
  });

  test('G1·43 chart actions are monotone over same-form kickers and pairs', () {
    for (final seat in Act0ChartSeatV1.values) {
      for (final prefix in Act0ChartPrefixV1.values) {
        for (final weaker in act0ChartHandsV1) {
          final low = act0ChartRanksV1.indexOf(weaker[1]);
          final high = act0ChartRanksV1.indexOf(weaker[0]);
          final stronger = <String>{
            if (weaker.length == 2)
              for (var i = 0; i < high; i++)
                '${act0ChartRanksV1[i]}${act0ChartRanksV1[i]}'
            else ...[
              if (weaker.endsWith('o')) '${weaker.substring(0, 2)}s',
              for (var i = high + 1; i < low; i++)
                '${weaker[0]}${act0ChartRanksV1[i]}${weaker[2]}',
            ],
          };
          final action = act0ChartActionV1(weaker, seat, prefix);
          if (_chartActionOrder(action) < 0) continue;
          for (final hand in stronger) {
            expect(
              _chartActionOrder(act0ChartActionV1(hand, seat, prefix)),
              greaterThanOrEqualTo(_chartActionOrder(action)),
              reason:
                  '${seat.name}/${prefix.name}: $hand must not play worse than $weaker',
            );
          }
        }
      }
    }
  });

  test('G1·43 BTN versus one open respects both Medium rows', () {
    const seat = Act0ChartSeatV1.btn;
    final higherRow = act0ChartGroupsV1[Act0ChartGroupV1.mediumHj]!;
    final lowerRow = act0ChartGroupsV1[Act0ChartGroupV1.mediumCo]!;
    for (final prefix in [Act0ChartPrefixV1.hjOpen, Act0ChartPrefixV1.coOpen]) {
      for (final higher in higherRow) {
        for (final lower in lowerRow) {
          expect(
            _chartActionOrder(act0ChartActionV1(higher, seat, prefix)),
            greaterThanOrEqualTo(
              _chartActionOrder(act0ChartActionV1(lower, seat, prefix)),
            ),
            reason:
                'BTN/${prefix.name}: $higher (HJ Medium) vs $lower (CO Medium)',
          );
        }
      }
    }
  });

  test('G1·41–43 historical chart errors are rejected', () {
    expect(
      chartGradesAgreeV1(
        act0ChartActionV1(
          'AJo',
          Act0ChartSeatV1.utg,
          Act0ChartPrefixV1.unopened,
        ).name,
        {'raise'},
      ),
      isFalse,
    );
    expect(
      chartGradesAgreeV1(
        act0ChartActionV1(
          'KQo',
          Act0ChartSeatV1.co,
          Act0ChartPrefixV1.hjOpen,
        ).name,
        {'call'},
      ),
      isFalse,
    );
    expect(
      chartGradesAgreeV1(
        act0ChartActionV1(
          'AQo',
          Act0ChartSeatV1.sb,
          Act0ChartPrefixV1.btnOpen,
        ).name,
        {'fold'},
      ),
      isFalse,
    );
    expect(
      chartCopyFindingsV1('wrong_fold', 'Fold QJo first in from CO.'),
      hasLength(1),
    );
    expect(
      chartCopyFindingsV1(
        'context_fold',
        'Fold QJo from CO against one HJ open.',
      ),
      isEmpty,
    );
    const raise = Act0ChartActionV1.raise;
    const call = Act0ChartActionV1.call;
    const fold = Act0ChartActionV1.fold;
    expect(
      act0ChartActionV1('AJo', Act0ChartSeatV1.utg, Act0ChartPrefixV1.unopened),
      fold,
    );
    expect(
      act0ChartActionV1('KQo', Act0ChartSeatV1.co, Act0ChartPrefixV1.hjOpen),
      fold,
    );
    expect(
      act0ChartActionV1('AQo', Act0ChartSeatV1.sb, Act0ChartPrefixV1.btnOpen),
      raise,
    );
    expect(
      act0ChartActionV1('KQs', Act0ChartSeatV1.btn, Act0ChartPrefixV1.hjOpen),
      call,
    );
    expect(
      act0ChartActionV1('KQo', Act0ChartSeatV1.btn, Act0ChartPrefixV1.hjOpen),
      call,
    );
    expect(
      act0ChartActionV1('QJo', Act0ChartSeatV1.co, Act0ChartPrefixV1.unopened),
      raise,
    );
    expect(
      chartCopyFindingsV1(
        'missing_strong',
        'In SB versus BTN, reraise Premium and Medium-HJ.',
      ),
      hasLength(1),
    );
    expect(
      chartCopyFindingsV1('wrong_open', 'The chart opens AJo from UTG.'),
      hasLength(1),
    );
    expect(
      chartCopyFindingsV1(
        'missing_suited',
        'With Medium hands, call from BTN with KQo, KJs, or QJs.',
      ),
      hasLength(1),
    );
    expect(
      chartCopyFindingsV1(
        'complete',
        'With Medium hands, call from BTN with AQo, AJo, KQs, KQo, ATs, ATo, KJs, or QJs.',
      ),
      isEmpty,
    );
    expect(
      chartCopyFindingsV1(
        'wrong_call',
        'The chart calls one HJ open with KQo from CO.',
      ),
      hasLength(1),
    );
  });
}

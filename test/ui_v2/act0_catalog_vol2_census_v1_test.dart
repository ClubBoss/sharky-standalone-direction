import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_chart_audit_v1.dart';
import '../support/act0_catalog_concept_order_v1.dart';
import '../support/act0_catalog_decision_copy_v1.dart';
import '../support/act0_catalog_learner_copy_v1.dart';
import '../support/act0_catalog_outs_v1.dart';
import '../support/act0_catalog_quality_audit_v1.dart';
import '../support/act0_catalog_reasoning_audit_v1.dart';
import '../support/act0_catalog_rendered_seat_cues_v1.dart';
import '../support/act0_catalog_rubric_guards_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_error_atlas_v1.dart';
import '../support/act0_table_chip_labels_v1.dart';
import '../support/act0_table_truth_v1.dart';

// TODO(B91 lead): generate the initial fixture before opening the PR:
// G1_UPDATE_SNAPSHOT=1 flutter test --no-pub --dart-define=SHARKY_W13_PLUS_PILOT=true test/ui_v2/act0_catalog_vol2_census_v1_test.dart
const _baselinePath = 'test/fixtures/act0_catalog_vol2_baseline_v1.json';
const _worlds = {13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24};
typedef _Census = Map<String, Map<String, List<String>>>;

Set<String> _keys(_Census census) => {
  for (final world in census.entries)
    for (final rule in world.value.entries)
      for (final finding in rule.value) '${world.key}|${rule.key}|$finding',
};

List<String> _additions(_Census current, _Census baseline) =>
    _keys(current).difference(_keys(baseline)).toList()..sort();

_Census _readBaseline(File file) {
  final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final world in raw.entries)
      world.key: {
        for (final rule in (world.value as Map<String, dynamic>).entries)
          rule.key: (rule.value as List).cast<String>(),
      },
  };
}

bool _isVerifiedScopeException(TableTruthRow row) {
  // scope.applicability reports the actual raw/projected frame's scope in
  // detail. Require an explicit scope, not just the exception status; other
  // invariants do not carry this scope evidence.
  return row.invariant == 'scope.applicability' &&
      row.result == 'EXPLICIT_EXCEPTION' &&
      Act0TableScopeV1.values.any(
        (scope) =>
            scope != Act0TableScopeV1.unclassified &&
            row.detail ==
                '${scope.name}: source scope must identify physical applicability',
      );
}

Future<_Census> _collectCensus(WidgetTester tester) async {
  final allRows = reasoningCatalogRowsV1;
  final pilot = allRows.where((row) => _worlds.contains(row.world.worldNumber));
  expect(
    catalogTasks
        .where((row) => _worlds.contains(row.world.worldNumber))
        .map((row) => row.world.worldNumber)
        .toSet(),
    _worlds,
    reason: 'Pilot census must contain every world W13–W24.',
  );
  final taskWorld = {
    for (final row in allRows) row.task.taskId: row.world.worldNumber,
  };
  final lessonWorld = {
    for (final row in allRows) row.lesson.lessonId: row.world.worldNumber,
  };
  final worldNumber = {
    for (final row in allRows) row.world.worldId: row.world.worldNumber,
  };
  final findings = {
    for (final world in _worlds) 'W$world': SplayTreeMap<String, Set<String>>(),
  };
  void add(int world, String rule, String task, String detail) {
    if (!_worlds.contains(world)) return;
    findings['W$world']!.putIfAbsent(rule, () => {}).add('$task|$detail');
  }

  void taskFinding(String rule, String task, String detail) =>
      add(taskWorld[task]!, rule, task, detail);

  // Render the canonical learner-facing snapshot for every pilot pair. E19
  // compares the same grade/label projection as the existing rubric.
  for (var world = 13; world < 24; world += 2) {
    final current = renderCatalogSnapshot(worlds: {world, world + 1});
    final previous = previousCatalogSnapshotV1(
      path:
          'test/fixtures/act0_catalog_snapshot_w${world}_w${world + 1}_v1.txt',
    );
    if (previous != null) {
      for (final f in catalogOptionLabelChangesV1(previous, current)) {
        taskFinding(f.rule, f.task, f.detail);
      }
    }
  }

  for (final row in pilot) {
    final task = row.task;
    final id = task.taskId;
    for (final f in catalogRubricFindingsV1(task)) {
      taskFinding(f.rule, f.task, f.detail);
    }
    for (final (rule, hits) in [
      ('seat_name', catalogSeatNameFindingsV1(task)),
      ('relative_seat', catalogRelativeSeatFindingsV1(task)),
      ('world_code', catalogWorldCodeFindingsV1(task)),
    ]) {
      for (final hit in hits) {
        taskFinding(rule, id, hit.substring('$id: '.length));
      }
    }
    // G1·35 is a coverage metric (short stacks vs stack-sensitive
    // explanations), not a per-task violation; preserve that distinction.
    final reasoning = auditCatalogReasoningV1(row);
    if (reasoning != null) {
      for (final rule in reasoning.findings.entries) {
        for (final detail in rule.value) {
          taskFinding('G1·${rule.key}', id, detail == id ? '' : detail);
        }
      }
    }
    for (final f in auditDecisionCopyV1(row)) {
      taskFinding('G1·${f.rule}', id, '${f.optionId}|${f.quote}');
    }
    for (final f in auditOpeningRangeClaimsV1(row)) {
      taskFinding('G1·44', f.id, f.detail);
    }
  }
  // G1·43 checks the global chart itself in the unchanged truth-guard run.
  for (final f in chartCatalogFindingsV1(pilot)) {
    taskFinding('G1·${f.rule}', f.id, f.detail);
  }

  // Run route-sensitive audits on the full route, not individual worlds:
  // prior lessons can teach terms, supply repair targets or own reused copy.
  for (final key in runCatalogAudit(rows: allRows).findings.keys) {
    final parts = key.split('|');
    taskFinding(parts[0], parts[1], parts.skip(2).join('|'));
  }
  final rendered = await auditRenderedCatalogSeatCuesV1(tester, pilot);
  for (final key in rendered.findings.keys) {
    final parts = key.split('|');
    taskFinding(parts[0], parts[1], parts.skip(2).join('|'));
  }
  final quality = runCatalogQualityAudit();
  for (final key in quality.findings) {
    final parts = key.split('|');
    final rule = parts[0];
    final owner = parts[1];
    // Aggregate checks retain their actual lesson/world owner, rather than
    // misattributing a lesson-wide finding to a random task.
    if (rule == '17.single_format_lesson' ||
        rule == '19.lesson_length_corridor') {
      add(lessonWorld[owner]!, rule, '@lesson:$owner', parts.skip(2).join('|'));
    } else if (rule == '11.btn_share_per_world') {
      add(worldNumber[owner]!, rule, '@world:$owner', parts.skip(2).join('|'));
    } else if (taskWorld.containsKey(owner)) {
      taskFinding(rule, owner, parts.skip(2).join('|'));
    } else if (parts.length > 2 && taskWorld.containsKey(parts[2])) {
      taskFinding(rule, parts[2], parts.skip(3).join('|'));
    } else {
      throw StateError('Unmapped quality finding: $key');
    }
  }
  for (final entry in quality.correctFeedbackOverLimit.entries) {
    final parts = entry.key.split('|');
    taskFinding(
      catalogCorrectFeedbackLengthRuleV1,
      parts[0],
      '${parts[1]}|${entry.value} words',
    );
  }

  for (final entry in auditCatalogOutsV1(pilot).findings.entries) {
    final parts = entry.key.split('|');
    taskFinding('E13', parts[0], '${parts.skip(1).join('|')}|${entry.value}');
  }
  final concepts = catalogConceptOrderFindingsV1(
    catalogTasks.where((row) => !row.task.repairOnly),
    catalogConceptsV1(),
  );
  for (final entry in concepts.entries) {
    final parts = entry.key.split('|');
    taskFinding('C5', parts[1], '${parts[2]}|${entry.value}');
  }
  for (final f in auditTableTruth(
    worlds: pilot.map((row) => row.world).toSet(),
  )) {
    if (f.result != 'PASS' && !_isVerifiedScopeException(f)) {
      taskFinding(f.invariant, f.taskId, '${f.variant}|${f.detail}');
    }
  }
  for (final f in auditAct0CatalogChipLabelsV1()) {
    if (f.passes == false) {
      taskFinding(f.rule, f.task, '${f.frame}|${f.anchor}|${f.detail}');
    }
  }
  return {
    for (final world in findings.entries)
      world.key: {
        for (final rule in world.value.entries)
          rule.key: rule.value.toList()..sort(),
      },
  };
}

void main() {
  test('only explicit exceptions with verified frame scope leave debt', () {
    bool excluded(String invariant, String status, String detail) =>
        _isVerifiedScopeException(
          TableTruthRow('task', 'decision', invariant, status, detail),
        );
    const rule = 'scope.applicability';
    const status = 'EXPLICIT_EXCEPTION';
    const detail =
        'explanation: source scope must identify physical applicability';
    expect(excluded(rule, status, detail), isTrue);
    expect(excluded(rule, 'FAIL', detail), isFalse);
    expect(excluded(rule, 'NEEDS_SOURCE_CONTEXT', detail), isFalse);
    expect(excluded(rule, status, ''), isFalse);
    expect(
      excluded(
        rule,
        status,
        detail.replaceFirst('explanation', 'unclassified'),
      ),
      isFalse,
    );
    expect(
      excluded(rule, status, detail.replaceFirst('explanation', 'unknown')),
      isFalse,
    );
    expect(excluded('D6.history_support', status, detail), isFalse);
  });

  test(
    'Vol2 text-only concepts already declare explanation applicability',
    () {
      final worlds = Act0ShellStateV1.authoredCatalog.worlds.where(
        (world) => _worlds.contains(world.worldNumber),
      );
      final scopeRows = auditTableTruth(
        worlds: worlds,
      ).where((row) => row.invariant == 'scope.applicability').toList();
      expect(scopeRows, isNotEmpty);
      expect(
        scopeRows.map((row) => row.result),
        everyElement('EXPLICIT_EXCEPTION'),
      );
      expect(scopeRows.every(_isVerifiedScopeException), isTrue);
      for (final world in worlds) {
        final concepts = world.lessons
            .expand((lesson) => lesson.taskList)
            .where((task) => task.phase == Act0LessonPhaseV1.theory);
        expect(concepts, isNotEmpty, reason: world.worldId);
        for (final task in concepts) {
          final table = task.runner.table;
          expect(
            table.scope,
            Act0TableScopeV1.explanation,
            reason: task.taskId,
          );
          expect(table.seats, isEmpty, reason: task.taskId);
          expect(table.heroCards, isEmpty, reason: task.taskId);
          expect(table.boardCards, isEmpty, reason: task.taskId);
          expect(table.streetLabel, isEmpty, reason: task.taskId);
          expect(table.potLabel, isEmpty, reason: task.taskId);
          expect(table.toCallLabel, isEmpty, reason: task.taskId);
          expect(table.actionTrail, isEmpty, reason: task.taskId);
          expect(table.handContributions, isNull, reason: task.taskId);
          expect(table.handTimelinePrefix, isNull, reason: task.taskId);
          expect(
            scopeRows.where((row) => row.taskId == task.taskId),
            isNotEmpty,
            reason: task.taskId,
          );
        }
      }
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  test('ratchet distinguishes world, rule, task and detail', () {
    final baseline = {
      'W13': {
        'E17': ['a|old', 'b|old'],
      },
    };
    final smaller = {
      'W13': {
        'E17': ['a|old'],
      },
    };
    expect(_additions(smaller, baseline), isEmpty);
    expect(_additions({'W14': smaller['W13']!}, baseline), ['W14|E17|a|old']);
    expect(
      _additions({
        'W13': {
          'E18': ['a|old'],
          'E17': ['a|new', 'c|old'],
        },
      }, baseline),
      ['W13|E17|a|new', 'W13|E17|c|old', 'W13|E18|a|old'],
    );
  });

  testWidgets(
    'W13–W24 pilot G1 census ratchets findings',
    (tester) async {
      final file = File(_baselinePath);
      final baseline = _readBaseline(file);
      final current = await _collectCensus(tester);
      final update = Platform.environment['G1_UPDATE_SNAPSHOT'] == '1';
      // The empty placeholder can be seeded once. After that, even an explicit
      // update may only remove findings, never admit new debt.
      if (!(update && baseline.isEmpty)) {
        expect(
          baseline.keys.toSet(),
          current.keys.toSet(),
          reason: 'Generate the complete W13–W24 baseline before the PR.',
        );
        final added = _additions(current, baseline);
        expect(
          added,
          isEmpty,
          reason: 'New Vol2 findings:\n${added.join('\n')}',
        );
      }
      if (update) {
        file.writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(current)}\n',
        );
      } else {
        final removed = _additions(baseline, current);
        expect(
          removed,
          isEmpty,
          reason:
              'Run G1_UPDATE_SNAPSHOT=1 to retire resolved findings:\n${removed.join('\n')}',
        );
      }
    },
    skip: !act0CurriculumPilotEnabledV1,
  );
}

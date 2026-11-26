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
import 'act0_b132_origin_choreography_reference.dart';

// TODO(B91 lead): generate the initial fixture before opening the PR:
// G1_UPDATE_SNAPSHOT=1 flutter test --no-pub --dart-define=SHARKY_W13_PLUS_PILOT=true test/ui_v2/act0_catalog_vol2_census_v1_test.dart
const _baselinePath = 'test/fixtures/act0_catalog_vol2_baseline_v1.json';
const _worlds = {13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26};
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

const _explanationScopeDetail =
    'explanation: source scope must identify physical applicability';

bool _hasNoHandFacts(Act0TableStateV1 table) =>
    table.scope == Act0TableScopeV1.explanation &&
    table.seats.isEmpty &&
    table.actionTrail.isEmpty &&
    table.heroCards.isEmpty &&
    table.boardCards.isEmpty &&
    table.streetLabel.isEmpty &&
    table.potLabel.isEmpty &&
    table.toCallLabel.isEmpty &&
    table.handContributions == null &&
    table.handTimelinePrefix == null;

bool _isVerifiedScopeException(
  TableTruthRow row, {
  Act0LessonTaskV1? task,
  Set<String> explanationTaskIds = const {},
}) {
  // A history is inapplicable to a text-only theory card, but only when
  // Table Truth independently verifies explanation scope for this task.
  // Keep all physical tables (including teaching-step overrides) in debt.
  if (row.invariant == 'D6.history_support') {
    return row.result == 'EXPLICIT_EXCEPTION' &&
        task != null &&
        task.taskId == row.taskId &&
        explanationTaskIds.contains(row.taskId) &&
        task.phase == Act0LessonPhaseV1.theory &&
        task.multiStreet == null &&
        _hasNoHandFacts(task.runner.table) &&
        task.runner.teachingSteps.every(
          (step) => step.table == null || _hasNoHandFacts(step.table!),
        );
  }
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

Set<String> _verifiedExplanationTaskIds(Iterable<TableTruthRow> rows) => {
  for (final row in rows)
    if (row.detail == _explanationScopeDetail && _isVerifiedScopeException(row))
      row.taskId,
};

Map<String, Act0LessonTaskV1> _vol2Tasks() => {
  for (final row in catalogTasks)
    if (_worlds.contains(row.world.worldNumber)) row.task.taskId: row.task,
};

Future<_Census> _collectCensus(WidgetTester tester) async {
  final allRows = reasoningCatalogRowsV1;
  final pilot = allRows.where((row) => _worlds.contains(row.world.worldNumber));
  expect(
    catalogTasks
        .where((row) => _worlds.contains(row.world.worldNumber))
        .map((row) => row.world.worldNumber)
        .toSet(),
    _worlds,
    reason: 'Pilot census must contain every world W13–W26.',
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
  for (var world = 13; world < 26; world += 2) {
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
  final tableTruthRows = auditTableTruth(
    worlds: pilot.map((row) => row.world).toSet(),
  );
  final pilotTasks = _vol2Tasks();
  final explanationTaskIds = _verifiedExplanationTaskIds(tableTruthRows);
  for (final f in tableTruthRows) {
    if (f.result != 'PASS' &&
        !_isVerifiedScopeException(
          f,
          task: pilotTasks[f.taskId],
          explanationTaskIds: explanationTaskIds,
        )) {
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
  test('B132 D6 played-hand census reports origin and candidate', () {
    final worlds = Act0ShellStateV1.authoredCatalog.worlds
        .where((w) => _worlds.contains(w.worldNumber))
        .toList();
    expect(worlds.map((w) => w.worldNumber).toSet(), _worlds);
    final rows = auditTableTruth(worlds: worlds);
    var beforeTotal = 0;
    var afterTotal = 0;
    for (final world in worlds) {
      final tasks = world.lessons.expand((l) => l.taskList).toList();
      final ids = tasks.map((t) => t.taskId).toSet();
      final before = tasks.where((task) {
        final table = task.runner.table;
        return table.scope == Act0TableScopeV1.playedHand &&
            originChoreographyPlanV1(table) == null;
      }).toList();
      final after = rows
          .where(
            (r) =>
                ids.contains(r.taskId) &&
                r.invariant == 'D6.history_support' &&
                r.result == 'NEEDS_SOURCE_CONTEXT',
          )
          .toList();
      beforeTotal += before.length;
      afterTotal += after.length;
      for (final task in before) {
        final trail = task.runner.table.actionTrail
            .where((item) => !item.isNote)
            .map((item) => item.label)
            .toList();
        final tokens = trail
            .where(
              (line) => RegExp(
                r'^preflop:|\bposts\b|\braises to\b|\bcalls .* more\b',
                caseSensitive: false,
              ).hasMatch(line),
            )
            .toList();
        print(
          'B132 W${world.worldNumber} ${task.taskId}: ${tokens.isEmpty ? (trail.firstOrNull ?? "empty trail") : tokens.first}',
        );
        final proof = rows
            .where(
              (r) =>
                  r.taskId == task.taskId &&
                  r.invariant == 'D6.history_support',
            )
            .single;
        expect(
          proof.result,
          anyOf('PASS', 'NEEDS_SOURCE_CONTEXT'),
          reason: task.taskId,
        );
        if (proof.result == 'PASS') {
          expect(
            rows
                .where(
                  (r) =>
                      r.taskId == task.taskId &&
                      r.variant.startsWith('choreography/') &&
                      r.result == 'FAIL',
                )
                .map((r) => r.key),
            isEmpty,
            reason: task.taskId,
          );
        }
      }
      print(
        'B132 W${world.worldNumber} D6 NEEDS_SOURCE_CONTEXT ${before.length} -> ${after.length}',
      );
    }
    print('B132 W13–W26 D6 NEEDS_SOURCE_CONTEXT $beforeTotal -> $afterTotal');
    expect(beforeTotal, greaterThan(0));
    expect(afterTotal, 0);
    expect(
      rows
          .where(
            (r) => r.invariant == 'D6.history_support' && r.result == 'FAIL',
          )
          .map((r) => r.key),
      isEmpty,
    );
  });

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

  test('D6 retires only verified text-only theory exceptions', () {
    const empty = Act0TableStateV1(
      scope: Act0TableScopeV1.explanation,
      tableFormat: Act0TableFormatV1.sixMax,
      playerCount: 6,
      seats: [],
      heroCards: [],
      boardCards: [],
      streetLabel: '',
      potLabel: '',
      toCallLabel: '',
      centerLabel: '',
      highlightedSeatIds: [],
      highlightedCardIds: [],
    );
    Act0LessonTaskV1 task(
      Act0TableStateV1 table, {
      Act0LessonPhaseV1 phase = Act0LessonPhaseV1.theory,
      List<Act0TeachingStepV1> teachingSteps = const [],
    }) => Act0LessonTaskV1(
      taskId: 'task',
      title: 'Text concept',
      phase: phase,
      rewardXp: 0,
      runner: Act0RunnerStateV1(
        lessonId: 'lesson',
        lessonTitle: '',
        lessonSubtitle: '',
        beatIndex: 1,
        beatCount: 1,
        phase: phase,
        caption: '',
        hint: '',
        question: '',
        options: const [],
        feedbackTitle: '',
        feedbackReason: '',
        primaryCtaLabel: '',
        nextLessonId: null,
        returnTarget: 'learn',
        table: table,
        teachingSteps: teachingSteps,
      ),
    );
    TableTruthRow scope(
      String id, {
      String status = 'EXPLICIT_EXCEPTION',
      String detail = _explanationScopeDetail,
    }) => TableTruthRow(id, 'decision', 'scope.applicability', status, detail);
    final verified = [scope('task')];
    bool excluded(
      Act0LessonTaskV1 candidate, {
      String status = 'EXPLICIT_EXCEPTION',
      List<TableTruthRow>? evidence,
    }) => _isVerifiedScopeException(
      TableTruthRow(
        'task',
        'choreography/applicability',
        'D6.history_support',
        status,
        'No supported choreography plan',
      ),
      task: candidate,
      explanationTaskIds: _verifiedExplanationTaskIds(evidence ?? verified),
    );

    expect(excluded(task(empty)), isTrue);
    expect(excluded(task(empty), evidence: []), isFalse);
    expect(excluded(task(empty), evidence: [scope('other')]), isFalse);
    expect(
      excluded(task(empty), evidence: [scope('task', status: 'FAIL')]),
      isFalse,
    );
    expect(
      excluded(
        task(empty),
        evidence: [
          scope(
            'task',
            detail: _explanationScopeDetail.replaceFirst(
              'explanation',
              'orientation',
            ),
          ),
        ],
      ),
      isFalse,
    );
    final seated = empty.copyWith(
      seats: const [
        Act0SeatStateV1(seatId: 'bb', seatLabel: 'BB', displayName: 'BB'),
      ],
    );
    final withTrail = empty.copyWith(
      actionTrail: const [Act0ActionTrailItemV1(label: 'BB checks')],
    );
    expect(excluded(task(seated)), isFalse);
    expect(excluded(task(withTrail)), isFalse);
    expect(excluded(task(empty.copyWith(potLabel: '5 BB'))), isFalse);
    expect(
      excluded(
        task(
          empty,
          teachingSteps: [
            Act0TeachingStepV1(title: 'Example', body: '', table: seated),
          ],
        ),
      ),
      isFalse,
    );
    expect(excluded(task(empty, phase: Act0LessonPhaseV1.drill)), isFalse);
    final playedHand = task(empty.copyWith(scope: Act0TableScopeV1.playedHand));
    expect(excluded(playedHand), isFalse);
    expect(excluded(playedHand, status: 'NEEDS_SOURCE_CONTEXT'), isFalse);
    expect(excluded(task(empty), status: 'NEEDS_SOURCE_CONTEXT'), isFalse);
    expect(excluded(task(empty), status: 'FAIL'), isFalse);
  });

  test(
    'Vol2 text-only concepts already declare explanation applicability',
    () {
      final worlds = Act0ShellStateV1.authoredCatalog.worlds.where(
        (world) => _worlds.contains(world.worldNumber),
      );
      final rows = auditTableTruth(worlds: worlds);
      final scopeRows = rows
          .where((row) => row.invariant == 'scope.applicability')
          .toList();
      final explanationTaskIds = _verifiedExplanationTaskIds(rows);
      final pilotTasks = _vol2Tasks();
      expect(scopeRows, isNotEmpty);
      expect(
        scopeRows.map((row) => row.result),
        everyElement('EXPLICIT_EXCEPTION'),
      );
      expect(scopeRows.every(_isVerifiedScopeException), isTrue);
      for (final world in worlds) {
        final tasks = {
          for (final lesson in world.lessons)
            for (final task in lesson.taskList) task.taskId: task,
        };
        final before = rows
            .where(
              (row) =>
                  tasks.containsKey(row.taskId) &&
                  row.invariant == 'D6.history_support' &&
                  row.result != 'PASS',
            )
            .toList();
        final removed = before
            .where(
              (row) => _isVerifiedScopeException(
                row,
                task: pilotTasks[row.taskId],
                explanationTaskIds: explanationTaskIds,
              ),
            )
            .toList();
        for (final row in before) {
          final task = tasks[row.taskId]!;
          final table = task.runner.table;
          print(
            'B161 W${world.worldNumber} ${row.taskId} ${row.result} '
            '${task.phase.name} scope=${table.scope.name} '
            'seats=${table.seats.length} trail=${table.actionTrail.length} '
            'retired=${removed.contains(row)}',
          );
        }
        print(
          'B161 W${world.worldNumber} D6 debt ${before.length} -> '
          '${before.length - removed.length}',
        );
        final concepts = world.lessons
            .expand((lesson) => lesson.taskList)
            .where((task) => task.phase == Act0LessonPhaseV1.theory);
        expect(concepts, isNotEmpty, reason: world.worldId);
        expect(
          removed.map((row) => row.taskId).toSet(),
          concepts.map((task) => task.taskId).toSet(),
          reason: world.worldId,
        );
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

  test('W1–W12 D6 rows cannot enter the Vol2 retirement filter', () {
    final rows = auditTableTruth(
      worlds: Act0ShellStateV1.authoredCatalog.worlds.where(
        (world) => world.worldNumber <= 12,
      ),
    );
    final explanationTaskIds = _verifiedExplanationTaskIds(rows);
    final pilotTasks = _vol2Tasks();
    final historyRows = rows.where(
      (row) => row.invariant == 'D6.history_support',
    );
    expect(historyRows, isNotEmpty);
    for (final row in historyRows) {
      expect(
        _isVerifiedScopeException(
          row,
          task: pilotTasks[row.taskId],
          explanationTaskIds: explanationTaskIds,
        ),
        isFalse,
        reason: row.key,
      );
    }
  });

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
    'W13–W26 pilot G1 census ratchets findings',
    (tester) async {
      final file = File(_baselinePath);
      final baseline = _readBaseline(file);
      final current = await _collectCensus(tester);
      final update = Platform.environment['G1_UPDATE_SNAPSHOT'] == '1';
      // Extend the existing ratchet only for the two new worlds. Existing
      // worlds must remain subject to the exact same no-new-debt check.
      const newWorlds = {'W25', 'W26'};
      final missing = current.keys.toSet().difference(baseline.keys.toSet());
      if (update) {
        expect(
          missing.difference(newWorlds),
          isEmpty,
          reason: 'Only W25–W26 may be seeded by B147.',
        );
      } else {
        expect(
          missing,
          isEmpty,
          reason: 'Generate the complete W13–W26 baseline before the PR.',
        );
      }
      expect(baseline.keys.toSet().difference(current.keys.toSet()), isEmpty);
      final comparable = {
        for (final entry in current.entries)
          if (!update || !missing.contains(entry.key)) entry.key: entry.value,
      };
      final added = _additions(comparable, baseline);
      expect(
        added,
        isEmpty,
        reason: 'New existing-world findings:\n${added.join('\n')}',
      );
      for (final world in newWorlds) {
        final rules = current[world]!;
        final count = rules.values.fold<int>(
          0,
          (sum, hits) => sum + hits.length,
        );
        print('B147 $world: $count findings (target <= 10)');
        for (final rule in rules.entries) {
          print('B147 $world ${rule.key}: ${rule.value.length}');
        }
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

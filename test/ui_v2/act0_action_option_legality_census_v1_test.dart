import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_ledger_v1.dart';

/// Action answers against the ledger's reconstructed state, for every task.
///
/// Where Hero is the seat the history leaves to act, every action option is
/// checked against that exact state: a keyed answer must be legal, a call
/// must cost exactly Hero's price, and a bet or raise must reach the legal
/// minimum. Illegal actions may appear only as wrong answers (legality
/// lessons teach them). Orientation and explanation frames never grade an
/// action decision.
const _actionIds = {
  'fold',
  'check',
  'call',
  'bet',
  'raise',
  'jam',
  'shove',
  'limp',
};

final _amount = RegExp(r'^(\d+(?:\.\d+)?) BB$');

typedef _Item = ({
  String id,
  Act0LessonPhaseV1 phase,
  Act0RunnerStateV1 runner,
});

({List<String> problems, int tasks, int options}) _census(List<_Item> items) {
  final problems = <String>[];
  var checkedTasks = 0;
  var checkedOptions = 0;
  for (final t in items) {
    final table = t.runner.table;
    if (table.scope != Act0TableScopeV1.playedHand) continue;
    if (t.phase == Act0LessonPhaseV1.theory) continue; // options not shown
    final actions = t.runner.options.where((o) => _actionIds.contains(o.id));
    if (actions.isEmpty) continue;
    final ledger = act0TableLedgerForV1(table);
    if (!ledger.isCertified) problems.add('${t.id} is not certified');
    if (ledger.nextActorSeatId != table.heroSeat.seatId) continue;
    checkedTasks += 1;
    final price = ledger.heroPriceBb;
    for (final o in actions) {
      checkedOptions += 1;
      final amount = _amount.firstMatch((o.amountLabel ?? '').trim());
      final value = amount == null ? null : double.parse(amount.group(1)!);
      final legal = switch (o.id) {
        'check' => price == 0,
        'call' || 'limp' => price > 0,
        'bet' => price == 0,
        'raise' => price > 0,
        _ => true,
      };
      final id = '${t.id}/${o.id}';
      if (o.isCorrect && !legal) problems.add('$id keyed but illegal');
      if (o.id == 'call' && value != null && value != price) {
        problems.add('$id costs $value BB; Hero owes $price BB');
      }
      if ((o.id == 'raise' || o.id == 'bet') &&
          value != null &&
          value < ledger.minRaiseToBb) {
        problems.add('$id to $value BB is below ${ledger.minRaiseToBb} BB');
      }
    }
  }
  return (problems: problems, tasks: checkedTasks, options: checkedOptions);
}

Act0RunnerOptionV1 _with(
  Act0RunnerOptionV1 o, {
  String? amountLabel,
  bool? isCorrect,
}) => Act0RunnerOptionV1(
  id: o.id,
  label: o.label,
  amountLabel: amountLabel ?? o.amountLabel,
  isCorrect: isCorrect ?? o.isCorrect,
  preferredLabel: o.preferredLabel,
  quality: o.quality,
  feedbackTitle: o.feedbackTitle,
  feedbackReason: o.feedbackReason,
);

void main() {
  final tasks = <Act0LessonTaskV1>[
    for (final w in Act0ShellStateV1.sample.worlds)
      for (final l in w.lessons) ...l.taskList,
  ];
  final items = [
    for (final t in tasks) (id: t.taskId, phase: t.phase, runner: t.runner),
  ];

  test('action answers are legal and priced at the reconstructed state', () {
    final result = _census(items);
    expect(result.problems, isEmpty);
    // The census must actually apply, not pass vacuously.
    expect(result.tasks, greaterThan(40));
    expect(result.options, greaterThan(100));
  });

  test('orientation and explanation frames never grade an action', () {
    final problems = <String>[];
    var frames = 0;
    for (final t in tasks) {
      final scope = t.runner.table.scope;
      if (scope == Act0TableScopeV1.playedHand) continue;
      frames += 1;
      for (final o in t.runner.options) {
        if (_actionIds.contains(o.id) || (o.amountLabel ?? '').isNotEmpty) {
          problems.add('${t.taskId}/${o.id} (${scope.name})');
        }
      }
    }
    expect(frames, 50);
    expect(problems, isEmpty);
  });

  test(
    'negative controls: mispriced call, under-raise, keyed illegal check',
    () {
      final t = tasks.singleWhere((t) => t.taskId == 'actions_fold_drill');
      List<String> problemsWith(
        Act0RunnerOptionV1 Function(Act0RunnerOptionV1) change,
      ) => _census([
        (
          id: t.taskId,
          phase: t.phase,
          runner: t.runner.copyWith(
            options: [for (final o in t.runner.options) change(o)],
          ),
        ),
      ]).problems;
      expect(
        problemsWith((o) => o.id == 'call' ? _with(o, amountLabel: '1 BB') : o),
        contains('actions_fold_drill/call costs 1.0 BB; Hero owes 2.0 BB'),
      );
      expect(
        problemsWith(
          (o) => o.id == 'raise' ? _with(o, amountLabel: '3 BB') : o,
        ),
        contains('actions_fold_drill/raise to 3.0 BB is below 4.0 BB'),
      );
      final check = tasks.singleWhere((t) => t.taskId == 'actions_call_drill');
      final keyedCheck = _census([
        (
          id: check.taskId,
          phase: check.phase,
          runner: check.runner.copyWith(
            options: [
              for (final o in check.runner.options) _with(o, isCorrect: false),
              const Act0RunnerOptionV1(
                id: 'check',
                label: 'Check',
                isCorrect: true,
                preferredLabel: 'Check',
                quality: Act0FeedbackQualityV1.correct,
                feedbackTitle: 'x',
                feedbackReason: 'x',
              ),
            ],
          ),
        ),
      ]).problems;
      expect(
        keyedCheck,
        contains('actions_call_drill/check keyed but illegal'),
      );
    },
  );
}

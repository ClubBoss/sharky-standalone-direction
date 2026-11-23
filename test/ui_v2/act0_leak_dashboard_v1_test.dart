import 'package:poker_analyzer/ui_v2/act0_shell/act0_leak_dashboard_v1.dart';
import 'package:test/test.dart';

final _now = DateTime.utc(2026, 11, 23, 12);
const _button = (Act0LeakDimensionV1.position, 'BTN');
const _flop = (Act0LeakDimensionV1.street, 'flop');
const _price = (Act0LeakDimensionV1.concept, 'call_price');
const _world = (Act0LeakDimensionV1.world, 'world_4');
const _skill = (Act0LeakDimensionV1.skill, 'Betting decisions');
const _rare = (Act0LeakDimensionV1.position, 'UTG');

Act0LeakObservationV1 _answer(
  String id, {
  int daysAgo = 0,
  bool correct = false,
  Set<Act0LeakBucketKeyV1> buckets = const {
    _button,
    _flop,
    _price,
    _world,
    _skill,
  },
  Act0LeakAttemptKindV1 kind = Act0LeakAttemptKindV1.firstIndependent,
}) => (
  id: id,
  recordedAt: _now.subtract(Duration(days: daysAgo)),
  correct: correct,
  buckets: buckets,
  kind: kind,
);

const _target = (
  kind: Act0LeakPracticeKindV1.dailyPractice,
  worldId: 'world_4',
  lessonId: 'call_price',
  taskId: 'daily-price-variant',
  sourceTaskId: 'price-drill',
);

Act0LeakDashboardV1 _report(
  List<Act0LeakObservationV1> answers, {
  int minimum = 8,
  Iterable<Act0LeakPracticeTargetV1> Function(String)? targets,
}) => Act0LeakDashboardV1.aggregate(
  observations: answers,
  nowUtc: _now,
  minimumAttempts: minimum,
  practiceForMiss: targets ?? (_) => const [],
);

void main() {
  test(
    'defaults to eight, suppresses small samples, and ranks three leaks',
    () {
      final answers = [
        for (var n = 0; n < 7; n++) _answer('first-$n', correct: n < 2),
        _answer('rare', buckets: {_rare}),
      ];
      final under = _report(answers);
      expect(under.state, Act0LeakDashboardStateV1.tooLittleData);
      expect(under.breakdown[_price]!.accuracy, isNull);
      expect(under.topLeaks, isEmpty);
      final ready = _report([...answers, _answer('eighth')]);
      expect(ready.state, Act0LeakDashboardStateV1.ready);
      expect(
        ready.breakdown.keys,
        containsAll([_button, _flop, _price, _world, _skill]),
      );
      expect(ready.breakdown[_price]!.accuracy, .25);
      expect(ready.breakdown[_rare]!.accuracy, isNull);
      expect(ready.topLeaks.map((leak) => leak.bucket), [
        _button,
        _flop,
        _skill,
      ]);
      expect(_report(answers, minimum: 7).breakdown[_price]!.accuracy, 2 / 7);
      expect(_report([]).state, Act0LeakDashboardStateV1.empty);
    },
  );

  test('only missed first answers resolve practice targets', () {
    final requested = <String>[];
    final report = _report(
      [
        _answer('miss'),
        _answer('another-miss'),
        _answer('correct', correct: true),
        _answer('retry', correct: true, kind: Act0LeakAttemptKindV1.repeat),
        _answer(
          'assisted',
          correct: true,
          kind: Act0LeakAttemptKindV1.unclassified,
        ),
      ],
      minimum: 1,
      targets: (id) {
        requested.add(id);
        return [_target];
      },
    );
    expect(report.overall.firstAttempts, 3);
    expect(report.overall.correctFirstAttempts, 1);
    expect(report.overall.repeats, 1);
    expect(report.breakdown[_flop]!.accuracy, 1 / 3);
    expect(requested, ['miss', 'another-miss']);
    for (final leak in report.topLeaks) {
      expect(leak.practiceTargets, [_target]);
    }
  });

  test(
    'UTC rolling windows use disjoint baselines and suppress thin samples',
    () {
      final report = _report([
        _answer('today', correct: true),
        _answer('at-7', daysAgo: 7, correct: true),
        _answer('at-8', daysAgo: 8),
        _answer('at-14', daysAgo: 14),
        _answer('at-30', daysAgo: 30),
        _answer('at-60', daysAgo: 60),
        _answer('too-old', daysAgo: 61),
        _answer('future', daysAgo: -1, correct: true),
      ], minimum: 2);
      expect(report.state, Act0LeakDashboardStateV1.improving);
      expect(report.sevenDays.current.firstAttempts, 2);
      expect(report.sevenDays.current.accuracy, 1);
      expect(report.sevenDays.previous.firstAttempts, 2);
      expect(report.sevenDays.previous.accuracy, 0);
      expect(report.thirtyDays.current.firstAttempts, 5);
      expect(report.thirtyDays.current.accuracy, .4);
      expect(report.thirtyDays.previous.firstAttempts, 1);
      expect(report.thirtyDays.previous.accuracy, isNull);
      expect(report.overall.firstAttempts, 7);
    },
  );

  test('Review does not build the dashboard when the flag is off', () {
    var reads = 0;
    final dashboard = Act0LeakDashboardV1.forReview(() {
      reads++;
      return _report([]);
    });
    expect(reads, leakDashboardV1 ? 1 : 0);
    expect(
      dashboard?.state,
      leakDashboardV1 ? Act0LeakDashboardStateV1.empty : null,
    );
  });
}

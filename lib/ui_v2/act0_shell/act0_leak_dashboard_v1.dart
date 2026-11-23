const leakDashboardV1 =
    !bool.fromEnvironment('dart.vm.product') &&
    bool.fromEnvironment('SHARKY_LEAK_DASHBOARD_V1');

enum Act0LeakDimensionV1 { position, street, skill, concept, world }

enum Act0LeakAttemptKindV1 { firstIndependent, repeat, unclassified }

enum Act0LeakDashboardStateV1 { empty, tooLittleData, ready, improving }

enum Act0LeakPracticeKindV1 { reviewRepair, dailyPractice }

typedef Act0LeakBucketKeyV1 = (Act0LeakDimensionV1, String);
typedef Act0LeakPracticeTargetV1 = ({
  Act0LeakPracticeKindV1 kind,
  String worldId,
  String lessonId,
  String taskId,
  String sourceTaskId,
});

/// Normalized from local archive evidence and verified catalogue metadata.
typedef Act0LeakObservationV1 = ({
  String id,
  DateTime recordedAt,
  Act0LeakAttemptKindV1 kind,
  bool correct,
  Set<Act0LeakBucketKeyV1> buckets,
});

class Act0LeakAccuracyV1 {
  const Act0LeakAccuracyV1({
    required this.firstAttempts,
    required this.correctFirstAttempts,
    required this.repeats,
    required this.minimumAttempts,
  });

  final int firstAttempts;
  final int correctFirstAttempts;
  final int repeats;
  final int minimumAttempts;

  double? get accuracy => firstAttempts < minimumAttempts
      ? null
      : correctFirstAttempts / firstAttempts;
}

typedef Act0LeakTrendV1 = ({
  Act0LeakAccuracyV1 current,
  Act0LeakAccuracyV1 previous,
});

typedef Act0RankedLeakV1 = ({
  Act0LeakBucketKeyV1 bucket,
  Act0LeakAccuracyV1 counts,
  List<Act0LeakPracticeTargetV1> practiceTargets,
});

class Act0LeakDashboardV1 {
  const Act0LeakDashboardV1._({
    required this.state,
    required this.overall,
    required this.breakdown,
    required this.topLeaks,
    required this.sevenDays,
    required this.thirtyDays,
  });

  static const title = 'Your leaks';
  static const insufficientDataLabel = 'Not enough data';

  final Act0LeakDashboardStateV1 state;
  final Act0LeakAccuracyV1 overall;
  final Map<Act0LeakBucketKeyV1, Act0LeakAccuracyV1> breakdown;
  final List<Act0RankedLeakV1> topLeaks;
  final Act0LeakTrendV1 sevenDays;
  final Act0LeakTrendV1 thirtyDays;

  /// The factory stays lazy so a disabled Review makes no dashboard reads.
  static Act0LeakDashboardV1? forReview(Act0LeakDashboardV1 Function() build) =>
      leakDashboardV1 ? build() : null;

  static Act0LeakDashboardV1 aggregate({
    required Iterable<Act0LeakObservationV1> observations,
    required DateTime nowUtc,
    required Iterable<Act0LeakPracticeTargetV1> Function(String attemptId)
    practiceForMiss,
    int minimumAttempts = 8,
  }) {
    if (minimumAttempts < 1) {
      throw ArgumentError.value(minimumAttempts, 'minimumAttempts');
    }
    final overall = _Counts();
    final byBucket = <Act0LeakBucketKeyV1, _Counts>{};
    final seven = _Trend(nowUtc.toUtc(), 7);
    final thirty = _Trend(nowUtc.toUtc(), 30);
    var hasAttempts = false;
    for (final attempt in observations) {
      if (attempt.recordedAt.isAfter(nowUtc)) continue;
      hasAttempts = true;
      overall.add(attempt);
      seven.add(attempt);
      thirty.add(attempt);
      for (final bucket in attempt.buckets) {
        byBucket.putIfAbsent(bucket, _Counts.new).add(attempt);
      }
    }
    final breakdown = byBucket.map(
      (bucket, counts) => MapEntry(bucket, counts.snapshot(minimumAttempts)),
    );
    final ranked =
        breakdown.entries
            .where(
              (entry) =>
                  entry.value.accuracy != null &&
                  entry.value.correctFirstAttempts < entry.value.firstAttempts,
            )
            .toList()
          ..sort((a, b) {
            final accuracy = a.value.accuracy!.compareTo(b.value.accuracy!);
            if (accuracy != 0) return accuracy;
            final sample = b.value.firstAttempts.compareTo(
              a.value.firstAttempts,
            );
            if (sample != 0) return sample;
            final dimension = a.key.$1.index.compareTo(b.key.$1.index);
            return dimension == 0 ? a.key.$2.compareTo(b.key.$2) : dimension;
          });
    final targetsByMiss = <String, Iterable<Act0LeakPracticeTargetV1>>{};
    final topLeaks = [
      for (final entry in ranked.take(3))
        (
          bucket: entry.key,
          counts: entry.value,
          practiceTargets: List<Act0LeakPracticeTargetV1>.unmodifiable({
            for (final id in byBucket[entry.key]!.misses)
              ...targetsByMiss.putIfAbsent(
                id,
                () => practiceForMiss(id).toList(),
              ),
          }),
        ),
    ];
    final week = seven.snapshot(minimumAttempts);
    final month = thirty.snapshot(minimumAttempts);
    final thisWeek = week.current.accuracy;
    final lastWeek = week.previous.accuracy;
    final state = !hasAttempts
        ? Act0LeakDashboardStateV1.empty
        : !breakdown.values.any((counts) => counts.accuracy != null)
        ? Act0LeakDashboardStateV1.tooLittleData
        : thisWeek != null && lastWeek != null && thisWeek > lastWeek
        ? Act0LeakDashboardStateV1.improving
        : Act0LeakDashboardStateV1.ready;
    return Act0LeakDashboardV1._(
      state: state,
      overall: overall.snapshot(minimumAttempts),
      breakdown: Map.unmodifiable(breakdown),
      topLeaks: List.unmodifiable(topLeaks),
      sevenDays: week,
      thirtyDays: month,
    );
  }
}

class _Counts {
  int first = 0;
  int correct = 0;
  int repeats = 0;
  final misses = <String>[];

  void add(Act0LeakObservationV1 observation) {
    switch (observation.kind) {
      case Act0LeakAttemptKindV1.firstIndependent:
        first++;
        if (observation.correct) {
          correct++;
        } else {
          misses.add(observation.id);
        }
      case Act0LeakAttemptKindV1.repeat:
        repeats++;
      case Act0LeakAttemptKindV1.unclassified:
        break;
    }
  }

  Act0LeakAccuracyV1 snapshot(int minimumAttempts) => Act0LeakAccuracyV1(
    firstAttempts: first,
    correctFirstAttempts: correct,
    repeats: repeats,
    minimumAttempts: minimumAttempts,
  );
}

class _Trend {
  _Trend(DateTime now, int days)
    : start = now.subtract(Duration(days: days)),
      priorStart = now.subtract(Duration(days: days * 2));

  final DateTime start;
  final DateTime priorStart;
  final _Counts current = _Counts();
  final _Counts previous = _Counts();

  // Adjacent rolling UTC windows. The shared cutoff belongs to current.
  void add(Act0LeakObservationV1 attempt) {
    if (!attempt.recordedAt.isBefore(start)) {
      current.add(attempt);
    } else if (!attempt.recordedAt.isBefore(priorStart)) {
      previous.add(attempt);
    }
  }

  Act0LeakTrendV1 snapshot(int minimumAttempts) => (
    current: current.snapshot(minimumAttempts),
    previous: previous.snapshot(minimumAttempts),
  );
}

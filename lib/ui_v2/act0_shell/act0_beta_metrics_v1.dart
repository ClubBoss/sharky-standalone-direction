import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'act0_completed_decision_contract_v1.dart';
import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_local_data_deletion_v1.dart';
import 'act0_path_progress_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_w1_rules_check_v1.dart';

const act0BetaMetricsEnabledV1 = bool.fromEnvironment('SHARKY_BETA_METRICS');

const act0BetaSurveyQuestionsV1 = [
  'Did you know what to do in the first lesson?',
  'Did the explanation help you understand a mistake?',
  'Would you practice again tomorrow?',
  'Did Home take you where you expected when you returned?',
  'After missing twice, could you keep going?',
];

const _initialBetaSurveyLengthV1 = 3;

enum Act0BetaSurveyAnswerV1 { yes, no, unsure }

enum Act0BetaReturnV1 { pending, returned, missed }

/// Beta return windows, fixed-choice feedback and first-week activity counts.
class Act0BetaActivityV1 {
  Act0BetaActivityV1._({
    required this.firstVisitUtc,
    required this.observedDay,
    required this.returnedDay2,
    required this.returnedDay7,
    required List<Act0BetaSurveyAnswerV1?> answers,
    Map<String, int> lessonDays = const {},
    List<int> practiceSteps = const [0, 0, 0, 0, 0, 0, 0, 0],
    this.rulesCheckStarted = false,
  }) : answers = List.unmodifiable(answers),
       lessonDays = Map.unmodifiable(lessonDays),
       practiceSteps = List.unmodifiable(practiceSteps);

  factory Act0BetaActivityV1.firstVisit(DateTime now) => Act0BetaActivityV1._(
    firstVisitUtc: now.toUtc(),
    observedDay: 0,
    returnedDay2: false,
    returnedDay7: false,
    answers: List.filled(act0BetaSurveyQuestionsV1.length, null),
  );

  final DateTime firstVisitUtc;
  final int observedDay;
  final bool returnedDay2, returnedDay7;
  final List<Act0BetaSurveyAnswerV1?> answers;
  final Map<String, int> lessonDays;
  final List<int> practiceSteps;
  final bool rulesCheckStarted;

  int? dayOf(DateTime time) {
    final elapsed = time.difference(firstVisitUtc);
    return elapsed.isNegative || elapsed.inDays > 7 ? null : elapsed.inDays;
  }

  Act0BetaActivityV1 _copy({
    int? day,
    bool? day2,
    bool? day7,
    List<Act0BetaSurveyAnswerV1?>? answers,
    Map<String, int>? lessonDays,
    List<int>? practiceSteps,
    bool? rulesCheckStarted,
  }) => Act0BetaActivityV1._(
    firstVisitUtc: firstVisitUtc,
    observedDay: day ?? observedDay,
    returnedDay2: day2 ?? returnedDay2,
    returnedDay7: day7 ?? returnedDay7,
    answers: answers ?? this.answers,
    lessonDays: lessonDays ?? this.lessonDays,
    practiceSteps: practiceSteps ?? this.practiceSteps,
    rulesCheckStarted: rulesCheckStarted ?? this.rulesCheckStarted,
  );

  Act0BetaActivityV1 _completeLesson(DateTime now, String lessonId) {
    final day = dayOf(now);
    if (day == null || lessonDays.containsKey(lessonId)) return this;
    return _copy(lessonDays: {...lessonDays, lessonId: day});
  }

  Act0BetaActivityV1 _completePracticeStep(DateTime now) {
    final day = dayOf(now);
    if (day == null) return this;
    return _copy(
      practiceSteps: [...practiceSteps]..[day] = practiceSteps[day] + 1,
    );
  }

  Act0BetaActivityV1 visitAt(DateTime now) {
    final elapsed = now.difference(firstVisitUtc);
    if (elapsed.isNegative) return this;
    final day = elapsed.inDays.clamp(0, 7);
    // A foreground after a clock rollback cannot fill an earlier missed day.
    if (day <= observedDay) return this;
    return _copy(
      day: day,
      day2: returnedDay2 || day == 1,
      day7: returnedDay7 || day == 6,
    );
  }

  Act0BetaReturnV1 day2At(DateTime now) => _returnAt(now, 2, returnedDay2);
  Act0BetaReturnV1 day7At(DateTime now) => _returnAt(now, 7, returnedDay7);

  Act0BetaReturnV1 _returnAt(DateTime now, int windowEnd, bool returned) {
    if (returned) return Act0BetaReturnV1.returned;
    return observedDay >= windowEnd ||
            now.difference(firstVisitUtc) >= Duration(days: windowEnd)
        ? Act0BetaReturnV1.missed
        : Act0BetaReturnV1.pending;
  }

  Act0BetaActivityV1 withAnswer(int question, Act0BetaSurveyAnswerV1? answer) {
    if (answers[question] == answer) return this;
    final updated = [...answers]..[question] = answer;
    return _copy(answers: updated);
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'firstVisitUtc': firstVisitUtc.toIso8601String(),
    'observedDay': observedDay,
    'returnedDay2': returnedDay2,
    'returnedDay7': returnedDay7,
    'answers': [for (final answer in answers) answer?.name],
    if (lessonDays.isNotEmpty) 'lessonDays': lessonDays,
    if (practiceSteps.any((count) => count > 0)) 'practiceSteps': practiceSteps,
    if (rulesCheckStarted) 'rulesCheckStarted': true,
  };

  static Act0BetaActivityV1? _parse(Object? raw) {
    if (raw case {
      'version': 1,
      'firstVisitUtc': final String firstVisit,
      'observedDay': final int day,
      'returnedDay2': final bool day2,
      'returnedDay7': final bool day7,
      'answers': final List<Object?> answers,
    }) {
      final first = DateTime.tryParse(firstVisit);
      if (first == null ||
          !first.isUtc ||
          day < 0 ||
          day > 7 ||
          (day2 && day < 1) ||
          (day7 && day < 6) ||
          (answers.length != _initialBetaSurveyLengthV1 &&
              answers.length != act0BetaSurveyQuestionsV1.length)) {
        return null;
      }
      final decoded = <Act0BetaSurveyAnswerV1?>[];
      for (final answer in answers) {
        final known = Act0BetaSurveyAnswerV1.values
            .where((value) => value.name == answer)
            .firstOrNull;
        if (answer != null && known == null) return null;
        decoded.add(known);
      }
      final map = raw as Map;
      final lessonDays = map['lessonDays'] ?? const <String, int>{};
      final practiceSteps =
          map['practiceSteps'] ?? const [0, 0, 0, 0, 0, 0, 0, 0];
      final rulesCheckStarted = map['rulesCheckStarted'] ?? false;
      if (lessonDays is! Map<String, Object?> ||
          lessonDays.values.any((day) => day is! int || day < 0 || day > 7) ||
          practiceSteps is! List ||
          practiceSteps.length != 8 ||
          practiceSteps.any((count) => count is! int || count < 0) ||
          rulesCheckStarted is! bool) {
        return null;
      }
      return Act0BetaActivityV1._(
        firstVisitUtc: first,
        observedDay: day,
        returnedDay2: day2,
        returnedDay7: day7,
        lessonDays: lessonDays.cast<String, int>(),
        practiceSteps: practiceSteps.cast<int>(),
        rulesCheckStarted: rulesCheckStarted,
        answers: [
          ...decoded,
          for (
            var i = decoded.length;
            i < act0BetaSurveyQuestionsV1.length;
            i++
          )
            null,
        ],
      );
    }
    return null;
  }
}

class Act0BetaMetricsStoreV1 {
  static const key = 'act0_beta_activity_v1';
  static Future<void>? _pending;

  static Future<void> flush() => _pending ?? Future<void>.value();

  static Future<Act0BetaActivityV1?> read() async {
    await flush();
    final generation = Act0LocalDataDeletionV1.generation;
    final prefs = await SharedPreferences.getInstance();
    if (Act0LocalDataDeletionV1.blocked ||
        generation != Act0LocalDataDeletionV1.generation) {
      return null;
    }
    return _read(prefs);
  }

  static Future<void> recordVisit(DateTime now) => _update(
    (data) => data?.visitAt(now) ?? Act0BetaActivityV1.firstVisit(now),
  );

  static Future<void> recordLesson(DateTime now, String lessonId) =>
      _update((data) => data?._completeLesson(now, lessonId));

  static Future<void> recordPracticeStep(DateTime now) =>
      _update((data) => data?._completePracticeStep(now));

  static Future<void> recordRulesCheckStarted() => _update(
    (data) => data == null || data.rulesCheckStarted
        ? data
        : data._copy(rulesCheckStarted: true),
  );

  static Future<void> setAnswer(int question, Act0BetaSurveyAnswerV1? answer) =>
      _update((data) => data?.withAnswer(question, answer));

  static Future<void> _update(
    Act0BetaActivityV1? Function(Act0BetaActivityV1?) change,
  ) {
    final generation = Act0LocalDataDeletionV1.generation;
    final write = flush().then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (Act0LocalDataDeletionV1.blocked ||
          generation != Act0LocalDataDeletionV1.generation) {
        return;
      }
      final current = _read(prefs);
      if (current == null && prefs.containsKey(key)) return;
      final next = change(current);
      if (next != null && !identical(current, next)) {
        if (!await prefs.setString(key, jsonEncode(next.toJson()))) {
          await prefs.reload();
          throw StateError('Beta activity could not be saved');
        }
      }
    });
    final tail = write.then<void>((_) {}, onError: (Object _) {});
    _pending = tail;
    unawaited(
      tail.then((_) {
        if (identical(_pending, tail)) _pending = null;
      }),
    );
    return write;
  }

  static Act0BetaActivityV1? _read(SharedPreferences prefs) {
    final raw = prefs.get(key);
    if (raw is! String) return null;
    try {
      return Act0BetaActivityV1._parse(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }
}

class Act0BetaLearningMetricsV1 {
  const Act0BetaLearningMetricsV1({
    required this.firstLessonCompleted,
    required this.worldOneEntryObserved,
    required this.worldOneCompleted,
    required this.correctedMistakes,
    this.completedRoutePracticeSteps = 0,
    this.firstLessonId = '',
    this.firstLessonTaskIds = const {},
    this.courseWorlds = const [],
    this.completedTaskIds = const {},
    this.currentLessonId = '',
    this.rulesBestScore = 0,
    this.rulesCheckCompleted = false,
    this.history = const Act0LearningEvidenceHistoryV1(),
  });

  factory Act0BetaLearningMetricsV1.fromProgress({
    required Act0WorldCardV1 firstWorld,
    required Set<String> completedTaskIds,
    required int correctedMistakes,
    int completedRoutePracticeSteps = 0,
    List<Act0WorldCardV1> courseWorlds = const [],
    String currentLessonId = '',
    int rulesBestScore = 0,
    bool rulesCheckCompleted = false,
    Act0LearningEvidenceHistoryV1 history =
        const Act0LearningEvidenceHistoryV1(),
  }) {
    final firstLesson = firstWorld.lessons.firstOrNull;
    final worldOneTaskIds = {
      for (final lesson in firstWorld.lessons)
        for (final task in lesson.taskList) task.taskId,
    };
    bool completed(Act0LessonCardV1 lesson) =>
        lesson.taskList.isNotEmpty &&
        act0LessonCompleteWithTaskIdsV1(lesson, completedTaskIds);
    return Act0BetaLearningMetricsV1(
      firstLessonCompleted: firstLesson != null && completed(firstLesson),
      // A selected lesson is only a route cursor: fresh progress and an 8/10
      // rules-check result both select W1 before the learner enters it. Keep
      // this cohort strict to durable learning activity already saved by the
      // app. The rules check itself is placement evidence, not a W1 entry.
      worldOneEntryObserved:
          completedTaskIds.any(worldOneTaskIds.contains) ||
          history.provenanceRecords.any(
            (record) =>
                record.worldId == firstWorld.worldId &&
                !record.isPlacementAssessment &&
                !record.isDiagnosticLearningEntry,
          ),
      worldOneCompleted:
          firstLesson != null && firstWorld.lessons.every(completed),
      correctedMistakes: correctedMistakes,
      completedRoutePracticeSteps: completedRoutePracticeSteps,
      firstLessonId: firstLesson?.lessonId ?? '',
      firstLessonTaskIds: {
        if (firstLesson != null)
          for (final task in firstLesson.courseTaskList) task.taskId,
      },
      history: history,
      courseWorlds: courseWorlds,
      completedTaskIds: Set.unmodifiable(completedTaskIds),
      currentLessonId: currentLessonId,
      rulesBestScore: rulesBestScore,
      rulesCheckCompleted: rulesCheckCompleted,
    );
  }

  final bool firstLessonCompleted, worldOneEntryObserved, worldOneCompleted;
  final int correctedMistakes;
  final int completedRoutePracticeSteps;
  final String firstLessonId;
  final Set<String> firstLessonTaskIds;
  final Act0LearningEvidenceHistoryV1 history;
  final List<Act0WorldCardV1> courseWorlds;
  final Set<String> completedTaskIds;
  final String currentLessonId;
  final int rulesBestScore;
  final bool rulesCheckCompleted;

  ({List<String> progress, String clipboard}) summary(
    Act0BetaActivityV1 activity,
    DateTime now, {
    required bool? reminderEnabled,
  }) {
    final course = [
      for (final world in courseWorlds)
        for (final lesson in world.lessons) (world: world, lesson: lesson),
    ];
    final byTask = {
      for (final row in course)
        for (final task in row.lesson.courseTaskList)
          (row.world.worldId, row.lesson.lessonId, task.taskId):
              row.lesson.lessonId,
    };
    final finished = course
        .where(
          (row) =>
              act0LessonCompleteWithTaskIdsV1(row.lesson, completedTaskIds),
        )
        .toList();
    final current = course
        .where((row) => row.lesson.lessonId == currentLessonId)
        .firstOrNull;
    final counts = <String, ({int first, int wrong, int helped})>{};
    final firstAnswers = <(String, String, String)>{};
    final missedInRun = <(String, String)>{};
    var retryCorrect = 0;
    var retryTotal = 0;
    for (final record in history.provenanceRecords) {
      final time = record.recordedAtUtc;
      if (time == null || activity.dayOf(time) == null || time.isAfter(now))
        continue;
      final runTask = (record.runId, record.taskId);
      final retryInLesson =
          record.runKind == 'lesson' &&
          record.runId.isNotEmpty &&
          missedInRun.contains(runTask);
      if (retryInLesson ||
          record.runKind == 'repair' ||
          record.runKind == 'recheck') {
        retryTotal++;
        if (record.isCorrect) retryCorrect++;
      }
      if (record.runKind != 'lesson') continue;
      if (record.isCorrect) {
        missedInRun.remove(runTask);
      } else {
        missedInRun.add(runTask);
      }
      final key = (record.worldId, record.lessonId, record.taskId);
      final lessonId = byTask[key];
      if (lessonId == null || !firstAnswers.add(key)) continue;
      final previous = counts[lessonId] ?? (first: 0, wrong: 0, helped: 0);
      counts[lessonId] = (
        first: previous.first + 1,
        wrong: previous.wrong + (record.isCorrect ? 0 : 1),
        helped: previous.helped + (record.hasKnownAssistance ? 1 : 0),
      );
    }
    final tookCheck = activity.rulesCheckStarted || rulesCheckCompleted;
    final scores = decisionsSince(activity.firstVisitUtc);
    final day = now.difference(activity.firstVisitUtc).inDays.clamp(0, 7);
    final farthest = course
        .where(
          (row) =>
              row == current ||
              counts.containsKey(row.lesson.lessonId) ||
              row.lesson.courseTaskList.any(
                (task) => completedTaskIds.contains(task.taskId),
              ),
        )
        .lastOrNull;
    String describeLesson(
      ({Act0WorldCardV1 world, Act0LessonCardV1 lesson})? row, {
      required bool forCopy,
    }) {
      if (row == null) return 'None';
      final lesson = forCopy ? row.lesson.lessonId : row.lesson.title;
      return 'W${row.world.worldNumber} / $lesson';
    }

    List<String> progress({required bool forCopy}) => [
      'Current lesson: ${describeLesson(current, forCopy: forCopy)}',
      'Farthest lesson reached: ${describeLesson(farthest, forCopy: forCopy)}',
      'Completed lessons: ${finished.length}',
      'Completed route practice steps: $completedRoutePracticeSteps',
      'W1 rules check: ${!tookCheck
          ? 'Not started'
          : rulesCheckCompleted
          ? 'Best $rulesBestScore/${act0W1RulesQuestionsV1.length}'
          : 'Started'}',
      'After a mistake: $retryCorrect/$retryTotal correct on follow-up attempts',
      'Reminder now: ${switch (reminderEnabled) {
        true => 'On',
        false => 'Off',
        null => 'Unavailable',
      }}',
    ];
    final lines = [
      'Sharky beta summary v1',
      'Beta day: $day',
      'First lesson: ${firstLessonCompleted ? 'Complete' : 'Incomplete'}',
      'World 1 entry: ${worldOneEntryObserved ? 'Observed' : 'Not observed'}',
      'World 1: ${worldOneCompleted ? 'Complete' : 'Incomplete'}',
      'Corrected mistakes: $correctedMistakes',
      'Day 2: ${activity.day2At(now).name}',
      'Day 7: ${activity.day7At(now).name}',
      'First lesson on your own: ${scores.onYourOwn.correct}/${scores.onYourOwn.total}',
      'First lesson with help: ${scores.withHelp.correct}/${scores.withHelp.total}',
      'Day 7 new review: ${scores.day7NewReview.correct}/${scores.day7NewReview.total}',
      ...progress(forCopy: true),
      for (var index = 0; index <= day; index++)
        'Beta day $index: ${activity.lessonDays.values.where((value) => value == index).length} lessons, '
            '${activity.practiceSteps[index]} practice steps',
      for (final row in course)
        if (counts[row.lesson.lessonId] case final count?)
          '${row.lesson.lessonId}: ${count.first} first answers, ${count.wrong} wrong, ${count.helped} with help',
      for (final (index, answer) in activity.answers.indexed)
        'Survey ${index + 1}: ${answer?.name ?? 'unanswered'}',
    ];
    return (progress: progress(forCopy: false), clipboard: lines.join('\n'));
  }

  ({
    ({int correct, int total}) onYourOwn,
    ({int correct, int total}) withHelp,
    ({int correct, int total}) day7NewReview,
  })
  decisionsSince(DateTime firstVisitUtc) {
    var own = (correct: 0, total: 0);
    var helped = (correct: 0, total: 0);
    var day7 = (correct: 0, total: 0);
    final seenTasks = <(String, String, String)>{};
    final firstLessonAnswersInBeta = <String>{};
    for (final record in history.provenanceRecords) {
      final recordedAt = record.recordedAtUtc;
      if (recordedAt == null ||
          record.isPlacementAssessment ||
          record.isDiagnosticLearningEntry) {
        continue;
      }
      final newTask = seenTasks.add((
        record.worldId,
        record.lessonId,
        record.taskId,
      ));
      final elapsed = recordedAt.difference(firstVisitUtc);
      if (elapsed.isNegative) continue;
      final ownAnswer = record.assistanceKind == Act0DecisionAssistanceV1.none;
      final correct = record.isCorrect ? 1 : 0;
      if (elapsed < const Duration(days: 1) &&
          record.worldId == 'world_1' &&
          record.lessonId == firstLessonId &&
          firstLessonTaskIds.contains(record.taskId) &&
          firstLessonAnswersInBeta.add(record.taskId)) {
        if (ownAnswer) {
          own = (correct: own.correct + correct, total: own.total + 1);
        } else if (record.hasKnownAssistance) {
          helped = (correct: helped.correct + correct, total: helped.total + 1);
        }
      }
      if (elapsed.inDays == 6 &&
          ownAnswer &&
          record.runKind == 'spaced_review' &&
          record.reviewKind == Act0ReviewKindV1.unseenTransfer &&
          newTask) {
        day7 = (correct: day7.correct + correct, total: day7.total + 1);
      }
    }
    return (onYourOwn: own, withHelp: helped, day7NewReview: day7);
  }
}

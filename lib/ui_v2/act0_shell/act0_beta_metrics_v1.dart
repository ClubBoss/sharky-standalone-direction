import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'act0_completed_decision_contract_v1.dart';
import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_local_data_deletion_v1.dart';
import 'act0_path_progress_v1.dart';
import 'act0_shell_state_v1.dart';

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

/// Only the two return windows and fixed-choice feedback are stored here.
/// Course completion and repairs already have their own local sources.
class Act0BetaActivityV1 {
  Act0BetaActivityV1._({
    required this.firstVisitUtc,
    required this.observedDay,
    required this.returnedDay2,
    required this.returnedDay7,
    required List<Act0BetaSurveyAnswerV1?> answers,
  }) : answers = List.unmodifiable(answers);

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

  Act0BetaActivityV1 visitAt(DateTime now) {
    final elapsed = now.difference(firstVisitUtc);
    if (elapsed.isNegative) return this;
    final day = elapsed.inDays.clamp(0, 7);
    // A foreground after a clock rollback cannot fill an earlier missed day.
    if (day <= observedDay) return this;
    return Act0BetaActivityV1._(
      firstVisitUtc: firstVisitUtc,
      observedDay: day,
      returnedDay2: returnedDay2 || day == 1,
      returnedDay7: returnedDay7 || day == 6,
      answers: answers,
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
    return Act0BetaActivityV1._(
      firstVisitUtc: firstVisitUtc,
      observedDay: observedDay,
      returnedDay2: returnedDay2,
      returnedDay7: returnedDay7,
      answers: updated,
    );
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    'firstVisitUtc': firstVisitUtc.toIso8601String(),
    'observedDay': observedDay,
    'returnedDay2': returnedDay2,
    'returnedDay7': returnedDay7,
    'answers': [for (final answer in answers) answer?.name],
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
      return Act0BetaActivityV1._(
        firstVisitUtc: first,
        observedDay: day,
        returnedDay2: day2,
        returnedDay7: day7,
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
    required this.worldOneCompleted,
    required this.correctedMistakes,
    this.firstLessonId = '',
    this.firstLessonTaskIds = const {},
    this.history = const Act0LearningEvidenceHistoryV1(),
  });

  factory Act0BetaLearningMetricsV1.fromProgress({
    required Act0WorldCardV1 firstWorld,
    required Set<String> completedTaskIds,
    required int correctedMistakes,
    Act0LearningEvidenceHistoryV1 history =
        const Act0LearningEvidenceHistoryV1(),
  }) {
    final firstLesson = firstWorld.lessons.firstOrNull;
    bool completed(Act0LessonCardV1 lesson) =>
        lesson.taskList.isNotEmpty &&
        act0LessonCompleteWithTaskIdsV1(lesson, completedTaskIds);
    return Act0BetaLearningMetricsV1(
      firstLessonCompleted: firstLesson != null && completed(firstLesson),
      worldOneCompleted:
          firstLesson != null && firstWorld.lessons.every(completed),
      correctedMistakes: correctedMistakes,
      firstLessonId: firstLesson?.lessonId ?? '',
      firstLessonTaskIds: {
        if (firstLesson != null)
          for (final task in firstLesson.courseTaskList) task.taskId,
      },
      history: history,
    );
  }

  final bool firstLessonCompleted, worldOneCompleted;
  final int correctedMistakes;
  final String firstLessonId;
  final Set<String> firstLessonTaskIds;
  final Act0LearningEvidenceHistoryV1 history;

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

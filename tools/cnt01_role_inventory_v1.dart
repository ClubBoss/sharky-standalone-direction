// CNT-01 technical inventory only. Not a task selector, scheduler or proof engine.
// Source: Act0ShellStateV1.sample; fingerprint owner stays in Act0.
// Reused from Draft #439 (5aca1011). Host through existing Flutter tests:
// production catalogue types depend on Flutter; this module is not a Dart CLI.
// Authored catalogue includes locked and derived items, not runnable eligibility.
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const String cnt01UnknownV1 = 'UNKNOWN';
const String cnt01CatalogSourceV1 =
    'lib/ui_v2/act0_shell/act0_shell_state_v1.dart';

class Cnt01RoleInventoryV1 {
  const Cnt01RoleInventoryV1._();

  /// A source-authored role is not learner-specific eligibility or proof.
  /// An author's transfer tag does not establish that a task is unseen.
  /// A review phase does not establish elapsed time or actual due status.
  static String sourceRole(Act0LessonTaskV1 task) {
    final teaching =
        task.phase == Act0LessonPhaseV1.theory ||
        task.resolvedTaskFamily == Act0TaskFamilyV1.learn;
    final repair =
        task.stepKind == Act0LessonStepKindV1.fixMistakes &&
        task.resolvedTaskFamily == Act0TaskFamilyV1.repair;
    if (teaching && !repair) return 'TEACHING';
    if (repair && !teaching) return 'REPAIR';
    return cnt01UnknownV1;
  }

  static String roleBasis(Act0LessonTaskV1 task) {
    final teaching =
        task.phase == Act0LessonPhaseV1.theory ||
        task.resolvedTaskFamily == Act0TaskFamilyV1.learn;
    final repair =
        task.stepKind == Act0LessonStepKindV1.fixMistakes &&
        task.resolvedTaskFamily == Act0TaskFamilyV1.repair;
    if (teaching && repair) return 'CONFLICT';
    if (task.phase == Act0LessonPhaseV1.theory) return 'phase.theory';
    if (task.resolvedTaskFamily == Act0TaskFamilyV1.learn) {
      return 'taskFamily.learn';
    }
    if (repair) return 'stepKind.fixMistakes';
    return cnt01UnknownV1;
  }

  /// The registry is source-owned; per-task original author/revision is not.
  /// The existing semantic fingerprint is NOT an editorial revision number.
  static List<Map<String, Object?>> fromAct0({
    required String baselineMainSha,
    Act0ShellStateV1? catalog,
  }) {
    final rows = <Map<String, Object?>>[];
    final source = catalog ?? Act0ShellStateV1.sample;
    for (final world in source.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          final options = task.runner.options;
          final correct = options
              .where(act0RunnerOptionIsAuthoredCorrectV1)
              .toList();
          final rationale = <String, String>{
            for (final option in correct)
              option.id: option.feedbackReason.trim().isEmpty
                  ? cnt01UnknownV1
                  : option.feedbackReason.trim(),
          };
          rows.add(<String, Object?>{
            'worldId': world.worldId,
            'lessonId': lesson.lessonId,
            'taskId': task.taskId,
            'taskIdentity': lesson.tasks.isEmpty
                ? 'DERIVED_LESSON_SINGLE'
                : 'EXPLICIT_TASK',
            'sourceRole': sourceRole(task),
            'roleBasis': roleBasis(task),
            'sourcePhase': task.phase.name,
            'sourceStepKind': task.stepKind.name,
            'sourceFamily': task.resolvedTaskFamily.name,
            'catalogSourcePath': cnt01CatalogSourceV1,
            'catalogSourceMainSha': baselineMainSha,
            'semanticRevision':
                act0AuthoredSourceFingerprintV1(
                  worldId: world.worldId,
                  lessonId: lesson.lessonId,
                  task: task,
                ) ??
                cnt01UnknownV1,
            'authoredSourcePath': cnt01UnknownV1,
            'authoredRevision': cnt01UnknownV1,
            'responsibleAuthor': cnt01UnknownV1,
            'choiceIds': <String>[for (final o in options) o.id],
            'authoredCorrectChoiceIds': <String>[for (final o in correct) o.id],
            'authoredRationaleByChoiceId': rationale,
            'hasAssessmentChoices': options.isNotEmpty,
          });
        }
      }
    }
    rows.sort((a, b) {
      for (final field in <String>['worldId', 'lessonId', 'taskId']) {
        final compared = (a[field] as String).compareTo(b[field] as String);
        if (compared != 0) return compared;
      }
      return 0;
    });
    return List<Map<String, Object?>>.unmodifiable(rows);
  }

  /// Falsifiers only. No evidence input can turn this static validator into
  /// proof of genuinely unseen transfer or naturally elapsed retention.
  static List<Map<String, String>> validateRows(
    List<Map<String, Object?>> rows, {
    Set<String> previouslyPresentedTaskIds = const <String>{},
    Set<String> assistanceExposedTaskIds = const <String>{},
  }) {
    final findings = <Map<String, String>>[];
    final usedIds = <String>{};
    final sha40 = RegExp(r'^[a-f0-9]{40}$');
    final sha64 = RegExp(r'^[a-f0-9]{64}$');

    void add(String level, String code, String taskId) {
      findings.add(<String, String>{
        'level': level,
        'code': code,
        'taskId': taskId,
      });
    }

    for (final row in rows) {
      String string(String key) =>
          (row[key] is String) ? (row[key] as String).trim() : '';
      final id = string('taskId');
      final role = string('sourceRole');
      final basis = string('roleBasis');

      if (id.isEmpty) {
        add('ERROR', 'MISSING_TASK_ID', id);
      } else if (!usedIds.add(id)) {
        add('ERROR', 'DUPLICATE_TASK_ID', id);
      }
      if (string('taskIdentity') == 'DERIVED_LESSON_SINGLE') {
        add('GAP', 'DERIVED_ID_NOT_EXPLICITLY_AUTHORED', id);
      }
      if (string('worldId').isEmpty ||
          string('lessonId').isEmpty ||
          string('catalogSourcePath').isEmpty ||
          !sha40.hasMatch(string('catalogSourceMainSha'))) {
        add('ERROR', 'MISSING_ORIGIN', id);
      }
      if (!sha64.hasMatch(string('semanticRevision'))) {
        add('ERROR', 'MISSING_SEMANTIC_REVISION', id);
      }

      if (basis == 'CONFLICT' ||
          (role == 'TEACHING' &&
              basis != 'phase.theory' &&
              basis != 'taskFamily.learn') ||
          (role == 'REPAIR' && basis != 'stepKind.fixMistakes')) {
        add('ERROR', 'ROLE_COLLISION', id);
      }
      if (!const <String>{
        'TEACHING',
        'REPAIR',
        'UNSEEN',
        'ELAPSED',
        cnt01UnknownV1,
      }.contains(role)) {
        add('ERROR', 'INVALID_ROLE', id);
      }
      if (role == 'UNSEEN') {
        if (previouslyPresentedTaskIds.contains(id)) {
          add('ERROR', 'UNSEEN_ALREADY_PRESENTED', id);
        }
        if (assistanceExposedTaskIds.contains(id)) {
          add('ERROR', 'UNSEEN_ASSISTANCE_EXPOSED', id);
        }
        add('GAP', 'UNSEEN_NEEDS_SOURCE_AND_LEARNER_PROOF', id);
      }
      if (role == 'ELAPSED') {
        add('GAP', 'ELAPSED_NEEDS_REAL_TIME_INDEPENDENT_PROOF', id);
      }
      if (role == cnt01UnknownV1) {
        add('GAP', 'ROLE_UNKNOWN', id);
      }
      if (string('authoredSourcePath').isEmpty ||
          string('authoredSourcePath') == cnt01UnknownV1) {
        add('GAP', 'AUTHOR_ORIGIN_UNKNOWN', id);
      }
      if (string('authoredRevision').isEmpty ||
          string('authoredRevision') == cnt01UnknownV1) {
        add('GAP', 'AUTHOR_REVISION_UNKNOWN', id);
      }
      if (string('responsibleAuthor').isEmpty ||
          string('responsibleAuthor') == cnt01UnknownV1) {
        add('GAP', 'RESPONSIBLE_UNKNOWN', id);
      }

      final rawChoices = row['choiceIds'];
      final rawExpected = row['authoredCorrectChoiceIds'];
      bool invalidIds(Object? value) =>
          value is! List ||
          value.any((id) => id is! String || id.trim().isEmpty);
      if (invalidIds(rawChoices)) {
        add('ERROR', 'MALFORMED_CHOICE_IDS', id);
      }
      if (invalidIds(rawExpected)) {
        add('ERROR', 'MALFORMED_ANSWER_IDS', id);
      }
      final choices = rawChoices is List
          ? rawChoices.whereType<String>().toList()
          : <String>[];
      final expected = rawExpected is List
          ? rawExpected.whereType<String>().toList()
          : <String>[];
      final claimsAssessment = row['hasAssessmentChoices'] == true;
      if (claimsAssessment && choices.isEmpty) {
        add('ERROR', 'ASSESSMENT_CHOICES_MISSING', id);
      }
      if (choices.length != choices.toSet().length) {
        add('ERROR', 'DUPLICATE_CHOICE_ID', id);
      }
      if (expected.any((choiceId) => !choices.contains(choiceId))) {
        add('ERROR', 'ANSWER_NOT_IN_CHOICES', id);
      }
      if ((claimsAssessment || choices.isNotEmpty) && expected.isEmpty) {
        add('GAP', 'AUTHORED_ANSWER_UNKNOWN', id);
      }
      final rationale = row['authoredRationaleByChoiceId'] is Map
          ? (row['authoredRationaleByChoiceId'] as Map)
          : const <Object?, Object?>{};
      for (final correctId in expected) {
        final text = rationale[correctId];
        if (text is! String ||
            text.trim().isEmpty ||
            text.trim() == cnt01UnknownV1) {
          add('GAP', 'AUTHORED_RATIONALE_UNKNOWN', id);
        }
      }
    }
    return List<Map<String, String>>.unmodifiable(findings);
  }
}

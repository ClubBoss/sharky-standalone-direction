// CNT-01 technical inventory only. Not a task selector, scheduler or proof engine.
// Source: Act0ShellStateV1.sample; fingerprint owner stays in Act0.
// Reuses Draft #445 (3aa7e00a) source fidelity and Draft #439 collector.
// Flutter-hosted catalogue check; includes locked rows, not runnable eligibility.
import 'dart:convert';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const String cnt01UnknownV1 = 'UNKNOWN';
// Current source-curation adoption by the authorized technical maintainer.
// This is not historic authorship, poker-truth review or learner qualification.
const String cnt01CurationRevisionV1 = 'cnt01_foundation_curation_v1_20261115';
const String cnt01CurationMaintainerV1 =
    'Work/root (Foundation technical inventory maintainer)';
const String cnt01FoundationScopeV1 = 'FOUNDATION_W1_W4';
const String cnt01OutsideScopeV1 = 'OUTSIDE_FOUNDATION_CURATION';

const String cnt01CatalogSourceV1 =
    'lib/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Order is meaningful for choices, but not for JSON object keys.
bool _sameInventoryValue(Object? actual, Object? expected) {
  if (actual is List && expected is List) {
    return actual.length == expected.length &&
        List<int>.generate(
          actual.length,
          (index) => index,
        ).every((index) => _sameInventoryValue(actual[index], expected[index]));
  }
  if (actual is Map && expected is Map) {
    return actual.length == expected.length &&
        expected.keys.every(
          (key) =>
              actual.containsKey(key) &&
              _sameInventoryValue(actual[key], expected[key]),
        );
  }
  return actual == expected;
}

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

  static bool isFoundationWorld(String worldId) => const <String>{
    'world_1',
    'world_2',
    'world_3',
    'world_4',
  }.contains(worldId);

  /// Declared use of current source, never learner-specific proof eligibility.
  static String declaredPurpose(Act0LessonTaskV1 task) {
    final role = sourceRole(task);
    if (role == 'TEACHING' || role == 'REPAIR') return role;
    final phase = task.phase;
    final step = task.stepKind;
    final family = task.resolvedTaskFamily;
    if (phase == Act0LessonPhaseV1.drill &&
        step == Act0LessonStepKindV1.fixMistakes &&
        family == Act0TaskFamilyV1.compare) {
      return 'CORRECTION_CANDIDATE';
    }
    if ((phase == Act0LessonPhaseV1.drill ||
            phase == Act0LessonPhaseV1.review) &&
        (step == Act0LessonStepKindV1.practice ||
            step == Act0LessonStepKindV1.proveIt) &&
        family == Act0TaskFamilyV1.transfer) {
      return 'TRANSFER_CANDIDATE';
    }
    if (phase == Act0LessonPhaseV1.review &&
        step == Act0LessonStepKindV1.review &&
        family == Act0TaskFamilyV1.review) {
      return 'REVIEW_CANDIDATE';
    }
    if (phase == Act0LessonPhaseV1.drill &&
        step == Act0LessonStepKindV1.practice &&
        const <Act0TaskFamilyV1>{
          Act0TaskFamilyV1.compare,
          Act0TaskFamilyV1.counting,
          Act0TaskFamilyV1.decision,
          Act0TaskFamilyV1.recognition,
          Act0TaskFamilyV1.sizing,
        }.contains(family)) {
      return 'PRACTICE';
    }
    return cnt01UnknownV1;
  }

  static String eligibilityDisposition(String purpose) {
    if (purpose == 'TEACHING') return 'TEACHING_OBSERVATION_ONLY';
    if (purpose == 'REPAIR' || purpose == 'CORRECTION_CANDIDATE') {
      return 'REPAIR_SOURCE_NO_UNSEEN_OR_ELAPSED_PROOF';
    }
    if (purpose == cnt01UnknownV1) return 'UNSUPPORTED_SOURCE_PURPOSE';
    return 'SOURCE_CANDIDATE_REQUIRES_LEARNER_EVIDENCE';
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
          final curated = isFoundationWorld(world.worldId);
          final purpose = curated ? declaredPurpose(task) : cnt01UnknownV1;
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
            'curationScope': curated
                ? cnt01FoundationScopeV1
                : cnt01OutsideScopeV1,
            'declaredPurpose': purpose,
            'purposeBasis': curated
                ? '${task.phase.name}/${task.stepKind.name}/${task.resolvedTaskFamily.name}'
                : cnt01UnknownV1,
            'eligibilityDisposition': curated
                ? eligibilityDisposition(purpose)
                : cnt01OutsideScopeV1,
            'inventoryEstablishesUnseen': false,
            'inventoryEstablishesElapsed': false,
            'currentSourceRevision': curated ? baselineMainSha : cnt01UnknownV1,
            'curationRevision': curated
                ? cnt01CurationRevisionV1
                : cnt01UnknownV1,
            'currentResponsibleMaintainer': curated
                ? cnt01CurationMaintainerV1
                : cnt01UnknownV1,
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
    Act0ShellStateV1? catalog,
    Set<String> previouslyPresentedTaskIds = const <String>{},
    Set<String> assistanceExposedTaskIds = const <String>{},
  }) {
    final findings = <Map<String, String>>[];
    final source = catalog ?? Act0ShellStateV1.sample;
    final sourceTasks = <String, List<Act0LessonTaskV1>>{};
    String key(String world, String lesson, String task) =>
        jsonEncode(<String>[world, lesson, task]);
    for (final world in source.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          sourceTasks
              .putIfAbsent(
                key(world.worldId, lesson.lessonId, task.taskId),
                () => <Act0LessonTaskV1>[],
              )
              .add(task);
        }
      }
    }
    final expectedRows = <String, Map<String, Object?>>{
      for (final row in fromAct0(baselineMainSha: '', catalog: source))
        key(
          row['worldId'] as String,
          row['lessonId'] as String,
          row['taskId'] as String,
        ): row,
    };
    final suppliedKeys = <String>{};
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
      final rowKey = key(string('worldId'), string('lessonId'), id);
      suppliedKeys.add(rowKey);
      final matches = sourceTasks[rowKey];
      if (matches == null || matches.length != 1) {
        add('ERROR', 'SOURCE_TASK_NOT_UNIQUE', id);
      } else {
        final task = matches.single;
        final expectedRow = expectedRows[rowKey]!;
        // Derived provenance cannot be upgraded to invented editorial metadata.
        // Also reject coherent fabricated answers with a copied real fingerprint.
        for (final field in <String>[
          'curationScope',
          'declaredPurpose',
          'purposeBasis',
          'eligibilityDisposition',
          'inventoryEstablishesUnseen',
          'inventoryEstablishesElapsed',
          'curationRevision',
          'currentResponsibleMaintainer',
          'taskIdentity',
          'choiceIds',
          'authoredCorrectChoiceIds',
          'authoredRationaleByChoiceId',
          'hasAssessmentChoices',
          'authoredSourcePath',
          'authoredRevision',
          'responsibleAuthor',
        ]) {
          if (!_sameInventoryValue(row[field], expectedRow[field])) {
            add('ERROR', 'SOURCE_FIELD_MISMATCH_$field', id);
          }
        }
        if (string('sourcePhase') != task.phase.name ||
            string('sourceStepKind') != task.stepKind.name ||
            string('sourceFamily') != task.resolvedTaskFamily.name) {
          add('ERROR', 'SOURCE_INPUT_MISMATCH', id);
        }
        if (role != sourceRole(task) || basis != roleBasis(task)) {
          add('ERROR', 'SOURCE_CLASSIFICATION_MISMATCH', id);
        }
        if (roleBasis(task) == 'CONFLICT') {
          add('ERROR', 'ROLE_COLLISION', id);
        }
        if (string('semanticRevision') !=
            act0AuthoredSourceFingerprintV1(
              worldId: string('worldId'),
              lessonId: string('lessonId'),
              task: task,
            )) {
          add('ERROR', 'SOURCE_SEMANTIC_REVISION_MISMATCH', id);
        }
      }

      if (isFoundationWorld(string('worldId'))) {
        if (string('declaredPurpose').isEmpty ||
            string('declaredPurpose') == cnt01UnknownV1) {
          add('ERROR', 'MISSING_FOUNDATION_PURPOSE', id);
        }
        if (string('currentResponsibleMaintainer') !=
            cnt01CurationMaintainerV1) {
          add('ERROR', 'CURRENT_MAINTAINER_UNSUPPORTED', id);
        }
        if (string('curationRevision') != cnt01CurationRevisionV1) {
          add('ERROR', 'CURATION_REVISION_MISMATCH', id);
        }
        final revision = string('currentSourceRevision');
        if (!sha40.hasMatch(revision)) {
          add('ERROR', 'MISSING_CURRENT_SOURCE_REVISION', id);
        } else if (revision != string('catalogSourceMainSha')) {
          add('ERROR', 'CURRENT_SOURCE_REVISION_MISMATCH', id);
        }
      } else if (string('currentSourceRevision') != cnt01UnknownV1) {
        add('ERROR', 'OUTSIDE_SCOPE_CURATION_CLAIM', id);
      }
      if (row['inventoryEstablishesUnseen'] != false ||
          row['inventoryEstablishesElapsed'] != false) {
        add('ERROR', 'STATIC_INVENTORY_CANNOT_ESTABLISH_PROOF', id);
      }

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
          string('catalogSourcePath') != cnt01CatalogSourceV1 ||
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
    for (final entry in sourceTasks.entries) {
      if (!suppliedKeys.contains(entry.key)) {
        add('ERROR', 'SOURCE_TASK_MISSING', entry.value.first.taskId);
      }
      if (entry.value.length != 1) {
        add('ERROR', 'SOURCE_TASK_NOT_UNIQUE', entry.value.first.taskId);
      }
    }
    return List<Map<String, String>>.unmodifiable(findings);
  }
}

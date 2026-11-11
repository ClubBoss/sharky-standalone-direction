// CNT-01 technical inventory only. Not a task selector, scheduler or proof engine.
// Source: Act0ShellStateV1.sample; fingerprint owner stays in Act0.
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const String cnt01UnknownV1 = 'UNKNOWN';
const String cnt01CatalogSourceV1 =
    'lib/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Order is meaningful for choices, but not for JSON object keys.
bool _sameInventoryValue(Object? actual, Object? expected) {
  if (actual is List && expected is List) {
    return actual.length == expected.length &&
        List<int>.generate(actual.length, (index) => index).every(
          (index) => _sameInventoryValue(actual[index], expected[index]),
        );
  }
  if (actual is Map && expected is Map) {
    return actual.length == expected.length && expected.keys.every(
      (key) => actual.containsKey(key) &&
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
    final teaching = task.phase == Act0LessonPhaseV1.theory ||
        task.resolvedTaskFamily == Act0TaskFamilyV1.learn;
    final repair = task.stepKind == Act0LessonStepKindV1.fixMistakes &&
        task.resolvedTaskFamily == Act0TaskFamilyV1.repair;
    if (teaching && !repair) return 'TEACHING';
    if (repair && !teaching) return 'REPAIR';
    return cnt01UnknownV1;
  }

  static String roleBasis(Act0LessonTaskV1 task) {
    final teaching = task.phase == Act0LessonPhaseV1.theory ||
        task.resolvedTaskFamily == Act0TaskFamilyV1.learn;
    final repair = task.stepKind == Act0LessonStepKindV1.fixMistakes &&
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
            'semanticRevision': act0AuthoredSourceFingerprintV1(
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
          sourceTasks.putIfAbsent(key(world.worldId, lesson.lessonId,
              task.taskId), () => <Act0LessonTaskV1>[]).add(task);
        }
      }
    }
    final expectedRows = <String, Map<String, Object?>>{
      for (final row in fromAct0(baselineMainSha: '', catalog: source))
        key(row['worldId'] as String, row['lessonId'] as String,
            row['taskId'] as String): row,
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
      String string(String key) => (row[key] is String)
          ? (row[key] as String).trim()
          : '';
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
          'taskIdentity', 'choiceIds', 'authoredCorrectChoiceIds',
          'authoredRationaleByChoiceId', 'hasAssessmentChoices',
          'authoredSourcePath', 'authoredRevision', 'responsibleAuthor',
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
        if (string('semanticRevision') != act0AuthoredSourceFingerprintV1(
          worldId: string('worldId'), lessonId: string('lessonId'), task: task,
        )) {
          add('ERROR', 'SOURCE_SEMANTIC_REVISION_MISMATCH', id);
        }
      }

      if (id.isEmpty) {
        add('ERROR', 'MISSING_TASK_ID', id);
      } else if (!usedIds.add(id)) {
        add('ERROR', 'DUPLICATE_TASK_ID', id);
      }
      if (string('taskIdentity') == 'DERIVED_LESSON_SINGLE') {
        add('GAP', 'DERIVED_ID_NOT_EXPLICITLY_AUTHORED', id);
      }
      if (string('worldId').isEmpty || string('lessonId').isEmpty ||
          string('catalogSourcePath') != cnt01CatalogSourceV1 ||
          !sha40.hasMatch(string('catalogSourceMainSha'))) {
        add('ERROR', 'MISSING_ORIGIN', id);
      }
      if (!sha64.hasMatch(string('semanticRevision'))) {
        add('ERROR', 'MISSING_SEMANTIC_REVISION', id);
      }

      if (basis == 'CONFLICT' ||
          (role == 'TEACHING' &&
              basis != 'phase.theory' && basis != 'taskFamily.learn') ||
          (role == 'REPAIR' && basis != 'stepKind.fixMistakes')) {
        add('ERROR', 'ROLE_COLLISION', id);
      }
      if (!const <String>{
        'TEACHING', 'REPAIR', 'UNSEEN', 'ELAPSED', cnt01UnknownV1
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

      final choices = (row['choiceIds'] is List)
          ? (row['choiceIds'] as List).whereType<String>().toList()
          : <String>[];
      final expected = (row['authoredCorrectChoiceIds'] is List)
          ? (row['authoredCorrectChoiceIds'] as List)
              .whereType<String>()
              .toList()
          : <String>[];
      if (choices.length != choices.toSet().length) {
        add('ERROR', 'DUPLICATE_CHOICE_ID', id);
      }
      if (expected.any((choiceId) => !choices.contains(choiceId))) {
        add('ERROR', 'ANSWER_NOT_IN_CHOICES', id);
      }
      if (choices.isNotEmpty && expected.isEmpty) {
        add('GAP', 'AUTHORED_ANSWER_UNKNOWN', id);
      }
      final rationale =
          row['authoredRationaleByChoiceId'] is Map
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

/// Flutter-hosted only: Act0's source fingerprint transitively needs dart:ui.
/// Run from the same clean, frozen checkout that Flutter compiles.
/// The host working directory and poker_analyzer package configuration must
/// both identify that checkout. This is NOT compiled-binary attestation:
/// CNT01_ROOT=/absolute/checkout CNT01_ATTESTATION=/absolute/attestation.json \
/// CNT01_OUTPUT=/absolute/inventory.json flutter test \
/// test/ui_v2/cnt01_role_inventory_v1_test.dart --plain-name "CNT-01 export"
///
/// The integrator supplies an independently verified JSON attestation:
/// {"schemaVersion":"cnt01_source_attestation_v1",
///  "baselineMainSha":"<40 hex>", "sourceRevision":"<40 hex>",
///  "verifiedBy":"<reviewer or receipt>", "files":{"<path>":"<sha256>"}}
/// files must cover EVERY lib/**/*.dart, pubspec.yaml, pubspec.lock and both
/// inventory files below. Hashes must come from the specified sourceRevision,
/// not be generated from an unchecked working directory. The baseline is only
/// context: no claim that it equals sourceRevision or its source tree is made.
/// This verifies bytes against that external attestation, NOT Git ancestry,
/// reviewer identity, dependencies or a running binary. No Git/network calls.
/// Missing/partial attestation fails before writing; data errors are preserved
/// in the JSON and make the export test fail. Never use this as CNT-01 acceptance.
Future<Map<String, Object?>> cnt01ExportV1({
  required String repositoryRoot,
  required String attestationPath,
}) async {
  if (!repositoryRoot.startsWith('/') || !attestationPath.startsWith('/')) {
    throw ArgumentError('Absolute root and attestation paths are required.');
  }
  final root = Directory(repositoryRoot).resolveSymbolicLinksSync();
  // flutter_tester does not implement Isolate.resolvePackageUri. Bind to
  // the host checkout and its package configuration instead; neither check
  // claims to attest compiled kernel bytes (that remains external evidence).
  if (root != Directory.current.resolveSymbolicLinksSync()) {
    throw StateError('Root does not match the Flutter host working directory.');
  }
  final configFile = File('$root/.dart_tool/package_config.json');
  final config = jsonDecode(configFile.readAsStringSync());
  if (config is! Map || config['configVersion'] != 2 ||
      config['packages'] is! List) {
    throw StateError('Invalid Flutter host package configuration.');
  }
  final packages = (config['packages'] as List).where(
    (entry) => entry is Map && entry['name'] == 'poker_analyzer',
  ).toList();
  if (packages.length != 1) {
    throw StateError('Expected exactly one poker_analyzer host package.');
  }
  final package = packages.single as Map;
  if (package['rootUri'] is! String || package['packageUri'] is! String) {
    throw StateError('Missing Flutter host package root or library URI.');
  }
  final packageRoot = configFile.uri.resolve(package['rootUri'] as String);
  final libraryRoot = packageRoot.resolve(package['packageUri'] as String);
  if (packageRoot.scheme != 'file' || libraryRoot.scheme != 'file' ||
      packageRoot.hasQuery || packageRoot.hasFragment ||
      libraryRoot.hasQuery || libraryRoot.hasFragment ||
      Directory.fromUri(packageRoot).resolveSymbolicLinksSync() != root ||
      Directory.fromUri(libraryRoot).resolveSymbolicLinksSync() != '$root/lib') {
    throw StateError('Root does not match the Flutter host package source.');
  }
  final raw = jsonDecode(File(attestationPath).readAsStringSync());
  if (raw is! Map || raw['schemaVersion'] != 'cnt01_source_attestation_v1' ||
      raw['files'] is! Map || raw['verifiedBy'] is! String ||
      (raw['verifiedBy'] as String).trim().isEmpty) {
    throw StateError('Missing source attestation.');
  }
  final sha40 = RegExp(r'^[a-f0-9]{40}$');
  for (final field in ['baselineMainSha', 'sourceRevision']) {
    if (raw[field] is! String || !sha40.hasMatch(raw[field] as String)) {
      throw StateError('Missing revision: $field');
    }
  }
  final files = raw['files'] as Map;
  final paths = <String>{
    'pubspec.yaml', 'pubspec.lock',
    'tools/cnt01_role_inventory_v1.dart',
    'test/ui_v2/cnt01_role_inventory_v1_test.dart',
  };
  for (final entry in Directory('$root/lib').listSync(
      recursive: true, followLinks: false)) {
    if (entry is Link) throw StateError('Symlink in source tree: ${entry.path}');
    if (entry is File && entry.path.endsWith('.dart')) {
      paths.add(entry.path.substring(root.length + 1));
    }
  }
  if (!paths.contains(cnt01CatalogSourceV1) ||
      files.length != paths.length || !paths.every(files.containsKey)) {
    throw StateError('Incomplete or unexpected source manifest.');
  }
  for (final path in paths) {
    final file = File('$root/$path');
    if (file.resolveSymbolicLinksSync() != file.path ||
        files[path] != sha256.convert(file.readAsBytesSync()).toString()) {
      throw StateError('Source attestation mismatch: $path');
    }
  }
  final rows = Cnt01RoleInventoryV1.fromAct0(
    baselineMainSha: raw['baselineMainSha'] as String,
  );
  final findings = Cnt01RoleInventoryV1.validateRows(rows);
  final findingCounts = <String, int>{};
  final roleCounts = <String, int>{};
  for (final row in rows) {
    final role = row['sourceRole'] as String;
    roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    row['catalogSourceRevision'] = raw['sourceRevision'];
  }
  for (final finding in findings) {
    final code = finding['code']!;
    findingCounts[code] = (findingCounts[code] ?? 0) + 1;
  }
  return <String, Object?>{
    'schemaVersion': 'cnt01_role_inventory_v1',
    'status': 'TECHNICAL_INVENTORY_ONLY_NOT_CNT01_ACCEPTANCE',
    'attestationKind': 'EXTERNAL_REVISION_LOCAL_BYTES_VERIFIED',
    'attestation': raw,
    'source': cnt01CatalogSourceV1,
    'count': rows.length,
    'sourceRoleCounts': roleCounts,
    'findingCounts': findingCounts,
    'errors': <Map<String, String>>[
      for (final f in findings) if (f['level'] == 'ERROR') f,
    ],
    'rows': rows,
  };
}

import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/content/drill_iso_group_validator.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

import 'content_quality_validator_v1.dart';

Future<void> main(List<String> args) async {
  final stagedOnly = args.contains('--staged-only');
  final stagedModules = stagedOnly
      ? await _collectStagedModuleVersions()
      : null;
  final root = Directory('content');
  if (!root.existsSync()) {
    stdout.writeln('[WARN] content directory not found, skipping validation.');
    exit(0);
  }

  final packs = root.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var overallSuccess = true;

  for (final pack in packs) {
    if (stagedModules != null &&
        !_moduleMatchesStaged(pack, stagedModules.keys.toSet())) {
      continue;
    }
    final versionDirs =
        pack
            .listSync()
            .whereType<Directory>()
            .where(
              (dir) => RegExp(
                r'v\d+',
                caseSensitive: false,
              ).hasMatch(dir.uri.pathSegments.last),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    if (versionDirs.isEmpty) {
      continue;
    }

    var filteredVersionDirs = versionDirs;
    if (stagedModules != null) {
      final moduleName = _moduleName(pack);
      final allowedVersions = stagedModules[moduleName];
      if (allowedVersions == null || allowedVersions.isEmpty) {
        continue;
      }
      filteredVersionDirs = filteredVersionDirs
          .where((dir) => allowedVersions.contains(_versionName(dir)))
          .toList();
      if (filteredVersionDirs.isEmpty) {
        continue;
      }
    }

    for (final version in filteredVersionDirs) {
      final result = await _validatePackVersion(version);
      overallSuccess = overallSuccess && result.isSuccess;
      if (result.isSuccess) {
        stdout.writeln(
          '[PASS] ${_relativePath(version.path)} '
          '(files: ${result.filesChecked})',
        );
      } else {
        stdout.writeln(
          '[FAIL] ${_relativePath(version.path)} '
          '(files: ${result.filesChecked})',
        );
        for (final error in result.errors) {
          stdout.writeln('  - $error');
        }
      }
    }
  }

  final Set<String>? tableFirstModules;
  if (stagedModules != null) {
    final stagedModuleSet = stagedModules.keys.toSet();
    final tableFirstSet = {...tableFirstLessonOrder};
    tableFirstModules = stagedModuleSet.intersection(tableFirstSet);
  } else {
    tableFirstModules = null;
  }

  if (tableFirstModules != null && tableFirstModules.isEmpty) {
    stdout.writeln(
      '[INFO] table-first validation skipped (no staged table-first modules)',
    );
  } else {
    final tableFirstErrors = await _validateTableFirstBundles(
      modules: tableFirstModules,
    );
    if (tableFirstErrors.isNotEmpty) {
      overallSuccess = false;
      stdout.writeln('[FAIL] table-first bundle validation');
      for (final error in tableFirstErrors) {
        stdout.writeln('  - $error');
      }
    } else {
      stdout.writeln('[PASS] table-first bundle validation');
    }
  }

  exit(overallSuccess ? 0 : 1);
}

Future<_ValidationResult> _validatePackVersion(Directory dir) async {
  final errors = <String>[];
  final base = await validateContentVersionDirV1(dir);
  errors.addAll(base.errors);
  final entities =
      dir
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in entities) {
    final extension = file.uri.pathSegments.last.split('.').last.toLowerCase();
    final content = await file.readAsString();
    errors.addAll(
      validateSharedCoreFormatBoundaryTextV1(
        filePath: _relativePath(file.path),
        content: content,
      ),
    );
    errors.addAll(
      validateProgressionAntiJumpTextV1(
        filePath: _relativePath(file.path),
        content: content,
      ),
    );
    errors.addAll(
      validateWorldNodePlacementTextV1(
        filePath: _relativePath(file.path),
        content: content,
      ),
    );
    if (extension == 'jsonl') {
      try {
        _validateJsonl(file, content, errors);
      } catch (_) {
        // Already reported by the base content-quality validator.
      }
    }
  }

  return _ValidationResult(
    isSuccess: errors.isEmpty,
    errors: errors,
    filesChecked: base.filesChecked,
  );
}

String _relativePath(String path) {
  final root = Directory.current.path;
  if (path.startsWith(root)) {
    return path.substring(root.length + 1);
  }
  return path;
}

List<String> validateSharedCoreFormatBoundaryTextV1({
  required String filePath,
  required String content,
}) {
  final normalized = filePath.replaceAll('\\', '/');
  final worldMatch = RegExp(
    r'content/worlds/world([0-9]+)/',
  ).firstMatch(normalized);
  if (worldMatch == null) {
    return const <String>[];
  }
  final worldIndex = int.tryParse(worldMatch.group(1) ?? '');
  if (worldIndex == null || worldIndex < 0 || worldIndex > 9) {
    return const <String>[];
  }

  final lowered = content.toLowerCase();
  final errors = <String>[];
  final lines = content.split('\n');
  final isSessionMetadataSurface =
      normalized.endsWith('/notes.md') || normalized.endsWith('/session.md');
  const prematureTrackRoutingPatterns = <Pattern>[
    'track selection',
    'cash track',
    'tournament track',
    'mixed track',
    'choose cash',
    'choose tournament',
    'choose mixed',
  ];
  const indirectTrackHandoffPatterns = <Pattern>[
    'choose one track',
    'track that fits your game',
  ];

  if (worldIndex <= 6) {
    const prematureContextTokens = <String>[
      '6-max',
      '9-max',
      'icm',
      'ante',
      'rake',
    ];
    for (final token in prematureContextTokens) {
      if (lowered.contains(token)) {
        errors.add(
          '$filePath: shared-core World $worldIndex must not introduce explicit '
          'format-context token "$token" before later specialization layers',
        );
      }
    }
    if (RegExp(
      r'\b(?:10|15|20|25|30|40|50|60|75|100|150|200)bb\b',
    ).hasMatch(lowered)) {
      errors.add(
        '$filePath: shared-core World $worldIndex must not introduce explicit '
        'stack-band policy wording before later specialization layers',
      );
    }
  }

  for (final pattern in prematureTrackRoutingPatterns) {
    if (lowered.contains(pattern.toString())) {
      final lineNumber = _firstMatchingLineNumber(lines, pattern);
      errors.add(
        '$filePath${lineNumber == null ? '' : ':$lineNumber'}: shared-core '
        'World $worldIndex must not introduce post-core track-routing wording '
        'before specialization split is explicit ("${pattern.toString()}")',
      );
    }
  }

  if (worldIndex <= 9) {
    final mentionsTrackChoice =
        lowered.contains('track') &&
        (lowered.contains('cash') ||
            lowered.contains('tournament') ||
            lowered.contains('mixed'));
    for (final pattern in indirectTrackHandoffPatterns) {
      if (lowered.contains(pattern.toString()) ||
          (pattern == 'track that fits your game' && mentionsTrackChoice)) {
        final lineNumber = _firstMatchingLineNumber(lines, pattern);
        errors.add(
          '$filePath${lineNumber == null ? '' : ':$lineNumber'}: shared-core '
          'World $worldIndex must not introduce indirect post-core '
          'track-choice wording before World 10 track surfaces are active '
          '("${pattern.toString()}")',
        );
      }
    }
  }

  if (worldIndex >= 5 &&
      worldIndex <= 9 &&
      isSessionMetadataSurface &&
      RegExp(
        r'^\s*-\s*todo\s*$',
        caseSensitive: false,
        multiLine: true,
      ).hasMatch(content)) {
    errors.add(
      '$filePath: surfaced World $worldIndex session metadata must not contain '
      'learner-facing TODO placeholder residue',
    );
  }

  const universalPolicyPatterns = <Pattern>[
    'every format',
    'all formats',
    'always correct',
    'always the right play',
    'final answer',
    'context-independent policy',
    'one correct play',
    'regardless of format',
    'regardless of stack depth',
    'regardless of icm',
    'regardless of rake',
    'same in cash and tournament',
    'same across cash and tournament',
  ];
  final mentionsContextAxis =
      lowered.contains('cash') ||
      lowered.contains('mtt') ||
      lowered.contains('tournament') ||
      lowered.contains('mixed') ||
      lowered.contains('6-max') ||
      lowered.contains('9-max') ||
      lowered.contains('icm') ||
      lowered.contains('ante') ||
      lowered.contains('rake') ||
      RegExp(
        r'\b(?:10|15|20|25|30|40|50|60|75|100|150|200)bb\b',
      ).hasMatch(lowered);
  if (mentionsContextAxis) {
    for (final pattern in universalPolicyPatterns) {
      if (lowered.contains(pattern)) {
        final lineNumber = _firstMatchingLineNumber(lines, pattern);
        errors.add(
          '$filePath${lineNumber == null ? '' : ':$lineNumber'}: shared-core '
          'World $worldIndex must not frame context-dependent strategy as '
          'universal policy ("$pattern")',
        );
      }
    }
  }

  return errors;
}

List<String> validateProgressionAntiJumpTextV1({
  required String filePath,
  required String content,
}) {
  final normalized = filePath.replaceAll('\\', '/');
  final world2SessionMatch = RegExp(
    r'content/worlds/world2/v1/sessions/w2\.s(\d+)/',
  ).firstMatch(normalized);
  if (world2SessionMatch == null) {
    return const <String>[];
  }

  final sessionIndex = int.tryParse(world2SessionMatch.group(1) ?? '');
  if (sessionIndex == null || sessionIndex >= 7) {
    return const <String>[];
  }

  final lowered = content.toLowerCase();
  const blockedPotOddsTokens = <String>[
    'pot odds',
    'pot-odds',
    'continue-price',
    'continue price',
    'price of continuing',
  ];

  for (final token in blockedPotOddsTokens) {
    if (lowered.contains(token)) {
      return <String>[
        '$filePath: World 2 session w2.s${sessionIndex.toString().padLeft(2, '0')} '
            'must not introduce "$token" before the outs bridge is established',
      ];
    }
  }

  return const <String>[];
}

List<String> validateWorldNodePlacementTextV1({
  required String filePath,
  required String content,
}) {
  final normalized = filePath.replaceAll('\\', '/');
  final worldMatch = RegExp(
    r'content/worlds/world([0-9]+)/',
  ).firstMatch(normalized);
  if (worldMatch == null) {
    return const <String>[];
  }

  final worldIndex = int.tryParse(worldMatch.group(1) ?? '');
  if (worldIndex == null) {
    return const <String>[];
  }

  final lowered = content.toLowerCase();
  final isExplicitRangeThinking =
      lowered.contains('"intent_v1": "think_in_ranges"') ||
      lowered.contains('"intent_v1":"think_in_ranges"') ||
      lowered.contains('range-first proxy');
  final isTournamentPressurePlacement =
      lowered.contains('icm') ||
      lowered.contains('tournament pressure') ||
      lowered.contains('survival pressure');

  if (isExplicitRangeThinking && worldIndex < 6) {
    return <String>[
      '$filePath: explicit range-thinking content must not be placed before '
          'World 6 in WORLD_NODE_MODE_MATRIX_v1',
    ];
  }

  if (isTournamentPressurePlacement && worldIndex < 8) {
    return <String>[
      '$filePath: tournament pressure / ICM intuition must not be placed '
          'before World 8 in WORLD_NODE_MODE_MATRIX_v1',
    ];
  }

  return const <String>[];
}

int? _firstMatchingLineNumber(List<String> lines, Pattern pattern) {
  for (var i = 0; i < lines.length; i++) {
    final loweredLine = lines[i].toLowerCase();
    if (pattern is RegExp) {
      if (pattern.hasMatch(loweredLine)) return i + 1;
      continue;
    }
    if (loweredLine.contains(pattern.toString().toLowerCase())) return i + 1;
  }
  return null;
}

void _validateJsonl(File file, String content, List<String> errors) {
  final lines = content.split('\n');
  final entries = <Map<String, dynamic>>[];
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i].trim();
    if (raw.isEmpty) {
      continue;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map && decoded is! List) {
        errors.add(
          '${_relativePath(file.path)}:${i + 1} not an object or array',
        );
        continue;
      }
      if (decoded is Map) {
        entries.add(decoded.cast<String, dynamic>());
      }
    } catch (_) {
      // JSON parse failure is already reported by validateContentVersionDirV1.
    }
  }
  if (file.path.endsWith('${Platform.pathSeparator}drills.jsonl')) {
    final moduleId = _inferModuleIdFromPath(file.path);
    errors.addAll(
      validateDrillIsoGroups(
        moduleId: moduleId,
        filePath: _relativePath(file.path),
        entries: entries,
      ),
    );
  }
}

Future<Map<String, Set<String>>> _collectStagedModuleVersions() async {
  final result = await Process.run('git', [
    'diff',
    '--cached',
    '--name-only',
    '--diff-filter=ACDMRT',
    '--',
    'content/**',
    'tools/validate_training_content.dart',
    'tooling/allowlists/**',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln('git diff failed (${result.exitCode})');
    exit(result.exitCode);
  }

  final modules = <String, Set<String>>{};
  for (final raw in result.stdout.toString().split('\n')) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('content/')) {
      continue;
    }
    final segments = trimmed.split('/');
    if (segments.length < 3) {
      continue;
    }
    final moduleName = segments[1];
    final versionName = segments[2];
    if (!RegExp(r'^v\d+$', caseSensitive: false).hasMatch(versionName)) {
      continue;
    }
    modules.putIfAbsent(moduleName, () => <String>{}).add(versionName);
  }
  return modules;
}

String _moduleName(Directory dir) => dir.uri.pathSegments.last;

String _versionName(Directory dir) => dir.uri.pathSegments.last;

bool _moduleMatchesStaged(Directory dir, Set<String> stagedModules) {
  return stagedModules.contains(_moduleName(dir));
}

String _inferModuleIdFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final marker = 'content/';
  final markerIndex = normalized.indexOf(marker);
  if (markerIndex < 0) {
    return 'unknown_module';
  }
  final remainder = normalized.substring(markerIndex + marker.length);
  final parts = remainder.split('/');
  if (parts.isEmpty || parts.first.trim().isEmpty) {
    return 'unknown_module';
  }
  return parts.first.trim();
}

Future<List<String>> _validateTableFirstBundles({Set<String>? modules}) async {
  final errors = <String>[];
  final modulesToCheck = modules == null
      ? tableFirstLessonOrder
      : tableFirstLessonOrder.where((id) => modules.contains(id));
  for (final moduleId in modulesToCheck) {
    final versionDir = Directory('content/$moduleId/v1');
    if (!versionDir.existsSync()) {
      errors.add('$moduleId: missing content/v1 bundle');
      continue;
    }
    final manifest = File('${versionDir.path}/manifest.json');
    if (!manifest.existsSync()) {
      errors.add('$moduleId: missing manifest.json');
    } else {
      try {
        final data = jsonDecode(manifest.readAsStringSync());
        if (data is! Map) {
          errors.add('$moduleId manifest.json must be an object');
        } else {
          _requireStringField(data, 'id', moduleId, errors);
          _requireStringField(data, 'title', moduleId, errors);
          _requireStringField(data, 'version', moduleId, errors);
        }
      } catch (e) {
        errors.add('$moduleId manifest.json parse error: $e');
      }
    }

    final drills = File('${versionDir.path}/drills.jsonl');
    if (!drills.existsSync()) {
      errors.add('$moduleId: missing drills.jsonl');
    } else {
      final lines = drills.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final raw = lines[i].trim();
        if (raw.isEmpty) continue;
        try {
          final decoded = jsonDecode(raw);
          if (decoded is! Map) {
            errors.add('$moduleId drills.jsonl line ${i + 1} not an object');
            continue;
          }
          final goal = decoded['goal'];
          if (goal is! String || goal.trim().isEmpty) {
            errors.add('$moduleId drills.jsonl line ${i + 1} missing goal');
          }
        } catch (e) {
          errors.add('$moduleId drills.jsonl line ${i + 1} invalid JSON ($e)');
        }
      }
    }
  }
  return errors;
}

void _requireStringField(
  Map data,
  String key,
  String moduleId,
  List<String> errors,
) {
  final value = data[key];
  if (value is! String || value.trim().isEmpty) {
    errors.add('$moduleId manifest.json missing $key');
  }
}

class _ValidationResult {
  _ValidationResult({
    required this.isSuccess,
    required this.errors,
    required this.filesChecked,
  });

  final bool isSuccess;
  final List<String> errors;
  final int filesChecked;
}

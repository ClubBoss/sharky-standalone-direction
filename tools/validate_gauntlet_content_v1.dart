import 'dart:io';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main(List<String> args) {
  final contentRoot = Directory('content');
  if (!contentRoot.existsSync()) {
    stderr.writeln('validate_gauntlet_content_v1: content/ not found');
    exitCode = 1;
    return;
  }

  final gauntletFiles =
      contentRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/v1/gauntlet.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final scheduleFiles =
      contentRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/schedules/daily/v1/schedule.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final errors = <String>[];
  final moduleIds = _scanDirectiveModuleIds(contentRoot, errors);
  final gauntlets = <String, _GauntletDoc>{};
  var stepCount = 0;

  for (final file in gauntletFiles) {
    final parsed = _parseGauntletFile(file, moduleIds, errors);
    if (parsed == null) continue;
    stepCount += parsed.steps.length;
    final existing = gauntlets[parsed.gauntletId];
    if (existing != null) {
      errors.add(
        '${file.path}: duplicate gauntlet_id ${parsed.gauntletId} (already in ${existing.path})',
      );
      continue;
    }
    gauntlets[parsed.gauntletId] = parsed;
  }

  var scheduleEntryCount = 0;
  for (final file in scheduleFiles) {
    final entries = _parseScheduleFile(file, gauntlets, errors);
    scheduleEntryCount += entries;
  }

  if (errors.isNotEmpty) {
    for (final error in errors) {
      stderr.writeln('validate_gauntlet_content_v1: $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'validate_gauntlet_content_v1: OK (${gauntlets.length} gauntlet(s), $stepCount step(s), ${scheduleFiles.length} schedule file(s), $scheduleEntryCount schedule entry(s))',
  );
}

const Set<String> _kAllowedGauntletKindsV1 = <String>{
  'playlist',
  'gauntlet',
  'challenge',
};
const Set<String> _kAllowedGauntletKeysV1 = <String>{
  'v',
  'gauntlet_id',
  'title',
  'kind',
  'world',
  'difficulty',
  'repeatable',
  'visible',
  'entry_module_id',
};
const Set<String> _kAllowedStepTypesV1 = <String>{
  'module',
  'pack',
  'checkpoint',
  'review_queue',
};
const Set<String> _kAllowedStepKeysV1 = <String>{'type', 'ref'};
const Set<String> _kAllowedMetaOnlyCostRewardKeysV1 = <String>{
  'currency',
  'amount',
  'reason',
};
const Set<String> _kAllowedScheduleKeysV1 = <String>{'v'};
const Set<String> _kAllowedScheduleEntryKeysV1 = <String>{
  'date',
  'cohort',
  'gauntlet_id',
};
const Set<String> _kAllowedCohortsV1 = <String>{
  'beginner',
  'intermediate',
  'advanced',
};
const List<String> _kForbiddenDirectiveTokensV1 = <String>[
  'random',
  'seed',
  'shuffle',
  'weight',
  'weights',
  'probability',
  'unlock_if',
  'n_of_m',
];

class _GauntletDoc {
  const _GauntletDoc({
    required this.path,
    required this.gauntletId,
    required this.steps,
  });

  final String path;
  final String gauntletId;
  final List<_GauntletStep> steps;
}

class _GauntletStep {
  const _GauntletStep({required this.type, required this.ref});

  final String type;
  final String ref;
}

class _DirectiveLine {
  const _DirectiveLine({
    required this.name,
    required this.kv,
    required this.lineNumber,
  });

  final String name;
  final Map<String, String> kv;
  final int lineNumber;
}

Set<String> _scanDirectiveModuleIds(
  Directory contentRoot,
  List<String> errors,
) {
  final theoryFiles =
      contentRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/v1/theory.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final moduleIds = <String>{};
  for (final file in theoryFiles) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (!line.startsWith('@')) break;
      if (!line.startsWith('@meta ')) continue;
      final payload = line.substring('@meta '.length).trim();
      final kv = _parseDirectiveKvTokensV1(payload, file.path, i + 1, errors);
      if (kv == null) continue;
      final moduleId = kv['module_id']?.trim();
      if (moduleId == null || moduleId.isEmpty) continue;
      moduleIds.add(moduleId);
    }
  }
  return moduleIds;
}

_GauntletDoc? _parseGauntletFile(
  File file,
  Set<String> moduleIds,
  List<String> errors,
) {
  final directives = _parseDirectiveHeaderOnlyFile(file, errors);
  if (directives.isEmpty) {
    errors.add('${file.path}: missing @gauntlet directive');
    return null;
  }

  Map<String, String>? gauntletKv;
  var gauntletLine = 1;
  final steps = <_GauntletStep>[];

  for (final d in directives) {
    switch (d.name) {
      case 'gauntlet':
        if (gauntletKv != null) {
          errors.add(
            '${file.path}:${d.lineNumber} duplicate @gauntlet directive',
          );
          continue;
        }
        for (final entry in d.kv.entries) {
          if (!_kAllowedGauntletKeysV1.contains(entry.key)) {
            errors.add(
              '${file.path}:${d.lineNumber} unknown @gauntlet key ${entry.key}',
            );
          }
        }
        gauntletKv = d.kv;
        gauntletLine = d.lineNumber;
        break;
      case 'step':
        for (final entry in d.kv.entries) {
          if (!_kAllowedStepKeysV1.contains(entry.key)) {
            errors.add(
              '${file.path}:${d.lineNumber} unknown @step key ${entry.key}',
            );
          }
        }
        final type = (d.kv['type'] ?? '').trim();
        final ref = (d.kv['ref'] ?? '').trim();
        if (type.isEmpty) {
          errors.add('${file.path}:${d.lineNumber} @step missing type');
        }
        if (ref.isEmpty) {
          errors.add('${file.path}:${d.lineNumber} @step missing ref');
        }
        if (type.isNotEmpty && !_kAllowedStepTypesV1.contains(type)) {
          errors.add(
            '${file.path}:${d.lineNumber} @step type must be one of ${_kAllowedStepTypesV1.join(', ')}',
          );
        }
        if (type == 'module' && ref.isNotEmpty && !moduleIds.contains(ref)) {
          errors.add(
            '${file.path}:${d.lineNumber} @step ref module_id $ref not found',
          );
        }
        if (type == 'pack' || type == 'checkpoint' || type == 'review_queue') {
          if (ref.isNotEmpty && !kCampaignPacksV1.containsKey(ref)) {
            errors.add(
              '${file.path}:${d.lineNumber} @step ref pack_id $ref not found in campaign registry',
            );
          }
        }
        steps.add(_GauntletStep(type: type, ref: ref));
        break;
      case 'cost':
      case 'reward':
        for (final entry in d.kv.entries) {
          if (!_kAllowedMetaOnlyCostRewardKeysV1.contains(entry.key)) {
            errors.add(
              '${file.path}:${d.lineNumber} unknown @${d.name} key ${entry.key}',
            );
          }
        }
        break;
      default:
        errors.add('${file.path}:${d.lineNumber} unknown directive @${d.name}');
        break;
    }
  }

  if (gauntletKv == null) {
    errors.add('${file.path}: missing @gauntlet directive');
    return null;
  }

  for (final key in const <String>['v', 'gauntlet_id', 'title', 'kind']) {
    if (!(gauntletKv.containsKey(key))) {
      errors.add('${file.path}: missing @gauntlet $key');
    }
  }
  final v = int.tryParse(gauntletKv['v'] ?? '');
  if (v != 1) {
    errors.add('${file.path}:$gauntletLine @gauntlet v must be 1');
  }
  final gauntletId = (gauntletKv['gauntlet_id'] ?? '').trim();
  if (gauntletId.isEmpty) {
    errors.add(
      '${file.path}:$gauntletLine @gauntlet gauntlet_id must be non-empty',
    );
  } else {
    final pathId = _gauntletIdFromPath(file.path);
    if (pathId != null && pathId != gauntletId) {
      errors.add(
        '${file.path}:$gauntletLine @gauntlet gauntlet_id=$gauntletId does not match path id $pathId',
      );
    }
  }
  final kind = (gauntletKv['kind'] ?? '').trim();
  if (kind.isNotEmpty && !_kAllowedGauntletKindsV1.contains(kind)) {
    errors.add(
      '${file.path}:$gauntletLine @gauntlet kind must be one of ${_kAllowedGauntletKindsV1.join(', ')}',
    );
  }
  final entryModuleId = (gauntletKv['entry_module_id'] ?? '').trim();
  if (entryModuleId.isNotEmpty && !moduleIds.contains(entryModuleId)) {
    errors.add(
      '${file.path}:$gauntletLine @gauntlet entry_module_id $entryModuleId not found',
    );
  }
  if (steps.isEmpty) {
    errors.add('${file.path}: requires at least one @step directive');
  }

  return _GauntletDoc(path: file.path, gauntletId: gauntletId, steps: steps);
}

int _parseScheduleFile(
  File file,
  Map<String, _GauntletDoc> gauntlets,
  List<String> errors,
) {
  final directives = _parseDirectiveHeaderOnlyFile(file, errors);
  if (directives.isEmpty) {
    errors.add('${file.path}: missing @schedule directive');
    return 0;
  }
  Map<String, String>? scheduleKv;
  final seenDateCohort = <String>{};
  var count = 0;
  for (final d in directives) {
    switch (d.name) {
      case 'schedule':
        if (scheduleKv != null) {
          errors.add(
            '${file.path}:${d.lineNumber} duplicate @schedule directive',
          );
          continue;
        }
        for (final entry in d.kv.entries) {
          if (!_kAllowedScheduleKeysV1.contains(entry.key)) {
            errors.add(
              '${file.path}:${d.lineNumber} unknown @schedule key ${entry.key}',
            );
          }
        }
        scheduleKv = d.kv;
        break;
      case 'entry':
        for (final entry in d.kv.entries) {
          if (!_kAllowedScheduleEntryKeysV1.contains(entry.key)) {
            errors.add(
              '${file.path}:${d.lineNumber} unknown @entry key ${entry.key}',
            );
          }
        }
        final date = (d.kv['date'] ?? '').trim();
        final cohort = (d.kv['cohort'] ?? '').trim();
        final gauntletId = (d.kv['gauntlet_id'] ?? '').trim();
        if (!_isValidDateKeyV1(date)) {
          errors.add(
            '${file.path}:${d.lineNumber} invalid date key $date (expected YYYY-MM-DD)',
          );
        }
        if (!_kAllowedCohortsV1.contains(cohort)) {
          errors.add(
            '${file.path}:${d.lineNumber} cohort must be one of ${_kAllowedCohortsV1.join(', ')}',
          );
        }
        if (gauntletId.isEmpty) {
          errors.add('${file.path}:${d.lineNumber} @entry missing gauntlet_id');
        } else if (!gauntlets.containsKey(gauntletId)) {
          errors.add(
            '${file.path}:${d.lineNumber} schedule references unknown gauntlet_id $gauntletId',
          );
        }
        final tupleKey = '$date|$cohort';
        if (date.isNotEmpty &&
            cohort.isNotEmpty &&
            !seenDateCohort.add(tupleKey)) {
          errors.add(
            '${file.path}:${d.lineNumber} duplicate schedule entry for $date cohort=$cohort',
          );
        }
        count++;
        break;
      default:
        errors.add('${file.path}:${d.lineNumber} unknown directive @${d.name}');
        break;
    }
  }

  if (scheduleKv == null) {
    errors.add('${file.path}: missing @schedule directive');
    return count;
  }
  final version = int.tryParse(scheduleKv['v'] ?? '');
  if (version != 1) {
    errors.add('${file.path}: @schedule v must be 1');
  }
  return count;
}

List<_DirectiveLine> _parseDirectiveHeaderOnlyFile(
  File file,
  List<String> errors,
) {
  final lines = file.readAsLinesSync();
  final directives = <_DirectiveLine>[];
  var sawNonDirective = false;
  for (var i = 0; i < lines.length; i++) {
    final raw = lines[i];
    final line = raw.trim();
    if (line.isEmpty) {
      continue;
    }
    if (!line.startsWith('@')) {
      sawNonDirective = true;
      continue;
    }
    if (sawNonDirective) {
      errors.add('${file.path}:${i + 1} directives must appear at top of file');
      continue;
    }
    final lower = line.toLowerCase();
    for (final token in _kForbiddenDirectiveTokensV1) {
      if (lower.contains(token)) {
        errors.add(
          '${file.path}:${i + 1} forbidden token "$token" in directive line',
        );
      }
    }
    final space = line.indexOf(' ');
    final name = (space == -1 ? line.substring(1) : line.substring(1, space))
        .trim()
        .toLowerCase();
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(name)) {
      errors.add('${file.path}:${i + 1} invalid directive name @$name');
      continue;
    }
    final payload = space == -1 ? '' : line.substring(space + 1).trim();
    final kv = _parseDirectiveKvTokensV1(payload, file.path, i + 1, errors);
    if (kv == null) {
      continue;
    }
    directives.add(_DirectiveLine(name: name, kv: kv, lineNumber: i + 1));
  }
  return directives;
}

Map<String, String>? _parseDirectiveKvTokensV1(
  String input,
  String path,
  int lineNumber,
  List<String> errors,
) {
  final result = <String, String>{};
  var i = 0;
  while (i < input.length) {
    while (i < input.length && input.codeUnitAt(i) == 32) {
      i++;
    }
    if (i >= input.length) break;
    final keyStart = i;
    while (i < input.length && input.codeUnitAt(i) != 61) {
      if (input.codeUnitAt(i) == 32) {
        errors.add('$path:$lineNumber invalid directive payload syntax');
        return null;
      }
      i++;
    }
    if (i >= input.length) {
      errors.add('$path:$lineNumber invalid directive payload syntax');
      return null;
    }
    final key = input.substring(keyStart, i).trim();
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(key)) {
      errors.add('$path:$lineNumber invalid key "$key" (ASCII [a-z0-9_] only)');
      return null;
    }
    if (result.containsKey(key)) {
      errors.add('$path:$lineNumber duplicate key $key');
      return null;
    }
    i++;
    if (i >= input.length) {
      errors.add('$path:$lineNumber invalid directive payload syntax');
      return null;
    }

    String value;
    if (input.codeUnitAt(i) == 34) {
      i++;
      final buffer = StringBuffer();
      var closed = false;
      while (i < input.length) {
        final ch = input.codeUnitAt(i);
        if (ch == 92) {
          if (i + 1 >= input.length) {
            errors.add('$path:$lineNumber invalid escape sequence');
            return null;
          }
          final next = input.codeUnitAt(i + 1);
          if (next == 34 || next == 92) {
            buffer.writeCharCode(next);
            i += 2;
            continue;
          }
          errors.add('$path:$lineNumber invalid escape sequence');
          return null;
        }
        if (ch == 34) {
          i++;
          closed = true;
          break;
        }
        buffer.writeCharCode(ch);
        i++;
      }
      if (!closed) {
        errors.add('$path:$lineNumber unterminated quoted string');
        return null;
      }
      value = buffer.toString();
    } else {
      final valueStart = i;
      while (i < input.length && input.codeUnitAt(i) != 32) {
        i++;
      }
      value = input.substring(valueStart, i).trim();
    }

    result[key] = value;
  }
  return result;
}

String? _gauntletIdFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final match = RegExp(
    r'^content/gauntlets/([^/]+)/v1/gauntlet\.md$',
  ).firstMatch(normalized);
  return match?.group(1);
}

bool _isValidDateKeyV1(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    return false;
  }
  final parts = value.split('-');
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return false;
  final parsed = DateTime.tryParse(
    '${parts[0]}-${parts[1]}-${parts[2]}T00:00:00Z',
  );
  if (parsed == null) return false;
  return parsed.year == year && parsed.month == month && parsed.day == day;
}

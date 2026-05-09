import 'dart:convert';
import 'dart:io';

const String _kDefaultStartDayKey = '2026-01-01';
const List<String> _kAllowedCohortsV1 = <String>[
  'beginner',
  'intermediate',
  'advanced',
];

const Map<String, ({int offset, int stride})> _kCohortRotationConfigV1 =
    <String, ({int offset, int stride})>{
      'beginner': (offset: 0, stride: 1),
      'intermediate': (offset: 1, stride: 1),
      'advanced': (offset: 0, stride: 1),
    };

void main(List<String> args) {
  final config = _parseArgs(args);
  if (!config.ok) {
    stderr.writeln(config.message);
    exitCode = 64;
    return;
  }

  final contentRoot = Directory('content');
  if (!contentRoot.existsSync()) {
    stderr.writeln('compile_daily_schedule_v1: content/ not found');
    exitCode = 1;
    return;
  }

  final gauntletIds = _scanGauntletIds(contentRoot);
  if (exitCode != 0) return;
  if (gauntletIds.isEmpty) {
    stderr.writeln('compile_daily_schedule_v1: no gauntlet.md files found');
    exitCode = 1;
    return;
  }

  final scheduleFile = File('content/schedules/daily/v1/schedule.md');
  final compiled = _compileScheduleMarkdown(
    startDayKey: config.startDayKey!,
    days: config.days,
    cohorts: config.cohorts,
    gauntletIds: gauntletIds,
  );
  final compiledBytes = utf8.encode(compiled);

  if (config.check) {
    if (!scheduleFile.existsSync()) {
      stderr.writeln(
        'compile_daily_schedule_v1: --check failed: ${scheduleFile.path} not found',
      );
      exitCode = 1;
      return;
    }
    final existingBytes = scheduleFile.readAsBytesSync();
    if (!_bytesEqual(existingBytes, compiledBytes)) {
      stderr.writeln(
        'compile_daily_schedule_v1: --check failed: ${scheduleFile.path} differs (deterministic snapshot mismatch)',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln(
      'compile_daily_schedule_v1: OK check (${config.days} day(s), cohorts=${config.cohorts.join(',')}, start=${config.startDayKey}, gauntlets=${gauntletIds.length})',
    );
    return;
  }

  scheduleFile.parent.createSync(recursive: true);
  scheduleFile.writeAsStringSync(compiled, flush: true);
  stdout.writeln(
    'compile_daily_schedule_v1: wrote ${scheduleFile.path} (${config.days} day(s), cohorts=${config.cohorts.join(',')}, start=${config.startDayKey}, gauntlets=${gauntletIds.length})',
  );
}

class _Config {
  const _Config({
    required this.ok,
    required this.days,
    required this.cohorts,
    required this.check,
    this.startDayKey,
    this.message,
  });

  final bool ok;
  final int days;
  final List<String> cohorts;
  final bool check;
  final String? startDayKey;
  final String? message;
}

_Config _parseArgs(List<String> args) {
  var days = 90;
  var startDayKey = _kDefaultStartDayKey;
  var check = false;
  var cohorts = List<String>.from(_kAllowedCohortsV1);

  for (final arg in args) {
    if (arg == '--check') {
      check = true;
      continue;
    }
    if (arg.startsWith('--days=')) {
      final raw = arg.substring('--days='.length).trim();
      final parsed = int.tryParse(raw);
      if (parsed == null || parsed <= 0) {
        return _usage(
          'compile_daily_schedule_v1: --days must be a positive integer',
        );
      }
      days = parsed;
      continue;
    }
    if (arg.startsWith('--start=')) {
      final raw = arg.substring('--start='.length).trim();
      if (!_isValidUtcDayKey(raw)) {
        return _usage('compile_daily_schedule_v1: --start must be YYYY-MM-DD');
      }
      startDayKey = raw;
      continue;
    }
    if (arg.startsWith('--cohorts=')) {
      final raw = arg.substring('--cohorts='.length).trim();
      if (raw.isEmpty) {
        return _usage('compile_daily_schedule_v1: --cohorts must not be empty');
      }
      final parsed = raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
      if (parsed.isEmpty) {
        return _usage('compile_daily_schedule_v1: --cohorts must not be empty');
      }
      final seen = <String>{};
      final ordered = <String>[];
      for (final cohort in parsed) {
        if (!_kAllowedCohortsV1.contains(cohort)) {
          return _usage(
            'compile_daily_schedule_v1: invalid cohort "$cohort" (allowed: ${_kAllowedCohortsV1.join(',')})',
          );
        }
        if (seen.add(cohort)) {
          ordered.add(cohort);
        }
      }
      cohorts = ordered;
      continue;
    }
    return _usage('compile_daily_schedule_v1: unknown arg $arg');
  }

  return _Config(
    ok: true,
    days: days,
    cohorts: cohorts,
    check: check,
    startDayKey: startDayKey,
  );
}

_Config _usage(String error) {
  final usage = <String>[
    error,
    'Usage: dart run tools/compile_daily_schedule_v1.dart [--days=N] [--start=YYYY-MM-DD] [--cohorts=beginner,intermediate,advanced] [--check]',
    'Defaults: --days=90, --start=$_kDefaultStartDayKey, --cohorts=beginner,intermediate,advanced',
    'Deterministic: no runtime RNG; same inputs produce byte-identical schedule.md output.',
  ].join('\n');
  return _Config(
    ok: false,
    days: 0,
    cohorts: const <String>[],
    check: false,
    message: usage,
  );
}

List<String> _scanGauntletIds(Directory contentRoot) {
  final files =
      contentRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/v1/gauntlet.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final ids = <String>[];
  final seen = <String>{};
  for (final file in files) {
    final id = _parseGauntletIdFromFile(file);
    if (id == null || id.isEmpty) {
      stderr.writeln(
        'compile_daily_schedule_v1: failed to parse @gauntlet gauntlet_id in ${file.path}',
      );
      exitCode = 1;
      return const <String>[];
    }
    if (!_isAsciiToken(id)) {
      stderr.writeln(
        'compile_daily_schedule_v1: invalid gauntlet_id "$id" in ${file.path}; expected ASCII [a-z0-9_]+',
      );
      exitCode = 1;
      return const <String>[];
    }
    if (!seen.add(id)) {
      stderr.writeln('compile_daily_schedule_v1: duplicate gauntlet_id "$id"');
      exitCode = 1;
      return const <String>[];
    }
    ids.add(id);
  }
  ids.sort();
  return List<String>.unmodifiable(ids);
}

String? _parseGauntletIdFromFile(File file) {
  final lines = file.readAsLinesSync();
  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    if (!line.startsWith('@')) break;
    if (!line.startsWith('@gauntlet ')) continue;
    final kv = _parseDirectiveKv(line.substring('@gauntlet '.length));
    return kv['gauntlet_id']?.trim();
  }
  return null;
}

Map<String, String> _parseDirectiveKv(String input) {
  final out = <String, String>{};
  var i = 0;
  while (i < input.length) {
    while (i < input.length && input.codeUnitAt(i) == 32) {
      i++;
    }
    if (i >= input.length) break;

    final keyStart = i;
    while (i < input.length) {
      final c = input.codeUnitAt(i);
      if (c == 32 || c == 61) break;
      i++;
    }
    final key = input.substring(keyStart, i).trim();
    if (key.isEmpty) break;

    while (i < input.length && input.codeUnitAt(i) == 32) {
      i++;
    }
    if (i >= input.length || input.codeUnitAt(i) != 61) break;
    i++;

    String value = '';
    if (i < input.length && input.codeUnitAt(i) == 34) {
      i++;
      final buf = StringBuffer();
      while (i < input.length) {
        final c = input.codeUnitAt(i);
        if (c == 34) {
          i++;
          break;
        }
        if (c == 92 && i + 1 < input.length) {
          buf.writeCharCode(input.codeUnitAt(i + 1));
          i += 2;
          continue;
        }
        buf.writeCharCode(c);
        i++;
      }
      value = buf.toString();
    } else {
      final valueStart = i;
      while (i < input.length && input.codeUnitAt(i) != 32) {
        i++;
      }
      value = input.substring(valueStart, i);
    }
    out[key] = value;
  }
  return out;
}

String _compileScheduleMarkdown({
  required String startDayKey,
  required int days,
  required List<String> cohorts,
  required List<String> gauntletIds,
}) {
  final start = DateTime.parse('${startDayKey}T00:00:00Z').toUtc();
  final lines = <String>['@schedule v=1', 'schedule_version: 1'];
  for (var dayIndex = 0; dayIndex < days; dayIndex++) {
    final date = _formatUtcDayKey(start.add(Duration(days: dayIndex)));
    for (final cohort in cohorts) {
      final cfg = _kCohortRotationConfigV1[cohort] ?? (offset: 0, stride: 1);
      final index = ((dayIndex * cfg.stride) + cfg.offset) % gauntletIds.length;
      lines.add(
        '@entry date=$date cohort=$cohort gauntlet_id=${gauntletIds[index]}',
      );
    }
  }
  return '${lines.join('\n')}\n';
}

String _formatUtcDayKey(DateTime utc) {
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

bool _isValidUtcDayKey(String value) {
  final re = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!re.hasMatch(value)) return false;
  try {
    final parsed = DateTime.parse('${value}T00:00:00Z').toUtc();
    return _formatUtcDayKey(parsed) == value;
  } catch (_) {
    return false;
  }
}

bool _isAsciiToken(String value) => RegExp(r'^[a-z0-9_]+$').hasMatch(value);

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

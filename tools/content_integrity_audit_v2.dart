import 'dart:convert';
import 'dart:io';

/// Content Integrity Audit V2
///
/// Validates logical consistency across lesson/drill/quiz/recap chains.
/// Reports duplicate IDs, difficulty/xp drift, broken references, and
/// xp-to-drill ratio anomalies. Supports --dry-run (default) and --apply
/// to optionally patch detected issues.

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  final contentRoot = Directory('content');
  if (!contentRoot.existsSync()) {
    _emitSummary(
      dryRun: dryRun,
      checked: 0,
      fixed: 0,
      duplicates: 0,
      xpIssues: 0,
      referenceIssues: 0,
      drillIssues: 0,
      pass: true,
    );
    return;
  }

  final files = <File>[];
  for (final entity in contentRoot.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.jsonl')) {
      files.add(entity);
    }
  }

  if (files.isEmpty) {
    _emitSummary(
      dryRun: dryRun,
      checked: 0,
      fixed: 0,
      duplicates: 0,
      xpIssues: 0,
      referenceIssues: 0,
      drillIssues: 0,
      pass: true,
    );
    return;
  }

  final entriesByFile = <String, List<_Entry>>{};
  final allEntries = <_Entry>[];

  for (final file in files) {
    final raw = file.readAsStringSync();
    final lines = raw.split('\n');
    final list = <_Entry>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        list.add(_Entry(file.path, i, line, null));
        continue;
      }
      try {
        final data = jsonDecode(line);
        if (data is Map<String, dynamic>) {
          final entry = _Entry(file.path, i, line, data);
          list.add(entry);
          allEntries.add(entry);
        } else {
          list.add(_Entry(file.path, i, line, null));
        }
      } catch (_) {
        list.add(_Entry(file.path, i, line, null));
      }
    }
    entriesByFile[file.path] = list;
  }

  int checked = 0;
  int fixed = 0;
  int duplicateIssues = 0;
  int xpIssues = 0;
  int referenceIssues = 0;
  int drillIssues = 0;

  final seenIds = <String, int>{};
  final idSet = <String>{};

  for (final entry in allEntries) {
    final data = entry.data;
    if (data == null) continue;
    checked++;
    final idValue = data['id'];
    if (idValue is String && idValue.trim().isNotEmpty) {
      final normalized = idValue.trim();
      final count = (seenIds[normalized] ?? 0) + 1;
      seenIds[normalized] = count;
      if (count == 1) {
        idSet.add(normalized);
      } else {
        duplicateIssues++;
        if (apply) {
          final newId = _generateUniqueId(normalized, idSet, count - 1);
          data['id'] = newId;
          entry.modified = true;
          idSet.add(newId);
          fixed++;
        }
      }
    }
  }

  if (!apply) {
    idSet.clear();
    for (final entry in allEntries) {
      final data = entry.data;
      if (data == null) continue;
      final idValue = data['id'];
      if (idValue is String && idValue.trim().isNotEmpty) {
        idSet.add(idValue.trim());
      }
    }
  }

  for (final entry in allEntries) {
    final data = entry.data;
    if (data == null) continue;

    final difficulty = _normalizeDifficulty(data['difficulty']);
    final xpValue = _parseXp(data['xp_value']);
    final expectedXp = difficulty == null
        ? null
        : _defaultXpForDifficulty(difficulty);

    if (difficulty != null) {
      final needsFix =
          xpValue == null ||
          xpValue < 10 ||
          xpValue > 250 ||
          (expectedXp != null && xpValue != expectedXp);
      if (needsFix) {
        xpIssues++;
        if (apply && expectedXp != null) {
          data['xp_value'] = expectedXp;
          entry.modified = true;
          fixed++;
        }
      }
    }

    final drillCount = _extractDrillCount(data);
    final finalXp = _parseXp(data['xp_value']);
    if (drillCount != null &&
        drillCount > 0 &&
        finalXp != null &&
        (finalXp / drillCount < 10 || finalXp / drillCount > 60)) {
      drillIssues++;
      if (apply) {
        final target = finalXp / drillCount < 10
            ? (drillCount * 15).clamp(25, 250)
            : (drillCount * 25).clamp(25, 250);
        data['xp_value'] = target;
        entry.modified = true;
        fixed++;
      }
    }

    final brokenRefs = _validateReferences(data, idSet);
    if (brokenRefs > 0) {
      referenceIssues += brokenRefs;
      if (apply) {
        entry.modified = true;
        fixed += brokenRefs;
      }
    }
  }

  if (apply) {
    for (final file in files) {
      final entries = entriesByFile[file.path] ?? const [];
      final buffer = StringBuffer();
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        if (entry.data == null) {
          buffer.writeln(entry.original);
        } else {
          buffer.writeln(jsonEncode(entry.data));
        }
      }
      file.writeAsStringSync(buffer.toString());
    }
  }

  final pass =
      duplicateIssues == 0 &&
      xpIssues == 0 &&
      referenceIssues == 0 &&
      drillIssues == 0;

  final status = pass ? 'PASS (✓)' : 'FAIL (✗)';
  stdout.writeln('Content Integrity Audit V2: $status');
  stdout.writeln(' - Entries checked: $checked, fixed: $fixed');
  stdout.writeln(
    ' - Issues -> duplicates: $duplicateIssues, '
    'difficulty/xp: $xpIssues, references: $referenceIssues, '
    'xp-to-drill: $drillIssues',
  );

  _emitSummary(
    dryRun: dryRun,
    checked: checked,
    fixed: fixed,
    duplicates: duplicateIssues,
    xpIssues: xpIssues,
    referenceIssues: referenceIssues,
    drillIssues: drillIssues,
    pass: pass,
  );
}

class _Entry {
  _Entry(this.filePath, this.index, this.original, this.data);
  final String filePath;
  final int index;
  final String original;
  Map<String, dynamic>? data;
  bool modified = false;
}

String _generateUniqueId(String base, Set<String> existing, int seed) {
  var counter = seed;
  while (true) {
    final candidate = '${base}_v2_$counter';
    if (!existing.contains(candidate)) {
      return candidate;
    }
    counter++;
  }
}

String? _normalizeDifficulty(Object? value) {
  if (value is String) {
    final lowered = value.trim().toLowerCase();
    if (lowered == 'easy' || lowered == 'medium' || lowered == 'hard') {
      return lowered;
    }
  }
  return null;
}

int? _parseXp(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

int _defaultXpForDifficulty(String difficulty) {
  switch (difficulty) {
    case 'easy':
      return 25;
    case 'hard':
      return 150;
    default:
      return 75;
  }
}

int? _extractDrillCount(Map<String, dynamic> data) {
  final count = data['drill_count'];
  if (count is int) return count;
  final drills = data['drills'];
  if (drills is List) return drills.length;
  final modules = data['drill_ids'];
  if (modules is List) return modules.length;
  return null;
}

int _validateReferences(Map<String, dynamic> data, Set<String> validIds) {
  var issues = 0;
  final keys = data.keys.toList();
  for (final key in keys) {
    final lower = key.toLowerCase();
    if (!(lower.contains('recap') ||
        lower.contains('quiz') ||
        lower.contains('lab'))) {
      continue;
    }
    final value = data[key];
    if (value is String) {
      if (value.trim().isEmpty || !validIds.contains(value.trim())) {
        issues++;
        data[key] = null;
      }
    } else if (value is List) {
      final filtered = value
          .whereType<String>()
          .where((id) => validIds.contains(id.trim()))
          .toList();
      if (filtered.length != value.length) {
        issues++;
        data[key] = filtered;
      }
    }
  }
  return issues;
}

void _emitSummary({
  required bool dryRun,
  required int checked,
  required int fixed,
  required int duplicates,
  required int xpIssues,
  required int referenceIssues,
  required int drillIssues,
  required bool pass,
}) {
  stdout.writeln(
    jsonEncode({
      'checked': checked,
      'fixed': fixed,
      'duplicates': duplicates,
      'xp_mismatches': xpIssues,
      'reference_issues': referenceIssues,
      'drill_issues': drillIssues,
      'dry_run': dryRun,
      'pass': pass,
    }),
  );
}

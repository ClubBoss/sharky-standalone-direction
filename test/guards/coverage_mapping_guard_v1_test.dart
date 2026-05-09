import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<Map<String, String>> _parseMarkdownTableByHeader(
  String markdown,
  String headerLine,
) {
  final lines = markdown.split('\n');
  final startIndex = lines.indexWhere((line) => line.trim() == headerLine);
  if (startIndex < 0) {
    throw StateError('Missing table header: $headerLine');
  }

  final tableLines = <String>[];
  for (var i = startIndex; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    if (!trimmed.startsWith('|')) {
      if (tableLines.isNotEmpty) break;
      continue;
    }
    tableLines.add(trimmed);
  }

  if (tableLines.length < 3) {
    throw StateError('Malformed markdown table for header: $headerLine');
  }
  final headers = tableLines.first
      .split('|')
      .map((cell) => cell.trim())
      .where((cell) => cell.isNotEmpty)
      .toList(growable: false);

  final rows = <Map<String, String>>[];
  for (final line in tableLines.skip(2)) {
    final cells = line
        .split('|')
        .map((cell) => cell.trim())
        .where((cell) => cell.isNotEmpty)
        .toList(growable: false);
    if (cells.length != headers.length) {
      continue;
    }
    rows.add(Map<String, String>.fromIterables(headers, cells));
  }
  return rows;
}

Set<String> _parseModeFamiliesFromStrategy(String markdown) {
  return markdown
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.startsWith('### '))
      .map((line) => line.substring(4).trim())
      .toSet();
}

List<String> _splitCsvCell(String value) {
  return value
      .split(',')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

List<String> _splitSkillFamilyParts(String value) {
  return value
      .split('/')
      .map((entry) => entry.trim().toLowerCase())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

void main() {
  final modeStrategyText = File(
    'docs/plan/MODE_FAMILY_STRATEGY_v1.md',
  ).readAsStringSync();
  final skillCoverageText = File(
    'docs/plan/SKILL_COVERAGE_MATRIX_v1.md',
  ).readAsStringSync();
  final worldNodeMatrixText = File(
    'docs/plan/WORLD_NODE_MODE_MATRIX_v1.md',
  ).readAsStringSync();

  final curatedModeFamilies = _parseModeFamiliesFromStrategy(modeStrategyText);
  final skillRows = _parseMarkdownTableByHeader(
    skillCoverageText,
    '| Skill family | Short description | Likely world anchor(s) | Preferred mode families | Current status | Note |',
  );
  final worldRows = _parseMarkdownTableByHeader(
    worldNodeMatrixText,
    '| World / node family | Intended cognitive role | Target skill families | Preferred mode families | Current status | Current reality / next gap |',
  );

  test(
    'non-deferred skill families in the coverage matrix have a world/node home',
    () {
      final mappedSkillCells = worldRows
          .map((row) => row['Target skill families'] ?? '')
          .toList(growable: false);

      for (final row in skillRows) {
        final skillFamily = row['Skill family'] ?? '';
        final status = row['Current status'] ?? '';
        if (status == 'deferred/later') {
          continue;
        }
        final skillParts = _splitSkillFamilyParts(skillFamily);
        expect(
          mappedSkillCells.any(
            (cell) {
              final normalizedCell = cell.toLowerCase();
              return skillParts.every(normalizedCell.contains);
            },
          ),
          isTrue,
          reason:
              'Skill family "$skillFamily" is not deferred/later but has no world/node home in WORLD_NODE_MODE_MATRIX_v1.',
        );
      }
    },
  );

  test('skill coverage matrix uses only curated mode families', () {
    for (final row in skillRows) {
      final skillFamily = row['Skill family'] ?? '';
      for (final modeFamily in _splitCsvCell(
        row['Preferred mode families'] ?? '',
      )) {
        expect(
          curatedModeFamilies.contains(modeFamily),
          isTrue,
          reason:
              'Skill family "$skillFamily" uses non-curated mode family "$modeFamily".',
        );
      }
    }
  });

  test('world/node mode matrix uses only curated mode families', () {
    for (final row in worldRows) {
      final worldNodeFamily = row['World / node family'] ?? '';
      for (final modeFamily in _splitCsvCell(
        row['Preferred mode families'] ?? '',
      )) {
        expect(
          curatedModeFamilies.contains(modeFamily),
          isTrue,
          reason:
              'World/node family "$worldNodeFamily" uses non-curated mode family "$modeFamily".',
        );
      }
    }
  });
}

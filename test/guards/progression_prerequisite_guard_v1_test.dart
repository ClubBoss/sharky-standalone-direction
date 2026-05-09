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

int? _firstWorldNumber(String value) {
  final match = RegExp(r'Worlds?\s+(\d+)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.parse(match.group(1)!);
}

int _requiredFirstWorldForSkill(
  List<Map<String, String>> skillRows,
  String skillFamily,
) {
  final row = skillRows.firstWhere(
    (entry) => (entry['Skill family'] ?? '') == skillFamily,
    orElse: () => throw StateError('Missing skill family: $skillFamily'),
  );
  final world = _firstWorldNumber(row['Likely world anchor(s)'] ?? '');
  if (world == null) {
    throw StateError('Missing world anchor for skill family: $skillFamily');
  }
  return world;
}

void main() {
  final modeStrategyText = File(
    'docs/plan/MODE_FAMILY_STRATEGY_v1.md',
  ).readAsStringSync();
  final progressionText = File(
    'docs/plan/PROGRESSION_PREREQUISITE_MATRIX_v1.md',
  ).readAsStringSync();
  final skillCoverageText = File(
    'docs/plan/SKILL_COVERAGE_MATRIX_v1.md',
  ).readAsStringSync();
  final worldNodeMatrixText = File(
    'docs/plan/WORLD_NODE_MODE_MATRIX_v1.md',
  ).readAsStringSync();

  final curatedModeFamilies = _parseModeFamiliesFromStrategy(modeStrategyText);
  final progressionRows = _parseMarkdownTableByHeader(
    progressionText,
    '| Skill / mode family | Prerequisite(s) | Likely earliest safe world anchor | Progression note / anti-jump warning |',
  );
  final progressionModeRows = _parseMarkdownTableByHeader(
    progressionText,
    '| Mode family | Prerequisite(s) | Likely earliest safe world anchor | Progression note / anti-jump warning |',
  );
  final skillRows = _parseMarkdownTableByHeader(
    skillCoverageText,
    '| Skill family | Short description | Likely world anchor(s) | Preferred mode families | Current status | Note |',
  );
  final worldRows = _parseMarkdownTableByHeader(
    worldNodeMatrixText,
    '| World / node family | Intended cognitive role | Target skill families | Preferred mode families | Current status | Current reality / next gap |',
  );

  test('progression mode families stay inside the curated strategy', () {
    for (final row in progressionModeRows) {
      final modeFamily = row['Mode family'] ?? '';
      expect(
        curatedModeFamilies.contains(modeFamily),
        isTrue,
        reason:
            'Progression matrix mode family "$modeFamily" is not in MODE_FAMILY_STRATEGY_v1.',
      );
    }
  });

  test('explicit prerequisite skill pairs keep increasing world order', () {
    const prerequisitePairs = <MapEntry<String, String>>[
      MapEntry('Positions / role recognition', 'Action choice'),
      MapEntry(
        'Hand strength / showdown comparison',
        'Preflop framework / hand categories',
      ),
      MapEntry('Action choice', 'Initiative / aggressor logic'),
    ];

    for (final pair in prerequisitePairs) {
      final prerequisiteWorld = _requiredFirstWorldForSkill(
        skillRows,
        pair.key,
      );
      final dependentWorld = _requiredFirstWorldForSkill(skillRows, pair.value);
      expect(
        prerequisiteWorld <= dependentWorld,
        isTrue,
        reason:
            'Skill family "${pair.value}" is anchored before its prerequisite "${pair.key}".',
      );
    }
  });

  test('exact earliest-safe world anchors are not undercut by world/node placement', () {
    for (final row in progressionRows) {
      final skillFamily = row['Skill / mode family'] ?? '';
      final earliestAnchor = row['Likely earliest safe world anchor'] ?? '';
      final earliestWorld = _firstWorldNumber(earliestAnchor);
      if (earliestWorld == null || earliestAnchor.contains('or')) {
        continue;
      }

      final matchingWorldRows = worldRows.where((worldRow) {
        final normalizedCell =
            (worldRow['Target skill families'] ?? '').toLowerCase();
        final skillParts = _splitSkillFamilyParts(skillFamily);
        return skillParts.every(normalizedCell.contains);
      }).toList(growable: false);

      if (matchingWorldRows.isEmpty) {
        continue;
      }

      for (final worldRow in matchingWorldRows) {
        final mappedWorld = _firstWorldNumber(worldRow['World / node family'] ?? '');
        if (mappedWorld == null) {
          continue;
        }
        expect(
          mappedWorld >= earliestWorld,
          isTrue,
          reason:
              'World/node family "${worldRow['World / node family']}" places "$skillFamily" before its earliest safe anchor "$earliestAnchor".',
        );
      }
    }
  });

  test('world/node matrix mode families stay inside the curated strategy', () {
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

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  Map<String, Object?> loadManifest(String moduleId) {
    final file = File(
      '${Directory.current.path}/content/$moduleId/v1/manifest.json',
    );
    final decoded = jsonDecode(file.readAsStringSync());
    return Map<String, Object?>.from(decoded as Map);
  }

  int drillsCount(String moduleId) {
    final file = File(
      '${Directory.current.path}/content/$moduleId/v1/drills.jsonl',
    );
    return file
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .length;
  }

  test('core parity modules are present and have non-trivial drill counts', () {
    const targets = <String, String>{
      'core_positions_and_initiative': 'Positions & Initiative',
      'core_starting_hands': 'Starting Hands',
    };

    for (final entry in targets.entries) {
      final moduleId = entry.key;
      final expectedTitle = entry.value;

      final manifest = loadManifest(moduleId);
      expect(manifest['id'], moduleId);
      expect(manifest['title'], expectedTitle);
      expect(drillsCount(moduleId), greaterThanOrEqualTo(10));
    }
  });
}

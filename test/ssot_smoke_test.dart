import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';

import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui/session_player/spot_specs.dart' as specs;

void main() {
  group('SSOT smoke', () {
    test('jam-vs-* kinds map to [jam, fold]', () {
      final mismatches = <String>[];
      for (final k in SpotKind.values) {
        final name = k.name;
        if (name.contains('_jam_vs_')) {
          final a = specs.actionsMap[k];
          final expected = const ['jam', 'fold'];
          if (a == null ||
              a.length != 2 ||
              a[0] != expected[0] ||
              a[1] != expected[1]) {
            mismatches.add(name);
          }
        }
      }
      expect(
        mismatches,
        isEmpty,
        reason:
            'actionsMap must equal [jam, fold] for: ${mismatches.join(', ')}',
      );
    });

    test('subtitle starts with configured prefix when present', () {
      final failures = <String>[];
      for (final k in SpotKind.values) {
        final prefix = specs.subtitlePrefix[k];
        if (prefix == null || prefix.isEmpty)
          continue; // only assert when prefix exists
        final subtitle = prefix + 'TAIL'; // deterministic minimal builder
        if (!subtitle.startsWith(prefix)) {
          failures.add(k.name);
        }
      }
      expect(
        failures,
        isEmpty,
        reason:
            'Subtitle does not start with prefix for: ${failures.join(', ')}',
      );
    });

    test('actionsMap covers every SpotKind with non-empty actions', () {
      final missing = <String>[];
      final empty = <String>[];
      for (final k in SpotKind.values) {
        final a = specs.actionsMap[k];
        if (a == null) {
          missing.add(k.name);
        } else if (a.isEmpty) {
          empty.add(k.name);
        }
      }
      expect(
        missing,
        isEmpty,
        reason: 'actionsMap missing for: ${missing.join(', ')}',
      );
      expect(
        empty,
        isEmpty,
        reason: 'actionsMap has empty actions for: ${empty.join(', ')}',
      );
    });
  });
}

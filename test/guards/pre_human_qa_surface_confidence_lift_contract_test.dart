import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'terminal review visible copy avoids internal route/blocker language',
    () {
      final source = File(
        'lib/campaign/campaign_pack_registry_v1.dart',
      ).readAsStringSync();
      final terminalStart = source.indexOf(
        'List<MicroTaskStep> _volumeITerminalReviewPackV1()',
      );
      expect(terminalStart, isNonNegative);
      final terminalEnd = source.indexOf(
        'String _stepNarrativeTextV1',
        terminalStart,
      );
      expect(terminalEnd, isNonNegative);
      final terminalPack = source.substring(terminalStart, terminalEnd);

      for (final forbidden in <String>[
        'terminal review state',
        'no future world is open',
        'blocked in this route',
        'Stay in terminal review',
        'Terminal review held',
        'Route-confusion',
        'Terminal close',
        'Route overreach',
      ]) {
        expect(terminalPack, isNot(contains(forbidden)));
      }

      expect(terminalPack, contains('Later worlds stay locked for now'));
      expect(
        terminalPack,
        contains('Stay in review and keep the Volume I clues sharp.'),
      );
      expect(
        terminalPack,
        contains('The next visible activity is review and keep-sharp work.'),
      );
    },
  );

  test('active-route screenshot capture uses reviewer-facing route labels', () {
    final source = File(
      'tools/act0_real_text_surface_capture_v1.dart',
    ).readAsStringSync();

    for (final forbidden in <String>[
      'Volume I Terminal Review',
      'Active Route',
      'This choice misses the visible route clue',
      'Stay in terminal review.',
    ]) {
      expect(source, isNot(contains(forbidden)));
    }

    expect(source, contains('Volume I review'));
    expect(source, contains(r'World \$number practice'));
    expect(source, contains('Look for the table clue first:'));
  });
}

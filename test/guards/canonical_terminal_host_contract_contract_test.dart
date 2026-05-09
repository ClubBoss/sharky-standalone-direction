import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'canonical terminal host contract defines a family-agnostic terminal launch model',
    () {
      final source = File(
        'lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart',
      ).readAsStringSync();

      expect(source.contains('enum CanonicalTerminalFamilyV1'), isTrue);
      expect(
        source.contains('class CanonicalTerminalResolvedHostLaunchV1'),
        isTrue,
      );
      expect(
        source.contains(
          'factory CanonicalTerminalResolvedHostLaunchV1.world1Microtask({',
        ),
        isTrue,
      );
      expect(
        source.contains('class CanonicalTerminalWorld1RuntimeConfigV1'),
        isTrue,
      );
      expect(
        source.contains('class CanonicalTerminalPhaseRuntimeConfigV1'),
        isTrue,
      );
      expect(
        source.contains('class CanonicalTerminalLegacyDrillRuntimeConfigV1'),
        isTrue,
      );
      expect(source.contains('required this.runtimeConfigV1,'), isTrue);
      expect(
        source.contains('required CanonicalTerminalWorld1RuntimeConfigV1'),
        isTrue,
      );
      expect(
        source.contains('required CanonicalTerminalPhaseRuntimeConfigV1'),
        isTrue,
      );
      expect(
        source.contains('required CanonicalTerminalLegacyDrillRuntimeConfigV1'),
        isTrue,
      );
      expect(source.contains('sessionDrillSurfaced'), isTrue);
    },
  );
}

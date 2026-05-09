import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'world1 and surfaced session-drill terminal families share one runtime-config seam',
    () {
      final hostContract = File(
        'lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart',
      ).readAsStringSync();
      final world1Adapter = File(
        'lib/ui_v2/runner/world1_canonical_host_adapter_v1.dart',
      ).readAsStringSync();
      final launcher = File(
        'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
      ).readAsStringSync();

      expect(
        hostContract.contains('class CanonicalTerminalWorld1RuntimeConfigV1'),
        isTrue,
      );
      expect(hostContract.contains('required this.runtimeConfigV1,'), isTrue);
      expect(
        hostContract.contains(
          'required CanonicalTerminalWorld1RuntimeConfigV1 runtimeConfigV1',
        ),
        isTrue,
      );
      expect(
        world1Adapter.contains(
          'runtimeConfigV1: CanonicalTerminalWorld1RuntimeConfigV1(',
        ),
        isTrue,
      );
      expect(
        launcher.contains(
          'runtimeConfigV1: CanonicalTerminalWorld1RuntimeConfigV1(',
        ),
        isTrue,
      );
    },
  );
}

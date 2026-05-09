import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'legacy drill terminal family uses the shared runtime-config seam at the terminal boundary',
    () {
      final hostContract = File(
        'lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart',
      ).readAsStringSync();
      final adapter = File(
        'lib/ui_v2/runner/legacy_drill_canonical_host_adapter_v1.dart',
      ).readAsStringSync();
      final runner = File(
        'lib/ui_v2/runner/canonical_terminal_legacy_drill_runner_v1.dart',
      ).readAsStringSync();

      expect(
        hostContract.contains(
          'class CanonicalTerminalLegacyDrillRuntimeConfigV1',
        ),
        isTrue,
      );
      expect(
        hostContract.contains(
          'required CanonicalTerminalLegacyDrillRuntimeConfigV1',
        ),
        isTrue,
      );
      expect(
        adapter.contains(
          'runtimeConfigV1: CanonicalTerminalLegacyDrillRuntimeConfigV1(',
        ),
        isTrue,
      );
      expect(
        runner.contains(
          'final CanonicalTerminalLegacyDrillRuntimeConfigV1 runtimeConfigV1;',
        ),
        isTrue,
      );
      expect(runner.contains('required this.runtimeConfigV1,'), isTrue);
    },
  );
}

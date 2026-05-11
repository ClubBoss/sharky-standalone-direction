import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'world1 host adapter canonicalizes runtime config through the shared host contract seam',
    () {
      final hostContract = File(
        'lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart',
      ).readAsStringSync();
      final world1Adapter = File(
        'lib/ui_v2/runner/world1_canonical_host_adapter_v1.dart',
      ).readAsStringSync();

      expect(
        hostContract.contains(
          'class CanonicalTerminalWorld1RuntimeConfigInputV1',
        ),
        isTrue,
      );
      expect(
        hostContract.contains('resolveCanonicalTerminalWorld1RuntimeConfigV1('),
        isTrue,
      );
      expect(
        world1Adapter.contains('class World1CanonicalHostLaunchStateV1'),
        isFalse,
      );
      expect(
        world1Adapter.contains('resolveWorld1CanonicalHostLaunchStateV1('),
        isFalse,
      );
      expect(
        world1Adapter.contains(
          'resolveCanonicalTerminalWorld1RuntimeConfigV1(',
        ),
        isTrue,
      );
      expect(
        world1Adapter.contains('runtimeConfigV1: _runtimeConfigV1'),
        isTrue,
      );
    },
  );
}

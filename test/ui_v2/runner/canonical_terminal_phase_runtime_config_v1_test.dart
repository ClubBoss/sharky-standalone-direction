import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';

void main() {
  test('phase1 terminal launch preserves shared runtime config', () {
    final resolved = CanonicalTerminalResolvedHostLaunchV1.phase1(
      runtimeConfigV1: const CanonicalTerminalPhaseRuntimeConfigV1(
        runIdV1: 'phase1-run',
      ),
    );

    final payload = resolved.phasePayloadV1;
    expect(payload.family, CanonicalTerminalFamilyV1.phase1);
    expect(payload.runtimeConfigV1.runIdV1, 'phase1-run');
    expect(payload.runtimeConfigV1.sessionStartLoggedV1, isFalse);
  });

  test(
    'phase2 terminal launch preserves session-start state in shared config',
    () {
      final resolved = CanonicalTerminalResolvedHostLaunchV1.phase2(
        runtimeConfigV1: const CanonicalTerminalPhaseRuntimeConfigV1(
          runIdV1: 'phase2-run',
          sessionStartLoggedV1: true,
        ),
      );

      final payload = resolved.phasePayloadV1;
      expect(payload.family, CanonicalTerminalFamilyV1.phase2);
      expect(payload.runtimeConfigV1.runIdV1, 'phase2-run');
      expect(payload.runtimeConfigV1.sessionStartLoggedV1, isTrue);
    },
  );

  test('phase3 terminal launch preserves shared runtime config', () {
    final resolved = CanonicalTerminalResolvedHostLaunchV1.phase3(
      runtimeConfigV1: const CanonicalTerminalPhaseRuntimeConfigV1(
        runIdV1: 'phase3-run',
      ),
    );

    final payload = resolved.phasePayloadV1;
    expect(payload.family, CanonicalTerminalFamilyV1.phase3);
    expect(payload.runtimeConfigV1.runIdV1, 'phase3-run');
    expect(payload.runtimeConfigV1.sessionStartLoggedV1, isFalse);
  });
}

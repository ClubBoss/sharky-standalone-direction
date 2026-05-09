import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';

void main() {
  test('legacy drill terminal launch preserves shared runtime config', () {
    final resolved = CanonicalTerminalResolvedHostLaunchV1.legacyDrill(
      runtimeConfigV1: const CanonicalTerminalLegacyDrillRuntimeConfigV1(
        moduleIdV1: 'legacy_alignment_v1',
        resolvedItemsV1: <Map<String, dynamic>>[
          <String, dynamic>{'question': 'Prompt'},
        ],
      ),
    );

    final payload = resolved.legacyDrillPayloadV1;
    expect(payload.runtimeConfigV1.moduleIdV1, 'legacy_alignment_v1');
    expect(payload.moduleId, 'legacy_alignment_v1');
    expect(payload.resolvedItemsV1, hasLength(1));
    expect(payload.resolvedItemsV1.single['question'], 'Prompt');
  });
}

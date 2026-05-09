import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:test/test.dart';

import 'worlds_pointer_matrix_v1_test_helper.dart';

const Set<String> _allowedInteropViolationCodesV1 = <String>{
  'interop_empty_steps',
  'interop_unsupported_legal_actions',
};

void main() {
  test('world1..world10 interop smoke matrix is deterministic', () {
    final store = CampaignRegistryStoreV1TestHelper();
    final runner = CampaignSpineRunnerV1(store: store);
    final adapter = const ReplayerToEngineV2AdapterV1();
    final engine = const EngineV2();

    final pointers = buildWorldPointerMatrixV1();
    expect(pointers.length, 40);

    final coveredWorlds = <int>{};
    var successCount = 0;
    var blockedCount = 0;
    final blockedByCode = <String, int>{};
    final blockedPointers = <String, List<String>>{};

    for (final pointer in pointers) {
      coveredWorlds.add(pointer.worldId);
      final replayer = runner.scenarioForPointer(pointer);

      final convertedA = adapter.tryConvert(
        scenarioId: '${pointer.packId}:${pointer.beatIndex}',
        replayer: replayer,
      );
      final convertedB = adapter.tryConvert(
        scenarioId: '${pointer.packId}:${pointer.beatIndex}',
        replayer: replayer,
      );

      expect(convertedA.scenario == null, convertedB.scenario == null);
      if (convertedA.scenario != null && convertedB.scenario != null) {
        expect(
          convertedA.scenario!.initialSnapshot,
          convertedB.scenario!.initialSnapshot,
        );
        expect(
          convertedA.scenario!.steps.map((step) => step.label).toList(),
          convertedB.scenario!.steps.map((step) => step.label).toList(),
        );
      }
      expect(convertedA.violations, convertedB.violations);

      if (convertedA.scenario == null) {
        blockedCount++;
        expect(convertedA.violations, isNotEmpty);
        for (final violation in convertedA.violations) {
          blockedByCode.update(
            violation.code,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
          final pointerLabel =
              'w${pointer.worldId}:${pointer.packId}:${pointer.beatIndex}';
          blockedPointers.update(
            violation.code,
            (values) => <String>[...values, pointerLabel],
            ifAbsent: () => <String>[pointerLabel],
          );
          expect(
            _allowedInteropViolationCodesV1.contains(violation.code),
            isTrue,
            reason: 'Unexpected interop violation code: ${violation.code}',
          );
        }
        continue;
      }

      successCount++;
      final firstRun = engine.runScenarioWithEvaluation(convertedA.scenario!);
      final secondRun = engine.runScenarioWithEvaluation(convertedA.scenario!);

      expect(firstRun, secondRun);
      expect(firstRun.outcome, isNotNull);
      expect(firstRun.trace.entries, isNotEmpty);
    }

    expect(coveredWorlds, Set<int>.from(List<int>.generate(10, (i) => i + 1)));
    expect(successCount + blockedCount, pointers.length);
    expect(successCount, greaterThanOrEqualTo(22));

    final sortedCodes = blockedByCode.entries.toList()
      ..sort((a, b) {
        final diff = b.value.compareTo(a.value);
        if (diff != 0) {
          return diff;
        }
        return a.key.compareTo(b.key);
      });

    if (sortedCodes.isEmpty) {
      print('interop smoke top violation: none');
    } else {
      final top = sortedCodes.first;
      final blocked = blockedPointers[top.key] ?? const <String>[];
      print(
        'interop smoke top violation: ${top.key} count=${top.value} '
        'pointers=${blocked.join(",")}',
      );
      expect(_allowedInteropViolationCodesV1.contains(top.key), isTrue);
    }
  });
}

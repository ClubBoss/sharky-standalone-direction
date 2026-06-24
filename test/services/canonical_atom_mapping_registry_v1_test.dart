import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/canonical_atom_mapping_registry_v1.dart';

void main() {
  const registry = CanonicalAtomMappingRegistryV1();

  CanonicalAtomMappingInputV1 mappingInput({
    required String sourceFamily,
    required String sourceWorld,
    required String sourceSessionId,
    required String exactTargetId,
    required String signalFamilyId,
  }) {
    return CanonicalAtomMappingInputV1(
      sourceFamily: sourceFamily,
      sourceWorld: sourceWorld,
      sourceSessionId: sourceSessionId,
      exactTargetId: exactTargetId,
      signalFamilyId: signalFamilyId,
    );
  }

  test('unknown W5 board-texture tuple remains explicitly unmapped', () {
    final atomId = registry.resolve(
      mappingInput(
        sourceFamily: 'w5_session_drill',
        sourceWorld: 'world_5',
        sourceSessionId: 'w5.s01',
        exactTargetId: 'classify_texture_intro_dry_raise_v1',
        signalFamilyId: 'board_texture_dry',
      ),
    );

    expect(atomId, isNull);
  });

  test('unknown W6 range-bucket tuple remains explicitly unmapped', () {
    final atomId = registry.resolve(
      mappingInput(
        sourceFamily: 'w6_session_drill',
        sourceWorld: 'world_6',
        sourceSessionId: 'w6.s01',
        exactTargetId: 'classify_missed_fold_recheck',
        signalFamilyId: 'range_bucket_missed',
      ),
    );

    expect(atomId, isNull);
  });

  test('source tuple, not similar board wording, controls mapping', () {
    final w5BoardTexture = mappingInput(
      sourceFamily: 'w5_session_drill',
      sourceWorld: 'world_5',
      sourceSessionId: 'w5.s01',
      exactTargetId: 'classify_texture_intro_dry_raise_v1',
      signalFamilyId: 'board_texture_dry',
    );
    final act0BoardRead = mappingInput(
      sourceFamily: 'act0_first_value',
      sourceWorld: 'world_1',
      sourceSessionId: 'act0',
      exactTargetId: 'board_read_target',
      signalFamilyId: 'board_cards',
    );

    expect(registry.resolve(w5BoardTexture), isNull);
    expect(registry.resolve(act0BoardRead), isNull);
  });

  test('same signal family with a different source tuple remains unmapped', () {
    final approvedLookingTuple = mappingInput(
      sourceFamily: 'w6_session_drill',
      sourceWorld: 'world_6',
      sourceSessionId: 'w6.s01',
      exactTargetId: 'classify_missed_fold_recheck',
      signalFamilyId: 'range_bucket_missed',
    );
    final differentTarget = mappingInput(
      sourceFamily: 'w6_session_drill',
      sourceWorld: 'world_6',
      sourceSessionId: 'w6.s01',
      exactTargetId: 'classify_missed_fold',
      signalFamilyId: 'range_bucket_missed',
    );

    expect(registry.resolve(approvedLookingTuple), isNull);
    expect(registry.resolve(differentTarget), isNull);
  });
}

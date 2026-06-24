import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/canonical_atom_mapping_registry_v1.dart';
import 'package:poker_analyzer/services/canonical_source_target_metadata_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';

void main() {
  const catalog = CanonicalSourceTargetMetadataCatalogV1();

  CanonicalAtomMappingInputV1 input({
    required String sourceFamily,
    required String sourceWorld,
    required String sourceSessionId,
    required String exactTargetId,
    required String signalFamilyId,
  }) => CanonicalAtomMappingInputV1(
    sourceFamily: sourceFamily,
    sourceWorld: sourceWorld,
    sourceSessionId: sourceSessionId,
    exactTargetId: exactTargetId,
    signalFamilyId: signalFamilyId,
  );

  test('known W5 source target carries the reviewed full tuple', () {
    final metadata = catalog.resolve(
      input(
        sourceFamily: 'w5_session_drill',
        sourceWorld: 'world_5',
        sourceSessionId: 'w5.s01',
        exactTargetId: 'classify_texture_intro_dry_raise_v1',
        signalFamilyId: 'board_texture_dry',
      ),
    );

    expect(metadata, isNotNull);
    expect(metadata!.sourceFamily, 'w5_session_drill');
    expect(metadata.sourceWorld, 'world_5');
    expect(metadata.sourceSessionId, 'w5.s01');
    expect(metadata.exactTargetId, 'classify_texture_intro_dry_raise_v1');
    expect(metadata.signalFamilyId, 'board_texture_dry');
    expect(metadata.expectedActionId, 'raise');
    expect(metadata.context, 'recheck');
  });

  test('known W5 source target keeps canonical atom null without proof', () {
    final metadata = catalog.resolve(
      input(
        sourceFamily: 'w5_session_drill',
        sourceWorld: 'world_5',
        sourceSessionId: 'w5.s01',
        exactTargetId: 'classify_texture_intro_dry_raise_v1',
        signalFamilyId: 'board_texture_dry',
      ),
    );

    expect(metadata!.canonicalAtomId, isNull);
  });

  test(
    'reviewed W5 and W6 classifier targets expand with null canonical IDs',
    () {
      final cases =
          <
            ({
              String sourceFamily,
              String sourceWorld,
              String exactTargetId,
              String signalFamilyId,
              String expectedActionId,
            })
          >[
            (
              sourceFamily: 'w5_session_drill',
              sourceWorld: 'world_5',
              exactTargetId: 'classify_texture_intro_wet_call_v1',
              signalFamilyId: 'board_texture_wet',
              expectedActionId: 'call',
            ),
            (
              sourceFamily: 'w5_session_drill',
              sourceWorld: 'world_5',
              exactTargetId: 'classify_texture_intro_paired_fold_v1',
              signalFamilyId: 'board_texture_paired',
              expectedActionId: 'fold',
            ),
            (
              sourceFamily: 'w6_session_drill',
              sourceWorld: 'world_6',
              exactTargetId: 'classify_strong_call_control',
              signalFamilyId: 'range_bucket_strong',
              expectedActionId: 'call',
            ),
            (
              sourceFamily: 'w6_session_drill',
              sourceWorld: 'world_6',
              exactTargetId: 'classify_strong_raise',
              signalFamilyId: 'range_bucket_strong',
              expectedActionId: 'raise',
            ),
            (
              sourceFamily: 'w6_session_drill',
              sourceWorld: 'world_6',
              exactTargetId: 'classify_medium_call_control',
              signalFamilyId: 'range_bucket_medium',
              expectedActionId: 'call',
            ),
            (
              sourceFamily: 'w6_session_drill',
              sourceWorld: 'world_6',
              exactTargetId: 'classify_weak_fold_pressure',
              signalFamilyId: 'range_bucket_weak',
              expectedActionId: 'fold',
            ),
            (
              sourceFamily: 'w6_session_drill',
              sourceWorld: 'world_6',
              exactTargetId: 'classify_missed_fold',
              signalFamilyId: 'range_bucket_missed',
              expectedActionId: 'fold',
            ),
          ];

      for (final entry in cases) {
        final metadata = catalog.resolve(
          input(
            sourceFamily: entry.sourceFamily,
            sourceWorld: entry.sourceWorld,
            sourceSessionId: 'w${entry.sourceWorld.substring(6)}.s01',
            exactTargetId: entry.exactTargetId,
            signalFamilyId: entry.signalFamilyId,
          ),
        );

        expect(metadata, isNotNull, reason: entry.exactTargetId);
        expect(metadata!.canonicalAtomId, isNull);
        expect(metadata.machineCueId, entry.signalFamilyId);
        expect(metadata.expectedActionId, entry.expectedActionId);
        expect(metadata.downgradeScope, 'source_local');
        expect(metadata.evidenceConfidence, 'source_proven');
      }
    },
  );

  test('machine cue identity is separate from learner display copy', () {
    final metadata = catalog.resolve(
      input(
        sourceFamily: 'w6_session_drill',
        sourceWorld: 'world_6',
        sourceSessionId: 'w6.s01',
        exactTargetId: 'classify_missed_fold_recheck',
        signalFamilyId: 'range_bucket_missed',
      ),
    );

    expect(metadata, isNotNull);
    expect(metadata!.machineCueId, 'range_bucket_missed');
    expect(metadata.learnerFacingClueName, 'Missed range bucket');
    expect(metadata.machineCueId, isNot(metadata.learnerFacingClueName));
    expect(metadata.expectedActionId, 'fold');
  });

  test('display clue changes do not participate in source-target identity', () {
    final tuple = input(
      sourceFamily: 'w6_session_drill',
      sourceWorld: 'world_6',
      sourceSessionId: 'w6.s01',
      exactTargetId: 'classify_missed_fold_recheck',
      signalFamilyId: 'range_bucket_missed',
    );

    const eventWithChangedClue = SessionDrillRetainedResultEventV1(
      schemaVersion: 1,
      eventId: 'event_w6_changed_clue',
      worldId: 'world_6',
      sourceSessionId: 'w6.s01',
      targetDrillId: 'classify_missed_fold_recheck',
      signalFamilyId: 'range_bucket_missed',
      learnerFacingClueName: 'Any replacement learner wording',
      targetKind: 'exact',
      selectedActionId: 'fold',
      expectedActionId: 'fold',
      result: 'success',
      context: 'recheck',
      sourceFamily: 'w6_session_drill',
      isRetainedForMasteryEvidence: true,
      sourceReceiptKey: 'receipt_w6_changed_clue',
    );

    final metadata = catalog.resolve(tuple);

    expect(metadata!.tupleKey, tuple.normalizedTupleKey);
    expect(metadata.learnerFacingClueName, isNotEmpty);
    expect(catalog.forRetainedResult(eventWithChangedClue), same(metadata));
  });

  test('unknown source target fails closed', () {
    expect(
      catalog.resolve(
        input(
          sourceFamily: 'w5_session_drill',
          sourceWorld: 'world_5',
          sourceSessionId: 'w5.s01',
          exactTargetId: 'unreviewed_target',
          signalFamilyId: 'board_texture_dry',
        ),
      ),
      isNull,
    );
  });

  test(
    'retained result event remains null canonical while metadata is readable',
    () {
      const event = SessionDrillRetainedResultEventV1(
        schemaVersion: 1,
        eventId: 'event_w6',
        worldId: 'world_6',
        sourceSessionId: 'w6.s01',
        targetDrillId: 'classify_missed_fold_recheck',
        skillAtomId: null,
        signalFamilyId: 'range_bucket_missed',
        learnerFacingClueName: 'A changed clue is display-only',
        targetKind: 'exact',
        selectedActionId: 'fold',
        expectedActionId: 'fold',
        result: 'success',
        context: 'recheck',
        sourceFamily: 'w6_session_drill',
        isRetainedForMasteryEvidence: true,
        sourceReceiptKey: 'receipt_w6',
      );

      expect(event.skillAtomId, isNull);
      expect(catalog.forRetainedResult(event)!.canonicalAtomId, isNull);
    },
  );
}

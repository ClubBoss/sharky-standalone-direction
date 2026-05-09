import 'package:poker_analyzer/engine_v2/audit/legacy_vs_engine_v2_parity_audit_v1.dart';
import 'package:test/test.dart';

import '../interop/worlds_pointer_matrix_v1_test_helper.dart';

const Set<String> _knownMismatchWhitelistV1 = <String>{};

void main() {
  test('legacy vs engine v2 parity audit over world1..10 pointer matrix', () {
    final pointers = buildWorldPointerMatrixV1()
        .map((pointer) {
          return CampaignPointerV1(
            packId: pointer.packId,
            worldId: pointer.worldId,
            beatIndex: pointer.beatIndex,
          );
        })
        .toList(growable: false);

    final result = runParityAuditV1(pointers: pointers);

    expect(result.total, 40);
    expect(result.compared, greaterThanOrEqualTo(30));
    expect(result.compared + result.skipped, result.total);

    final mismatchedPointerIds = result.mismatchDetails
        .map((detail) => detail.pointerId)
        .toSet();
    final unexpectedMismatches = mismatchedPointerIds.difference(
      _knownMismatchWhitelistV1,
    );
    expect(unexpectedMismatches, isEmpty);
    expect(
      result.mismatches,
      lessThanOrEqualTo(_knownMismatchWhitelistV1.length),
    );

    if (result.mismatchDetails.isNotEmpty) {
      final ordered = result.mismatchDetails.toList()
        ..sort((a, b) => a.pointerId.compareTo(b.pointerId));
      for (final detail in ordered) {
        print(
          'parity mismatch ${detail.pointerId}: '
          'legacy=${detail.legacy.verdict.name}/${detail.legacy.errorBucket.name} '
          'engine_v2=${detail.engineV2.verdict.name}/${detail.engineV2.errorBucket.name}',
        );
      }
    }

    if (result.skipDetails.isNotEmpty) {
      final orderedSkips = result.skipDetails.toList()
        ..sort((a, b) => a.pointerId.compareTo(b.pointerId));
      for (final skip in orderedSkips) {
        print(
          'parity skip ${skip.pointerId}: ${skip.reasonCode} ${skip.reason}',
        );
      }
    }
  });
}

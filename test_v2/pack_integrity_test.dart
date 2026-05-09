import 'package:test/test.dart';
// ignore: unused_import
import 'package:poker_analyzer/ui/flutter_stub_test.dart'
    if (dart.library.ui) 'package:flutter/material.dart';
import 'package:poker_analyzer/ui/training_pack_template_v2_test_api.dart'
    if (dart.library.ui) 'package:poker_analyzer/ui/training_pack_template_v2_test_api_flutter.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';

void main() {
  group('Pack integrity', () {
    test('declared packs validate successfully', () {
      final packs = declaredStubPacks();
      expect(packs, isNotEmpty, reason: 'Stub packs should not be empty.');

      final allowedKinds = SpotKind.values.toSet();

      for (final pack in packs) {
        expect(
          pack.meta['id'],
          equals(pack.id),
          reason: '${pack.id} meta id mismatch',
        );
        expect(
          pack.spots.length,
          greaterThan(0),
          reason: '${pack.id} must have spots',
        );
        expect(pack.validate(), isTrue, reason: '${pack.id} failed validation');

        for (final spot in pack.spots) {
          expect(
            allowedKinds.contains(spot.kind),
            isTrue,
            reason: '${spot.kind} should exist in SpotKind enum',
          );
        }
      }
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/w11_campaign_fixture_projection_v1.dart';
import 'package:poker_analyzer/campaign/w11_route_admission_contract_v1.dart';
import 'package:poker_analyzer/campaign/w11_route_backed_proof_registry_v1.dart';

const _fixturePath =
    'content/worlds/world11/v1/sessions/w11.s01/campaign/'
    'w11.s01_campaign_fixture_v1.json';
const _proofRegistryPath =
    'lib/campaign/w11_route_backed_proof_registry_v1.dart';

void main() {
  test(
    'W11 route-backed proof registers source-owned beats without learner visibility',
    () {
      final decoded = jsonDecode(File(_fixturePath).readAsStringSync());
      expect(decoded, isA<Map<String, Object?>>());
      if (decoded is! Map<String, Object?>) return;

      final projected = projectW11CampaignFixtureV1(decoded);
      final admissionBeats = buildW11RouteAdmissionBeatsV1(projected);
      final proof = buildW11RouteBackedProofV1(admissionBeats);

      expect(proof.routeId, 'w11_source_route_proof_v1');
      expect(proof.worldId, 'world11');
      expect(proof.sessionId, 'w11.s01');
      expect(proof.learnerVisible, isFalse);
      expect(proof.w10HandoffEnabled, isFalse);
      expect(proof.beats, admissionBeats);
      expect(proof.beats, hasLength(6));
      expect(proof.beats.first.routeBeatId, 'world11.w11.s01.w11.s01.r01');
      expect(proof.beats.last.routeBeatId, 'world11.w11.s01.w11.s01.r06');

      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world11_')),
        isEmpty,
        reason: 'W11 proof must not register an active campaign pack.',
      );

      final registrySource = File(
        _proofRegistryPath,
      ).readAsStringSync().toLowerCase();
      for (final forbidden in const <String>[
        'microtaskstep',
        'progress_service.dart',
        'ui_v2/',
        'world10',
        'world12',
        'world13',
      ]) {
        expect(
          registrySource,
          isNot(contains(forbidden)),
          reason: 'W11 route proof registry must not depend on $forbidden.',
        );
      }
    },
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/w12_campaign_fixture_projection_v1.dart';
import 'package:poker_analyzer/campaign/w12_route_admission_contract_v1.dart';
import 'package:poker_analyzer/campaign/w12_route_backed_proof_registry_v1.dart';

const _fixturePath =
    'content/worlds/world12/v1/sessions/w12.s01/campaign/'
    'w12.s01_campaign_fixture_v1.json';
const _proofRegistryPath =
    'lib/campaign/w12_route_backed_proof_registry_v1.dart';

void main() {
  test(
    'W12 route-backed proof registers source-owned beats with learner visibility',
    () {
      final decoded = jsonDecode(File(_fixturePath).readAsStringSync());
      expect(decoded, isA<Map<String, Object?>>());
      if (decoded is! Map<String, Object?>) return;

      final projected = projectW12CampaignFixtureV1(decoded);
      final admissionBeats = buildW12RouteAdmissionBeatsV1(projected);
      final proof = buildW12RouteBackedProofV1(admissionBeats);

      expect(proof.routeId, 'w12_source_route_proof_v1');
      expect(proof.worldId, 'world12');
      expect(proof.sessionId, 'w12.s01');
      expect(proof.learnerVisible, isTrue);
      expect(proof.w11HandoffEnabled, isTrue);
      expect(proof.beats, admissionBeats);
      expect(proof.beats, hasLength(6));
      expect(proof.beats.first.routeBeatId, 'world12.w12.s01.w12.s01.r01');
      expect(proof.beats.last.routeBeatId, 'world12.w12.s01.w12.s01.r06');

      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world12_')).toSet(),
        const <String>{
          'world12_spine_campaign_v1',
          'world12_spine_followup_v1_b0',
          'world12_spine_followup_v1_b1',
          'world12_spine_followup_v1_b2',
        },
        reason: 'W12 proof must match admitted route packs.',
      );
      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world13_')),
        isEmpty,
        reason: 'W12 proof must not register W13 packs.',
      );

      final registrySource = File(
        _proofRegistryPath,
      ).readAsStringSync().toLowerCase();
      for (final forbidden in const <String>[
        'microtaskstep',
        'progress_service.dart',
        'ui_v2/',
        'world10',
        'world11',
        'world13',
      ]) {
        expect(
          registrySource,
          isNot(contains(forbidden)),
          reason: 'W12 route proof registry must not depend on $forbidden.',
        );
      }
    },
  );
}

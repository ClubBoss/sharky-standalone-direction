import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/w10_to_w11_transition_policy_v1.dart';
import 'package:poker_analyzer/campaign/w11_route_backed_proof_registry_v1.dart';

const _policyPath = 'lib/campaign/w10_to_w11_transition_policy_v1.dart';
const _progressServicePath = 'lib/services/progress_service.dart';

void main() {
  test(
    'W10 to W11 transition policy enables handoff without W12 or W13 unlock',
    () {
      const proof = W11RouteBackedProofV1(
        routeId: kW11SourceRouteProofIdV1,
        worldId: 'world11',
        sessionId: 'w11.s01',
        beats: [],
        learnerVisible: true,
        w10HandoffEnabled: true,
      );

      final policy = buildW10ToW11TransitionPolicyV1(proof);

      expect(policy.sourceTerminalPackId, 'world10_spine_followup_v1_b2');
      expect(policy.targetRouteProofId, kW11SourceRouteProofIdV1);
      expect(policy.activeHandoffEnabled, isTrue);
      expect(policy.requiresLearnerVisibleW11, isTrue);
      expect(policy.requiresRuntimeConsumption, isFalse);
      expect(policy.impliesVolumeICompletion, isFalse);
      expect(policy.allowsW13Unlock, isFalse);
      expect(policy.descriptorOnly, isFalse);

      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world11_')).toSet(),
        const <String>{
          'world11_spine_campaign_v1',
          'world11_spine_followup_v1_b0',
          'world11_spine_followup_v1_b1',
          'world11_spine_followup_v1_b2',
        },
        reason: 'Transition policy must point at admitted W11 campaign packs.',
      );
      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world12_')),
        isEmpty,
        reason: 'Transition policy must not add active W12 campaign packs.',
      );

      final progressSource = File(_progressServicePath).readAsStringSync();
      expect(
        progressSource,
        isNot(contains(kW11SourceRouteProofIdV1)),
        reason: 'Transition policy must not wire ProgressService by proof id.',
      );

      final policySource = File(_policyPath).readAsStringSync().toLowerCase();
      for (final forbidden in const <String>[
        'progress_service.dart',
        'ui_v2/',
        'world12',
        'world13',
        'mastery',
        'leak',
      ]) {
        expect(
          policySource,
          isNot(contains(forbidden)),
          reason: 'Transition policy descriptor must not depend on $forbidden.',
        );
      }
    },
  );
}

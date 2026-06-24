import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/w12_route_backed_proof_registry_v1.dart';
import 'package:poker_analyzer/campaign/w12_volume_i_admission_policy_v1.dart';

const _learnPathShellPath =
    'lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
const _policyPath = 'lib/campaign/w12_volume_i_admission_policy_v1.dart';
const _progressServicePath = 'lib/services/progress_service.dart';

void main() {
  test(
    'W12 Volume I admission stays planned-visible with entry and handoff disabled',
    () {
      const proof = W12RouteBackedProofV1(
        routeId: kW12SourceRouteProofIdV1,
        worldId: 'world12',
        sessionId: 'w12.s01',
        beats: [],
        learnerVisible: false,
        w11HandoffEnabled: false,
      );

      final policy = buildW12VolumeIAdmissionPolicyV1(proof);

      expect(
        policy.state,
        W12VolumeIAdmissionStateV1.plannedContinuationHandoffDisabled,
      );
      expect(policy.routeProofId, kW12SourceRouteProofIdV1);
      expect(policy.surfaceOwner, 'Act0LearnPathShellV1');
      expect(
        policy.surfaceCopyKey,
        'act0_shell_levels_planned_foundation_line',
      );
      expect(policy.learnerVisibleAsPlannedContinuation, isTrue);
      expect(policy.activeEntryEnabled, isFalse);
      expect(policy.w11HandoffEnabled, isFalse);
      expect(policy.runtimeConsumptionEnabled, isFalse);
      expect(policy.requiresRuntimeConsumptionBeforeActiveEntry, isTrue);
      expect(policy.w13FrontierOnly, isTrue);
      expect(policy.impliesVolumeICompletion, isFalse);
      expect(policy.allowsPremiumOrPaywallClaim, isFalse);
      expect(policy.allowsAiMasteryOrLeakClaim, isFalse);

      final learnSurface = File(_learnPathShellPath).readAsStringSync();
      expect(
        learnSurface,
        contains('W11-W12 planned foundation chapters, coming later.'),
      );
      expect(learnSurface, contains(policy.surfaceCopyKey));
      for (final forbidden in const <String>[
        'Unlock W13',
        'Finish Volume I now',
        'Volume I complete',
        'Premium preview',
        'See what premium adds',
      ]) {
        expect(learnSurface, isNot(contains(forbidden)));
      }

      final progressSource = File(_progressServicePath).readAsStringSync();
      expect(
        progressSource,
        isNot(contains(kW12SourceRouteProofIdV1)),
        reason: 'W12 admission policy must not wire active progression.',
      );

      final policySource = File(_policyPath).readAsStringSync().toLowerCase();
      for (final forbidden in const <String>[
        'progress_service.dart',
        'ui_v2/',
        'world11',
        'world13',
      ]) {
        expect(
          policySource,
          isNot(contains(forbidden)),
          reason: 'Admission policy descriptor must not depend on $forbidden.',
        );
      }
    },
  );
}

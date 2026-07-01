import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/w11_campaign_fixture_projection_v1.dart';
import 'package:poker_analyzer/campaign/w11_route_admission_contract_v1.dart';

const _fixturePath =
    'content/worlds/world11/v1/sessions/w11.s01/campaign/'
    'w11.s01_campaign_fixture_v1.json';
const _contractPath = 'lib/campaign/w11_route_admission_contract_v1.dart';

void main() {
  test(
    'W11 source route contract preserves projection fields with registry admission',
    () {
      final decoded = jsonDecode(File(_fixturePath).readAsStringSync());
      expect(decoded, isA<Map<String, Object?>>());
      if (decoded is! Map<String, Object?>) return;

      final projected = projectW11CampaignFixtureV1(decoded);
      final beats = buildW11RouteAdmissionBeatsV1(projected);

      expect(beats, hasLength(projected.length));
      expect(beats.map((beat) => beat.routeBeatId), const <String>[
        'world11.w11.s01.w11.s01.r01',
        'world11.w11.s01.w11.s01.r02',
        'world11.w11.s01.w11.s01.r03',
        'world11.w11.s01.w11.s01.r04',
        'world11.w11.s01.w11.s01.r05',
        'world11.w11.s01.w11.s01.r06',
      ]);

      for (var i = 0; i < projected.length; i++) {
        final source = projected[i];
        final beat = beats[i];

        expect(beat.worldId, source.worldId);
        expect(beat.sessionId, source.sessionId);
        expect(beat.repId, source.repId);
        expect(beat.sourceRef, source.sourceRef);
        expect(beat.visibleState, source.visibleState);
        expect(beat.learnerPrompt, source.learnerPrompt);
        expect(beat.legalChoices, source.legalChoices);
        expect(beat.expectedAnswer, source.expectedAnswer);
        expect(beat.targetSkillId, source.targetSkillId);
        expect(beat.errorType, source.errorType);
        expect(beat.correctFeedback, source.correctFeedback);
        expect(beat.incorrectFeedback, source.incorrectFeedback);
        expect(beat.repairCue, source.repairCue);
        expect(beat.telemetryInputs, source.telemetryInputs);
      }

      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world11_')).toSet(),
        const <String>{
          'world11_spine_campaign_v1',
          'world11_spine_followup_v1_b0',
          'world11_spine_followup_v1_b1',
          'world11_spine_followup_v1_b2',
        },
        reason: 'The W11 route contract now has admitted learner packs.',
      );
      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world12_')),
        isEmpty,
        reason: 'W11 admission must not register W12 packs.',
      );

      final contractSource = File(
        _contractPath,
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
          contractSource,
          isNot(contains(forbidden)),
          reason: 'W11 route contract must not depend on $forbidden.',
        );
      }
    },
  );
}

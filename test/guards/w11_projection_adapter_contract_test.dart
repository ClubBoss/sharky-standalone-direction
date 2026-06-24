import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/w11_campaign_fixture_projection_v1.dart';

const _fixturePath =
    'content/worlds/world11/v1/sessions/w11.s01/campaign/'
    'w11.s01_campaign_fixture_v1.json';
const _adapterPath = 'lib/campaign/w11_campaign_fixture_projection_v1.dart';

void main() {
  test(
    'W11 fixture projects six source-owned reps without route admission',
    () {
      final fixtureFile = File(_fixturePath);
      expect(fixtureFile.existsSync(), isTrue);
      if (!fixtureFile.existsSync()) return;

      final decoded = jsonDecode(fixtureFile.readAsStringSync());
      expect(decoded, isA<Map<String, Object?>>());
      if (decoded is! Map<String, Object?>) return;

      final projected = projectW11CampaignFixtureV1(decoded);

      expect(projected, hasLength(6));
      expect(projected.map((rep) => rep.repId), const <String>[
        'w11.s01.r01',
        'w11.s01.r02',
        'w11.s01.r03',
        'w11.s01.r04',
        'w11.s01.r05',
        'w11.s01.r06',
      ]);

      for (final rep in projected) {
        expect(rep.worldId, 'world11');
        expect(rep.sessionId, 'w11.s01');
        expect(rep.sourceRef, startsWith('session.md#scenario-rep-'));
        expect(rep.legalChoices, const <String>['continue', 'fold']);
        expect(rep.legalChoices, contains(rep.expectedAnswer));
        expect(rep.errorType, isNotEmpty);
        expect(rep.repairCue, isNotEmpty);
        expect(rep.correctFeedback, isNotEmpty);
        expect(rep.incorrectFeedback, isNotEmpty);
        expect(rep.telemetryInputs, contains('user_choice'));
        expect(rep.telemetryInputs, contains('correct_or_incorrect'));
        expect(rep.telemetryInputs, contains('error_type'));
        expect(rep.telemetryInputs, contains('time_to_decision'));
        expect(
          rep.telemetryInputs.last,
          '${rep.worldId}/${rep.sessionId}/${rep.repId}',
        );
      }

      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world11_')),
        isEmpty,
        reason: 'Projection must not add a W11 campaign registration.',
      );

      final adapter = File(_adapterPath).readAsStringSync().toLowerCase();
      for (final forbiddenImport in const <String>[
        'canonical/',
        'progress_service.dart',
        'ui_v2/',
        'world10',
        'world12',
        'world13',
      ]) {
        expect(
          adapter,
          isNot(contains(forbiddenImport)),
          reason: 'Projection must not depend on $forbiddenImport.',
        );
      }
    },
  );
}

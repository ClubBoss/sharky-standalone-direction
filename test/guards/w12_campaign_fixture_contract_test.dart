import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

const _packetPath =
    'content/worlds/world12/v1/sessions/w12.s01/'
    'w12.s01_deterministic_source_packet_v1.md';
const _fixturePath =
    'content/worlds/world12/v1/sessions/w12.s01/campaign/'
    'w12.s01_campaign_fixture_v1.json';

void main() {
  test(
    'W12 campaign fixture preserves the six non-routed source packet reps',
    () {
      final packetFile = File(_packetPath);
      final fixtureFile = File(_fixturePath);

      expect(packetFile.existsSync(), isTrue);
      expect(fixtureFile.existsSync(), isTrue);
      if (!packetFile.existsSync() || !fixtureFile.existsSync()) return;

      final packet = packetFile.readAsStringSync();
      final decoded = jsonDecode(fixtureFile.readAsStringSync());
      expect(decoded, isA<Map<String, Object?>>());
      if (decoded is! Map<String, Object?>) return;

      expect(decoded['world_id'], 'world12');
      expect(decoded['session_id'], 'w12.s01');
      final reps = decoded['reps'];
      expect(reps, isA<List<Object?>>());
      if (reps is! List<Object?>) return;
      expect(reps, hasLength(6));

      const repIds = <String>[
        'w12.s01.r01',
        'w12.s01.r02',
        'w12.s01.r03',
        'w12.s01.r04',
        'w12.s01.r05',
        'w12.s01.r06',
      ];
      expect(
        reps.map((rep) => (rep as Map<String, Object?>)['rep_id']),
        repIds,
      );

      for (final rawRep in reps) {
        expect(rawRep, isA<Map<String, Object?>>());
        if (rawRep is! Map<String, Object?>) continue;
        final repId = rawRep['rep_id'] as String;
        for (final field in const <String>[
          'world_id',
          'session_id',
          'rep_id',
          'source_ref',
          'visible_state',
          'learner_prompt',
          'legal_choices',
          'expected_answer',
          'target_skill_id',
          'error_type',
          'correct_feedback',
          'incorrect_feedback',
          'repair_cue',
          'telemetry_inputs',
        ]) {
          expect(rawRep[field], isNotNull, reason: '$repId missing $field');
        }
        for (final field in const <String>[
          'world_id',
          'session_id',
          'source_ref',
          'visible_state',
          'learner_prompt',
          'expected_answer',
          'target_skill_id',
          'error_type',
          'correct_feedback',
          'incorrect_feedback',
          'repair_cue',
        ]) {
          expect(rawRep[field], _packetField(packet, repId, field));
        }

        final legalChoices = rawRep['legal_choices'];
        expect(legalChoices, isA<List<Object?>>());
        if (legalChoices is! List<Object?>) continue;
        expect(legalChoices, hasLength(2));
        expect(
          legalChoices,
          _packetField(packet, repId, 'legal_choices').split(' | '),
        );
        expect(
          legalChoices,
          contains(rawRep['expected_answer']),
          reason: '$repId expected answer must be a legal choice',
        );
        expect(rawRep['target_skill_id'], isNotEmpty);
        expect(rawRep['error_type'], isNotEmpty);
        expect(
          rawRep['telemetry_inputs'],
          _packetField(packet, repId, 'telemetry_inputs').split(' | '),
        );
      }

      final normalized = fixtureFile.readAsStringSync().toLowerCase();
      for (final forbidden in <RegExp>[
        RegExp(r'\bw13\b'),
        RegExp(r'\bpremium\b'),
        RegExp(r'\bpaid\b'),
        RegExp(r'\bpaywall\b'),
        RegExp(r'\btrial\b'),
        RegExp(r'\bunlock\b'),
        RegExp(r'volume i complete'),
        RegExp(r'\bsolver\b'),
        RegExp(r'\bgto\b'),
        RegExp(r'\bai\b'),
        RegExp(r'\badaptive\b'),
        RegExp(r'\bmastery\b'),
        RegExp(r'\bleak\b'),
        RegExp(r'\bspecialization\b'),
      ]) {
        expect(
          normalized,
          isNot(contains(forbidden)),
          reason: forbidden.pattern,
        );
      }

      expect(
        kCampaignPackIdsV1.where((id) => id.startsWith('world12_')),
        isEmpty,
        reason: 'The fixture must not create a W12 campaign registration.',
      );
    },
  );
}

String _packetField(String packet, String repId, String field) {
  final header = '## Rep $repId\n';
  final start = packet.indexOf(header);
  expect(start, isNonNegative, reason: 'Missing packet rep $repId');
  final next = packet.indexOf('\n## Rep ', start + header.length);
  final section = packet.substring(start, next < 0 ? packet.length : next);
  final fieldMatch = RegExp(
    r'^- ' + RegExp.escape(field) + r': (.+)$',
    multiLine: true,
  ).firstMatch(section);
  expect(fieldMatch, isNotNull, reason: 'Missing $field in packet $repId');
  return fieldMatch!.group(1)!;
}

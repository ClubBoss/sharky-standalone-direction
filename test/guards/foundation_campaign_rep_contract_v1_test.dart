import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

const _contractPath = 'docs/_reviews/foundation_campaign_rep_contract_v1.md';
const _packetPath =
    'content/worlds/world11/v1/sessions/w11.s01/'
    'w11.s01_deterministic_source_packet_v1.md';

void main() {
  test('foundation campaign contract defines every shared rep field', () {
    final contractFile = File(_contractPath);
    expect(contractFile.existsSync(), isTrue);
    if (!contractFile.existsSync()) return;
    final contract = contractFile.readAsStringSync();

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
      expect(contract, contains('`$field`'));
    }
  });

  test('W11 packet has six complete non-routed foundation reps', () {
    final packetFile = File(_packetPath);
    const sessionPath = 'content/worlds/world11/v1/sessions/w11.s01/session.md';
    expect(packetFile.existsSync(), isTrue);
    if (!packetFile.existsSync()) return;
    final sessionFile = File(sessionPath);
    expect(sessionFile.existsSync(), isTrue);
    if (!sessionFile.existsSync()) return;
    final packet = packetFile.readAsStringSync();
    final session = sessionFile.readAsStringSync().toLowerCase();
    final repMatches = RegExp(
      r'^## Rep (w11\.s01\.r0[1-6])$',
      multiLine: true,
    ).allMatches(packet).toList(growable: false);

    expect(repMatches.map((match) => match.group(1)), const <String>[
      'w11.s01.r01',
      'w11.s01.r02',
      'w11.s01.r03',
      'w11.s01.r04',
      'w11.s01.r05',
      'w11.s01.r06',
    ]);

    for (var index = 0; index < repMatches.length; index++) {
      final start = repMatches[index].start;
      final end = index + 1 < repMatches.length
          ? repMatches[index + 1].start
          : packet.length;
      final rep = packet.substring(start, end);
      for (final field in const <String>[
        'world_id:',
        'session_id:',
        'rep_id:',
        'source_ref:',
        'visible_state:',
        'learner_prompt:',
        'legal_choices:',
        'expected_answer:',
        'target_skill_id:',
        'error_type:',
        'correct_feedback:',
        'incorrect_feedback:',
        'repair_cue:',
        'telemetry_inputs:',
      ]) {
        expect(
          rep,
          contains(field),
          reason: 'Missing $field in rep ${index + 1}',
        );
      }
      expect(rep, contains('continue | fold'));
      expect(
        session,
        contains('### scenario rep ${index + 1}'),
        reason: 'source_ref must resolve to an authored W11 scenario anchor',
      );
    }

    expect(packet, contains('expected_answer: fold'), reason: 'Need fold reps');
    expect(
      RegExp(r'expected_answer: fold').allMatches(packet).length,
      greaterThanOrEqualTo(2),
    );
    expect(
      RegExp(r'expected_answer: continue').allMatches(packet).length,
      greaterThanOrEqualTo(2),
    );

    final normalized = packet.toLowerCase();
    for (final forbidden in <RegExp>[
      RegExp(r'\bw12\b'),
      RegExp(r'\bw13\b'),
      RegExp(r'\bpremium\b'),
      RegExp(r'\bpaid\b'),
      RegExp(r'\bunlock\b'),
      RegExp(r'volume i complete'),
      RegExp(r'\bsolver\b'),
      RegExp(r'\bgto\b'),
      RegExp(r'\bai\b'),
      RegExp(r'\bmastery\b'),
      RegExp(r'\bleak\b'),
    ]) {
      expect(normalized, isNot(contains(forbidden)), reason: forbidden.pattern);
    }

    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world11_')),
      isEmpty,
      reason: 'The source packet must not create a W11 campaign registration.',
    );
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

const _root = 'content/worlds/world12/v1';
const _sessionPath = '$_root/sessions/w12.s01/session.md';
const _packetPath =
    '$_root/sessions/w12.s01/w12.s01_deterministic_source_packet_v1.md';

void main() {
  test('W12 source draft has one structured non-routed mindset session', () {
    expect(File('$_root/world.md').existsSync(), isTrue);
    expect(File('$_root/index.md').existsSync(), isTrue);
    expect(File('$_root/sessions/index.md').existsSync(), isTrue);
    expect(File('$_root/sessions/w12.s01/notes.md').existsSync(), isTrue);

    final session = File(_sessionPath).readAsStringSync();
    for (final heading in const <String>[
      '# Session w12.s01',
      '## Objective',
      '## Scenario',
      '## Decision',
      '## Explanation',
    ]) {
      expect(session, contains(heading));
    }

    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world12_')),
      isEmpty,
      reason: 'The active source draft must not register W12 as a campaign.',
    );
  });

  test('W12 packet has six complete deterministic source reps', () {
    final packetFile = File(_packetPath);
    final sessionFile = File(_sessionPath);
    expect(packetFile.existsSync(), isTrue);
    expect(sessionFile.existsSync(), isTrue);
    if (!packetFile.existsSync() || !sessionFile.existsSync()) return;

    final packet = packetFile.readAsStringSync();
    final session = sessionFile.readAsStringSync().toLowerCase();
    final repMatches = RegExp(
      r'^## Rep (w12\.s01\.r0[1-6])$',
      multiLine: true,
    ).allMatches(packet).toList(growable: false);

    expect(repMatches.map((match) => match.group(1)), const <String>[
      'w12.s01.r01',
      'w12.s01.r02',
      'w12.s01.r03',
      'w12.s01.r04',
      'w12.s01.r05',
      'w12.s01.r06',
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

      final legalChoices = _packetField(rep, 'legal_choices').split(' | ');
      final expectedAnswer = _packetField(rep, 'expected_answer');
      expect(legalChoices, hasLength(2));
      expect(legalChoices, contains(expectedAnswer));
      expect(
        session,
        contains('### scenario rep ${index + 1}'),
        reason: 'source_ref must resolve to an authored W12 scenario anchor',
      );
    }

    final expectedAnswers = RegExp(
      r'^- expected_answer: (.+)$',
      multiLine: true,
    ).allMatches(packet).map((match) => match.group(1)).toSet();
    expect(expectedAnswers.length, greaterThanOrEqualTo(2));

    final normalized = '$packet\n${sessionFile.readAsStringSync()}'
        .toLowerCase();
    for (final forbidden in <RegExp>[
      RegExp(r'\bw13\b'),
      RegExp(r'\bpremium\b'),
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
      expect(normalized, isNot(contains(forbidden)), reason: forbidden.pattern);
    }
  });
}

String _packetField(String repSection, String field) {
  final fieldMatch = RegExp(
    r'^- ' + RegExp.escape(field) + r': (.+)$',
    multiLine: true,
  ).firstMatch(repSection);
  expect(fieldMatch, isNotNull, reason: 'Missing $field');
  return fieldMatch!.group(1)!;
}

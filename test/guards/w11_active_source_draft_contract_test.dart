import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  test('W11 source draft has one structured admitted transfer session', () {
    const root = 'content/worlds/world11/v1';
    const sessionPath = '$root/sessions/w11.s01/session.md';

    expect(File('$root/world.md').existsSync(), isTrue);
    expect(File('$root/index.md').existsSync(), isTrue);
    expect(File('$root/sessions/index.md').existsSync(), isTrue);
    expect(File('$root/sessions/w11.s01/notes.md').existsSync(), isTrue);

    final session = File(sessionPath).readAsStringSync();
    for (final heading in const <String>[
      '# Session w11.s01',
      '## Objective',
      '## Scenario',
      '## Decision',
      '## Explanation',
    ]) {
      expect(session, contains(heading));
    }

    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world11_')).toSet(),
      const <String>{
        'world11_spine_campaign_v1',
        'world11_spine_followup_v1_b0',
        'world11_spine_followup_v1_b1',
        'world11_spine_followup_v1_b2',
      },
      reason: 'The active source draft now coexists with admitted W11 packs.',
    );
    expect(
      kCampaignPackIdsV1.where((id) => id.startsWith('world12_')),
      isEmpty,
      reason: 'The active source draft must not register W12 as a campaign.',
    );
  });

  test('W11 transfer source keeps one price-first decision focus', () {
    const sessionPath = 'content/worlds/world11/v1/sessions/w11.s01/session.md';
    final session = File(sessionPath).readAsStringSync();

    expect(session, contains(RegExp(r'price\s+before continuing with a draw')));
    expect(session, isNot(contains('whether a value bet has a clear job')));
  });
}

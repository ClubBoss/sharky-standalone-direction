import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tools/validate_training_content.dart' as boundary;
import '../../tools/world_intents_ssot_v1.dart';
import '../../tools/why_v1_ssot_v1.dart';

void main() {
  const arcSessions = <String>[
    'w3.s01',
    'w3.s02',
    'w3.s03',
    'w3.s04',
    'w3.s05',
    'w3.s06',
    'w3.s07',
    'w3.s08',
    'w3.s09',
    'w3.s10',
    'w3.s11',
    'w3.s12',
    'w3.s13',
    'w3.s14',
  ];

  const stagedSessions = <String>{'w3.s01', 'w3.s02', 'w3.s03'};
  const tailSessions = <String>{'w3.s11', 'w3.s12', 'w3.s13', 'w3.s14'};
  const expectedChainFiles = <String, String>{
    'w3.s01': 'd.chain_preflop_framework_intro_v1.json',
    'w3.s02': 'd.chain_preflop_category_reuse_v1.json',
    'w3.s03': 'd.chain_preflop_checkpoint_v1.json',
    'w3.s04': 'd.chain_preflop_premium_strong_reps_v1.json',
    'w3.s05': 'd.chain_preflop_medium_weak_discipline_v1.json',
    'w3.s06': 'd.chain_preflop_mixed_context_checkpoint_v1.json',
    'w3.s07': 'd.chain_preflop_open_fold_position_v1.json',
    'w3.s08': 'd.chain_preflop_continue_fold_discipline_v1.json',
    'w3.s09': 'd.chain_preflop_same_hand_different_action_v1.json',
    'w3.s10': 'd.chain_preflop_final_checkpoint_v1.json',
    'w3.s11': 'd.chain_position_open_call_v1.json',
    'w3.s12': 'd.chain_position_continue_fold_v1.json',
    'w3.s13': 'd.chain_position_open_fold_v1.json',
    'w3.s14': 'd.chain_position_sensitive_open_fold_v1.json',
  };

  Map<String, dynamic> _readJson(String path) {
    return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  }

  test('World 3 preflop hand-chain arc converges validator-facing metadata', () {
    for (final sessionId in arcSessions) {
      final filePath =
          'content/worlds/world3/v1/sessions/$sessionId/drills/${expectedChainFiles[sessionId]!}';
      final json = _readJson(filePath);
      expect(json['intent_v1'], 'action_sequence', reason: filePath);
      expect(
        allowedIntentsV1ForSessionId(sessionId).contains(json['intent_v1']),
        isTrue,
        reason: filePath,
      );

      if (stagedSessions.contains(sessionId)) {
        expect(isRuntimeValidWhyV1V1(json['why_v1']), isTrue, reason: filePath);
      }

      if (tailSessions.contains(sessionId)) {
        final steps = json['steps'] as List<dynamic>;
        final firstStep = steps.first as Map<String, dynamic>;
        expect(firstStep['expected_action'], 'hero', reason: filePath);
        expect(
          firstStep['available_actions_v1'],
          equals(const <String>['hero', 'villain']),
          reason: filePath,
        );
        final notesPath =
            'content/worlds/world3/v1/sessions/$sessionId/notes.md';
        final notes = File(notesPath).readAsStringSync();
        expect(
          boundary.validateSharedCoreFormatBoundaryTextV1(
            filePath: notesPath,
            content: notes,
          ),
          isEmpty,
          reason: notesPath,
        );
      }
    }
  });

  test('validator no longer reports World 3 content-path failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('validate_world_content_v1: content/worlds/world3/'),
      isFalse,
      reason: combined,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart';

void main() {
  test('repair_same_clue_v1 renders accepted same-clue sentence', () {
    expect(
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'repair_same_clue_v1',
        clueLabel: 'No bet yet',
        skillLabel: 'Action read',
      ),
      'You missed that nobody has bet yet. This hand repeats that table clue.',
    );
  });

  test('repair_exact_replay_v1 renders accepted replay sentence', () {
    expect(
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'repair_exact_replay_v1',
        clueLabel: 'No bet yet',
        skillLabel: 'Action read',
      ),
      'Replay this spot to fix the no-bet-yet clue.',
    );
  });

  test('fallback_next_hand_v1 renders accepted fallback sentence', () {
    expect(
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'fallback_next_hand_v1',
        clueLabel: 'No bet yet',
        skillLabel: 'Action read',
      ),
      'Next hand: keep building Action read.',
    );
  });

  test('unknown template id does not render arbitrary copy', () {
    expect(
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'unknown_template',
        clueLabel: 'No bet yet',
        skillLabel: 'Action read',
      ),
      isNull,
    );
  });

  test('missing labels degrade safely without forbidden terms', () {
    final lines = <String?>[
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'repair_same_clue_v1',
        clueLabel: '',
        skillLabel: 'Action read',
      ),
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'repair_exact_replay_v1',
        clueLabel: '',
        skillLabel: 'Action read',
      ),
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'fallback_next_hand_v1',
        clueLabel: 'No bet yet',
        skillLabel: '',
      ),
    ];

    for (final line in lines) {
      expect(line, isNull);
      expect(_containsForbiddenToken(line ?? '', 'ai'), isFalse);
    }
  });

  test('rendered copy excludes forbidden terms', () {
    final lines = <String>[
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'repair_same_clue_v1',
        clueLabel: 'No bet yet',
        skillLabel: 'Action read',
      )!,
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'repair_exact_replay_v1',
        clueLabel: 'No bet yet',
        skillLabel: 'Action read',
      )!,
      act0RepairIntentCopyGuardLineV1(
        safeTemplateId: 'fallback_next_hand_v1',
        clueLabel: 'No bet yet',
        skillLabel: 'Action read',
      )!,
    ];
    const forbidden = <String>{
      'ai',
      'ml',
      'adaptive',
      'solver',
      'gto',
      'optimal',
      'win-rate',
      'guaranteed',
      'premium',
      'paywall',
      'trial',
      'purchase',
      'restore',
    };

    for (final line in lines) {
      expect(line.contains('You missed No bet yet'), isFalse);
      expect(line.contains('fix No bet yet'), isFalse);
      for (final token in forbidden) {
        expect(_containsForbiddenToken(line, token), isFalse, reason: token);
      }
    }
  });
}

bool _containsForbiddenToken(String text, String token) {
  final normalizedToken = token.toLowerCase();
  return text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9-]+'))
      .where((part) => part.isNotEmpty)
      .contains(normalizedToken);
}

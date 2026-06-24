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

  test('repair result receipt renders fixed and repeated same-signal copy', () {
    expect(
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: true,
        exactReplay: false,
        clueLabel: 'No bet yet',
      ),
      'Repair fixed: you caught the no-bet-yet clue.',
    );
    expect(
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: false,
        exactReplay: false,
        clueLabel: 'No bet yet',
      ),
      'Still missed: nobody had bet yet. One more repair hand will help.',
    );
  });

  test('repair result receipt renders exact replay copy', () {
    expect(
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: true,
        exactReplay: true,
        clueLabel: 'No bet yet',
      ),
      'Replay fixed: you handled this spot correctly.',
    );
    expect(
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: false,
        exactReplay: true,
        clueLabel: 'No bet yet',
      ),
      'Replay missed again: try the same spot once more.',
    );
  });

  test(
    'session repair summary renders fixed and repeated same-signal copy',
    () {
      expect(
        act0RepairSessionSummaryCopyGuardLinesV1(
          repaired: true,
          exactReplay: false,
          clueLabel: 'No bet yet',
        ),
        <String>['Today you repaired the no-bet-yet clue.'],
      );
      expect(
        act0RepairSessionSummaryCopyGuardLinesV1(
          repaired: false,
          exactReplay: false,
          clueLabel: 'No bet yet',
        ),
        <String>[
          'Still fragile: the no-bet-yet clue.',
          'Next focus: one more no-bet-yet repair hand.',
        ],
      );
    },
  );

  test('session repair summary renders exact replay copy', () {
    expect(
      act0RepairSessionSummaryCopyGuardLinesV1(
        repaired: true,
        exactReplay: true,
        clueLabel: 'No bet yet',
      ),
      isEmpty,
    );
    expect(
      act0RepairSessionSummaryCopyGuardLinesV1(
        repaired: false,
        exactReplay: true,
        clueLabel: 'No bet yet',
      ),
      isEmpty,
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

  test('review repair coach renders learner-facing, safe clue copy', () {
    expect(
      act0ReviewRepairCoachCopyGuardLinesV1(clueLabel: 'No bet yet'),
      <String>[
        'The no-bet-yet clue is still the one to fix.',
        'Next repair: one no-bet-yet hand',
      ],
    );
    expect(act0ReviewRepairCoachCopyGuardLinesV1(clueLabel: ''), isEmpty);
  });

  test('review repair coach normalizes first-week abstract labels', () {
    for (final abstractLabel in <String>['Legal actions', 'Meet the table']) {
      final lines = act0ReviewRepairCoachCopyGuardLinesV1(
        clueLabel: abstractLabel,
      );
      expect(lines, <String>[
        'The no-bet-yet clue is still the one to fix.',
        'Next repair: one no-bet-yet hand',
      ]);
      expect(lines.join(' '), isNot(contains(abstractLabel)));
    }
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
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: true,
        exactReplay: false,
        clueLabel: 'No bet yet',
      )!,
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: false,
        exactReplay: false,
        clueLabel: 'No bet yet',
      )!,
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: true,
        exactReplay: true,
        clueLabel: 'No bet yet',
      )!,
      act0RepairResultReceiptCopyGuardLineV1(
        repaired: false,
        exactReplay: true,
        clueLabel: 'No bet yet',
      )!,
      ...act0RepairSessionSummaryCopyGuardLinesV1(
        repaired: true,
        exactReplay: false,
        clueLabel: 'No bet yet',
      ),
      ...act0RepairSessionSummaryCopyGuardLinesV1(
        repaired: false,
        exactReplay: false,
        clueLabel: 'No bet yet',
      ),
      ...act0RepairSessionSummaryCopyGuardLinesV1(
        repaired: true,
        exactReplay: true,
        clueLabel: 'No bet yet',
      ),
      ...act0RepairSessionSummaryCopyGuardLinesV1(
        repaired: false,
        exactReplay: true,
        clueLabel: 'No bet yet',
      ),
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
      'unlock',
      'guarantee',
      'leak',
      'detected',
      'mastered',
      'forever',
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

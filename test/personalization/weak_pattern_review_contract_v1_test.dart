import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/weak_pattern_review_contract_v1.dart';

void main() {
  test('review contract derives one shared weak-pattern review target', () {
    const recommendation = PersonalizedRecommendationV1(
      recommendedFocusId: 'board_texture',
      reasonCode: 'progression_review_fit',
      shortHintText: 'Review the weak pattern before adding a harder step.',
      recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
      recommendedNextSessionTarget: 'w2.s01',
    );
    const signals = <RecentTelemetrySignalV1>[
      RecentTelemetrySignalV1(
        name: 'correct',
        payload: <String, Object?>{
          'correct': false,
          'error_type': 'board_slot_confusion',
        },
      ),
    ];

    final contract = WeakPatternReviewContractFactoryV1.derive(
      recommendation: recommendation,
      recentSignals: signals,
      resolveModuleTitle: (moduleId) =>
          moduleId == 'w2.s01' ? 'Board Texture' : moduleId,
    );

    expect(contract, isNotNull);
    expect(contract!.weaknessLabel, 'Board Texture');
    expect(
      contract.reviewGoal,
      'Name the board texture first, then choose the line.',
    );
    expect(contract.targetEntryId, 'w2.s04');
    expect(contract.focusId, 'board_texture');
    expect(contract.headline, 'Review: Board Texture');
    expect(
      contract.reasonLine,
      'Review target: Board Texture. Goal: Name the board texture first, then choose the line.',
    );
    expect(contract.ctaLabel, 'REVIEW');
  });

  test(
    'review contract upgrades explicit initiative weakness to a specific practice target',
    () {
      const recommendation = PersonalizedRecommendationV1(
        recommendedFocusId: 'initiative',
        reasonCode: 'progression_review_fit',
        shortHintText: 'Review the weak pattern before adding a harder step.',
        recommendedNextAction: PersonalizedNextActionV1.reviewFocus,
        recommendedNextSessionTarget: 'core_positions_and_initiative',
      );
      const signals = <RecentTelemetrySignalV1>[
        RecentTelemetrySignalV1(
          name: 'correct',
          payload: <String, Object?>{
            'correct': false,
            'error_type': 'action_selection',
          },
        ),
      ];

      final contract = WeakPatternReviewContractFactoryV1.derive(
        recommendation: recommendation,
        recentSignals: signals,
        resolveModuleTitle: (moduleId) =>
            moduleId == 'core_positions_and_initiative'
            ? 'Positions and Initiative'
            : moduleId,
      );

      expect(contract, isNotNull);
      expect(contract!.targetEntryId, 'w2.s03');
      expect(contract.weaknessLabel, 'Positions and Initiative');
    },
  );
}

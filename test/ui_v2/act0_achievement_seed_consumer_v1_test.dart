import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('consumer reads only from achievement seed projection', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_achievement_seed_projection_v1.dart'));
    expect(source, isNot(contains('act0_review_mistake_history')));
    expect(source, isNot(contains('Act0ReviewMistakeHistory')));
    expect(source, isNot(contains('act0_repair_intent')));
    expect(source, isNot(contains('Act0RepairIntent')));
    expect(source, isNot(contains('act0_learning_evidence_contract')));
  });

  test('consumer has no route progression telemetry or economy dependency', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('ProgressService')));
    expect(source, isNot(contains('Route')));
    expect(source, isNot(contains('Navigator')));
    expect(source, isNot(contains('Telemetry')));
    expect(source, isNot(contains('telemetry')));
    expect(source, isNot(contains('xp')));
    expect(source, isNot(contains('economy')));
  });

  test('consumer keeps only earned seeds and caps moments at three', () {
    final consumer = Act0AchievementSeedConsumerV1.fromProjection(
      Act0AchievementSeedProjectionV1(
        seeds: <Act0AchievementSeedV1>[
          _seed(act0AchievementSeedFirstSessionCompleteV1, sequence: 4),
          _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
          _seed(act0AchievementSeedFirstRepairNoteV1, sequence: 2),
          _seed(act0AchievementSeedFirstReviewHistoryItemV1, sequence: 3),
          _seed(
            act0AchievementSeedFirstEvidenceSignalV1,
            state: act0AchievementSeedStateNotEarnedV1,
            earned: false,
          ),
          _seed(
            act0AchievementSeedFirstLessonCompleteV1,
            state: act0AchievementSeedStateBlockedMissingSourceV1,
            earned: false,
          ),
        ],
      ),
    );

    expect(consumer.hasMoments, isTrue);
    expect(consumer.moments.map((moment) => moment.label), <String>[
      'First correct read',
      'First repair note',
      'First review note',
    ]);
    expect(
      consumer.moments.map((moment) => moment.seedId),
      isNot(contains(act0AchievementSeedFirstLessonCompleteV1)),
    );
    expect(
      consumer.moments.map((moment) => moment.seedId),
      isNot(contains(act0AchievementSeedFirstEvidenceSignalV1)),
    );
  });

  testWidgets('Profile renders no earned moments block with empty consumer', (
    tester,
  ) async {
    await _pumpProfile(tester, consumer: const Act0AchievementSeedConsumerV1());

    expect(
      find.byKey(const Key('act0_shell_profile_earned_moments')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_profile_hero_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_profile_progress_proof')),
      findsOneWidget,
    );
  });

  testWidgets('Profile renders compact earned moments when seeds are earned', (
    tester,
  ) async {
    final consumer = Act0AchievementSeedConsumerV1.fromProjection(
      Act0AchievementSeedProjectionV1(
        seeds: <Act0AchievementSeedV1>[
          _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
          _seed(act0AchievementSeedThreeDayStreakV1, sequence: 3),
        ],
      ),
    );

    await _pumpProfile(tester, consumer: consumer);
    await _scrollToEarnedMoments(tester);

    expect(
      find.byKey(const Key('act0_shell_profile_earned_moments')),
      findsOneWidget,
    );
    expect(find.text('Earned moments'), findsOneWidget);
    expect(find.text('Small wins Sharky can prove.'), findsOneWidget);
    expect(find.text('First correct read'), findsOneWidget);
    expect(find.text('3-day streak'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_profile_earned_moments')),
        matching: find.byType(ElevatedButton),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_profile_earned_moments')),
        matching: find.byType(TextButton),
      ),
      findsNothing,
    );
  });

  testWidgets('Profile earned moments never render blocked or unearned seeds', (
    tester,
  ) async {
    final consumer = Act0AchievementSeedConsumerV1.fromProjection(
      Act0AchievementSeedProjectionV1(
        seeds: <Act0AchievementSeedV1>[
          _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
          _seed(
            act0AchievementSeedFirstLessonCompleteV1,
            state: act0AchievementSeedStateBlockedMissingSourceV1,
            earned: false,
          ),
          _seed(
            act0AchievementSeedFirstCleanMiniDrillV1,
            state: act0AchievementSeedStateBlockedMissingSourceV1,
            earned: false,
          ),
          _seed(
            act0AchievementSeedFirstEvidenceSignalV1,
            state: act0AchievementSeedStateNotEarnedV1,
            earned: false,
          ),
        ],
      ),
    );

    await _pumpProfile(tester, consumer: consumer);
    await _scrollToEarnedMoments(tester);

    expect(find.text('First correct read'), findsOneWidget);
    expect(find.text('Lesson complete'), findsNothing);
    expect(find.text('Clean mini-drill'), findsNothing);
    expect(find.text('First evidence signal'), findsNothing);
  });

  testWidgets('Profile earned moments contain no forbidden claim copy', (
    tester,
  ) async {
    final consumer = Act0AchievementSeedConsumerV1.fromProjection(
      Act0AchievementSeedProjectionV1(
        seeds: <Act0AchievementSeedV1>[
          _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
          _seed(act0AchievementSeedFirstRepairNoteV1, sequence: 2),
          _seed(act0AchievementSeedFirstReviewHistoryItemV1, sequence: 3),
        ],
      ),
    );

    await _pumpProfile(tester, consumer: consumer);
    await _scrollToEarnedMoments(tester);

    final blockText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('act0_shell_profile_earned_moments')),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'mastered',
      'leak fixed',
      'ai detected',
      'gto',
      'solver',
      'premium',
      'top player',
      'clear/fixed',
      'resolved',
      'reward',
      'xp',
      'leaderboard',
    ]) {
      expect(blockText, isNot(contains(forbidden)));
    }
  });
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  required Act0AchievementSeedConsumerV1 consumer,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0ProfileShellV1(
          profile: Act0ShellStateV1.sample.profile,
          achievementSeedConsumer: consumer,
          onRetakePlacement: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollToEarnedMoments(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(
      const Key('act0_shell_profile_earned_moments'),
      skipOffstage: false,
    ),
    280,
    scrollable: find.byType(Scrollable),
  );
  await tester.pumpAndSettle();
}

Act0AchievementSeedV1 _seed(
  String id, {
  String state = act0AchievementSeedStateEarnedV1,
  bool earned = true,
  int? sequence,
}) {
  return Act0AchievementSeedV1(
    id: id,
    internalTitle: id,
    sourceOwner: 'test_projection',
    state: state,
    earned: earned,
    earnedSequence: sequence,
    sourceSummary: const <String, Object?>{},
    eligibilityState: state,
  );
}

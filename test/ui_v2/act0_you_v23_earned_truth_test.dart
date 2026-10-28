import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'act0_review_v4_test.dart' as review_fixtures;

// Captured from the EN V1 integrated audit on the 14 Pro reference after a
// real first-use experienced Placement: wrong, unsure, then correct.
const _nativeFixture =
    'test/ui_v2/fixtures/en_v1_f1_native_wrong_unsure_correct_prefs_v1.json';
final _now = DateTime.utc(2026, 10, 29, 12);

Map<String, Object> _nativePrefs({bool dropCorrect = false}) {
  final raw = Map<String, Object>.from(
    jsonDecode(File(_nativeFixture).readAsStringSync()) as Map,
  );
  if (dropCorrect) {
    final p = jsonDecode(raw['act0_shell_progress_v1'] as String) as Map;
    p['learningEvidenceHistory'] = [
      for (final r in p['learningEvidenceHistory'] as List)
        if ((r as Map)['isCorrect'] != true) r,
    ];
    raw['act0_shell_progress_v1'] = jsonEncode(p);
  }
  return raw;
}

Future<void> _mountYou(WidgetTester t, {Key? key}) async {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  await t.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: key,
        initialTab: Act0ShellTabV1.profile,
        showPlacementOnStart: false,
        clock: Act0FixedUtcClockV1(_now),
      ),
    ),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Finder _earned(String seedId) =>
    find.byKey(Key('act0_shell_profile_earned_moment_$seedId'));

void _expectNoOpenMistakeEarned() {
  for (final id in act0YouV23OpenMistakeSeedIdsV1) {
    expect(_earned(id), findsNothing, reason: '$id is not an achievement');
  }
  expect(find.text('Back to the spot'), findsNothing);
  expect(find.text('One miss to fix'), findsNothing);
}

void _expectOpenRepairRow(WidgetTester t) {
  final p = t.widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1));
  expect(p.youRepairCount, greaterThan(0));
  expect(find.byKey(const Key('you_v23_review')), findsOneWidget);
  expect(find.textContaining('to repair'), findsWidgets);
}

// Repair visibility stays owned by the existing Review/repair sources; You
// only mirrors them and never turns them into earned moments.
void _expectRepairRowMatchesSource(WidgetTester t) {
  final p = t.widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1));
  expect(
    find.byKey(const Key('you_v23_review')),
    p.youRepairCount + p.youDueCount > 0 ? findsOneWidget : findsNothing,
  );
}

Map<String, Object> _singleRepairWithNativeCorrect() {
  final f = review_fixtures.reviewV4Fixture('single');
  final native =
      jsonDecode(_nativePrefs()['act0_shell_progress_v1'] as String) as Map;
  final p = jsonDecode(f['act0_shell_progress_v1'] as String) as Map;
  p['learningEvidenceHistory'] = [
    for (final r in native['learningEvidenceHistory'] as List)
      if ((r as Map)['isCorrect'] == true) r,
  ];
  f['act0_shell_progress_v1'] = jsonEncode(p);
  return f;
}

void main() {
  const skip = !kAct0YouV23Preview;

  testWidgets(
    'wrong + unsure + independent correct keeps only First correct read',
    (t) async {
      SharedPreferences.setMockInitialValues(_nativePrefs());
      await _mountYou(t);
      expect(_earned(act0AchievementSeedFirstCorrectReadV1), findsOneWidget);
      expect(find.text('1 earned'), findsOneWidget);
      _expectNoOpenMistakeEarned();
      _expectRepairRowMatchesSource(t);
      // A correct Placement read is not XP; only the source 0 XP may show.
      expect(find.textContaining(RegExp(r'[1-9]\d* / \d+ XP')), findsNothing);
    },
    skip: skip,
  );

  testWidgets('mistakes without an independent correct answer earn nothing', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues(_nativePrefs(dropCorrect: true));
    await _mountYou(t);
    expect(find.text('Not earned yet'), findsOneWidget);
    expect(_earned(act0AchievementSeedFirstCorrectReadV1), findsNothing);
    _expectNoOpenMistakeEarned();
    _expectRepairRowMatchesSource(t);
  }, skip: skip);

  testWidgets('independent correct and an open repair stay separate', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues(_singleRepairWithNativeCorrect());
    await _mountYou(t);
    expect(_earned(act0AchievementSeedFirstCorrectReadV1), findsOneWidget);
    expect(find.text('1 earned'), findsOneWidget);
    _expectNoOpenMistakeEarned();
    _expectOpenRepairRow(t);
  }, skip: skip);

  testWidgets('a single open repair intent earns nothing', (t) async {
    SharedPreferences.setMockInitialValues(
      review_fixtures.reviewV4Fixture('single'),
    );
    await _mountYou(t);
    expect(find.text('Not earned yet'), findsOneWidget);
    _expectNoOpenMistakeEarned();
    _expectOpenRepairRow(t);
  }, skip: skip);

  testWidgets(
    'restart and tab return reproduce the same truth without mutation',
    (t) async {
      SharedPreferences.setMockInitialValues(_nativePrefs());
      final before = (await SharedPreferences.getInstance()).getString(
        'act0_shell_progress_v1',
      );
      await _mountYou(t);
      await t.tap(find.text('Home'));
      await t.pumpAndSettle();
      await t.tap(find.text('You'));
      await t.pumpAndSettle();
      expect(_earned(act0AchievementSeedFirstCorrectReadV1), findsOneWidget);
      _expectNoOpenMistakeEarned();

      await t.pumpWidget(const SizedBox());
      await _mountYou(t, key: const ValueKey('restart'));
      expect(_earned(act0AchievementSeedFirstCorrectReadV1), findsOneWidget);
      expect(find.text('1 earned'), findsOneWidget);
      _expectNoOpenMistakeEarned();
      _expectRepairRowMatchesSource(t);
      final after = (await SharedPreferences.getInstance()).getString(
        'act0_shell_progress_v1',
      );
      final b = jsonDecode(before!) as Map;
      final a = jsonDecode(after!) as Map;
      for (final k in [
        'learningEvidenceHistory',
        'reviewMistakeHistory',
        'openRepairIntents',
        'completedTaskIds',
        'earnedXp',
      ]) {
        expect(jsonEncode(a[k]), jsonEncode(b[k]), reason: k);
      }
    },
    skip: skip,
  );

  test('excluded open-mistake seeds cannot crowd out earned moments', () {
    Act0AchievementSeedV1 seed(String id, int order) => Act0AchievementSeedV1(
      id: id,
      internalTitle: id,
      sourceOwner: 'test',
      state: act0AchievementSeedStateEarnedV1,
      earned: true,
      earnedSequence: order,
      sourceSummary: const <String, Object?>{},
      eligibilityState: act0AchievementSeedStateEarnedV1,
    );
    final projection = Act0AchievementSeedProjectionV1(
      seeds: [
        seed(act0AchievementSeedFirstRepairNoteV1, 1),
        seed(act0AchievementSeedFirstReviewHistoryItemV1, 2),
        seed(act0AchievementSeedFirstCorrectReadV1, 3),
        seed(act0AchievementSeedFirstEvidenceSignalV1, 4),
        seed(act0AchievementSeedFirstSessionCompleteV1, 5),
      ],
    );
    final all = Act0AchievementSeedConsumerV1.fromProjection(projection);
    expect(all.moments.map((m) => m.seedId), [
      act0AchievementSeedFirstRepairNoteV1,
      act0AchievementSeedFirstReviewHistoryItemV1,
      act0AchievementSeedFirstCorrectReadV1,
    ]);
    final truthful = Act0AchievementSeedConsumerV1.fromProjection(
      projection,
      excludedSeedIds: act0YouV23OpenMistakeSeedIdsV1,
    );
    expect(truthful.moments.map((m) => m.seedId), [
      act0AchievementSeedFirstCorrectReadV1,
      act0AchievementSeedFirstEvidenceSignalV1,
      act0AchievementSeedFirstSessionCompleteV1,
    ]);
  });

  testWidgets(
    'You V23 never features an open-mistake seed even if one is supplied',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ProfileShellV1(
              profile: Act0ShellStateV1.sample.profile,
              achievementSeedConsumer: const Act0AchievementSeedConsumerV1(
                moments: [
                  Act0AchievementMomentViewModelV1(
                    seedId: act0AchievementSeedFirstRepairNoteV1,
                    label: 'Back to the spot',
                  ),
                  Act0AchievementMomentViewModelV1(
                    seedId: act0AchievementSeedFirstCorrectReadV1,
                    label: 'First correct read',
                  ),
                ],
              ),
              onRetakePlacement: () {},
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(_earned(act0AchievementSeedFirstCorrectReadV1), findsOneWidget);
      expect(find.text('1 earned'), findsOneWidget);
      _expectNoOpenMistakeEarned();
    },
    skip: skip,
  );
}

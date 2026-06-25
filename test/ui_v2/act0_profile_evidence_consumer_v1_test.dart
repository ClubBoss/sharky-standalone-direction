import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('consumer renders no signal without eligible projection rows', () {
    final consumer = Act0ProfileEvidenceConsumerV1.fromProjection(
      Act0ProfileEvidenceProjectionV1(
        signals: <Act0ProfileCapabilitySignalV1>[
          _signal(
            eligibilityState: act0ProfileEvidenceStateInsufficientSampleV1,
            attemptCount: 4,
            correctCount: 3,
          ),
          _signal(
            skillAtomId: 'position_read',
            eligibilityState: act0ProfileEvidenceStateNeedsMorePracticeV1,
            attemptCount: 5,
            correctCount: 1,
          ),
        ],
      ),
    );

    expect(consumer.hasSignal, isFalse);
    expect(consumer.signal, isNull);
  });

  test(
    'consumer chooses deterministic first eligible signal, not strongest',
    () {
      final consumer = Act0ProfileEvidenceConsumerV1.fromProjection(
        Act0ProfileEvidenceProjectionV1(
          signals: <Act0ProfileCapabilitySignalV1>[
            _signal(
              skillAtomId: 'action_read',
              attemptCount: 5,
              correctCount: 3,
            ),
            _signal(
              skillAtomId: 'position_read',
              attemptCount: 8,
              correctCount: 8,
            ),
          ],
        ),
      );

      expect(consumer.hasSignal, isTrue);
      expect(consumer.signal!.skillAtomId, 'action_read');
      expect(consumer.signal!.skillLabel, 'Action reading');
      expect(consumer.signal!.proofLine, '3/5 correct in Action reading');
    },
  );

  test('consumer ignores eligible rows without learner-safe skill label', () {
    final consumer = Act0ProfileEvidenceConsumerV1.fromProjection(
      Act0ProfileEvidenceProjectionV1(
        signals: <Act0ProfileCapabilitySignalV1>[
          _signal(skillAtomId: 'internal_unknown_atom'),
        ],
      ),
    );

    expect(consumer.hasSignal, isFalse);
  });

  test('consumer does not read review mistake history', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_profile_evidence_consumer_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_profile_evidence_projection_v1.dart'));
    expect(source, isNot(contains('act0_review_mistake_history')));
    expect(source, isNot(contains('ReviewMistakeHistory')));
    expect(source, isNot(contains('RepairIntent')));
  });

  testWidgets('Profile renders no evidence block when no signal is provided', (
    tester,
  ) async {
    await _pumpProfile(tester);

    expect(
      find.byKey(const Key('act0_shell_profile_evidence_signal')),
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

  testWidgets('Profile renders one read-only evidence signal when eligible', (
    tester,
  ) async {
    await _pumpProfile(
      tester,
      signal: const Act0ProfileEvidenceSignalViewModelV1(
        signalId: 'profile_evidence_v1|action_read',
        skillAtomId: 'action_read',
        skillLabel: 'Action reading',
        correctCount: 3,
        attemptCount: 5,
        proofLine: '3/5 correct in Action reading',
      ),
    );
    await _scrollToEvidenceSignal(tester);

    expect(
      find.byKey(const Key('act0_shell_profile_evidence_signal')),
      findsOne,
    );
    expect(find.text('Evidence signal'), findsOne);
    expect(find.text('You are building this skill.'), findsOne);
    expect(find.text('3/5 correct in Action reading'), findsOne);
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_profile_evidence_signal')),
        matching: find.byType(ElevatedButton),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_profile_evidence_signal')),
        matching: find.byType(TextButton),
      ),
      findsNothing,
    );
  });

  testWidgets('Profile evidence signal contains no forbidden claim copy', (
    tester,
  ) async {
    await _pumpProfile(
      tester,
      signal: const Act0ProfileEvidenceSignalViewModelV1(
        signalId: 'profile_evidence_v1|action_read',
        skillAtomId: 'action_read',
        skillLabel: 'Action reading',
        correctCount: 3,
        attemptCount: 5,
        proofLine: '3/5 correct in Action reading',
      ),
    );
    await _scrollToEvidenceSignal(tester);

    final evidenceText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('act0_shell_profile_evidence_signal')),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    expect(evidenceText, isNot(contains('master')));
    expect(evidenceText, isNot(contains('leak')));
    expect(evidenceText, isNot(contains('ai')));
    expect(evidenceText, isNot(contains('gto')));
    expect(evidenceText, isNot(contains('solver')));
    expect(evidenceText, isNot(contains('strongest')));
    expect(evidenceText, isNot(contains('weakest')));
    expect(evidenceText, isNot(contains('premium')));
    expect(evidenceText, isNot(contains('badge')));
    expect(evidenceText, isNot(contains('achievement')));
  });
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  Act0ProfileEvidenceSignalViewModelV1? signal,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0ProfileShellV1(
          profile: Act0ShellStateV1.sample.profile,
          evidenceSignal: signal,
          onRetakePlacement: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollToEvidenceSignal(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(
      const Key('act0_shell_profile_evidence_signal'),
      skipOffstage: false,
    ),
    280,
    scrollable: find.byType(Scrollable),
  );
  await tester.pumpAndSettle();
}

Act0ProfileCapabilitySignalV1 _signal({
  String skillAtomId = 'action_read',
  int attemptCount = 5,
  int correctCount = 3,
  String eligibilityState = act0ProfileEvidenceStateEligibleSignalV1,
}) {
  final sampleThresholdMet =
      eligibilityState != act0ProfileEvidenceStateInsufficientSampleV1;
  final positiveSignalThresholdMet =
      eligibilityState == act0ProfileEvidenceStateEligibleSignalV1;
  return Act0ProfileCapabilitySignalV1(
    signalId: 'profile_evidence_v1|$skillAtomId',
    skillAtomId: skillAtomId,
    attemptCount: attemptCount,
    correctCount: correctCount,
    incorrectCount: attemptCount - correctCount,
    accuracyPercent: ((correctCount * 100) / attemptCount).round(),
    sampleThreshold: act0ProfileEvidenceMinimumAttemptsV1,
    sampleThresholdMet: sampleThresholdMet,
    positiveSignalThresholdMet: positiveSignalThresholdMet,
    worldIds: const <String>['world_1'],
    lessonIds: const <String>['fold_check_call_raise'],
    latestOrder: attemptCount,
    eligibilityState: eligibilityState,
  );
}

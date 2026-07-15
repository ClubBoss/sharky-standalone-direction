import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  const table = Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    streetLabel: 'Preflop',
    potLabel: 'Pot 1.5 BB',
    toCallLabel: '',
    centerLabel: 'Blinds posted',
    emptyBoardLabel: 'No community cards yet',
    heroCards: <Act0CardStateV1>[],
    boardCards: <Act0CardStateV1>[],
    seats: <Act0SeatStateV1>[
      Act0SeatStateV1(seatId: 'utg', seatLabel: 'UTG', displayName: 'Seat'),
      Act0SeatStateV1(seatId: 'hj', seatLabel: 'HJ', displayName: 'Seat'),
      Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'Cutoff'),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Hero',
        isHero: true,
        isDealerButton: true,
        stackLabel: '100 BB',
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
      ),
    ],
    heroSeatId: 'btn',
    highlightedSeatIds: <String>['btn', 'sb', 'bb'],
    highlightedCardIds: <String>[],
    selectableSeatIds: <String>['utg', 'btn', 'hj'],
  );

  Act0RunnerStateV1 runner({
    required Act0LessonPhaseV1 phase,
    required String question,
    List<Act0TeachingStepV1> teachingSteps = const <Act0TeachingStepV1>[],
  }) => Act0RunnerStateV1(
    lessonId: 'first_table_guide',
    lessonTitle: 'First Table Guide',
    lessonSubtitle: 'Read one spot, answer once, and see why.',
    beatIndex: 2,
    beatCount: 5,
    phase: phase,
    caption: 'You are at the bottom seat in this first example.',
    hint: 'Find You, then notice BTN, the dealer position for this hand.',
    question: question,
    options: <Act0RunnerOptionV1>[
      Act0RunnerOptionV1(
        id: 'top',
        label: 'Top seat',
        seatId: 'utg',
        isCorrect: false,
        preferredLabel: 'You badge',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Look for You.',
        feedbackReason: 'The You badge marks your seat.',
      ),
      Act0RunnerOptionV1(
        id: 'bottom',
        label: 'You badge',
        seatId: 'btn',
        isCorrect: true,
        preferredLabel: 'You badge',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Your seat found!',
        feedbackReason: 'The You badge marks your seat.',
      ),
    ],
    feedbackTitle: 'Your seat found!',
    feedbackReason: 'The You badge marks your seat.',
    primaryCtaLabel: 'Continue',
    nextLessonId: null,
    returnTarget: 'learn',
    table: table,
    teachingSteps: teachingSteps,
  );

  Future<void> pumpRunner(WidgetTester tester, Act0RunnerStateV1 runner) {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
            selectedTaskId: 'what_poker_is_find_hero',
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onChooseSeat: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );
  }

  test(
    'first-session source uses You for learner-facing identity teaching',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
      ).readAsStringSync();
      final start = source.indexOf('final _firstTableGuideMeetTableRunner');
      final end = source.indexOf('final _boardCountRunner', start);
      final firstSession = source.substring(start, end);

      expect(firstSession, contains('Which marker identifies you?'));
      expect(firstSession, contains('Which seat has the You badge?'));
      expect(firstSession, contains('You marks your seat. BTN is the Button'));
      expect(firstSession, isNot(contains('seat marked Hero')));
      expect(firstSession, isNot(contains('Which seat is the hero seat?')));
    },
  );

  testWidgets(
    'short identity teaching stays below a stable table with its footer rail anchored',
    (tester) async {
      await pumpRunner(
        tester,
        runner(
          phase: Act0LessonPhaseV1.theory,
          question: 'Which marker identifies you?',
          teachingSteps: const <Act0TeachingStepV1>[
            Act0TeachingStepV1(
              title: 'You means learner.',
              body:
                  'The You badge marks your seat. BTN is the Button position for this hand.',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final surfaceRect = tester.getRect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
      );
      final laneRect = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_content_lane')),
      );
      final footerRect = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_fixed_footer')),
      );

      expect(surfaceRect.top, greaterThanOrEqualTo(tableRect.bottom));
      expect(laneRect.top - surfaceRect.top, lessThanOrEqualTo(24));
      expect(footerRect.bottom, closeTo(surfaceRect.bottom, 2));
      expect(laneRect.bottom, lessThanOrEqualTo(footerRect.top));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'table-tap prompt is intrinsic while the lower surface stays continuous',
    (tester) async {
      await pumpRunner(
        tester,
        runner(
          phase: Act0LessonPhaseV1.drill,
          question: 'Which seat has the You badge?',
        ),
      );
      await tester.pumpAndSettle();

      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final surfaceRect = tester.getRect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
      );
      final promptRect = tester.getRect(
        find.byKey(const Key('act0_shell_seat_tap_prompt')),
      );

      expect(
        find.byKey(const Key('act0_shell_wave1_hero_you_badge')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_marker_btn_dealer')),
        findsOneWidget,
      );
      expect(surfaceRect.top, greaterThanOrEqualTo(tableRect.bottom));
      expect(promptRect.top - surfaceRect.top, lessThanOrEqualTo(16));
      expect(promptRect.height, lessThan(220));
      expect(promptRect.height, lessThan(surfaceRect.height - 48));
      expect(tester.takeException(), isNull);
    },
  );
}

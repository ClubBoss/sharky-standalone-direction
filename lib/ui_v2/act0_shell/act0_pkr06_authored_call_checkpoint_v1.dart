import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// NEW_AUTHORING: a new price exercise, not reconstructed catalog history.
/// This descriptor is not catalog admission or a legal-execution certificate.
/// All six 100 BB starting budgets are new authored facts. Cards stay unknown.
class Act0Pkr06AuthoredCallBasisV1 {
  const Act0Pkr06AuthoredCallBasisV1._();

  String get taskId => 'pkr06_authored_call_price_checkpoint';
  String get provenance => 'NEW_AUTHORING_2026_11_08';
  String get pendingActorSeatId => 'bb';
  int get anteBb => 0;

  /// Authored at hand start, before blinds. Missing keys mean unknown, not 0.
  Map<String, int> get startingBudgetBb => const {
    'utg': 100,
    'hj': 100,
    'co': 100,
    'btn': 100,
    'sb': 100,
    'bb': 100,
  };
  List<String> get zeroContributionFoldedSeatIds => const [
    'utg',
    'hj',
    'co',
    'btn',
  ];

  int get sbRaiseToBb => 3;
  int get bbAlreadyCommittedBb => 1;
  int get expectedAdditionalCallBb => sbRaiseToBb - bbAlreadyCommittedBb;
  int get resultingBbCommitmentBb => sbRaiseToBb;
  int get snapshotPotBb => sbRaiseToBb + bbAlreadyCommittedBb;
}

const act0Pkr06AuthoredCallBasisV1 = Act0Pkr06AuthoredCallBasisV1._();

/// A pending preflop decision, with no call, outcome, or later street recorded.
/// No placeholder ranks/suits stand in for unknown hole cards.
const act0Pkr06AuthoredCallTableV1 = Act0TableStateV1(
  scope: Act0TableScopeV1.playedHand,
  tableFormat: Act0TableFormatV1.sixMax,
  playerCount: 6,
  seats: [
    Act0SeatStateV1(
      seatId: 'utg',
      seatLabel: 'UTG',
      displayName: 'Under the gun',
      isInHand: false,
      isFolded: true,
      hasActed: true,
      stackLabel: '100 BB',
      currentBetLabel: '0 BB',
      cardsVisibleMode: Act0CardsVisibleModeV1.none,
    ),
    Act0SeatStateV1(
      seatId: 'hj',
      seatLabel: 'HJ',
      displayName: 'Hijack',
      isInHand: false,
      isFolded: true,
      hasActed: true,
      stackLabel: '100 BB',
      currentBetLabel: '0 BB',
      cardsVisibleMode: Act0CardsVisibleModeV1.none,
    ),
    Act0SeatStateV1(
      seatId: 'co',
      seatLabel: 'CO',
      displayName: 'Cutoff',
      isInHand: false,
      isFolded: true,
      hasActed: true,
      stackLabel: '100 BB',
      currentBetLabel: '0 BB',
      cardsVisibleMode: Act0CardsVisibleModeV1.none,
    ),
    Act0SeatStateV1(
      seatId: 'btn',
      seatLabel: 'BTN',
      displayName: 'Button',
      isDealerButton: true,
      isInHand: false,
      isFolded: true,
      hasActed: true,
      stackLabel: '100 BB',
      currentBetLabel: '0 BB',
      cardsVisibleMode: Act0CardsVisibleModeV1.none,
    ),
    Act0SeatStateV1(
      seatId: 'sb',
      seatLabel: 'SB',
      displayName: 'Small blind',
      isSmallBlind: true,
      blindAmountLabel: '0.5 BB',
      hasActed: true,
      isLastAggressor: true,
      stackLabel: '97 BB',
      currentBetLabel: '3 BB',
      bet: Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.raise,
        label: 'SB',
        amountLabel: '3 BB',
      ),
    ),
    Act0SeatStateV1(
      seatId: 'bb',
      seatLabel: 'BB',
      displayName: 'You',
      isHero: true,
      isBigBlind: true,
      blindAmountLabel: '1 BB',
      isActive: true,
      stackLabel: '99 BB',
      currentBetLabel: '1 BB',
      bet: Act0SeatBetStateV1(
        kind: Act0SeatBetKindV1.post,
        label: 'BB',
        amountLabel: '1 BB',
      ),
    ),
  ],
  heroCards: [],
  boardCards: [],
  streetLabel: 'Preflop',
  potLabel: 'Pot 4 BB',
  toCallLabel: 'To call 2 BB',
  centerLabel: 'BB to act',
  emptyBoardLabel: 'No board yet',
  actionTrail: [
    Act0ActionTrailItemV1(label: 'SB posts 0.5 BB'),
    Act0ActionTrailItemV1(label: 'BB posts 1 BB'),
    Act0ActionTrailItemV1(label: 'UTG folds'),
    Act0ActionTrailItemV1(label: 'HJ folds'),
    Act0ActionTrailItemV1(label: 'CO folds'),
    Act0ActionTrailItemV1(label: 'BTN folds'),
    Act0ActionTrailItemV1(label: 'SB raises to 3 BB'),
  ],
  activeSeatId: 'bb',
  heroSeatId: 'bb',
  highlightedSeatIds: [],
  highlightedCardIds: [],
);

/// Uses the real State/Runner types but does not register a task or award XP.
/// The catalog owner must choose placement, navigation, and reward explicitly.
/// Correctness here means the price answer only, never a strategy recommendation.
/// Source inspection expects price/order consistency; runtime is NOT_RUN.
/// Choreography cannot parse this history; that is not admission or a reason
/// to rewrite the history. A separate numeric-success guard is still required.
Act0LessonTaskV1 act0Pkr06AuthoredCallCheckpointV1({
  required String lessonId,
  required String lessonTitle,
  required int beatIndex,
  required int beatCount,
  required int rewardXp,
  required String returnTarget,
  required String? nextLessonId,
}) => Act0LessonTaskV1(
  taskId: act0Pkr06AuthoredCallBasisV1.taskId,
  title: 'Count the call',
  phase: Act0LessonPhaseV1.drill,
  rewardXp: rewardXp,
  taskFamily: Act0TaskFamilyV1.counting,
  tablePresentation: Act0TaskTablePresentationV1.stablePractice,
  summary: 'Find the extra chips needed to match a raise.',
  runner: Act0RunnerStateV1(
    lessonId: lessonId,
    lessonTitle: lessonTitle,
    lessonSubtitle: 'The price of a call',
    beatIndex: beatIndex,
    beatCount: beatCount,
    phase: Act0LessonPhaseV1.drill,
    caption:
        'No ante. All six players started with 100 BB. '
        'UTG, HJ, CO and BTN folded. SB raised to 3 BB total.',
    hint: 'Your 1 BB blind already counts toward the total.',
    question: 'If BB calls, how many more BB must be added?',
    options: const [
      Act0RunnerOptionV1(
        id: 'call_add_1',
        label: 'Call',
        amountLabel: '1 BB',
        isCorrect: false,
        quality: Act0FeedbackQualityV1.wrong,
        preferredLabel: 'Add 2 BB (3 BB total)',
        feedbackTitle: 'One more BB is not enough.',
        feedbackReason:
            'You already committed 1 BB. Adding 1 BB makes '
            '2 BB total, short of the 3 BB price.',
      ),
      Act0RunnerOptionV1(
        id: 'call_add_2',
        label: 'Call',
        amountLabel: '2 BB',
        isCorrect: true,
        quality: Act0FeedbackQualityV1.correct,
        preferredLabel: 'Add 2 BB (3 BB total)',
        feedbackTitle: 'The call costs 2 more BB.',
        feedbackReason:
            '3 BB to match minus your 1 BB blind equals 2 BB '
            'to add. Your total commitment would be 3 BB. This answers '
            'the price question, not whether calling is a good play.',
      ),
      Act0RunnerOptionV1(
        id: 'call_add_3',
        label: 'Call',
        amountLabel: '3 BB',
        isCorrect: false,
        quality: Act0FeedbackQualityV1.wrong,
        preferredLabel: 'Add 2 BB (3 BB total)',
        feedbackTitle: 'Count the blind already posted.',
        feedbackReason:
            '3 BB is the total to match, not extra chips. '
            'Adding 3 BB to your 1 BB blind would make 4 BB total.',
      ),
    ],
    feedbackTitle: 'Separate extra chips from the total.',
    feedbackReason:
        'All hole cards are unknown. This exercise checks only '
        'the call amount, not hand strength or the best strategic action.',
    primaryCtaLabel: 'Check answer',
    nextLessonId: nextLessonId,
    returnTarget: returnTarget,
    table: act0Pkr06AuthoredCallTableV1,
  ),
);

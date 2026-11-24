part of 'act0_shell_state_v1.dart';

// Live Room curriculum mapped from the audited live_room_v1 spec.
final _act0LiveRoomV1 = Act0WorldCardV1(
  worldId: act0LiveRoomModuleIdV1,
  // The Learn and runner shell share this card shape for section selection.
  worldNumber: 0,
  title: 'Live Room',
  subtitle: 'Live \$1/\$2 no-limit hold’em cash.',
  status: Act0WorldStateV1.current,
  progressLabel: '0 of 7 lessons complete',
  primaryCtaLabel: 'Open lessons',
  unlockLabel: 'Available now',
  isSelectable: true,
  isLocked: false,
  rewardXp: 0,
  lessons: [
    _liveRoomLessonV1("verbal_action", "Declare your action", [
      _liveRoomTaskV1(
        "live_room_call_first",
        Act0TaskFamilyV1.recognition,
        "This room binds the first clear, legal verbal declaration made in turn. An opponent bets \$12.",
        "In turn, you clearly say “call,” then immediately say “raise to \$30.” What action stands?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Call \$12",
            isCorrect: true,
            preferredLabel: "Call \$12",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "In this room, your first clear, legal declaration in turn commits you to the \$12 call.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Raise to \$30",
            isCorrect: false,
            preferredLabel: "Call \$12",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "Under this room’s rule, the later raise declaration cannot replace your binding call.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_raise_then_chips",
        Act0TaskFamilyV1.decision,
        "This room accepts an in-turn “raise” without a spoken amount followed by a legal total released in one motion. An opponent bets \$10 on the flop. In turn, you say “raise,” then put out \$30 total in one motion.",
        "How is it ruled?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Call \$10",
            isCorrect: false,
            preferredLabel: "Raise to \$30",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "Your spoken raise came first and the chips supplied its legal total.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Raise to \$30",
            isCorrect: true,
            preferredLabel: "Raise to \$30",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "You declared the raise before moving chips and put out a legal amount. The \$20 increase exceeds the \$10 minimum increase.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_spoken_amount",
        Act0TaskFamilyV1.transfer,
        "This room gives clear, legal in-turn verbal totals priority over conflicting chip amounts. An opponent bets \$10 on the flop. In turn, you clearly say “raise to \$30,” but accidentally push out \$25. You have chips behind.",
        "What total should you put in?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "\$30",
            isCorrect: true,
            preferredLabel: "\$30",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Under this room’s rule, your declared \$30 total binds, so add \$5.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "\$25",
            isCorrect: false,
            preferredLabel: "\$30",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "This room uses your declared total when the chip count conflicts with it.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_speak_first",
        Act0TaskFamilyV1.review,
        "You want to raise to \$40 over a \$15 flop bet.",
        "What is the clearest action on your turn?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Say “call” while putting out \$40",
            isCorrect: false,
            preferredLabel: "Say “raise to \$40,” then put out \$40",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "Saying “call” conflicts with your intended raise and may be ruled a \$15 call.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Say “raise to \$40,” then put out \$40",
            isCorrect: true,
            preferredLabel: "Say “raise to \$40,” then put out \$40",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Declaring both the action and the total before moving chips makes the amount clear, and the \$25 increase is legal here.",
          ),
        ],
        phase: Act0LessonPhaseV1.review,
      ),
    ]),
    _liveRoomLessonV1("string_bets", "Move chips once", [
      _liveRoomTaskV1(
        "live_room_late_raise",
        Act0TaskFamilyV1.recognition,
        "This room counts the first completed silent chip release as the wager and disallows a second trip without a prior raise declaration. Facing \$12 on the flop, you silently release \$12 as a wager, reach back, then push another \$18 forward.",
        "What action stands?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Call \$12",
            isCorrect: true,
            preferredLabel: "Call \$12",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "The first motion completed a call. Without an earlier raise declaration, the second motion cannot turn it into a raise.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Raise to \$30",
            isCorrect: false,
            preferredLabel: "Call \$12",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "Adding chips on a second trip after completing the call is a string raise.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_first_bet",
        Act0TaskFamilyV1.decision,
        "The flop checks to you. You say nothing and release \$10 as a bet, then reach back and push another \$10 forward. This room counts only the first completed motion.",
        "How much is the bet?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "\$20",
            isCorrect: false,
            preferredLabel: "\$10",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "You never declared \$20 before making the first bet, so the second motion does not count.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "\$10",
            isCorrect: true,
            preferredLabel: "\$10",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "The first motion made a legal \$10 bet. The extra \$10 is a separate motion and is returned under this rule.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_avoid_string",
        Act0TaskFamilyV1.transfer,
        "This room accepts a silent raise when multiple chips totaling a legal raise are released together in one motion. You want to raise a \$10 flop bet to \$35. You have counted out multiple chips totaling \$35.",
        "Which silent chip action makes the raise clear?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Release all \$35 together in one motion",
            isCorrect: true,
            preferredLabel: "Release all \$35 together in one motion",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Releasing the chips together puts out the full legal \$35 raise under this room’s one-motion rule.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Release \$10, then reach back for \$25",
            isCorrect: false,
            preferredLabel: "Release all \$35 together in one motion",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The first motion matches the bet. The later chips can be disallowed as a string raise.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
    ]),
    _liveRoomLessonV1("oversized_chip", "Know the one-chip rule", [
      _liveRoomTaskV1(
        "live_room_silent_chip",
        Act0TaskFamilyV1.recognition,
        "An opponent bets \$8. You silently put out one \$25 chip on your turn.",
        "What happens under the one-chip rule?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Raise to \$25",
            isCorrect: false,
            preferredLabel: "Call \$8 and get \$17 back",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The chip denomination alone does not signal a raise when you face a bet.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Call \$8 and get \$17 back",
            isCorrect: true,
            preferredLabel: "Call \$8 and get \$17 back",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "One oversized chip without a prior raise declaration matches the \$8 you face. The remaining \$17 is change.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_declare_chip_raise",
        Act0TaskFamilyV1.decision,
        "In this room, a single oversized chip released silently when facing a bet counts as a call. A clear legal raise declared in turn before releasing the chip binds. An opponent bets \$8 on the flop. You want to raise to \$25 using one chip.",
        "What should you do?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Say “raise to \$25” before releasing the chip",
            isCorrect: true,
            preferredLabel: "Say “raise to \$25” before releasing the chip",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "The spoken amount makes your intent clear. The \$17 increase over \$8 meets the minimum raise.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Release the \$25 chip silently and then say “raise”",
            isCorrect: false,
            preferredLabel: "Say “raise to \$25” before releasing the chip",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The silent chip is already a call under this rule. Declare the raise before releasing it.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_no_wager",
        Act0TaskFamilyV1.transfer,
        "On the flop, no one has bet. You release a single \$25 chip silently. This room counts a silent opening chip at face value.",
        "What is your action?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Check and take the chip back",
            isCorrect: false,
            preferredLabel: "Bet \$25",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The chip was released as a wager. The one-chip call convention applies when there is a bet to match.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Bet \$25",
            isCorrect: true,
            preferredLabel: "Bet \$25",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "There is no outstanding wager to call. This room treats the face value of the first betting chip as your bet.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
    ]),
    _liveRoomLessonV1("showdown", "Show your hand correctly", [
      _liveRoomTaskV1(
        "live_room_river_bet",
        Act0TaskFamilyV1.recognition,
        "In this room, the last player to bet or raise on the river shows first. Only the small blind and the button reach showdown. On the river, the small blind bets and the button calls.",
        "Who shows first?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "The small blind",
            isCorrect: true,
            preferredLabel: "The small blind",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "The small blind made the last aggressive action on the river by betting.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "The button",
            isCorrect: false,
            preferredLabel: "The small blind",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "Calling ends the betting but does not make the button the aggressor.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_river_raise",
        Act0TaskFamilyV1.decision,
        "In this room, the last player to bet or raise on the river shows first. Only the small blind and the button reach showdown. On the river, the small blind bets, the button raises, and the small blind calls.",
        "Who shows first?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "The small blind",
            isCorrect: false,
            preferredLabel: "The button",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The original bet was followed by a raise, so the bettor is no longer the last aggressor.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "The button",
            isCorrect: true,
            preferredLabel: "The button",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "The raise was the last aggressive action on the river, even though the small blind placed the first bet.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_checked_river",
        Act0TaskFamilyV1.transfer,
        "In this room, when the river is checked around, the first live seat left of the button shows first. The player immediately left of the button has folded. The next seat and the button are still in. The button bet the turn, and both players check the river.",
        "Who shows first?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label:
                "The first player still in the hand to the left of the button",
            isCorrect: true,
            preferredLabel:
                "The first player still in the hand to the left of the button",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Under this room’s checked-river rule, skip the folded seat and start with the next live player.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "The button because they bet the turn",
            isCorrect: false,
            preferredLabel:
                "The first player still in the hand to the left of the button",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "This room uses seat order when the river checks through, so the button’s turn bet does not set the showing order.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_table_both",
        Act0TaskFamilyV1.transfer,
        "At showdown, only one of your two hole cards is needed for your best five-card hand.",
        "How should you table your hand to claim the pot?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Show just the card that plays and discard the other",
            isCorrect: false,
            preferredLabel: "Turn both hole cards faceup on the table",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "A single faceup card does not properly table a two-card hold’em hand.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Turn both hole cards faceup on the table",
            isCorrect: true,
            preferredLabel: "Turn both hole cards faceup on the table",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "The dealer needs both cards visible and identifiable as your hand to verify the result.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_cards_speak",
        Act0TaskFamilyV1.review,
        "The river board is A♣ 8♦ 8♠ 4♥ 2♣. You table A♦ K♠ and mistakenly say “one pair.” Your opponent tables Q♣ Q♦.",
        "Who wins?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "You win with aces and eights",
            isCorrect: true,
            preferredLabel: "You win with aces and eights",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Your best five cards are two aces, two eights and a king. That beats queens and eights because the higher pair is compared first. The tabled cards determine the hand.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Your opponent wins because you announced one pair",
            isCorrect: false,
            preferredLabel: "You win with aces and eights",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "A mistaken description does not change the value of your properly tabled hand.",
          ),
        ],
        phase: Act0LessonPhaseV1.review,
      ),
    ]),
    _liveRoomLessonV1("room_fees", "Calculate the cost of play", [
      _liveRoomTaskV1(
        "live_room_rake_below_cap",
        Act0TaskFamilyV1.recognition,
        "This room takes 10% of each eligible pot, capped at \$5. You win an eligible \$30 pot before rake, with no other drops.",
        "How much is pushed to you?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "\$25",
            isCorrect: false,
            preferredLabel: "\$27",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The \$5 cap limits the fee. It is not a flat charge on every pot.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "\$27",
            isCorrect: true,
            preferredLabel: "\$27",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Ten percent of \$30 is \$3, which is below the \$5 cap. The payout is \$30 minus \$3, or \$27.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_rake_above_cap",
        Act0TaskFamilyV1.decision,
        "This room takes 10% of each eligible pot, capped at \$5. You win an eligible \$80 pot before rake, with no other drops.",
        "How much is pushed to you?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "\$75",
            isCorrect: true,
            preferredLabel: "\$75",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Ten percent of \$80 is \$8, so the \$5 cap applies. The payout is \$80 minus \$5, or \$75.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "\$72",
            isCorrect: false,
            preferredLabel: "\$75",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "That would deduct the uncapped \$8. The room stops at \$5.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_rake_win_rate",
        Act0TaskFamilyV1.transfer,
        "Over exactly 100 hands at \$1/\$2, your result with the same pot outcomes before rake would be +\$50. The room takes 10% per eligible pot, capped at \$5, and deducts \$20 in total from pots you win.",
        "How does your win rate change?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "From +25 to +5 BB/100",
            isCorrect: false,
            preferredLabel: "From +25 to +15 BB/100",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The \$20 deduction is 10 BB at \$1/\$2, so subtract 10 BB/100 from the gross rate.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "From +25 to +15 BB/100",
            isCorrect: true,
            preferredLabel: "From +25 to +15 BB/100",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Your net result is \$50 minus \$20, or \$30. At \$2 per big blind, \$50 is 25 BB, \$30 is 15 BB, and the cost is 10 BB over 100 hands.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_time_charge",
        Act0TaskFamilyV1.transfer,
        "A different room charges \$6 per player each half hour instead of taking money from pots. You play 2 hours at \$1/\$2 and are charged for all four half hours.",
        "What do you pay?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "\$24, or 12 BB",
            isCorrect: true,
            preferredLabel: "\$24, or 12 BB",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Four \$6 charges total \$24. Divide by the \$2 big blind to get 12 BB. The charge applies even if you win no pots.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "\$12, or 6 BB",
            isCorrect: false,
            preferredLabel: "\$24, or 12 BB",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "There are four half hours in 2 hours, so you pay four charges rather than two.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_time_win_rate",
        Act0TaskFamilyV1.review,
        "At \$1/\$2 you play 60 hands in 2 hours. You make +\$36 before fees and pay \$6 every half hour, with no pot rake.",
        "What is your net win rate?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "+6 BB/100",
            isCorrect: false,
            preferredLabel: "+10 BB/100",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "You made 6 BB over 60 hands. Multiply by 100/60 to express it per 100 hands.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "+10 BB/100",
            isCorrect: true,
            preferredLabel: "+10 BB/100",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Four charges cost \$24. Your \$12 net is 6 BB in 60 hands, or 10 BB/100. The gross rate was 30 BB/100 and the time charge cost 20 BB/100.",
          ),
        ],
        phase: Act0LessonPhaseV1.review,
      ),
    ]),
    _liveRoomLessonV1("live_open_sizes", "Size a live preflop raise", [
      _liveRoomTaskV1(
        "live_room_unopened",
        Act0TaskFamilyV1.recognition,
        "In this \$1/\$2 live game, an unopened pot commonly gets a 5–6 BB raise. Everyone folds to you and you decide to open.",
        "What dollar range matches this table, and what would a 2.5 BB online-style open be at the same blinds?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Live \$10–\$12, online-style \$5",
            isCorrect: true,
            preferredLabel: "Live \$10–\$12, online-style \$5",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Multiply each size by the \$2 big blind. At this live table the starting size is 5–6 BB, and 2.5 BB is the online comparison.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Live \$5–\$6, online-style \$2.50",
            isCorrect: false,
            preferredLabel: "Live \$10–\$12, online-style \$5",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "The sizes in the question are in big blinds. Each big blind is \$2.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_one_limper",
        Act0TaskFamilyV1.decision,
        "One player has called the \$2 big blind and nobody has raised. You decide to raise. Start from a 5 BB base and add 1 BB for each limper.",
        "What total do you make it?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "\$10 total",
            isCorrect: false,
            preferredLabel: "\$12 total",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "\$10 is the 5 BB base. Add \$2 for the one limper.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "\$12 total",
            isCorrect: true,
            preferredLabel: "\$12 total",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "One player limped, so the total is 5 + 1 = 6 BB. At \$2 per BB that is \$12.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_two_limpers",
        Act0TaskFamilyV1.transfer,
        "Two players have each called the \$2 big blind and nobody has raised. You decide to raise. Start from a 5 BB base and add 1 BB for each limper.",
        "What total do you make it?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "\$14 total",
            isCorrect: true,
            preferredLabel: "\$14 total",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Two limpers add 2 BB to the 5 BB base. The resulting 7 BB is \$14.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "\$12 total",
            isCorrect: false,
            preferredLabel: "\$14 total",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "\$12 adds only 1 BB. Both players who called the blind count as limpers.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
    ]),
    _liveRoomLessonV1("table_etiquette", "Keep the action clear", [
      _liveRoomTaskV1(
        "live_room_early_call_unchanged",
        Act0TaskFamilyV1.recognition,
        "A player bets \$15. You say “call” before the player ahead of you acts. That player folds, leaving the bet at \$15.",
        "What can the dealer rule?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "You always get a fresh choice",
            isCorrect: false,
            preferredLabel: "Your \$15 call stands",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "Speaking early does not automatically cancel a declaration. The dealer checks whether the action changed.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label: "Your \$15 call stands",
            isCorrect: true,
            preferredLabel: "Your \$15 call stands",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "A fold leaves the wager you face unchanged. Under the common convention the dealer can hold you to the early call.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_early_call_changed",
        Act0TaskFamilyV1.decision,
        "A player bets \$15. You say “call” before the player ahead of you acts. That player legally raises to \$40.",
        "What should you do?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Wait for the dealer to confirm your options",
            isCorrect: true,
            preferredLabel: "Wait for the dealer to confirm your options",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "The raise changed what you face. Under the common convention your early \$15 call does not commit you to matching \$40, and the dealer applies the room rule.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label:
                "Put in \$40 because “call” automatically applies to the new price",
            isCorrect: false,
            preferredLabel: "Wait for the dealer to confirm your options",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "You spoke before the raise changed the action. The dealer must resolve the out-of-turn call before you act.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_protect_cards",
        Act0TaskFamilyV1.transfer,
        "You still have a live hand and the dealer is collecting nearby folded cards.",
        "What should you do?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label: "Slide them toward the center so the dealer can see them",
            isCorrect: false,
            preferredLabel:
                "Keep your cards together and visible to the dealer, with a hand or allowed protector resting on them",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "Sliding cards forward can look like a fold and puts them near the discarded cards.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label:
                "Keep your cards together and visible to the dealer, with a hand or allowed protector resting on them",
            isCorrect: true,
            preferredLabel:
                "Keep your cards together and visible to the dealer, with a hand or allowed protector resting on them",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "Keeping control of your cards reduces the risk that they get swept into the pile of discarded cards. A room may be unable to restore them.",
          ),
        ],
        phase: Act0LessonPhaseV1.drill,
      ),
      _liveRoomTaskV1(
        "live_room_announce_all_in",
        Act0TaskFamilyV1.review,
        "It is your turn and you intend to wager your entire stack.",
        "How can you make that clear?",
        [
          Act0RunnerOptionV1(
            id: "a",
            label:
                "Say “all-in” clearly before moving chips, and keep the full stack visible",
            isCorrect: true,
            preferredLabel:
                "Say “all-in” clearly before moving chips, and keep the full stack visible",
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Correct',
            feedbackReason:
                "An unambiguous declaration in turn communicates the full-stack wager. Keeping the chips visible lets the dealer verify the amount.",
          ),
          Act0RunnerOptionV1(
            id: "b",
            label:
                "Silently put out one large chip and leave the rest of your stack behind",
            isCorrect: false,
            preferredLabel:
                "Say “all-in” clearly before moving chips, and keep the full stack visible",
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Try again',
            feedbackReason:
                "A single chip can be interpreted as a call when facing a bet or as a bet for the chip’s value in an unopened round. It does not clearly commit the full stack.",
          ),
        ],
        phase: Act0LessonPhaseV1.review,
      ),
    ]),
  ],
);

typedef _LiveRoomTaskV1 = ({
  String id,
  Act0TaskFamilyV1 family,
  String premise,
  String question,
  List<Act0RunnerOptionV1> options,
  Act0LessonPhaseV1 phase,
});

_LiveRoomTaskV1 _liveRoomTaskV1(
  String id,
  Act0TaskFamilyV1 family,
  String premise,
  String question,
  List<Act0RunnerOptionV1> options, {
  required Act0LessonPhaseV1 phase,
}) => (
  id: id,
  family: family,
  premise: premise,
  question: question,
  options: List.unmodifiable(options),
  phase: phase,
);

Act0LessonCardV1 _liveRoomLessonV1(
  String id,
  String title,
  List<_LiveRoomTaskV1> authored,
) {
  final tasks = <Act0LessonTaskV1>[
    for (final (index, task) in authored.indexed)
      Act0LessonTaskV1(
        taskId: task.id,
        title: task.question,
        phase: task.phase,
        taskFamily: task.family,
        stepKind: task.phase == Act0LessonPhaseV1.review
            ? Act0LessonStepKindV1.review
            : Act0LessonStepKindV1.practice,
        rewardXp: 0,
        runner: Act0RunnerStateV1(
          lessonId: id,
          lessonTitle: title,
          lessonSubtitle: 'Live Room',
          beatIndex: index + 1,
          beatCount: authored.length,
          phase: task.phase,
          caption: task.premise,
          hint: '',
          question: task.question,
          options: task.options,
          feedbackTitle: 'Correct',
          feedbackReason: task.options
              .singleWhere((option) => option.isCorrect)
              .feedbackReason,
          primaryCtaLabel: 'Continue',
          nextLessonId: null,
          returnTarget: 'learn',
          table: _liveRoomExplanationV1,
        ),
      ),
  ];
  return Act0LessonCardV1(
    lessonId: id,
    title: title,
    subtitle: 'Live Room',
    state: Act0LessonStateV1.available,
    phaseLabel: 'Practice',
    primaryCtaLabel: 'Start',
    isSelectable: true,
    isLocked: false,
    rewardXp: 0,
    runner: tasks.first.runner,
    tasks: List.unmodifiable(tasks),
  );
}

const _liveRoomExplanationV1 = Act0TableStateV1(
  scope: Act0TableScopeV1.explanation,
  showDecisionPremise: true,
  tableFormat: Act0TableFormatV1.sixMax,
  playerCount: 0,
  seats: [],
  heroCards: [],
  boardCards: [],
  streetLabel: '',
  potLabel: '',
  toCallLabel: '',
  centerLabel: '',
  highlightedSeatIds: [],
  highlightedCardIds: [],
);

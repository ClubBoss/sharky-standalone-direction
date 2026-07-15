import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_presentation_config_v1.dart';

void main() {
  Future<void> pump(WidgetTester tester, Act0TableIdentityPolicyV1 policy) =>
      tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 344,
            height: 598,
            child: Act0TableSceneV1(
              table: _table,
              config: Act0TablePresentationConfigV1(
                identityPolicy: policy,
                maxTableHeight: 1000,
              ),
            ),
          ),
        ),
      );
  final dealer = find.byKey(const Key('act0_shell_marker_hero_dealer'));

  testWidgets(
    'learner position keeps exactly one canonical dealer disc while learner-only hides it',
    (tester) async {
      await pump(tester, Act0TableIdentityPolicyV1.currentProduction);
      expect(dealer, findsOneWidget);
      await pump(tester, Act0TableIdentityPolicyV1.learnerOnly);
      expect(dealer, findsNothing);
      await pump(tester, Act0TableIdentityPolicyV1.learnerPosition);
      expect(dealer, findsOneWidget);
      final puckRect = tester.getRect(dealer);
      final heroIdentityRect = tester.getRect(
        find.byKey(const Key('act0_shell_hero_identity_hero')),
      );
      final tableRect = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      expect(puckRect.width, greaterThan(0));
      expect(puckRect.height, greaterThan(0));
      expect(tableRect.contains(puckRect.topLeft), isTrue);
      expect(tableRect.contains(puckRect.bottomRight), isTrue);
      expect(puckRect.overlaps(heroIdentityRect), isFalse);
      expect(
        find.byKey(const Key('act0_shell_wave1_hero_you_badge')),
        findsOneWidget,
      );
      await pump(
        tester,
        Act0TableIdentityPolicyV1.learnerPositionAndDealerOrder,
      );
      expect(dealer, findsOneWidget);
      expect(find.text('BTN'), findsWidgets);
    },
  );
}

const _table = Act0TableStateV1(
  tableFormat: Act0TableFormatV1.sixMax,
  playerCount: 3,
  streetLabel: 'Flop',
  potLabel: 'Pot 3 BB',
  toCallLabel: 'Call 1 BB',
  centerLabel: 'No bet yet',
  heroCards: <Act0CardStateV1>[
    Act0CardStateV1(rank: 'A', suit: '♠'),
    Act0CardStateV1(rank: 'K', suit: '♦', tone: Act0CardToneV1.red),
  ],
  boardCards: <Act0CardStateV1>[
    Act0CardStateV1(rank: 'A', suit: '♥', tone: Act0CardToneV1.red),
    Act0CardStateV1(rank: '7', suit: '♣'),
    Act0CardStateV1(rank: '2', suit: '♦', tone: Act0CardToneV1.red),
  ],
  seats: <Act0SeatStateV1>[
    Act0SeatStateV1(
      seatId: 'hero',
      seatLabel: 'BTN',
      displayName: 'Hero',
      isHero: true,
      isDealerButton: true,
    ),
    Act0SeatStateV1(
      seatId: 'sb',
      seatLabel: 'SB',
      displayName: 'Small blind',
      isSmallBlind: true,
    ),
    Act0SeatStateV1(
      seatId: 'bb',
      seatLabel: 'BB',
      displayName: 'Big blind',
      isBigBlind: true,
    ),
  ],
  highlightedSeatIds: <String>[],
  highlightedCardIds: <String>[],
  heroSeatId: 'hero',
);

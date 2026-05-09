import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_seat_state_badge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_seat_body_contract_v1.dart';

void main() {
  testWidgets('world1 canonical seat body renders badges and label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: buildWorld1CanonicalSeatBodyV1(
              const World1CanonicalSeatBodyContractV1(
                displaySeatId: 'btn',
                logicalSeatId: 'btn',
                labelText: 'BTN',
                seatSize: 56,
                seatColor: Colors.blueGrey,
                textColor: Colors.white,
                borderColor: Colors.cyan,
                borderWidth: 2,
                opacity: 1,
                glowShadows: null,
                canRotateSeatDisplay: true,
                rotatingHeroSeatId: 'btn',
                showHeroBadge: true,
                showActBadge: true,
                showFoldBadge: false,
                showOutBadge: false,
                tablePracticeSession: false,
                canonicalOrderBadgeText: null,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('BTN'), findsOneWidget);
    expect(find.text('HERO'), findsOneWidget);
    expect(find.text('ACT'), findsOneWidget);
    expect(
      find.byKey(const Key('microtask_hero_display_btn_v1')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<RunnerSeatStateBadgeV1>(
            find.byKey(const Key('microtask_seat_state_badge_hero_v1')),
          )
          .visualPriorityV1,
      RunnerSeatStateBadgePriorityV1.primary,
    );
    expect(
      tester
          .widget<RunnerSeatStateBadgeV1>(
            find.byKey(const Key('microtask_seat_state_badge_act_v1')),
          )
          .visualPriorityV1,
      RunnerSeatStateBadgePriorityV1.primary,
    );
  });

  testWidgets('world1 canonical seat body renders fold and out states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: buildWorld1CanonicalSeatBodyV1(
              const World1CanonicalSeatBodyContractV1(
                displaySeatId: 'sb',
                logicalSeatId: 'sb',
                labelText: 'SB',
                seatSize: 48,
                seatColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.white,
                borderWidth: 1.5,
                opacity: 0.7,
                glowShadows: null,
                canRotateSeatDisplay: false,
                rotatingHeroSeatId: null,
                showHeroBadge: false,
                showActBadge: false,
                showFoldBadge: true,
                showOutBadge: true,
                tablePracticeSession: true,
                canonicalOrderBadgeText: '2 Small Blind',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('SB'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('OUT'), findsOneWidget);
    expect(find.text('2 Small Blind'), findsOneWidget);
    expect(find.byKey(const Key('table_practice_seat_sb')), findsOneWidget);
    expect(
      tester
          .widget<RunnerSeatStateBadgeV1>(
            find.byKey(const Key('microtask_seat_state_badge_folded_sb')),
          )
          .visualPriorityV1,
      RunnerSeatStateBadgePriorityV1.secondary,
    );
    expect(
      tester
          .widget<RunnerSeatStateBadgeV1>(
            find.byKey(const Key('microtask_seat_state_badge_out_sb')),
          )
          .visualPriorityV1,
      RunnerSeatStateBadgePriorityV1.secondary,
    );
    expect(
      tester
          .widget<RunnerSeatStateBadgeV1>(
            find.byKey(const Key('microtask_seat_order_badge_sb_v1')),
          )
          .visualPriorityV1,
      RunnerSeatStateBadgePriorityV1.secondary,
    );
  });
}

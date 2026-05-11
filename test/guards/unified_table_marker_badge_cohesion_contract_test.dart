import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_seat_state_badge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_seat_body_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_marker_contract_v1.dart';

void main() {
  testWidgets(
    'world1 seat state hierarchy keeps hero/act primary while demoting order and folded state',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: buildWorld1CanonicalSeatBodyV1(
                const World1CanonicalSeatBodyContractV1(
                  displaySeatId: 'sb',
                  logicalSeatId: 'sb',
                  labelText: 'SB',
                  canonicalOrderBadgeText: '2',
                  seatSize: 56,
                  seatColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.white,
                  borderWidth: 1.5,
                  opacity: 1,
                  glowShadows: null,
                  canRotateSeatDisplay: false,
                  rotatingHeroSeatId: null,
                  showHeroBadge: true,
                  showActBadge: true,
                  showFoldBadge: true,
                  showOutBadge: false,
                  tablePracticeSession: false,
                ),
              ),
            ),
          ),
        ),
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
              find.byKey(const Key('microtask_seat_order_badge_sb_v1')),
            )
            .visualPriorityV1,
        RunnerSeatStateBadgePriorityV1.secondary,
      );
    },
  );

  testWidgets(
    'world1 blind cue markers reuse the shared secondary badge shell',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildWorld1CanonicalChipStackBadgeV1(
                  label: 'SB',
                  amount: 1,
                  chipSize: 10,
                  compact: true,
                ),
                buildWorld1CanonicalChipStackBadgeV1(
                  label: 'D',
                  amount: 0,
                  chipSize: 10,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      );

      final shells = tester
          .widgetList<RunnerSeatStateBadgeShellV1>(
            find.byType(RunnerSeatStateBadgeShellV1),
          )
          .toList(growable: false);

      expect(shells, hasLength(2));
      expect(
        shells[0].tone,
        RunnerSeatStateBadgeToneV1.forcedBet,
        reason: 'SB/BB markers should use the calmer forced-bet badge grammar.',
      );
      expect(
        shells[0].visualPriorityV1,
        RunnerSeatStateBadgePriorityV1.secondary,
      );
      expect(shells[1].tone, RunnerSeatStateBadgeToneV1.neutral);
      expect(
        shells[1].visualPriorityV1,
        RunnerSeatStateBadgePriorityV1.secondary,
      );
      expect(find.text('SB'), findsOneWidget);
      expect(find.text('0.5'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    },
  );
}

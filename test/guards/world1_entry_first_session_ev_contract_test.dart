import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_runner_authority_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  test('world1 entry keeps table-literacy seat-first and graduates later packs into action decisions', () {
    final tablePack = world1MicroTaskPackFor('world1_act0_table_literacy');
    final actionPack = world1MicroTaskPackFor('world1_act0_action_literacy');
    final streetPack = world1MicroTaskPackFor('world1_act0_street_flow');

    final tableMode = resolveWorld1CanonicalRunnerModeV1(
      isWorld2SeatQuizBeat: false,
      stepIndicatesActionDecision:
          (tablePack.first.allowedActions?.isNotEmpty ?? false) ||
          world1SpineExpectedActionKindV1(tablePack.first) != null,
      isCampaignSpineSession: true,
      packContainsTableLiteracy: true,
      hasCampaignPointer: false,
      replayerHasSteps: false,
      legalActionsPresent: false,
      engineInteropAvailable: false,
    );
    final actionMode = resolveWorld1CanonicalRunnerModeV1(
      isWorld2SeatQuizBeat: false,
      stepIndicatesActionDecision:
          (actionPack.first.allowedActions?.isNotEmpty ?? false) ||
          world1SpineExpectedActionKindV1(actionPack.first) != null,
      isCampaignSpineSession: true,
      packContainsTableLiteracy: false,
      hasCampaignPointer: false,
      replayerHasSteps: false,
      legalActionsPresent: false,
      engineInteropAvailable: false,
    );
    final streetMode = resolveWorld1CanonicalRunnerModeV1(
      isWorld2SeatQuizBeat: false,
      stepIndicatesActionDecision:
          (streetPack.first.allowedActions?.isNotEmpty ?? false) ||
          world1SpineExpectedActionKindV1(streetPack.first) != null,
      isCampaignSpineSession: true,
      packContainsTableLiteracy: false,
      hasCampaignPointer: false,
      replayerHasSteps: false,
      legalActionsPresent: false,
      engineInteropAvailable: false,
    );

    expect(tableMode, World1CanonicalRunnerModeV1.seatQuiz);
    expect(actionMode, World1CanonicalRunnerModeV1.handLoop);
    expect(streetMode, World1CanonicalRunnerModeV1.handLoop);
  });

  test('world1 entry action pack now ships a clean raise-call-fold progression', () {
    final pack = world1MicroTaskPackFor('world1_act0_action_literacy');

    expect(pack, hasLength(3));
    expect(pack.map((step) => step.expectedActionKind).toList(), <String?>[
      'raise',
      'call',
      'fold',
    ]);
    expect(
      pack.map((step) => step.heroSeatId).toList(),
      <String?>['BTN', 'BB', 'SB'],
    );
  });

  test('world1 entry street-flow pack now proves flop-turn-river contrast directly', () {
    final pack = world1MicroTaskPackFor('world1_act0_street_flow');

    expect(pack, hasLength(3));
    expect(
      pack.map((step) => step.street).toList(),
      <MicroTaskStreetV1?>[
        MicroTaskStreetV1.flop,
        MicroTaskStreetV1.turn,
        MicroTaskStreetV1.river,
      ],
    );
    expect(pack.map((step) => step.expectedActionKind).toList(), <String?>[
      'bet',
      'call',
      'fold',
    ]);
  });
}

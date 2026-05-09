import 'package:test/test.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';

void main() {
  test('canonical shared learner host grammar stays deterministic', () {
    expect(
      kCanonicalSharedLearnerHostGrammarProfileV1.id,
      'canonicalLearnerHostGrammarV1',
    );
    expect(
      kCanonicalSharedLearnerHostGrammarProfileV1.primitives
          .map(sharedLearnerHostPrimitiveIdV1)
          .toList(growable: false),
      const <String>[
        'progression_chrome',
        'completion_surface',
        'prompt_status_capsule',
        'seat_state_badge',
        'compact_header_band',
        'scene_support_lane',
        'bottom_action_hierarchy',
      ],
    );
    expect(
      kCanonicalSharedLearnerHostGrammarProfileV1.remainingGaps
          .map(sharedLearnerHostGapIdV1)
          .toList(growable: false),
      isEmpty,
    );
  });

  test('world1 shared learner host grammar stays deterministic', () {
    expect(
      kWorld1SharedLearnerHostGrammarProfileV1.id,
      'world1SharedLearnerHostGrammarV1',
    );
    expect(
      kWorld1SharedLearnerHostGrammarProfileV1.primitives
          .map(sharedLearnerHostPrimitiveIdV1)
          .toList(growable: false),
      const <String>[
        'progression_chrome',
        'completion_surface',
        'prompt_status_capsule',
        'seat_state_badge',
        'compact_header_band',
        'scene_support_lane',
        'bottom_action_hierarchy',
      ],
    );
    expect(
      kWorld1SharedLearnerHostGrammarProfileV1.remainingGaps
          .map(sharedLearnerHostGapIdV1)
          .toList(growable: false),
      isEmpty,
    );
  });

  test('current migrated host families resolve to truthful shared grammar', () {
    final canonicalSurfacedSessionAdoption =
        resolveSharedLearnerHostGrammarAdoptionV1(
          hostFamily: 'sessionDrillPlayer',
          screenFamily: 'CanonicalTerminalSessionDrillSurfacedRunnerV1',
          itemType: 'session',
          modeFamily: 'sessionDrillSingleStep',
        );
    final sessionAdoption = resolveSharedLearnerHostGrammarAdoptionV1(
      hostFamily: 'sessionDrillPlayer',
      screenFamily: 'SessionDrillPlayerV1Screen',
      itemType: 'session',
      modeFamily: 'sessionDrillSingleStep',
    );
    final world1Adoption = resolveSharedLearnerHostGrammarAdoptionV1(
      hostFamily: 'world1FoundationsRunner',
      screenFamily: 'World1FoundationsMicroTaskRunnerScreen',
      itemType: 'campaign_pack',
      modeFamily: 'campaignSpine',
    );

    expect(canonicalSurfacedSessionAdoption, isNotNull);
    expect(sessionAdoption, isNotNull);
    expect(world1Adoption, isNotNull);
    expect(
      canonicalSurfacedSessionAdoption!.profile.id,
      kCanonicalSharedLearnerHostGrammarIdV1,
    );
    expect(sessionAdoption!.profile.id, kCanonicalSharedLearnerHostGrammarIdV1);
    expect(world1Adoption!.profile.id, kWorld1SharedLearnerHostGrammarIdV1);
  });

  test(
    'session drill wrapper normalizes to one canonical implementation owner',
    () {
      final sessionAdoptions = kSharedLearnerHostGrammarAdoptionsV1
          .where((adoption) => adoption.hostFamily == 'sessionDrillPlayer')
          .toList(growable: false);

      expect(
        sessionAdoptions.where(
          (adoption) =>
              adoption.screenFamily ==
              'CanonicalTerminalSessionDrillSurfacedRunnerV1',
        ),
        hasLength(1),
      );
      expect(
        sessionAdoptions.where(
          (adoption) => adoption.screenFamily == 'SessionDrillPlayerV1Screen',
        ),
        isEmpty,
      );
      expect(
        normalizeSharedLearnerHostScreenFamilyV1(
          'SessionDrillPlayerV1Screen',
        ),
        'CanonicalTerminalSessionDrillSurfacedRunnerV1',
      );
    },
  );

  test('world1 campaign spine and seat quiz slices share one active grammar', () {
    final campaignSpineAdoption = resolveSharedLearnerHostGrammarAdoptionV1(
      hostFamily: 'world1FoundationsRunner',
      screenFamily: 'World1FoundationsMicroTaskRunnerScreen',
      itemType: 'campaign_pack',
      modeFamily: 'campaignSpine',
    );
    final seatQuizAdoption = resolveSharedLearnerHostGrammarAdoptionV1(
      hostFamily: 'world1FoundationsRunner',
      screenFamily: 'World1FoundationsMicroTaskRunnerScreen',
      itemType: 'campaign_pack',
      modeFamily: 'seatQuiz',
    );

    expect(campaignSpineAdoption, isNotNull);
    expect(seatQuizAdoption, isNotNull);
    expect(
      campaignSpineAdoption!.profile.id,
      kWorld1SharedLearnerHostGrammarIdV1,
    );
    expect(
      seatQuizAdoption!.profile.id,
      kWorld1SharedLearnerHostGrammarIdV1,
    );
  });

  test(
    'legacy drill runner factual slice is not yet claimed as canonical host grammar',
    () {
      final drillRunnerAdoption = resolveSharedLearnerHostGrammarAdoptionV1(
        hostFamily: 'drillRunner',
        screenFamily: 'DrillRunnerScreen',
        itemType: 'legacy_factual_drill',
        modeFamily: 'factualLegacy',
      );

      expect(drillRunnerAdoption, isNull);
    },
  );
}

import 'dart:convert';

final RegExp _kCardIdV1Pattern = RegExp(r'^[AKQJT98765432][shdc]$');
final RegExp _kIntentIdV1Pattern = RegExp(r'^[a-z0-9_]+$');
const Set<String> _kPositionQuestionShapesV1 = <String>{
  'in_position',
  'out_of_position',
  'acts_later',
};
const Set<String> _kInitiativePolicyShapesV1 = <String>{'pressure_owner'};
const Set<String> _kBoardTexturePolicyShapesV1 = <String>{'pressure_level'};
const Set<String> _kBoardTexturePolicyTargetsV1 = <String>{
  'calmer',
  'pressure_building',
};

enum DrillKindV1 {
  seatTap,
  actionChoice,
  boardTap,
  holeCardsTap,
  betSizingChoice,
  showdownWinnerChoice,
  positionThinkingChoice,
  initiativeAggressorChoice,
  outsCountChoice,
  boardTextureClassifier,
  rangeBucketClassifier,
  handChain,
}

enum DrillUserEventKindV1 { seatTap, actionChoice, boardTap, holeCardsTap }

class DrillExpectedV1 {
  const DrillExpectedV1({
    this.seatId,
    this.role,
    this.actionId,
    this.presetId,
    this.boardSlot,
    this.cardSlot,
    this.cardId,
  });

  final String? seatId;
  final String? role;
  final String? actionId;
  final String? presetId;
  final String? boardSlot;
  final String? cardSlot;
  final String? cardId;

  factory DrillExpectedV1.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw const FormatException('expected must not be empty');
    }
    final cardId = json['cardId'];
    if (cardId != null) {
      if (cardId is! String || !_isCardIdV1(cardId)) {
        throw const FormatException(
          'expected.cardId must match card id format [AKQJT98765432][shdc]',
        );
      }
    }
    return DrillExpectedV1(
      seatId: json['seatId'] as String?,
      role: json['role'] as String?,
      actionId: json['actionId'] as String?,
      presetId: json['presetId'] as String?,
      boardSlot: json['boardSlot'] as String?,
      cardSlot: _normalizeHoleCardSlotV1(json['cardSlot']),
      cardId: cardId as String?,
    );
  }
}

class DrillScenarioCoreV1 {
  const DrillScenarioCoreV1({
    this.introV1,
    this.recapV1,
    this.streetV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
    this.acceptableActionsV1,
    this.feedbackAcceptableV1,
    this.feedbackCorrectV1,
    this.feedbackIncorrectByActionV1,
    this.feedbackIncorrectV1,
  });

  final String? introV1;
  final String? recapV1;
  final String? streetV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
  final List<String>? acceptableActionsV1;
  final String? feedbackAcceptableV1;
  final String? feedbackCorrectV1;
  final Map<String, String>? feedbackIncorrectByActionV1;
  final String? feedbackIncorrectV1;
}

class DrillScenarioSeatContextV1 {
  const DrillScenarioSeatContextV1({
    required this.playerCountV1,
    required this.heroSeatV1,
    required this.villainSeatV1,
    required this.activeSeatsV1,
    this.foldedSeatsV1,
    this.emptySeatsV1,
    this.lastAggressorV1,
    this.initiativeOwnerV1,
    this.blindLevelV1,
  });

  final int playerCountV1;
  final String heroSeatV1;
  final String villainSeatV1;
  final List<String> activeSeatsV1;
  final List<String>? foldedSeatsV1;
  final List<String>? emptySeatsV1;
  final String? lastAggressorV1;
  final String? initiativeOwnerV1;
  final DrillScenarioBlindLevelContextV1? blindLevelV1;
}

class DrillScenarioBlindLevelContextV1 {
  const DrillScenarioBlindLevelContextV1({
    required this.smallBlindSeatV1,
    required this.bigBlindSeatV1,
    required this.smallBlindAmountV1,
    required this.bigBlindAmountV1,
    this.anteAmountV1,
  });

  final String smallBlindSeatV1;
  final String bigBlindSeatV1;
  final int smallBlindAmountV1;
  final int bigBlindAmountV1;
  final int? anteAmountV1;
}

class DrillScenarioBoardContextV1 {
  const DrillScenarioBoardContextV1({this.boardCardsV1, this.heroHoleCardsV1});

  final List<String>? boardCardsV1;
  final List<String>? heroHoleCardsV1;
}

class DrillScenarioTableContextV1 {
  const DrillScenarioTableContextV1({this.seatContextV1, this.boardContextV1});

  final DrillScenarioSeatContextV1? seatContextV1;
  final DrillScenarioBoardContextV1? boardContextV1;
}

class DrillScenarioOutsContextV1 {
  const DrillScenarioOutsContextV1({
    required this.streetV1,
    required this.heroHoleCardsV1,
    required this.boardCardsV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
  });

  final String streetV1;
  final List<String> heroHoleCardsV1;
  final List<String> boardCardsV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
}

class DrillScenarioShowdownContextV1 {
  const DrillScenarioShowdownContextV1({
    required this.streetV1,
    required this.heroHoleCardsV1,
    required this.villainHoleCardsV1,
    required this.boardCardsV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
  });

  final String streetV1;
  final List<String> heroHoleCardsV1;
  final List<String> villainHoleCardsV1;
  final List<String> boardCardsV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
}

class DrillScenarioBoardTapContextV1 {
  const DrillScenarioBoardTapContextV1({required this.expectedBoardSlotV1});

  final String expectedBoardSlotV1;
}

class DrillScenarioSeatTapContextV1 {
  const DrillScenarioSeatTapContextV1({
    this.expectedSeatIdV1,
    this.expectedRoleV1,
  });

  final String? expectedSeatIdV1;
  final String? expectedRoleV1;
}

class DrillScenarioInitiativeContextV1 {
  const DrillScenarioInitiativeContextV1({
    required this.streetV1,
    required this.playerCountV1,
    required this.heroSeatV1,
    required this.villainSeatV1,
    required this.activeSeatsV1,
    required this.lastAggressorV1,
    required this.initiativeOwnerV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
  });

  final String streetV1;
  final int playerCountV1;
  final String heroSeatV1;
  final String villainSeatV1;
  final List<String> activeSeatsV1;
  final String lastAggressorV1;
  final String initiativeOwnerV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
}

class DrillScenarioPositionContextV1 {
  const DrillScenarioPositionContextV1({
    required this.streetV1,
    required this.playerCountV1,
    required this.heroSeatV1,
    required this.villainSeatV1,
    required this.activeSeatsV1,
    this.foldedSeatsV1,
    this.emptySeatsV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
  });

  final String streetV1;
  final int playerCountV1;
  final String heroSeatV1;
  final String villainSeatV1;
  final List<String> activeSeatsV1;
  final List<String>? foldedSeatsV1;
  final List<String>? emptySeatsV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
}

class DrillScenarioBoardTextureContextV1 {
  const DrillScenarioBoardTextureContextV1({
    required this.streetV1,
    required this.boardCardsV1,
    required this.boardTextureV1,
    this.availableActionsV1,
    this.expectedActionIdV1,
  });

  final String streetV1;
  final List<String> boardCardsV1;
  final String boardTextureV1;
  final List<String>? availableActionsV1;
  final String? expectedActionIdV1;
}

class DrillScenarioActionFollowUpV1 {
  const DrillScenarioActionFollowUpV1({
    required this.tableContextV1,
    required this.availableActionsV1,
    required this.expectedActionIdV1,
  });

  final DrillScenarioTableContextV1 tableContextV1;
  final List<String> availableActionsV1;
  final String expectedActionIdV1;
}

class DrillScenarioHandChainStepContextV1 {
  const DrillScenarioHandChainStepContextV1({
    required this.coreV1,
    this.tableContextV1,
    this.actionFollowUpV1,
    this.questionShapeV1,
    this.promptV1,
    this.whyV1,
    this.expectedPresetIdV1,
    this.acceptablePresetIdsV1,
    this.rangeBucketV1,
  });

  final DrillScenarioCoreV1 coreV1;
  final DrillScenarioTableContextV1? tableContextV1;
  final DrillScenarioActionFollowUpV1? actionFollowUpV1;
  final String? questionShapeV1;
  final String? promptV1;
  final String? whyV1;
  final String? expectedPresetIdV1;
  final List<String>? acceptablePresetIdsV1;
  final String? rangeBucketV1;
}

class DrillScenarioHandChainContextV1 {
  const DrillScenarioHandChainContextV1({
    required this.chainIdV1,
    required this.stepsV1,
  });

  final String chainIdV1;
  final List<DrillScenarioHandChainStepContextV1> stepsV1;

  int get stepCountV1 => stepsV1.length;

  DrillScenarioHandChainStepContextV1? stepAtIndexV1(int index) {
    if (index < 0 || index >= stepsV1.length) {
      return null;
    }
    return stepsV1[index];
  }
}

class DrillSpecV1 {
  const DrillSpecV1({
    required this.id,
    required this.kind,
    required this.prompt,
    required this.expected,
    required this.errorClass,
    this.intentV1,
    this.questionShapeV1,
    this.initiativePolicyShapeV1,
    this.boardTexturePolicyShapeV1,
    this.boardTexturePolicyTargetV1,
    this.whyV1,
    this.acceptableActions,
    this.acceptablePresetIds,
    this.boardTextureV1,
    this.availableActionsV1,
    this.streetV1,
    this.boardCardsV1,
    this.playerCountV1,
    this.heroSeatV1,
    this.villainSeatV1,
    this.activeSeatsV1,
    this.foldedSeatsV1,
    this.emptySeatsV1,
    this.lastAggressorV1,
    this.initiativeOwnerV1,
    this.smallBlindSeatV1,
    this.bigBlindSeatV1,
    this.smallBlindAmountV1,
    this.bigBlindAmountV1,
    this.anteAmountV1,
    this.pressureOwnerV1,
    this.heroHoleCardsV1,
    this.villainHoleCardsV1,
    this.introV1,
    this.recapV1,
    this.feedbackAcceptableV1,
    this.feedbackCorrectV1,
    this.feedbackIncorrectByActionV1,
    this.feedbackIncorrectV1,
    this.expectedActionV1,
    this.rangeBucketV1,
    this.chainIdV1,
    this.chainStepsV1,
  });

  final String id;
  final DrillKindV1 kind;
  final String prompt;
  final DrillExpectedV1 expected;
  final String errorClass;
  final String? intentV1;
  final String? questionShapeV1;
  final String? initiativePolicyShapeV1;
  final String? boardTexturePolicyShapeV1;
  final String? boardTexturePolicyTargetV1;
  final String? whyV1;
  final List<String>? acceptableActions;
  final List<String>? acceptablePresetIds;
  final String? boardTextureV1;
  final List<String>? availableActionsV1;
  final String? streetV1;
  final List<String>? boardCardsV1;
  final int? playerCountV1;
  final String? heroSeatV1;
  final String? villainSeatV1;
  final List<String>? activeSeatsV1;
  final List<String>? foldedSeatsV1;
  final List<String>? emptySeatsV1;
  final String? lastAggressorV1;
  final String? initiativeOwnerV1;
  final String? smallBlindSeatV1;
  final String? bigBlindSeatV1;
  final int? smallBlindAmountV1;
  final int? bigBlindAmountV1;
  final int? anteAmountV1;
  final String? pressureOwnerV1;
  final List<String>? heroHoleCardsV1;
  final List<String>? villainHoleCardsV1;
  final String? introV1;
  final String? recapV1;
  final String? feedbackAcceptableV1;
  final String? feedbackCorrectV1;
  final Map<String, String>? feedbackIncorrectByActionV1;
  final String? feedbackIncorrectV1;
  final String? expectedActionV1;
  final String? rangeBucketV1;
  final String? chainIdV1;
  final List<DrillChainStepV1>? chainStepsV1;

  DrillScenarioCoreV1 get scenarioCoreV1 {
    return DrillScenarioCoreV1(
      introV1: introV1,
      recapV1: recapV1,
      streetV1: streetV1,
      availableActionsV1: availableActionsV1,
      expectedActionIdV1: expected.actionId ?? expectedActionV1,
      acceptableActionsV1: acceptableActions,
      feedbackAcceptableV1: feedbackAcceptableV1,
      feedbackCorrectV1: feedbackCorrectV1,
      feedbackIncorrectByActionV1: feedbackIncorrectByActionV1,
      feedbackIncorrectV1: feedbackIncorrectV1,
    );
  }

  DrillScenarioSeatContextV1? get scenarioSeatContextV1 {
    if (playerCountV1 == null ||
        heroSeatV1 == null ||
        villainSeatV1 == null ||
        activeSeatsV1 == null) {
      return null;
    }
    final blindLevel = _scenarioBlindLevelContextFromValuesV1(
      smallBlindSeatV1: smallBlindSeatV1,
      bigBlindSeatV1: bigBlindSeatV1,
      smallBlindAmountV1: smallBlindAmountV1,
      bigBlindAmountV1: bigBlindAmountV1,
      anteAmountV1: anteAmountV1,
      fieldPrefix: 'drill',
    );
    return DrillScenarioSeatContextV1(
      playerCountV1: playerCountV1!,
      heroSeatV1: heroSeatV1!,
      villainSeatV1: villainSeatV1!,
      activeSeatsV1: activeSeatsV1!,
      foldedSeatsV1: foldedSeatsV1,
      emptySeatsV1: emptySeatsV1,
      lastAggressorV1: lastAggressorV1,
      initiativeOwnerV1: initiativeOwnerV1,
      blindLevelV1: blindLevel,
    );
  }

  DrillScenarioBoardContextV1? get scenarioBoardContextV1 {
    if (boardCardsV1 == null && heroHoleCardsV1 == null) {
      return null;
    }
    return DrillScenarioBoardContextV1(
      boardCardsV1: boardCardsV1,
      heroHoleCardsV1: heroHoleCardsV1,
    );
  }

  DrillScenarioTableContextV1? get scenarioTableContextV1 {
    final seatContext = scenarioSeatContextV1;
    final boardContext = scenarioBoardContextV1;
    if (seatContext == null && boardContext == null) {
      return null;
    }
    return DrillScenarioTableContextV1(
      seatContextV1: seatContext,
      boardContextV1: boardContext,
    );
  }

  DrillScenarioOutsContextV1? get scenarioOutsContextV1 {
    final street = scenarioCoreV1.streetV1;
    final boardContext = scenarioBoardContextV1;
    final heroHoleCards = boardContext?.heroHoleCardsV1;
    final boardCards = boardContext?.boardCardsV1;
    if (street == null ||
        heroHoleCards == null ||
        heroHoleCards.length != 2 ||
        boardCards == null ||
        boardCards.isEmpty) {
      return null;
    }
    return DrillScenarioOutsContextV1(
      streetV1: street,
      heroHoleCardsV1: heroHoleCards,
      boardCardsV1: boardCards,
      availableActionsV1: scenarioCoreV1.availableActionsV1,
      expectedActionIdV1: scenarioCoreV1.expectedActionIdV1,
    );
  }

  DrillScenarioShowdownContextV1? get scenarioShowdownContextV1 {
    final street = scenarioCoreV1.streetV1;
    final boardContext = scenarioBoardContextV1;
    final heroHoleCards = boardContext?.heroHoleCardsV1;
    final boardCards = boardContext?.boardCardsV1;
    final villainHoleCards = villainHoleCardsV1;
    if (street == null ||
        heroHoleCards == null ||
        heroHoleCards.length != 2 ||
        villainHoleCards == null ||
        villainHoleCards.length != 2 ||
        boardCards == null ||
        boardCards.length != 5) {
      return null;
    }
    return DrillScenarioShowdownContextV1(
      streetV1: street,
      heroHoleCardsV1: heroHoleCards,
      villainHoleCardsV1: villainHoleCards,
      boardCardsV1: boardCards,
      availableActionsV1: scenarioCoreV1.availableActionsV1,
      expectedActionIdV1: scenarioCoreV1.expectedActionIdV1,
    );
  }

  DrillScenarioBoardTapContextV1? get scenarioBoardTapContextV1 {
    final expectedBoardSlot = expected.boardSlot?.trim().toLowerCase();
    if (kind != DrillKindV1.boardTap ||
        expectedBoardSlot == null ||
        expectedBoardSlot.isEmpty) {
      return null;
    }
    return DrillScenarioBoardTapContextV1(
      expectedBoardSlotV1: expectedBoardSlot,
    );
  }

  DrillScenarioSeatTapContextV1? get scenarioSeatTapContextV1 {
    final expectedSeatId = expected.seatId?.trim();
    final expectedRole = expected.role?.trim().toLowerCase();
    if (kind != DrillKindV1.seatTap ||
        ((expectedSeatId == null || expectedSeatId.isEmpty) &&
            (expectedRole == null || expectedRole.isEmpty))) {
      return null;
    }
    return DrillScenarioSeatTapContextV1(
      expectedSeatIdV1: expectedSeatId,
      expectedRoleV1: expectedRole,
    );
  }

  DrillScenarioInitiativeContextV1? get scenarioInitiativeContextV1 {
    final seatContext = scenarioSeatContextV1;
    final street = scenarioCoreV1.streetV1;
    if (kind != DrillKindV1.initiativeAggressorChoice ||
        seatContext == null ||
        street == null ||
        seatContext.lastAggressorV1 == null ||
        seatContext.initiativeOwnerV1 == null) {
      return null;
    }
    return DrillScenarioInitiativeContextV1(
      streetV1: street,
      playerCountV1: seatContext.playerCountV1,
      heroSeatV1: seatContext.heroSeatV1,
      villainSeatV1: seatContext.villainSeatV1,
      activeSeatsV1: seatContext.activeSeatsV1,
      lastAggressorV1: seatContext.lastAggressorV1!,
      initiativeOwnerV1: seatContext.initiativeOwnerV1!,
      availableActionsV1: scenarioCoreV1.availableActionsV1,
      expectedActionIdV1: scenarioCoreV1.expectedActionIdV1,
    );
  }

  DrillScenarioPositionContextV1? get scenarioPositionContextV1 {
    final seatContext = scenarioSeatContextV1;
    final street = scenarioCoreV1.streetV1;
    if (kind != DrillKindV1.positionThinkingChoice ||
        seatContext == null ||
        street == null) {
      return null;
    }
    return DrillScenarioPositionContextV1(
      streetV1: street,
      playerCountV1: seatContext.playerCountV1,
      heroSeatV1: seatContext.heroSeatV1,
      villainSeatV1: seatContext.villainSeatV1,
      activeSeatsV1: seatContext.activeSeatsV1,
      foldedSeatsV1: seatContext.foldedSeatsV1,
      emptySeatsV1: seatContext.emptySeatsV1,
      availableActionsV1: scenarioCoreV1.availableActionsV1,
      expectedActionIdV1: scenarioCoreV1.expectedActionIdV1,
    );
  }

  DrillScenarioBoardTextureContextV1? get scenarioBoardTextureContextV1 {
    final street = scenarioCoreV1.streetV1;
    final boardCards = scenarioBoardContextV1?.boardCardsV1;
    final boardTexture = boardTextureV1?.trim().toLowerCase();
    if (kind != DrillKindV1.boardTextureClassifier ||
        street == null ||
        boardCards == null ||
        boardCards.length != 3 ||
        boardTexture == null ||
        boardTexture.isEmpty) {
      return null;
    }
    return DrillScenarioBoardTextureContextV1(
      streetV1: street,
      boardCardsV1: boardCards,
      boardTextureV1: boardTexture,
      availableActionsV1: scenarioCoreV1.availableActionsV1,
      expectedActionIdV1: scenarioCoreV1.expectedActionIdV1,
    );
  }

  DrillScenarioHandChainContextV1? get scenarioFactualHandChainContextV1 {
    if (kind != DrillKindV1.handChain) {
      return null;
    }
    final chainId = chainIdV1;
    final steps = chainStepsV1;
    if (chainId == null ||
        steps == null ||
        (chainId != 'w2_s07_position_then_initiative_v1' &&
            chainId != 'w2_s08_texture_then_outs_v1')) {
      return null;
    }
    return DrillScenarioHandChainContextV1(
      chainIdV1: chainId,
      stepsV1: List<DrillScenarioHandChainStepContextV1>.unmodifiable(
        steps.map(
          (step) => DrillScenarioHandChainStepContextV1(
            coreV1: step.scenarioCoreV1,
            tableContextV1: step.scenarioTableContextV1,
            actionFollowUpV1: step.scenarioActionFollowUpV1,
            questionShapeV1: step.questionShapeV1,
            promptV1: step.prompt,
            whyV1: step.whyV1,
            expectedPresetIdV1: step.expectedPresetIdV1,
            acceptablePresetIdsV1: step.acceptablePresetIds,
            rangeBucketV1: step.rangeBucketV1,
          ),
        ),
      ),
    );
  }

  factory DrillSpecV1.fromJson(Map<String, dynamic> json) {
    final id = _requireNonEmptyString(json, 'id');
    final kindRaw = _requireNonEmptyString(json, 'kind');
    final prompt = _requireNonEmptyString(json, 'prompt');
    final errorClass = _requireNonEmptyString(json, 'error_class');
    final intentRaw = json['intent_v1'];
    if (intentRaw != null) {
      if (intentRaw is! String || !_kIntentIdV1Pattern.hasMatch(intentRaw)) {
        throw const FormatException(
          'intent_v1 must match [a-z0-9_]+ when present',
        );
      }
    }
    final whyV1 = _parseOptionalWhyV1(json['why_v1']);
    final acceptableActions = _parseOptionalAcceptableActions(
      json['acceptable_actions'],
    );
    final acceptablePresetIds = _parseOptionalAcceptablePresetIds(
      json['acceptable_preset_ids'],
    );
    final kind = _parseDrillKindV1(kindRaw);
    final expectedRaw = json['expected'];
    final expected =
        (kind == DrillKindV1.boardTextureClassifier ||
            kind == DrillKindV1.rangeBucketClassifier ||
            kind == DrillKindV1.handChain)
        ? const DrillExpectedV1()
        : () {
            if (expectedRaw is! Map) {
              throw const FormatException('expected must be an object');
            }
            return DrillExpectedV1.fromJson(
              expectedRaw.cast<String, dynamic>(),
            );
          }();
    final boardTextureRaw = json['board_texture_v1'];
    final questionShapeRaw = json['question_shape_v1'];
    final initiativePolicyShapeRaw = json['initiative_policy_shape_v1'];
    final boardTexturePolicyShapeRaw = json['board_texture_policy_shape_v1'];
    final boardTexturePolicyTargetRaw = json['board_texture_policy_target_v1'];
    final availableActionsRaw = json['available_actions_v1'];
    final streetRaw = json['street_v1'];
    final boardCardsRaw = json['board_cards_v1'];
    final playerCountRaw = json['player_count_v1'];
    final heroSeatRaw = json['hero_seat_v1'];
    final villainSeatRaw = json['villain_seat_v1'];
    final activeSeatsRaw = json['active_seats_v1'];
    final foldedSeatsRaw = json['folded_seats_v1'];
    final emptySeatsRaw = json['empty_seats_v1'];
    final lastAggressorRaw = json['last_aggressor_v1'];
    final initiativeOwnerRaw = json['initiative_owner_v1'];
    final smallBlindSeatRaw = json['small_blind_seat_v1'];
    final bigBlindSeatRaw = json['big_blind_seat_v1'];
    final smallBlindAmountRaw = json['small_blind_amount_v1'];
    final bigBlindAmountRaw = json['big_blind_amount_v1'];
    final anteAmountRaw = json['ante_amount_v1'];
    final pressureOwnerRaw = json['pressure_owner_v1'];
    final heroHoleCardsRaw = json['hero_hole_cards_v1'];
    final villainHoleCardsRaw = json['villain_hole_cards_v1'];
    final introRaw = json['intro_v1'];
    final recapRaw = json['recap_v1'];
    final feedbackAcceptableRaw = json['feedback_acceptable_v1'];
    final feedbackCorrectRaw = json['feedback_correct_v1'];
    final feedbackIncorrectByActionRaw = json['feedback_incorrect_by_action_v1'];
    final feedbackIncorrectRaw = json['feedback_incorrect_v1'];
    final expectedActionRaw = json['expected_action'];
    final rangeBucketRaw = json['range_bucket_v1'];
    final chainIdRaw = json['chain_id'];
    final stepsRaw = json['steps'];
    final spec = DrillSpecV1(
      id: id,
      kind: kind,
      prompt: prompt,
      expected: expected,
      errorClass: errorClass,
      intentV1: intentRaw as String?,
      questionShapeV1: _parseOptionalPositionQuestionShapeV1(questionShapeRaw),
      initiativePolicyShapeV1: _parseOptionalInitiativePolicyShapeV1(
        initiativePolicyShapeRaw,
      ),
      boardTexturePolicyShapeV1: _parseOptionalBoardTexturePolicyShapeV1(
        boardTexturePolicyShapeRaw,
      ),
      boardTexturePolicyTargetV1: _parseOptionalBoardTexturePolicyTargetV1(
        boardTexturePolicyTargetRaw,
      ),
      whyV1: whyV1,
      acceptableActions: acceptableActions,
      acceptablePresetIds: acceptablePresetIds,
      boardTextureV1: boardTextureRaw is String
          ? boardTextureRaw.trim().toLowerCase()
          : null,
      availableActionsV1: _parseOptionalAvailableActionsV1(availableActionsRaw),
      streetV1: streetRaw is String ? streetRaw.trim().toLowerCase() : null,
      boardCardsV1: _parseOptionalBoardCardsV1(boardCardsRaw),
      playerCountV1: _parseOptionalPlayerCountV1(playerCountRaw),
      heroSeatV1: _parseOptionalSeatIdV1(heroSeatRaw),
      villainSeatV1: _parseOptionalSeatIdV1(villainSeatRaw),
      activeSeatsV1: _parseOptionalSeatIdListV1(activeSeatsRaw),
      foldedSeatsV1: _parseOptionalSeatIdListV1(foldedSeatsRaw),
      emptySeatsV1: _parseOptionalSeatIdListV1(emptySeatsRaw),
      lastAggressorV1: _parseOptionalHeroVillainIdV1(
        lastAggressorRaw,
        'last_aggressor_v1',
      ),
      initiativeOwnerV1: _parseOptionalHeroVillainIdV1(
        initiativeOwnerRaw,
        'initiative_owner_v1',
      ),
      smallBlindSeatV1: _parseOptionalSeatIdV1(smallBlindSeatRaw),
      bigBlindSeatV1: _parseOptionalSeatIdV1(bigBlindSeatRaw),
      smallBlindAmountV1: _parseOptionalPositiveIntV1(
        smallBlindAmountRaw,
        'small_blind_amount_v1',
      ),
      bigBlindAmountV1: _parseOptionalPositiveIntV1(
        bigBlindAmountRaw,
        'big_blind_amount_v1',
      ),
      anteAmountV1: _parseOptionalPositiveIntV1(
        anteAmountRaw,
        'ante_amount_v1',
      ),
      pressureOwnerV1: _parseOptionalHeroVillainIdV1(
        pressureOwnerRaw,
        'pressure_owner_v1',
      ),
      heroHoleCardsV1: _parseOptionalHoleCardsV1(heroHoleCardsRaw),
      villainHoleCardsV1: _parseOptionalHoleCardsV1(villainHoleCardsRaw),
      introV1: _parseOptionalShortCopyV1(introRaw),
      recapV1: _parseOptionalShortCopyV1(recapRaw),
      feedbackAcceptableV1: _parseOptionalShortCopyV1(feedbackAcceptableRaw),
      feedbackCorrectV1: _parseOptionalShortCopyV1(feedbackCorrectRaw),
      feedbackIncorrectByActionV1: _parseOptionalShortCopyMapV1(
        feedbackIncorrectByActionRaw,
        'feedback_incorrect_by_action_v1',
      ),
      feedbackIncorrectV1: _parseOptionalShortCopyV1(feedbackIncorrectRaw),
      expectedActionV1: expectedActionRaw is String
          ? expectedActionRaw.trim().toLowerCase()
          : null,
      rangeBucketV1: rangeBucketRaw is String
          ? rangeBucketRaw.trim().toLowerCase()
          : null,
      chainIdV1: chainIdRaw is String ? chainIdRaw.trim() : null,
      chainStepsV1: stepsRaw == null ? null : _parseChainStepsV1(stepsRaw),
    );
    _validateExpectedForKind(spec);
    return spec;
  }

  factory DrillSpecV1.fromJsonString(String source) {
    return DrillSpecV1.fromJson(
      (jsonDecode(source) as Map).cast<String, dynamic>(),
    );
  }
}

void validateDeterministicChainStepShapeContractV1({
  required DrillChainStepV1 step,
  required String errorPrefix,
}) {
  if (step.prompt.trim().isEmpty) {
    throw StateError('$errorPrefix requires non-empty prompt');
  }
  if (step.errorClass.trim().isEmpty) {
    throw StateError('$errorPrefix requires non-empty error_class');
  }
  if (!_kHandChainStreetsV1.contains(step.street)) {
    throw StateError('$errorPrefix requires street preflop|flop|turn|river');
  }

  final expectedCount = <String?>[
    step.expectedActionV1,
    step.expectedPresetIdV1,
    step.rangeBucketV1,
  ].where((value) => value != null && value.isNotEmpty).length;
  if (expectedCount != 1) {
    throw StateError('$errorPrefix requires exactly one structured target');
  }

  if (step.feedbackCorrectV1 == null || step.feedbackIncorrectV1 == null) {
    throw StateError(
      '$errorPrefix requires explicit feedback_correct_v1 and feedback_incorrect_v1',
    );
  }

  final expectedAction = step.expectedActionV1;
  if (expectedAction != null) {
    final availableActions = step.availableActionsV1;
    if (availableActions == null || availableActions.isEmpty) {
      throw StateError('$errorPrefix requires available_actions_v1');
    }
    if (!availableActions.contains(expectedAction)) {
      throw StateError(
        '$errorPrefix requires expected_action inside available_actions_v1',
      );
    }
  }
}

void validateDeterministicMultiStepChainShapeContractV1({
  required DrillSpecV1 spec,
  required int minSteps,
  required int maxSteps,
  required String errorPrefix,
}) {
  if (spec.kind != DrillKindV1.handChain) {
    throw StateError('$errorPrefix requires hand_chain_v1');
  }
  final chainId = spec.chainIdV1;
  if (chainId == null || chainId.isEmpty) {
    throw StateError('$errorPrefix requires chain_id');
  }
  final steps = spec.chainStepsV1;
  if (steps == null || steps.length < minSteps || steps.length > maxSteps) {
    throw StateError('$errorPrefix requires steps length $minSteps..$maxSteps');
  }
  for (var i = 0; i < steps.length; i++) {
    validateDeterministicChainStepShapeContractV1(
      step: steps[i],
      errorPrefix: '$errorPrefix step ${i + 1}',
    );
  }
}

String? _parseOptionalShortCopyV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) {
    throw const FormatException('optional short copy fields must be strings');
  }
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}

String? _parseOptionalPositionQuestionShapeV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) {
    throw const FormatException('question_shape_v1 must be a string');
  }
  final trimmed = raw.trim().toLowerCase();
  if (trimmed.isEmpty) return null;
  if (!_kPositionQuestionShapesV1.contains(trimmed)) {
    throw const FormatException(
      'question_shape_v1 must be in_position|out_of_position|acts_later',
    );
  }
  return trimmed;
}

String? _parseOptionalInitiativePolicyShapeV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) {
    throw const FormatException('initiative_policy_shape_v1 must be a string');
  }
  final trimmed = raw.trim().toLowerCase();
  if (trimmed.isEmpty) return null;
  if (!_kInitiativePolicyShapesV1.contains(trimmed)) {
    throw const FormatException(
      'initiative_policy_shape_v1 must be pressure_owner',
    );
  }
  return trimmed;
}

String? _parseOptionalBoardTexturePolicyShapeV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) {
    throw const FormatException(
      'board_texture_policy_shape_v1 must be a string',
    );
  }
  final trimmed = raw.trim().toLowerCase();
  if (trimmed.isEmpty) return null;
  if (!_kBoardTexturePolicyShapesV1.contains(trimmed)) {
    throw const FormatException(
      'board_texture_policy_shape_v1 must be pressure_level',
    );
  }
  return trimmed;
}

String? _parseOptionalBoardTexturePolicyTargetV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) {
    throw const FormatException(
      'board_texture_policy_target_v1 must be a string',
    );
  }
  final trimmed = raw.trim().toLowerCase();
  if (trimmed.isEmpty) return null;
  if (!_kBoardTexturePolicyTargetsV1.contains(trimmed)) {
    throw const FormatException(
      'board_texture_policy_target_v1 must be calmer|pressure_building',
    );
  }
  return trimmed;
}

String? _parseOptionalWhyV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.contains('\n') || trimmed.contains('\r')) return null;
  if (trimmed.length < 8 || trimmed.length > 140) return null;
  for (final codeUnit in trimmed.codeUnits) {
    if (codeUnit < 32 || codeUnit > 126) {
      return null;
    }
  }
  return trimmed;
}

List<String>? _parseOptionalAvailableActionsV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! List) {
    throw const FormatException('available_actions_v1 must be an array');
  }
  final values = <String>[];
  final seen = <String>{};
  for (final item in raw) {
    if (item is! String) {
      throw const FormatException(
        'available_actions_v1 entries must be strings',
      );
    }
    final normalized = item.trim().toLowerCase();
    if (!_kIntentIdV1Pattern.hasMatch(normalized)) {
      throw const FormatException(
        'available_actions_v1 entries must match [a-z0-9_]+',
      );
    }
    if (seen.add(normalized)) {
      values.add(normalized);
    }
  }
  if (values.isEmpty) return null;
  return List<String>.unmodifiable(values);
}

List<String>? _parseOptionalBoardCardsV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! List) {
    throw const FormatException('board_cards_v1 must be an array');
  }
  final values = <String>[];
  for (final item in raw) {
    if (item is! String || !_isCardIdV1(item.trim())) {
      throw const FormatException(
        'board_cards_v1 entries must match [AKQJT98765432][shdc]',
      );
    }
    values.add(item.trim());
  }
  if (values.isEmpty) return null;
  return List<String>.unmodifiable(values);
}

List<String>? _parseOptionalHoleCardsV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! List) {
    throw const FormatException('hole card fields must be an array');
  }
  if (raw.length != 2) {
    throw const FormatException(
      'hole card fields must contain exactly 2 cards',
    );
  }
  final values = <String>[];
  for (final item in raw) {
    if (item is! String || !_isCardIdV1(item.trim())) {
      throw const FormatException(
        'hole card entries must match [AKQJT98765432][shdc]',
      );
    }
    values.add(item.trim());
  }
  return List<String>.unmodifiable(values);
}

int? _parseOptionalPlayerCountV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! int) {
    throw const FormatException('player_count_v1 must be an integer');
  }
  if (raw < 2 || raw > 10) {
    throw const FormatException('player_count_v1 must be between 2 and 10');
  }
  return raw;
}

int? _parseOptionalPositiveIntV1(Object? raw, String fieldName) {
  if (raw == null) return null;
  if (raw is! int) {
    throw FormatException('$fieldName must be an integer');
  }
  if (raw <= 0) {
    throw FormatException('$fieldName must be positive when present');
  }
  return raw;
}

String? _parseOptionalSeatIdV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! String) {
    throw const FormatException('seat id fields must be strings');
  }
  final normalized = raw.trim().toLowerCase();
  if (!_kIntentIdV1Pattern.hasMatch(normalized)) {
    throw const FormatException('seat id fields must match [a-z0-9_]+');
  }
  return normalized.isEmpty ? null : normalized;
}

List<String>? _parseOptionalSeatIdListV1(Object? raw) {
  if (raw == null) return null;
  if (raw is! List) {
    throw const FormatException('active_seats_v1 must be an array');
  }
  final values = <String>[];
  final seen = <String>{};
  for (final item in raw) {
    final parsed = _parseOptionalSeatIdV1(item);
    if (parsed == null) continue;
    if (seen.add(parsed)) {
      values.add(parsed);
    }
  }
  if (values.isEmpty) return null;
  return List<String>.unmodifiable(values);
}

String? _parseOptionalHeroVillainIdV1(Object? raw, String fieldName) {
  if (raw == null) return null;
  if (raw is! String) {
    throw FormatException('$fieldName must be a string');
  }
  final normalized = raw.trim().toLowerCase();
  if (!const <String>{'hero', 'villain'}.contains(normalized)) {
    throw FormatException('$fieldName must be hero|villain when present');
  }
  return normalized;
}

DrillScenarioBlindLevelContextV1? _scenarioBlindLevelContextFromValuesV1({
  required String? smallBlindSeatV1,
  required String? bigBlindSeatV1,
  required int? smallBlindAmountV1,
  required int? bigBlindAmountV1,
  required int? anteAmountV1,
  required String fieldPrefix,
}) {
  final hasBlindLevelState =
      smallBlindSeatV1 != null ||
      bigBlindSeatV1 != null ||
      smallBlindAmountV1 != null ||
      bigBlindAmountV1 != null ||
      anteAmountV1 != null;
  if (!hasBlindLevelState) {
    return null;
  }
  if (smallBlindSeatV1 == null ||
      bigBlindSeatV1 == null ||
      smallBlindAmountV1 == null ||
      bigBlindAmountV1 == null) {
    throw StateError(
      '$fieldPrefix blind-level state requires small_blind_seat_v1, big_blind_seat_v1, small_blind_amount_v1, and big_blind_amount_v1 together',
    );
  }
  if (smallBlindSeatV1 == bigBlindSeatV1) {
    throw StateError(
      '$fieldPrefix blind-level state requires distinct small and big blind seats',
    );
  }
  if (bigBlindAmountV1 < smallBlindAmountV1) {
    throw StateError(
      '$fieldPrefix blind-level state requires big blind amount >= small blind amount',
    );
  }
  return DrillScenarioBlindLevelContextV1(
    smallBlindSeatV1: smallBlindSeatV1,
    bigBlindSeatV1: bigBlindSeatV1,
    smallBlindAmountV1: smallBlindAmountV1,
    bigBlindAmountV1: bigBlindAmountV1,
    anteAmountV1: anteAmountV1,
  );
}

List<String>? _parseOptionalAcceptableActions(Object? raw) {
  if (raw == null) return null;
  if (raw is! List) {
    throw const FormatException('acceptable_actions must be an array');
  }
  final values = <String>{};
  for (final item in raw) {
    if (item is! String) {
      throw const FormatException('acceptable_actions entries must be strings');
    }
    final normalized = item.trim().toLowerCase();
    if (!_kIntentIdV1Pattern.hasMatch(normalized)) {
      throw const FormatException(
        'acceptable_actions entries must match [a-z0-9_]+',
      );
    }
    values.add(normalized);
  }
  if (values.isEmpty) return null;
  final sorted = values.toList()..sort();
  return List<String>.unmodifiable(sorted);
}

const Set<String> _kBetSizingPresetIdsV1 = <String>{
  'one_third_pot',
  'half_pot',
  'pot',
  'min_raise',
};
const Set<String> _kOutsCountIdsV1 = <String>{'4', '8', '9', '15'};
const Set<String> _kBoardTextureV1Values = <String>{
  'dry',
  'wet',
  'paired',
  'connected',
  'high_card',
};
const Set<String> _kBoardTextureActionsV1 = <String>{'fold', 'call', 'raise'};
const Set<String> _kRangeBucketV1Values = <String>{
  'strong',
  'medium',
  'weak',
  'draw',
  'missed',
};
const Set<String> _kRangeBucketActionsV1 = <String>{'fold', 'call', 'raise'};
const Set<String> _kHandChainStreetsV1 = <String>{
  'preflop',
  'flop',
  'turn',
  'river',
};

class DrillChainStepV1 {
  const DrillChainStepV1({
    required this.street,
    required this.prompt,
    required this.errorClass,
    this.intentV1,
    this.boardTextureV1,
    this.boardCardsV1,
    this.heroHoleCardsV1,
    this.availableActionsV1,
    this.playerCountV1,
    this.heroSeatV1,
    this.villainSeatV1,
    this.activeSeatsV1,
    this.foldedSeatsV1,
    this.emptySeatsV1,
    this.lastAggressorV1,
    this.initiativeOwnerV1,
    this.smallBlindSeatV1,
    this.bigBlindSeatV1,
    this.smallBlindAmountV1,
    this.bigBlindAmountV1,
    this.anteAmountV1,
    this.questionShapeV1,
    this.expectedActionV1,
    this.expectedPresetIdV1,
    this.rangeBucketV1,
    this.acceptableActions,
    this.acceptablePresetIds,
    this.whyV1,
    this.feedbackCorrectV1,
    this.feedbackIncorrectV1,
  });

  final String street;
  final String prompt;
  final String errorClass;
  final String? intentV1;
  final String? boardTextureV1;
  final List<String>? boardCardsV1;
  final List<String>? heroHoleCardsV1;
  final List<String>? availableActionsV1;
  final int? playerCountV1;
  final String? heroSeatV1;
  final String? villainSeatV1;
  final List<String>? activeSeatsV1;
  final List<String>? foldedSeatsV1;
  final List<String>? emptySeatsV1;
  final String? lastAggressorV1;
  final String? initiativeOwnerV1;
  final String? smallBlindSeatV1;
  final String? bigBlindSeatV1;
  final int? smallBlindAmountV1;
  final int? bigBlindAmountV1;
  final int? anteAmountV1;
  final String? questionShapeV1;
  final String? expectedActionV1;
  final String? expectedPresetIdV1;
  final String? rangeBucketV1;
  final List<String>? acceptableActions;
  final List<String>? acceptablePresetIds;
  final String? whyV1;
  final String? feedbackCorrectV1;
  final String? feedbackIncorrectV1;

  DrillScenarioCoreV1 get scenarioCoreV1 {
    return DrillScenarioCoreV1(
      streetV1: street,
      availableActionsV1: availableActionsV1,
      expectedActionIdV1: expectedActionV1,
      acceptableActionsV1: acceptableActions,
      feedbackCorrectV1: feedbackCorrectV1,
      feedbackIncorrectV1: feedbackIncorrectV1,
    );
  }

  DrillScenarioSeatContextV1? get scenarioSeatContextV1 {
    if (playerCountV1 == null ||
        heroSeatV1 == null ||
        villainSeatV1 == null ||
        activeSeatsV1 == null) {
      return null;
    }
    final blindLevel = _scenarioBlindLevelContextFromValuesV1(
      smallBlindSeatV1: smallBlindSeatV1,
      bigBlindSeatV1: bigBlindSeatV1,
      smallBlindAmountV1: smallBlindAmountV1,
      bigBlindAmountV1: bigBlindAmountV1,
      anteAmountV1: anteAmountV1,
      fieldPrefix: 'hand_chain_v1',
    );
    return DrillScenarioSeatContextV1(
      playerCountV1: playerCountV1!,
      heroSeatV1: heroSeatV1!,
      villainSeatV1: villainSeatV1!,
      activeSeatsV1: activeSeatsV1!,
      foldedSeatsV1: foldedSeatsV1,
      emptySeatsV1: emptySeatsV1,
      lastAggressorV1: lastAggressorV1,
      initiativeOwnerV1: initiativeOwnerV1,
      blindLevelV1: blindLevel,
    );
  }

  DrillScenarioBoardContextV1? get scenarioBoardContextV1 {
    if (boardCardsV1 == null && heroHoleCardsV1 == null) {
      return null;
    }
    return DrillScenarioBoardContextV1(
      boardCardsV1: boardCardsV1,
      heroHoleCardsV1: heroHoleCardsV1,
    );
  }

  DrillScenarioTableContextV1? get scenarioTableContextV1 {
    final seatContext = scenarioSeatContextV1;
    final boardContext = scenarioBoardContextV1;
    if (seatContext == null && boardContext == null) {
      return null;
    }
    return DrillScenarioTableContextV1(
      seatContextV1: seatContext,
      boardContextV1: boardContext,
    );
  }

  DrillScenarioActionFollowUpV1? get scenarioActionFollowUpV1 {
    final tableContext = scenarioTableContextV1;
    final actionIds = scenarioCoreV1.availableActionsV1;
    final expectedActionId = scenarioCoreV1.expectedActionIdV1;
    if (tableContext == null ||
        actionIds == null ||
        expectedActionId == null ||
        actionIds.length != 2) {
      return null;
    }
    final actionSet = actionIds.toSet();
    if (actionSet.length != 2 ||
        !actionSet.contains('call') ||
        !actionSet.contains('raise') ||
        !actionSet.contains(expectedActionId)) {
      return null;
    }
    return DrillScenarioActionFollowUpV1(
      tableContextV1: tableContext,
      availableActionsV1: actionIds,
      expectedActionIdV1: expectedActionId,
    );
  }
}

List<DrillChainStepV1> _parseChainStepsV1(Object raw) {
  if (raw is! List) {
    throw const FormatException('steps must be an array for hand_chain_v1');
  }
  if (raw.length < 2 || raw.length > 4) {
    throw const FormatException('hand_chain_v1 steps length must be 2..4');
  }
  final steps = <DrillChainStepV1>[];
  for (final item in raw) {
    if (item is! Map) {
      throw const FormatException('each hand_chain_v1 step must be an object');
    }
    final step = item.cast<String, dynamic>();
    final street = _requireNonEmptyString(step, 'street').trim().toLowerCase();
    if (!_kHandChainStreetsV1.contains(street)) {
      throw const FormatException(
        'hand_chain_v1 step street must be preflop|flop|turn|river',
      );
    }
    final prompt = _requireNonEmptyString(step, 'prompt');
    final errorClass = _requireNonEmptyString(step, 'error_class');
    final intentRaw = step['intent_v1'];
    if (intentRaw != null) {
      if (intentRaw is! String || !_kIntentIdV1Pattern.hasMatch(intentRaw)) {
        throw const FormatException(
          'hand_chain_v1 step intent_v1 must match [a-z0-9_]+ when present',
        );
      }
    }
    final boardTextureRaw = step['board_texture_v1'];
    final boardCardsRaw = step['board_cards_v1'];
    final heroHoleCardsRaw = step['hero_hole_cards_v1'];
    final availableActionsRaw = step['available_actions_v1'];
    final playerCountRaw = step['player_count_v1'];
    final heroSeatRaw = step['hero_seat_v1'];
    final villainSeatRaw = step['villain_seat_v1'];
    final activeSeatsRaw = step['active_seats_v1'];
    final foldedSeatsRaw = step['folded_seats_v1'];
    final emptySeatsRaw = step['empty_seats_v1'];
    final lastAggressorRaw = step['last_aggressor_v1'];
    final initiativeOwnerRaw = step['initiative_owner_v1'];
    final smallBlindSeatRaw = step['small_blind_seat_v1'];
    final bigBlindSeatRaw = step['big_blind_seat_v1'];
    final smallBlindAmountRaw = step['small_blind_amount_v1'];
    final bigBlindAmountRaw = step['big_blind_amount_v1'];
    final anteAmountRaw = step['ante_amount_v1'];
    final questionShapeRaw = step['question_shape_v1'];
    final expectedActionRaw = step['expected_action'];
    final expectedPresetRaw = step['expected_preset_id'];
    final rangeBucketRaw = step['range_bucket_v1'];
    final expectedAction = expectedActionRaw is String
        ? expectedActionRaw.trim().toLowerCase()
        : null;
    final expectedPreset = expectedPresetRaw is String
        ? expectedPresetRaw.trim().toLowerCase()
        : null;
    final expectedRangeBucket = rangeBucketRaw is String
        ? rangeBucketRaw.trim().toLowerCase()
        : null;
    final expectedCount = <String?>[
      expectedAction,
      expectedPreset,
      expectedRangeBucket,
    ].where((v) => v != null && v.isNotEmpty).length;
    if (expectedCount != 1) {
      throw const FormatException(
        'hand_chain_v1 step must include exactly one of expected_action, expected_preset_id, range_bucket_v1',
      );
    }
    final acceptableActions = _parseOptionalAcceptableActions(
      step['acceptable_actions'],
    );
    final acceptablePresetIds = _parseOptionalAcceptablePresetIds(
      step['acceptable_preset_ids'],
    );
    final availableActions = _parseOptionalAvailableActionsV1(
      availableActionsRaw,
    );
    if (expectedAction != null &&
        availableActions == null &&
        !_kRangeBucketActionsV1.contains(expectedAction)) {
      throw const FormatException(
        'hand_chain_v1 expected_action must be fold|call|raise',
      );
    }
    if (expectedPreset != null &&
        !_kBetSizingPresetIdsV1.contains(expectedPreset)) {
      throw const FormatException(
        'hand_chain_v1 expected_preset_id must be one_third_pot|half_pot|pot|min_raise',
      );
    }
    if (expectedRangeBucket != null &&
        !_kRangeBucketV1Values.contains(expectedRangeBucket)) {
      throw const FormatException(
        'hand_chain_v1 range_bucket_v1 must be strong|medium|weak|draw|missed',
      );
    }
    if (expectedPreset != null && acceptableActions != null) {
      throw const FormatException(
        'hand_chain_v1 preset step cannot include acceptable_actions',
      );
    }
    if (expectedPreset == null && acceptablePresetIds != null) {
      throw const FormatException(
        'hand_chain_v1 acceptable_preset_ids require expected_preset_id',
      );
    }
    final playerCount = _parseOptionalPlayerCountV1(playerCountRaw);
    final heroSeat = _parseOptionalSeatIdV1(heroSeatRaw);
    final villainSeat = _parseOptionalSeatIdV1(villainSeatRaw);
    final activeSeats = _parseOptionalSeatIdListV1(activeSeatsRaw);
    final foldedSeats = _parseOptionalSeatIdListV1(foldedSeatsRaw);
    final emptySeats = _parseOptionalSeatIdListV1(emptySeatsRaw);
    final lastAggressor = _parseOptionalHeroVillainIdV1(
      lastAggressorRaw,
      'hand_chain_v1 last_aggressor_v1',
    );
    final initiativeOwner = _parseOptionalHeroVillainIdV1(
      initiativeOwnerRaw,
      'hand_chain_v1 initiative_owner_v1',
    );
    final smallBlindSeat = _parseOptionalSeatIdV1(smallBlindSeatRaw);
    final bigBlindSeat = _parseOptionalSeatIdV1(bigBlindSeatRaw);
    final smallBlindAmount = _parseOptionalPositiveIntV1(
      smallBlindAmountRaw,
      'hand_chain_v1 small_blind_amount_v1',
    );
    final bigBlindAmount = _parseOptionalPositiveIntV1(
      bigBlindAmountRaw,
      'hand_chain_v1 big_blind_amount_v1',
    );
    final anteAmount = _parseOptionalPositiveIntV1(
      anteAmountRaw,
      'hand_chain_v1 ante_amount_v1',
    );
    _scenarioBlindLevelContextFromValuesV1(
      smallBlindSeatV1: smallBlindSeat,
      bigBlindSeatV1: bigBlindSeat,
      smallBlindAmountV1: smallBlindAmount,
      bigBlindAmountV1: bigBlindAmount,
      anteAmountV1: anteAmount,
      fieldPrefix: 'hand_chain_v1',
    );
    if (availableActions != null &&
        expectedAction != null &&
        !availableActions.contains(expectedAction)) {
      throw const FormatException(
        'hand_chain_v1 expected_action must be present in available_actions_v1',
      );
    }
    if (availableActions != null &&
        acceptableActions != null &&
        acceptableActions.any((action) => !availableActions.contains(action))) {
      throw const FormatException(
        'hand_chain_v1 acceptable_actions must be a subset of available_actions_v1',
      );
    }
    steps.add(
      DrillChainStepV1(
        street: street,
        prompt: prompt,
        errorClass: errorClass,
        intentV1: intentRaw as String?,
        boardTextureV1: boardTextureRaw is String
            ? boardTextureRaw.trim().toLowerCase()
            : null,
        boardCardsV1: _parseOptionalBoardCardsV1(boardCardsRaw),
        heroHoleCardsV1: _parseOptionalHoleCardsV1(heroHoleCardsRaw),
        availableActionsV1: availableActions,
        playerCountV1: playerCount,
        heroSeatV1: heroSeat,
        villainSeatV1: villainSeat,
        activeSeatsV1: activeSeats,
        foldedSeatsV1: foldedSeats,
        emptySeatsV1: emptySeats,
        lastAggressorV1: lastAggressor,
        initiativeOwnerV1: initiativeOwner,
        smallBlindSeatV1: smallBlindSeat,
        bigBlindSeatV1: bigBlindSeat,
        smallBlindAmountV1: smallBlindAmount,
        bigBlindAmountV1: bigBlindAmount,
        anteAmountV1: anteAmount,
        questionShapeV1: _parseOptionalPositionQuestionShapeV1(
          questionShapeRaw,
        ),
        expectedActionV1: expectedAction,
        expectedPresetIdV1: expectedPreset,
        rangeBucketV1: expectedRangeBucket,
        acceptableActions: acceptableActions,
        acceptablePresetIds: acceptablePresetIds,
        whyV1: _parseOptionalWhyV1(step['why_v1']),
        feedbackCorrectV1: step['feedback_correct_v1'] as String?,
        feedbackIncorrectV1: step['feedback_incorrect_v1'] as String?,
      ),
    );
  }
  return List<DrillChainStepV1>.unmodifiable(steps);
}

List<String>? _parseOptionalAcceptablePresetIds(Object? raw) {
  if (raw == null) return null;
  if (raw is! List) {
    throw const FormatException('acceptable_preset_ids must be an array');
  }
  final values = <String>{};
  for (final item in raw) {
    if (item is! String) {
      throw const FormatException(
        'acceptable_preset_ids entries must be strings',
      );
    }
    final normalized = item.trim().toLowerCase();
    if (!_kBetSizingPresetIdsV1.contains(normalized)) {
      throw const FormatException(
        'acceptable_preset_ids entries must be one_third_pot|half_pot|pot|min_raise',
      );
    }
    values.add(normalized);
  }
  if (values.isEmpty) return null;
  final sorted = values.toList()..sort();
  return List<String>.unmodifiable(sorted);
}

Map<String, String>? _parseOptionalShortCopyMapV1(Object? raw, String field) {
  if (raw == null) return null;
  if (raw is! Map) {
    throw FormatException('$field must be an object');
  }
  final values = <String, String>{};
  for (final entry in raw.entries) {
    final keyRaw = entry.key;
    if (keyRaw is! String) {
      throw FormatException('$field keys must be strings');
    }
    final key = keyRaw.trim().toLowerCase();
    if (key.isEmpty || !_kIntentIdV1Pattern.hasMatch(key)) {
      throw FormatException('$field keys must match [a-z0-9_]+');
    }
    final value = _parseOptionalShortCopyV1(entry.value);
    if (value == null) {
      throw FormatException('$field[$key] must be a non-empty short string');
    }
    values[key] = value;
  }
  if (values.isEmpty) return null;
  return Map<String, String>.unmodifiable(values);
}

String _requireNonEmptyString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string');
  }
  return value;
}

class DrillUserEventV1 {
  const DrillUserEventV1._({
    required this.kind,
    this.seatId,
    this.role,
    this.actionId,
    this.chainStepIndex,
    this.boardSlot,
    this.cardSlot,
    this.cardId,
  });

  final DrillUserEventKindV1 kind;
  final String? seatId;
  final String? role;
  final String? actionId;
  final int? chainStepIndex;
  final String? boardSlot;
  final String? cardSlot;
  final String? cardId;

  factory DrillUserEventV1.seatTap({String? seatId, String? role}) {
    return DrillUserEventV1._(
      kind: DrillUserEventKindV1.seatTap,
      seatId: seatId,
      role: role,
    );
  }

  factory DrillUserEventV1.actionChoice(
    String actionId, {
    int? chainStepIndex,
  }) {
    return DrillUserEventV1._(
      kind: DrillUserEventKindV1.actionChoice,
      actionId: actionId,
      chainStepIndex: chainStepIndex,
    );
  }

  factory DrillUserEventV1.boardTap(String boardSlot) {
    return DrillUserEventV1._(
      kind: DrillUserEventKindV1.boardTap,
      boardSlot: boardSlot,
    );
  }

  factory DrillUserEventV1.holeCardsTap({
    required String cardSlot,
    String? cardId,
  }) {
    return DrillUserEventV1._(
      kind: DrillUserEventKindV1.holeCardsTap,
      cardSlot: cardSlot,
      cardId: cardId,
    );
  }
}

class DrillEvalResultV1 {
  const DrillEvalResultV1({
    required this.isPass,
    required this.errorClass,
    required this.reason,
    this.isSoftPass = false,
  });

  final bool isPass;
  final String? errorClass;
  final String reason;
  final bool isSoftPass;
}

class DrillEvaluatorV1 {
  const DrillEvaluatorV1();

  DrillEvalResultV1 evaluate(DrillSpecV1 spec, DrillUserEventV1 event) {
    switch (spec.kind) {
      case DrillKindV1.seatTap:
        if (event.kind != DrillUserEventKindV1.seatTap) {
          return _fail(spec, 'wrong_event_kind');
        }
        final seatTapContext = spec.scenarioSeatTapContextV1;
        final seatMatch =
            seatTapContext?.expectedSeatIdV1 != null &&
            seatTapContext!.expectedSeatIdV1 == event.seatId;
        final roleMatch =
            seatTapContext?.expectedRoleV1 != null &&
            seatTapContext!.expectedRoleV1 == event.role;
        if (seatMatch || roleMatch) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        return _fail(spec, 'seat_tap_mismatch');
      case DrillKindV1.actionChoice:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final chosenActionId = event.actionId?.trim().toLowerCase();
        final expectedActionId = spec.expected.actionId?.trim().toLowerCase();
        if (expectedActionId == chosenActionId) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        if (chosenActionId != null &&
            (spec.acceptableActions?.contains(chosenActionId) ?? false)) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'legal_but_worse',
            isSoftPass: true,
          );
        }
        return _fail(spec, 'action_choice_mismatch');
      case DrillKindV1.boardTap:
        if (event.kind != DrillUserEventKindV1.boardTap) {
          return _fail(spec, 'wrong_event_kind');
        }
        final expectedBoardSlot =
            spec.scenarioBoardTapContextV1?.expectedBoardSlotV1;
        if (expectedBoardSlot != null && expectedBoardSlot == event.boardSlot) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        return _fail(spec, 'board_tap_mismatch');
      case DrillKindV1.betSizingChoice:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final chosenPresetId = event.actionId?.trim().toLowerCase();
        final expectedPresetId = spec.expected.presetId?.trim().toLowerCase();
        if (expectedPresetId == chosenPresetId) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        if (chosenPresetId != null &&
            (spec.acceptablePresetIds?.contains(chosenPresetId) ?? false)) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'legal_but_worse',
            isSoftPass: true,
          );
        }
        return _fail(spec, 'bet_sizing_choice_mismatch');
      case DrillKindV1.showdownWinnerChoice:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final chosenWinnerId = event.actionId?.trim().toLowerCase();
        final expectedWinnerId = spec.expected.actionId?.trim().toLowerCase();
        if (expectedWinnerId == chosenWinnerId) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        return _fail(spec, 'showdown_winner_choice_mismatch');
      case DrillKindV1.positionThinkingChoice:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final chosenActorId = event.actionId?.trim().toLowerCase();
        final expectedActorId = spec.expected.actionId?.trim().toLowerCase();
        if (expectedActorId == chosenActorId) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        return _fail(spec, 'position_thinking_choice_mismatch');
      case DrillKindV1.initiativeAggressorChoice:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final chosenActorId = event.actionId?.trim().toLowerCase();
        final expectedActorId = spec.expected.actionId?.trim().toLowerCase();
        if (expectedActorId == chosenActorId) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        return _fail(spec, 'initiative_aggressor_choice_mismatch');
      case DrillKindV1.outsCountChoice:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final chosenOutsId = event.actionId?.trim();
        final expectedOutsId = spec.expected.actionId?.trim();
        if (expectedOutsId == chosenOutsId) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        return _fail(spec, 'outs_count_choice_mismatch');
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.rangeBucketClassifier:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final chosenActionId = event.actionId?.trim().toLowerCase();
        final expectedActionId = spec.expectedActionV1?.trim().toLowerCase();
        if (expectedActionId == chosenActionId) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        if (chosenActionId != null &&
            (spec.acceptableActions?.contains(chosenActionId) ?? false)) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'legal_but_worse',
            isSoftPass: true,
          );
        }
        return _fail(
          spec,
          spec.kind == DrillKindV1.boardTextureClassifier
              ? 'board_texture_classifier_mismatch'
              : 'range_bucket_classifier_mismatch',
        );
      case DrillKindV1.handChain:
        if (event.kind != DrillUserEventKindV1.actionChoice) {
          return _fail(spec, 'wrong_event_kind');
        }
        final steps = spec.chainStepsV1;
        final index = event.chainStepIndex;
        if (steps == null ||
            index == null ||
            index < 0 ||
            index >= steps.length) {
          return _fail(spec, 'hand_chain_step_index_invalid');
        }
        final step = steps[index];
        final chosen = event.actionId?.trim().toLowerCase();
        if (step.expectedActionV1 != null) {
          if (chosen == step.expectedActionV1) {
            return const DrillEvalResultV1(
              isPass: true,
              errorClass: null,
              reason: 'match',
            );
          }
          if (chosen != null &&
              (step.acceptableActions?.contains(chosen) ?? false)) {
            return const DrillEvalResultV1(
              isPass: true,
              errorClass: null,
              reason: 'legal_but_worse',
              isSoftPass: true,
            );
          }
        } else if (step.expectedPresetIdV1 != null) {
          if (chosen == step.expectedPresetIdV1) {
            return const DrillEvalResultV1(
              isPass: true,
              errorClass: null,
              reason: 'match',
            );
          }
          if (chosen != null &&
              (step.acceptablePresetIds?.contains(chosen) ?? false)) {
            return const DrillEvalResultV1(
              isPass: true,
              errorClass: null,
              reason: 'legal_but_worse',
              isSoftPass: true,
            );
          }
        } else if (step.rangeBucketV1 != null && chosen == step.rangeBucketV1) {
          return const DrillEvalResultV1(
            isPass: true,
            errorClass: null,
            reason: 'match',
          );
        }
        return DrillEvalResultV1(
          isPass: false,
          errorClass: step.errorClass,
          reason: 'hand_chain_mismatch',
        );
      case DrillKindV1.holeCardsTap:
        if (event.kind != DrillUserEventKindV1.holeCardsTap) {
          return _fail(spec, 'wrong_event_kind');
        }
        if (spec.expected.cardSlot != event.cardSlot) {
          return _fail(spec, 'hole_cards_tap_mismatch');
        }
        if (spec.expected.cardId != null &&
            spec.expected.cardId != event.cardId) {
          return _fail(spec, 'hole_cards_tap_mismatch');
        }
        return const DrillEvalResultV1(
          isPass: true,
          errorClass: null,
          reason: 'match',
        );
    }
  }

  DrillEvalResultV1 _fail(DrillSpecV1 spec, String reason) {
    return DrillEvalResultV1(
      isPass: false,
      errorClass: spec.errorClass,
      reason: reason,
    );
  }
}

DrillKindV1 _parseDrillKindV1(String raw) {
  switch (raw) {
    case 'seat_tap':
      return DrillKindV1.seatTap;
    case 'action_choice':
      return DrillKindV1.actionChoice;
    case 'board_tap':
      return DrillKindV1.boardTap;
    case 'bet_sizing_choice_v1':
      return DrillKindV1.betSizingChoice;
    case 'showdown_winner_choice_v1':
      return DrillKindV1.showdownWinnerChoice;
    case 'position_thinking_choice_v1':
      return DrillKindV1.positionThinkingChoice;
    case 'initiative_aggressor_choice_v1':
      return DrillKindV1.initiativeAggressorChoice;
    case 'outs_count_choice_v1':
      return DrillKindV1.outsCountChoice;
    case 'board_texture_classifier_v1':
      return DrillKindV1.boardTextureClassifier;
    case 'range_bucket_classifier_v1':
      return DrillKindV1.rangeBucketClassifier;
    case 'hand_chain_v1':
      return DrillKindV1.handChain;
    case 'hole_cards_tap':
    case 'card_tap':
      return DrillKindV1.holeCardsTap;
  }
  throw FormatException('Unknown drill kind: $raw');
}

void _validateExpectedForKind(DrillSpecV1 spec) {
  switch (spec.kind) {
    case DrillKindV1.seatTap:
      if (spec.expected.seatId == null && spec.expected.role == null) {
        throw const FormatException(
          'expected must include seatId and/or role for seat_tap',
        );
      }
      break;
    case DrillKindV1.actionChoice:
      if (spec.expected.actionId == null || spec.expected.actionId!.isEmpty) {
        throw const FormatException(
          'expected.actionId is required for action_choice',
        );
      }
      final incorrectByAction = spec.feedbackIncorrectByActionV1;
      if (incorrectByAction != null) {
        const allowedActions = <String>{'fold', 'call', 'raise'};
        if (incorrectByAction.keys.any((action) => !allowedActions.contains(action))) {
          throw const FormatException(
            'feedback_incorrect_by_action_v1 keys for action_choice must be fold|call|raise',
          );
        }
      }
      break;
    case DrillKindV1.boardTap:
      if (spec.expected.boardSlot == null || spec.expected.boardSlot!.isEmpty) {
        throw const FormatException(
          'expected.boardSlot is required for board_tap',
        );
      }
      break;
    case DrillKindV1.betSizingChoice:
      final presetId = spec.expected.presetId;
      if (presetId == null || !_kBetSizingPresetIdsV1.contains(presetId)) {
        throw const FormatException(
          'expected.presetId is required for bet_sizing_choice_v1 and must be one_third_pot|half_pot|pot|min_raise',
        );
      }
      break;
    case DrillKindV1.showdownWinnerChoice:
      final actionId = spec.expected.actionId?.trim().toLowerCase();
      if (actionId == null ||
          !const <String>{
            'hero',
            'villain',
            'board_plays',
          }.contains(actionId)) {
        throw const FormatException(
          'expected.actionId is required for showdown_winner_choice_v1 and must be hero|villain|board_plays',
        );
      }
      final availableActions = spec.availableActionsV1;
      if (availableActions != null &&
          availableActions.any(
            (action) => !const <String>{
              'hero',
              'villain',
              'board_plays',
            }.contains(action),
          )) {
        throw const FormatException(
          'available_actions_v1 for showdown_winner_choice_v1 must be hero|villain|board_plays',
        );
      }
      if (availableActions != null && !availableActions.contains(actionId)) {
        throw const FormatException(
          'available_actions_v1 for showdown_winner_choice_v1 must include expected.actionId',
        );
      }
      final acceptable = spec.acceptableActions;
      if (acceptable != null &&
          acceptable.any(
            (action) => !const <String>{
              'hero',
              'villain',
              'board_plays',
            }.contains(action),
          )) {
        throw const FormatException(
          'acceptable_actions for showdown_winner_choice_v1 must be hero|villain|board_plays',
        );
      }
      if (acceptable != null &&
          availableActions != null &&
          acceptable.any((action) => !availableActions.contains(action))) {
        throw const FormatException(
          'acceptable_actions for showdown_winner_choice_v1 must be a subset of available_actions_v1 when present',
        );
      }
      break;
    case DrillKindV1.positionThinkingChoice:
      final actionId = spec.expected.actionId?.trim().toLowerCase();
      if (actionId == null ||
          !const <String>{'hero', 'villain'}.contains(actionId)) {
        throw const FormatException(
          'expected.actionId is required for position_thinking_choice_v1 and must be hero|villain',
        );
      }
      final availableActions = spec.availableActionsV1;
      if (availableActions != null &&
          availableActions.any(
            (action) => !const <String>{'hero', 'villain'}.contains(action),
          )) {
        throw const FormatException(
          'available_actions_v1 for position_thinking_choice_v1 must be hero|villain',
        );
      }
      if (availableActions != null && !availableActions.contains(actionId)) {
        throw const FormatException(
          'available_actions_v1 for position_thinking_choice_v1 must include expected.actionId',
        );
      }
      final acceptable = spec.acceptableActions;
      if (acceptable != null &&
          acceptable.any(
            (action) => !const <String>{'hero', 'villain'}.contains(action),
          )) {
        throw const FormatException(
          'acceptable_actions for position_thinking_choice_v1 must be hero|villain',
        );
      }
      if (acceptable != null &&
          availableActions != null &&
          acceptable.any((action) => !availableActions.contains(action))) {
        throw const FormatException(
          'acceptable_actions for position_thinking_choice_v1 must be a subset of available_actions_v1 when present',
        );
      }
      break;
    case DrillKindV1.initiativeAggressorChoice:
      final actionId = spec.expected.actionId?.trim().toLowerCase();
      if (actionId == null ||
          !const <String>{'hero', 'villain'}.contains(actionId)) {
        throw const FormatException(
          'expected.actionId is required for initiative_aggressor_choice_v1 and must be hero|villain',
        );
      }
      final availableActions = spec.availableActionsV1;
      if (availableActions != null &&
          availableActions.any(
            (action) => !const <String>{'hero', 'villain'}.contains(action),
          )) {
        throw const FormatException(
          'available_actions_v1 for initiative_aggressor_choice_v1 must be hero|villain',
        );
      }
      if (availableActions != null && !availableActions.contains(actionId)) {
        throw const FormatException(
          'available_actions_v1 for initiative_aggressor_choice_v1 must include expected.actionId',
        );
      }
      final acceptable = spec.acceptableActions;
      if (acceptable != null &&
          acceptable.any(
            (action) => !const <String>{'hero', 'villain'}.contains(action),
          )) {
        throw const FormatException(
          'acceptable_actions for initiative_aggressor_choice_v1 must be hero|villain',
        );
      }
      if (acceptable != null &&
          availableActions != null &&
          acceptable.any((action) => !availableActions.contains(action))) {
        throw const FormatException(
          'acceptable_actions for initiative_aggressor_choice_v1 must be a subset of available_actions_v1 when present',
        );
      }
      break;
    case DrillKindV1.outsCountChoice:
      final actionId = spec.expected.actionId?.trim();
      if (actionId == null || !_kOutsCountIdsV1.contains(actionId)) {
        throw const FormatException(
          'expected.actionId is required for outs_count_choice_v1 and must be 4|8|9|15',
        );
      }
      final availableActions = spec.availableActionsV1;
      if (availableActions != null &&
          availableActions.any(
            (action) => !_kOutsCountIdsV1.contains(action),
          )) {
        throw const FormatException(
          'available_actions_v1 for outs_count_choice_v1 must be 4|8|9|15',
        );
      }
      if (availableActions != null && !availableActions.contains(actionId)) {
        throw const FormatException(
          'available_actions_v1 for outs_count_choice_v1 must include expected.actionId',
        );
      }
      final acceptable = spec.acceptableActions;
      if (acceptable != null &&
          acceptable.any((action) => !_kOutsCountIdsV1.contains(action))) {
        throw const FormatException(
          'acceptable_actions for outs_count_choice_v1 must be 4|8|9|15',
        );
      }
      if (acceptable != null &&
          availableActions != null &&
          acceptable.any((action) => !availableActions.contains(action))) {
        throw const FormatException(
          'acceptable_actions for outs_count_choice_v1 must be a subset of available_actions_v1 when present',
        );
      }
      break;
    case DrillKindV1.boardTextureClassifier:
      final boardTexture = spec.boardTextureV1;
      if (boardTexture == null ||
          !_kBoardTextureV1Values.contains(boardTexture)) {
        throw const FormatException(
          'board_texture_v1 is required for board_texture_classifier_v1 and must be dry|wet|paired|connected|high_card',
        );
      }
      final availableActions = spec.availableActionsV1;
      if (availableActions != null &&
          availableActions.any(
            (action) => !_kBoardTextureActionsV1.contains(action),
          )) {
        throw const FormatException(
          'available_actions_v1 for board_texture_classifier_v1 must be fold|call|raise',
        );
      }
      final expectedAction = spec.expectedActionV1;
      if (expectedAction == null ||
          !_kBoardTextureActionsV1.contains(expectedAction)) {
        throw const FormatException(
          'expected_action is required for board_texture_classifier_v1 and must be fold|call|raise',
        );
      }
      if (availableActions != null &&
          !availableActions.contains(expectedAction)) {
        throw const FormatException(
          'available_actions_v1 for board_texture_classifier_v1 must include expected_action',
        );
      }
      final acceptable = spec.acceptableActions;
      if (acceptable != null &&
          acceptable.any(
            (action) => !_kBoardTextureActionsV1.contains(action),
          )) {
        throw const FormatException(
          'acceptable_actions for board_texture_classifier_v1 must be fold|call|raise',
        );
      }
      if (acceptable != null &&
          availableActions != null &&
          acceptable.any((action) => !availableActions.contains(action))) {
        throw const FormatException(
          'acceptable_actions for board_texture_classifier_v1 must be a subset of available_actions_v1 when present',
        );
      }
      break;
    case DrillKindV1.rangeBucketClassifier:
      final rangeBucket = spec.rangeBucketV1;
      if (rangeBucket == null || !_kRangeBucketV1Values.contains(rangeBucket)) {
        throw const FormatException(
          'range_bucket_v1 is required for range_bucket_classifier_v1 and must be strong|medium|weak|draw|missed',
        );
      }
      final expectedAction = spec.expectedActionV1;
      if (expectedAction == null ||
          !_kRangeBucketActionsV1.contains(expectedAction)) {
        throw const FormatException(
          'expected_action is required for range_bucket_classifier_v1 and must be fold|call|raise',
        );
      }
      final acceptable = spec.acceptableActions;
      if (acceptable != null &&
          acceptable.any(
            (action) => !_kRangeBucketActionsV1.contains(action),
          )) {
        throw const FormatException(
          'acceptable_actions for range_bucket_classifier_v1 must be fold|call|raise',
        );
      }
      break;
    case DrillKindV1.handChain:
      final chainId = spec.chainIdV1;
      if (chainId == null || chainId.isEmpty) {
        throw const FormatException('chain_id is required for hand_chain_v1');
      }
      final steps = spec.chainStepsV1;
      if (steps == null || steps.length < 2 || steps.length > 4) {
        throw const FormatException(
          'hand_chain_v1 steps are required and length must be 2..4',
        );
      }
      break;
    case DrillKindV1.holeCardsTap:
      final cardSlot = spec.expected.cardSlot;
      if (cardSlot == null || (cardSlot != 'p0' && cardSlot != 'p1')) {
        throw const FormatException(
          'expected.cardSlot is required for hole_cards_tap (p0|p1)',
        );
      }
      break;
  }
}

String? _normalizeHoleCardSlotV1(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final normalized = raw.trim().toLowerCase();
  switch (normalized) {
    case 'hole_left':
      return 'p0';
    case 'hole_right':
      return 'p1';
    case 'p0':
    case 'p1':
      return normalized;
    default:
      return raw;
  }
}

List<String> parseDrillIdsFromIndexV1(String source) {
  final ids = <String>[];
  for (final rawLine in const LineSplitter().convert(source)) {
    final line = rawLine.trimRight();
    final match = RegExp(r'^- ([a-z0-9_]+):').firstMatch(line);
    if (match != null) {
      ids.add(match.group(1)!);
    }
  }
  return ids;
}

bool hasListedDrillsInIndexV1(String source) =>
    parseDrillIdsFromIndexV1(source).isNotEmpty;

bool isCardIdV1(String value) => _isCardIdV1(value);

bool _isCardIdV1(String value) => _kCardIdV1Pattern.hasMatch(value);

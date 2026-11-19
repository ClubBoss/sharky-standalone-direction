part 'campaign_pack_registry_spine_v1.dart';
part 'campaign_pack_registry_packs_v1.dart';

/// Compatibility campaign pack registry for the older intro/core microtask
/// chain. This file remains live for runner/bootstrap/test compatibility, but
/// it is no longer the active product content truth for Sharky_1.0.
enum MicroTaskStreetV1 { flop, turn, river }

class MicroTaskStep {
  const MicroTaskStep({
    required this.prompt,
    required this.hint,
    required this.expectedSeatIds,
    this.contextText,
    this.tradeoffText,
    this.consequenceText,
    this.insightText,
    this.instructionText,
    this.goalText,
    this.guidedScope,
    this.isoGroup,
    this.heroSeatId,
    this.street,
    this.boardCards,
    this.heroCards,
    this.pot,
    this.toCall,
    this.allowedActions,
    this.expectedActionKind,
  });

  final String prompt;
  final String hint;
  final List<String> expectedSeatIds;
  final String? contextText;
  final String? tradeoffText;
  final String? consequenceText;
  final String? insightText;
  final String? instructionText;
  final String? goalText;
  final String? guidedScope;
  final String? isoGroup;
  final String? heroSeatId;
  final MicroTaskStreetV1? street;
  final List<String>? boardCards;
  final List<String>? heroCards;
  final int? pot;
  final int? toCall;
  final List<String>? allowedActions;
  final String? expectedActionKind;
}

typedef World1MicroTaskPack = List<MicroTaskStep>;

MicroTaskStep mtStep({
  required String prompt,
  required String hint,
  required List<String> expectedSeatIds,
  String? instructionText,
  String? goalText,
  String? guidedScope,
  String? isoGroup,
  String? contextText,
  String? tradeoffText,
  String? consequenceText,
  String? insightText,
  String? heroSeatId,
  MicroTaskStreetV1? street,
  List<String>? boardCards,
  List<String>? heroCards,
  int? pot,
  int? toCall,
  List<String>? allowedActions,
  String? expectedActionKind,
}) {
  assert(
    _isValidBoardCardsCountV1(boardCards),
    'boardCards must be null or length 0/3/4/5',
  );
  assert(
    _isValidHeroCardsCountV1(heroCards),
    'heroCards must be null or length 2',
  );
  return MicroTaskStep(
    prompt: prompt,
    hint: hint,
    expectedSeatIds: expectedSeatIds,
    instructionText: instructionText,
    goalText: goalText,
    guidedScope: guidedScope,
    isoGroup: isoGroup,
    contextText: contextText,
    tradeoffText: tradeoffText,
    consequenceText: consequenceText,
    insightText: insightText,
    heroSeatId: heroSeatId,
    street: street,
    boardCards: boardCards == null ? null : List<String>.from(boardCards),
    heroCards: heroCards == null ? null : List<String>.from(heroCards),
    pot: pot,
    toCall: toCall,
    allowedActions: allowedActions == null
        ? null
        : List<String>.from(allowedActions),
    expectedActionKind: expectedActionKind,
  );
}

bool _isValidBoardCardsCountV1(List<String>? cards) {
  if (cards == null) return true;
  return cards.length == 0 ||
      cards.length == 3 ||
      cards.length == 4 ||
      cards.length == 5;
}

bool _isValidHeroCardsCountV1(List<String>? cards) {
  if (cards == null) return true;
  return cards.length == 2;
}

World1MicroTaskPack pack12(
  List<MicroTaskStep> steps, {
  int minDistinctConsequenceTexts = 0,
}) {
  assert(steps.length == 12, 'Campaign pack must contain exactly 12 hands.');
  assert(
    minDistinctConsequenceTexts <= 0 ||
        distinctConsequenceTextCount(steps) >= minDistinctConsequenceTexts,
    'Campaign pack consequence text variety invariant failed.',
  );
  return steps;
}

int distinctConsequenceTextCount(Iterable<MicroTaskStep> steps) {
  final values = steps
      .map((step) => step.consequenceText?.trim() ?? '')
      .where((value) => value.isNotEmpty)
      .toSet();
  return values.length;
}

bool hasPositiveAndNegativeConsequenceDeltas(
  Iterable<MicroTaskStep> steps, {
  String positiveToken = '+8',
  String negativeToken = '-6',
}) {
  var sawPositive = false;
  var sawNegative = false;
  for (final step in steps) {
    final consequence = step.consequenceText ?? '';
    if (consequence.contains(positiveToken)) {
      sawPositive = true;
    }
    if (consequence.contains(negativeToken)) {
      sawNegative = true;
    }
    if (sawPositive && sawNegative) {
      return true;
    }
  }
  return false;
}

int distinctConsequenceTextCountForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  final pack = kCampaignPacksV1[normalized];
  if (pack == null) {
    return 0;
  }
  return distinctConsequenceTextCount(pack);
}

bool hasPositiveAndNegativeConsequenceDeltasForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  final pack = kCampaignPacksV1[normalized];
  if (pack == null) {
    return false;
  }
  return hasPositiveAndNegativeConsequenceDeltas(pack);
}

const Set<String> kCampaignPackIdsV1 = <String>{
  'world1_act0_table_literacy',
  'world1_act0_action_literacy',
  'world1_act0_street_flow',
  'world1_spine_campaign_v1',
  'world1_spine_followup_v1_b0',
  'world1_spine_followup_v1_b1',
  'world1_spine_followup_v1_b2',
  'world2_spine_campaign_v1',
  'world2_spine_followup_v1_b0',
  'world2_spine_followup_v1_b1',
  'world2_spine_followup_v1_b2',
  'world3_spine_campaign_v1',
  'world3_spine_followup_v1_b0',
  'world3_spine_followup_v1_b1',
  'world3_spine_followup_v1_b2',
  'world4_spine_campaign_v1',
  'world4_spine_followup_v1_b0',
  'world4_spine_followup_v1_b1',
  'world4_spine_followup_v1_b2',
  'world5_spine_campaign_v1',
  'world5_spine_followup_v1_b0',
  'world5_spine_followup_v1_b1',
  'world5_spine_followup_v1_b2',
  'world6_spine_campaign_v1',
  'world6_spine_followup_v1_b0',
  'world6_spine_followup_v1_b1',
  'world6_spine_followup_v1_b2',
  'volume_i_terminal_review_v1',
  'world7_spine_campaign_v1',
  'world7_spine_followup_v1_b0',
  'world7_spine_followup_v1_b1',
  'world7_spine_followup_v1_b2',
  'world8_spine_campaign_v1',
  'world8_spine_followup_v1_b0',
  'world8_spine_followup_v1_b1',
  'world8_spine_followup_v1_b2',
  'world9_spine_campaign_v1',
  'world9_spine_followup_v1_b0',
  'world9_spine_followup_v1_b1',
  'world9_spine_followup_v1_b2',
  'world10_spine_campaign_v1',
  'world10_spine_followup_v1_b0',
  'world10_spine_followup_v1_b1',
  'world10_spine_followup_v1_b2',
  'world11_spine_campaign_v1',
  'world11_spine_followup_v1_b0',
  'world11_spine_followup_v1_b1',
  'world11_spine_followup_v1_b2',
  'world12_spine_campaign_v1',
  'world12_spine_followup_v1_b0',
  'world12_spine_followup_v1_b1',
  'world12_spine_followup_v1_b2',
};

int campaignHandCountForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  if (!kCampaignPackIdsV1.contains(normalized)) {
    return 0;
  }
  final pack = kCampaignPacksV1[normalized];
  return pack?.length ?? 0;
}

bool isCampaignPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  return kCampaignPackIdsV1.contains(normalized);
}

List<String> campaignFollowupPackIdsV1() {
  final ids = <String>[];
  for (final id in kCampaignPackIdsV1) {
    if (id.contains('_spine_followup_v1_b0') ||
        id.contains('_spine_followup_v1_b1') ||
        id.contains('_spine_followup_v1_b2')) {
      ids.add(id);
    }
  }
  ids.sort();
  return ids;
}

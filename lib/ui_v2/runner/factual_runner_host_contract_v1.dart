import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_reveal_payload_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_source_meta_contract_v1.dart';

enum FactualRunnerHostFamilyV1 {
  position,
  outs,
  factualHandChain,
  initiative,
  texture,
}

@immutable
class FactualRunnerHostSupplementCardV1 {
  const FactualRunnerHostSupplementCardV1({
    required this.testKey,
    required this.title,
    required this.body,
    this.eyebrow,
  });

  final String testKey;
  final String title;
  final String body;
  final String? eyebrow;
}

@immutable
class FactualRunnerHostSupplementContractV1 {
  const FactualRunnerHostSupplementContractV1({
    this.introCards = const <FactualRunnerHostSupplementCardV1>[],
    this.recapCards = const <FactualRunnerHostSupplementCardV1>[],
  });

  final List<FactualRunnerHostSupplementCardV1> introCards;
  final List<FactualRunnerHostSupplementCardV1> recapCards;

  bool get hasIntroCards => introCards.isNotEmpty;
  bool get hasRecapCards => recapCards.isNotEmpty;
  bool get hasAnyCards => hasIntroCards || hasRecapCards;
}

FactualRunnerHostFamilyV1? parseFactualRunnerHostFamilyV1(Object? raw) {
  final normalized = raw?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return switch (normalized) {
    'position' => FactualRunnerHostFamilyV1.position,
    'outs' => FactualRunnerHostFamilyV1.outs,
    'factualHandChain' => FactualRunnerHostFamilyV1.factualHandChain,
    'initiative' => FactualRunnerHostFamilyV1.initiative,
    'texture' => FactualRunnerHostFamilyV1.texture,
    _ => null,
  };
}

@immutable
class FactualRunnerHostContractV1 {
  const FactualRunnerHostContractV1({
    required this.family,
    required this.presentation,
    required this.sections,
    this.sourceMeta = const RunnerHostSourceMetaContractV1(),
    this.supplements = const FactualRunnerHostSupplementContractV1(),
  });

  final FactualRunnerHostFamilyV1 family;
  final RunnerHostPromptRevealPresentationResolvedV1 presentation;
  final RunnerHostSectionResponsibilityV1 sections;
  final RunnerHostSourceMetaContractV1 sourceMeta;
  final FactualRunnerHostSupplementContractV1 supplements;

  bool get showsSourceMeta => sections.showSourceMeta && sourceMeta.hasEntries;
  RunnerHostPromptRevealPresentationResolvedV1 get promptReveal => presentation;
  RunnerRevealPayloadResolvedV1 get reveal => presentation.reveal;
  String get shortPrompt => presentation.shortPrompt;
  String get detailsPrompt => presentation.detailsPrompt;
  bool get canReveal => presentation.canReveal;
  List<RunnerHostSourceMetaEntryV1> get sourceMetaEntries => sourceMeta.entries;
  bool get showIntro => sections.showIntro;
  bool get showRecap => sections.showRecap;
  bool get showCompletionInHeader => sections.showCompletionInHeader;
  bool get showEmbeddedFeedbackBelowTable =>
      sections.showEmbeddedFeedbackBelowTable;
  List<FactualRunnerHostSupplementCardV1> get introSupplementCards =>
      supplements.introCards;
  List<FactualRunnerHostSupplementCardV1> get recapSupplementCards =>
      supplements.recapCards;
  bool get hasAnySupplementCards => supplements.hasAnyCards;
}

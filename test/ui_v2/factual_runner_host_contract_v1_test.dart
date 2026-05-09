import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_runner_item_normalizer_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';

void main() {
  test('factual host contract keeps behavior unchanged when supplements are absent', () {
    final presentation = resolveRunnerHostPromptRevealPresentationV1(
      const RunnerHostPromptRevealPresentationInputV1(
        sourceId: 'legacy_alignment_v1#drill1',
        canonicalPrompt: 'Who acts last?',
        shortPromptOverride: 'Who acts last?',
      ),
    );

    final contract = FactualRunnerHostContractV1(
      family: FactualRunnerHostFamilyV1.position,
      presentation: presentation,
      sections: const RunnerHostSectionResponsibilityV1(
        showIntro: true,
        showRecap: true,
      ),
    );

    expect(contract.showIntro, isTrue);
    expect(contract.showRecap, isTrue);
    expect(contract.introSupplementCards, isEmpty);
    expect(contract.recapSupplementCards, isEmpty);
    expect(contract.hasAnySupplementCards, isFalse);
  });

  test('factual host contract accepts canonical surfaced supplement cards', () {
    final presentation = resolveRunnerHostPromptRevealPresentationV1(
      const RunnerHostPromptRevealPresentationInputV1(
        sourceId: 'legacy_alignment_v1#drill1',
        canonicalPrompt: 'Count your outs.',
        shortPromptOverride: 'Count your outs.',
      ),
    );

    final contract = FactualRunnerHostContractV1(
      family: FactualRunnerHostFamilyV1.outs,
      presentation: presentation,
      sections: const RunnerHostSectionResponsibilityV1(
        showIntro: true,
        showRecap: true,
      ),
      supplements: const FactualRunnerHostSupplementContractV1(
        introCards: <FactualRunnerHostSupplementCardV1>[
          FactualRunnerHostSupplementCardV1(
            testKey: 'outs_intro_v1',
            eyebrow: 'Outs',
            title: 'Count clean outs first',
            body: 'Discount dirty outs before comparing price and equity.',
          ),
        ],
        recapCards: <FactualRunnerHostSupplementCardV1>[
          FactualRunnerHostSupplementCardV1(
            testKey: 'outs_recap_v1',
            title: 'Rule of 2 and 4 is approximate',
            body: 'Use it as a shortcut, then refine when the spot is close.',
          ),
        ],
      ),
    );

    expect(contract.hasAnySupplementCards, isTrue);
    expect(contract.introSupplementCards, hasLength(1));
    expect(contract.recapSupplementCards, hasLength(1));
    expect(contract.introSupplementCards.single.testKey, 'outs_intro_v1');
    expect(contract.recapSupplementCards.single.title, 'Rule of 2 and 4 is approximate');
  });

  test('legacy factual host builder stays compatible when supplements are absent', () {
    final item = normalizeLegacyDrillRunnerItemV1(<String, dynamic>{
      'question': 'Who acts last?',
      'factual_family_v1': 'position',
      'reaction_text': 'Button closes the action.',
    });
    final presentation = resolveRunnerHostPromptRevealPresentationV1(
      const RunnerHostPromptRevealPresentationInputV1(
        sourceId: 'legacy_alignment_v1#drill1',
        canonicalPrompt: 'Who acts last?',
        shortPromptOverride: 'Who acts last?',
      ),
    );

    final contract = buildLegacyDrillRunnerFactualHostContractV1(
      item: item,
      presentation: presentation,
      sections: const RunnerHostSectionResponsibilityV1(),
    );

    expect(contract, isNotNull);
    expect(contract!.family, FactualRunnerHostFamilyV1.position);
    expect(contract.hasAnySupplementCards, isFalse);
  });
}

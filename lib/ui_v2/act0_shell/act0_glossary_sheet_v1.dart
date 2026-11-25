import 'package:flutter/material.dart';

import 'act0_poker_reference_tools_v1.dart';
import 'act0_task_help_policy_v1.dart';
import 'skin/act0_skin_components_v1.dart';
import 'skin/act0_skin_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Only current learner-visible copy; never future teaching, hidden hints,
/// graded choices or feedback. Option definitions can themselves be answers.
String act0GlossaryTaskTextV1(Act0RunnerStateV1 runner, {String? question}) => [
  runner.caption,
  question ?? runner.question,
  if (runner.activeTeachingStep case final step?) '${step.title} ${step.body}',
].join(' ');

/// The same rule runs in every runner composition and task family.
Set<Act0TaskHelpToolV1> act0TaskHelpToolsForRunnerV1(
  Act0RunnerStateV1 runner, {
  String? question,
}) => act0TaskHelpToolsV1(
  question: question ?? runner.question,
  context: act0GlossaryTaskTextV1(runner, question: question),
  hasExposedOpponentCards: runner.table.seats.any(
    (seat) =>
        !seat.isHero &&
        seat.holeCards.isNotEmpty &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp,
  ),
  canDraw:
      runner.table.boardCards.length == 3 ||
      runner.table.boardCards.length == 4,
);

/// Glossary terms used in [taskText], in dictionary order.
List<Act0GlossaryTermV1> act0GlossaryTermsInV1(String taskText) => [
  for (final t in act0GlossaryTermsV1)
    if (t.usedIn(taskText)) t,
];

Future<void> showAct0GlossarySheetV1(
  BuildContext context, {
  required String taskText,
  required Set<Act0TaskHelpToolV1> tools,
  Future<bool> Function()? onNumericHelp,
  bool allowGlossary = true,
  bool initialFromFlop = true,
  bool allowHandRanks = false,
  List<String> assessmentOptions = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : null,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Act0SkinTokensV1.surface,
    builder: (_) => Act0GlossarySheetV1(
      taskText: taskText,
      tools: tools,
      onNumericHelp: onNumericHelp,
      allowGlossary: allowGlossary,
      initialFromFlop: initialFromFlop,
      allowHandRanks: allowHandRanks,
      assessmentOptions: assessmentOptions,
    ),
  );
}

class Act0GlossarySheetV1 extends StatelessWidget {
  const Act0GlossarySheetV1({
    super.key,
    required this.taskText,
    required this.tools,
    this.onNumericHelp,
    this.allowGlossary = true,
    this.initialFromFlop = true,
    this.allowHandRanks = false,
    this.assessmentOptions = const [],
  });

  final String taskText;
  final Set<Act0TaskHelpToolV1> tools;
  final Future<bool> Function()? onNumericHelp;
  final bool allowGlossary;
  final bool initialFromFlop;
  final bool allowHandRanks;
  final List<String> assessmentOptions;

  @override
  Widget build(BuildContext context) {
    final inTask = allowGlossary
        ? act0GlossaryTermsInV1(taskText).where((term) {
            // Do not define any offered answer, regardless of its grade.
            return !assessmentOptions.any(
              (option) =>
                  term.usedIn(option) ||
                  (option.trim().length > 4 &&
                      term.definition.toLowerCase().contains(
                        option.trim().toLowerCase(),
                      )),
            );
          }).toList()
        : <Act0GlossaryTermV1>[];
    final showRanks =
        allowHandRanks &&
        RegExp(
          r'\bhand (?:ranks?|hierarchy|strength)\b|\bwhich hand (?:wins|is stronger)\b|\b(?:royal flush|straight flush|four of a kind|full house|two pair|high card)\b',
          caseSensitive: false,
        ).hasMatch(taskText);
    String slug(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    Widget entry(String title, String body, String key) => Padding(
      key: Key(key),
      padding: const EdgeInsets.symmetric(vertical: Act0SkinTokensV1.gapSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Act0SkinTokensV1.headline),
          Text(body, style: Act0SkinTokensV1.secondary),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Act0SkinTokensV1.screenGutter),
            child: Column(
              children: [
                Act0SkinSheetHeaderV1(
                  title: 'Help',
                  trailing: IconButton(
                    key: const Key('act0_glossary_close'),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: Act0SkinTokensV1.muted,
                  ),
                ),
                Expanded(
                  child: ListView(
                    key: const Key('act0_glossary_sheet'),
                    controller: controller,
                    children: [
                      if (tools.isNotEmpty)
                        Act0PokerReferenceToolsV1(
                          tools: tools,
                          onOpen: onNumericHelp,
                          initialFromFlop: initialFromFlop,
                        ),
                      if (inTask.isNotEmpty) ...[
                        const Text(
                          'IN THIS TASK',
                          key: Key('act0_glossary_in_task'),
                          style: Act0SkinTokensV1.sectionLabel,
                        ),
                        for (final term in inTask)
                          entry(
                            term.name,
                            term.definition,
                            'act0_glossary_term_${slug(term.name)}',
                          ),
                      ],
                      if (showRanks) ...[
                        const Text(
                          'HAND RANKS, BEST FIRST',
                          key: Key('act0_glossary_hand_ranks'),
                          style: Act0SkinTokensV1.sectionLabel,
                        ),
                        for (final (i, rank) in act0HandRanksV1.indexed)
                          entry(
                            '${i + 1}. ${rank.name}',
                            '${rank.example}. ${rank.definition}',
                            'act0_glossary_rank_${slug(rank.name)}',
                          ),
                      ],
                      if (tools.isEmpty && inTask.isEmpty && !showRanks)
                        const Text(
                          'Use the question and visible facts to make your decision.',
                          style: Act0SkinTokensV1.secondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

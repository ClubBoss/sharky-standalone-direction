import 'package:flutter/material.dart';

import 'act0_poker_reference_tools_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

/// Text a learner can read in this task before answering: lesson, teaching
/// steps, question and option labels. Feedback is left out on purpose.
String act0GlossaryTaskTextV1(Act0RunnerStateV1 runner) => [
  runner.lessonTitle,
  runner.caption,
  runner.question,
  runner.hint,
  for (final s in runner.teachingSteps) '${s.title} ${s.body}',
  for (final o in runner.options) o.label,
].join(' ');

/// Glossary terms used in [taskText], in dictionary order.
List<Act0GlossaryTermV1> act0GlossaryTermsInV1(String taskText) => [
  for (final t in act0GlossaryTermsV1)
    if (t.usedIn(taskText)) t,
];

Future<void> showAct0GlossarySheetV1(
  BuildContext context, {
  required String taskText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : null,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Act0ShellTokensV1.surface,
    builder: (_) => Act0GlossarySheetV1(taskText: taskText),
  );
}

class Act0GlossarySheetV1 extends StatelessWidget {
  const Act0GlossarySheetV1({super.key, required this.taskText});

  final String taskText;

  @override
  Widget build(BuildContext context) {
    final inTask = act0GlossaryTermsInV1(taskText);
    final others = [
      for (final t in act0GlossaryTermsV1)
        if (!inTask.contains(t)) t,
    ];
    final title = Act0ShellTokensV1.body.copyWith(
      color: Act0ShellTokensV1.text,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    );
    final text = Act0ShellTokensV1.body.copyWith(
      color: Act0ShellTokensV1.textMuted,
      fontSize: 14,
      height: 1.3,
    );
    Widget heading(String label, String key) => Padding(
      key: Key(key),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.textMuted,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    Widget entry(String name, String body, String key) => Padding(
      key: Key(key),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: title),
          const SizedBox(height: 2),
          Text(body, style: text),
        ],
      ),
    );
    String slug(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Glossary', style: title.copyWith(fontSize: 20)),
                ),
                IconButton(
                  key: const Key('act0_glossary_close'),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: Act0ShellTokensV1.textMuted,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              key: const Key('act0_glossary_sheet'),
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                const Act0PokerReferenceToolsV1(),
                if (inTask.isNotEmpty) ...[
                  heading('IN THIS TASK', 'act0_glossary_in_task'),
                  for (final t in inTask)
                    entry(
                      t.name,
                      t.definition,
                      'act0_glossary_term_${slug(t.name)}',
                    ),
                ],
                heading('HAND RANKS, BEST FIRST', 'act0_glossary_hand_ranks'),
                for (final (i, r) in act0HandRanksV1.indexed)
                  entry(
                    '${i + 1}. ${r.name}',
                    '${r.example}. ${r.definition}',
                    'act0_glossary_rank_${slug(r.name)}',
                  ),
                heading(
                  inTask.isEmpty ? 'TERMS' : 'OTHER TERMS',
                  'act0_glossary_other_terms',
                ),
                for (final t in others)
                  entry(
                    t.name,
                    t.definition,
                    'act0_glossary_term_${slug(t.name)}',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

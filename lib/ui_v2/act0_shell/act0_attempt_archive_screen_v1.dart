import 'package:flutter/material.dart';

import 'act0_academy_reading_style_v1.dart';
import 'act0_attempt_archive_v1.dart';
import 'act0_completed_decision_contract_v1.dart';
import 'act0_shell_tokens_v1.dart';

class Act0AttemptArchiveScreenV1 extends StatefulWidget {
  const Act0AttemptArchiveScreenV1({
    super.key,
    required this.archive,
    required this.onClose,
    required this.onSelect,
    required this.onRemove,
  });

  final Act0AttemptArchiveV1 archive;
  final VoidCallback onClose;
  final ValueChanged<String?> onSelect;
  final ValueChanged<String> onRemove;

  @override
  State<Act0AttemptArchiveScreenV1> createState() =>
      _Act0AttemptArchiveScreenV1State();
}

class _Act0AttemptArchiveScreenV1State
    extends State<Act0AttemptArchiveScreenV1> {
  String? _confirmRemovalId;

  @override
  Widget build(BuildContext context) {
    final archive = widget.archive;
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onClose();
      },
      child: ListView.builder(
        key: const Key('act0_attempt_archive_list'),
        padding: EdgeInsets.fromLTRB(
          pagePadding,
          Act0ShellTokensV1.gapMd,
          pagePadding,
          Act0ShellTokensV1.gapXl,
        ),
        itemCount: archive.attempts.isEmpty ? 2 : archive.attempts.length + 1,
        itemBuilder: (context, index) {
          final Widget child;
          if (index == 0) {
            child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  key: const Key('act0_attempt_archive_back'),
                  onPressed: widget.onClose,
                  child: const Text('Back to Review'),
                ),
                const Text(
                  'Attempt archive',
                  style: Act0AcademyReadingStyleV1.sectionTitle,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
            );
          } else if (archive.attempts.isEmpty) {
            child = const Text(
              'No saved attempts yet.',
              style: Act0AcademyReadingStyleV1.muted,
            );
          } else {
            child = _attemptRow(context, archive.attempts[index - 1]);
          }
          return Act0ShellTokensV1.centeredContent(
            context,
            tabletMaxWidth: 860,
            child: child,
          );
        },
      ),
    );
  }

  Widget _attemptRow(BuildContext context, Act0ArchivedAttemptV1 attempt) {
    final evidence = attempt.evidence;
    final selected = widget.archive.selectedId == attempt.id;
    final time = evidence.recordedAtUtc!.toLocal();
    final dateLabels = MaterialLocalizations.of(context);
    final date = dateLabels.formatMediumDate(time);
    final clock = dateLabels.formatTimeOfDay(TimeOfDay.fromDateTime(time));
    final result = switch (evidence.resultKind) {
      'correct' || 'co_correct' => 'Correct',
      'acceptable' => 'Acceptable',
      'suboptimal' => 'Suboptimal',
      _ => 'Incorrect',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          key: Key('act0_attempt_archive_entry_${attempt.id}'),
          contentPadding: EdgeInsets.zero,
          title: Text(
            attempt.taskLabel ?? evidence.taskId,
            style: Act0AcademyReadingStyleV1.body,
          ),
          subtitle: Text(
            '$date · $clock · $result',
            style: Act0AcademyReadingStyleV1.muted,
          ),
          selected: selected,
          trailing: Icon(selected ? Icons.expand_less : Icons.expand_more),
          onTap: () {
            setState(() => _confirmRemovalId = null);
            widget.onSelect(selected ? null : attempt.id);
          },
        ),
        if (selected) ...[
          Text(
            'Your choice: ${attempt.choiceLabel ?? evidence.choiceId}',
            style: Act0AcademyReadingStyleV1.body,
          ),
          Text(switch (evidence.assistanceKind) {
            Act0DecisionAssistanceV1.none => 'Help: none',
            Act0DecisionAssistanceV1.quickHint => 'Help: quick hint',
            Act0DecisionAssistanceV1.theoryRecall => 'Help: theory recall',
            Act0DecisionAssistanceV1.legacyUnknown => 'Help: unknown',
          }, style: Act0AcademyReadingStyleV1.muted),
          if (attempt.reflection.confidence case final confidence?)
            Text(switch (confidence) {
              Act0DecisionConfidenceV1.unsure => 'Confidence: unsure',
              Act0DecisionConfidenceV1.somewhatSure =>
                'Confidence: somewhat sure',
              Act0DecisionConfidenceV1.verySure => 'Confidence: very sure',
            }, style: Act0AcademyReadingStyleV1.muted),
          if (attempt.reflection.openedClue case final clue?)
            Text(
              'Opened clue: ${clue.text}',
              style: Act0AcademyReadingStyleV1.muted,
            ),
          if (_confirmRemovalId == attempt.id) ...[
            const Text(
              'Remove this attempt from the archive?',
              style: Act0AcademyReadingStyleV1.body,
            ),
            Wrap(
              children: [
                TextButton(
                  key: const Key('act0_attempt_archive_confirm_remove'),
                  onPressed: () {
                    setState(() => _confirmRemovalId = null);
                    widget.onRemove(attempt.id);
                  },
                  child: const Text('Remove attempt'),
                ),
                TextButton(
                  onPressed: () => setState(() => _confirmRemovalId = null),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ] else
            TextButton(
              key: const Key('act0_attempt_archive_remove'),
              onPressed: () => setState(() => _confirmRemovalId = attempt.id),
              child: const Text('Remove from archive'),
            ),
        ],
        const Divider(),
      ],
    );
  }
}

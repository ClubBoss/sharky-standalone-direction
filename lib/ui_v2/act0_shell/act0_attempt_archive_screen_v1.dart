import 'package:flutter/material.dart';

import 'act0_academy_reading_style_v1.dart';
import 'act0_attempt_archive_v1.dart';
import 'act0_attempt_replay_screen_v1.dart';
import 'act0_completed_decision_contract_v1.dart';
import 'act0_club_night_tokens_v1.dart';
import 'act0_imported_hand_v1.dart';
import 'act0_manual_hand_screen_v1.dart';
import 'act0_shell_tokens_v1.dart';
import 'act0_w14_skill_state_v1.dart';

class Act0AttemptArchiveScreenV1 extends StatefulWidget {
  const Act0AttemptArchiveScreenV1({
    super.key,
    required this.archive,
    required this.onClose,
    required this.onSelect,
    required this.onRemove,
    required this.onOwnHandsChanged,
    this.onPracticeCallPrice,
  });

  final Act0AttemptArchiveV1 archive;
  final VoidCallback onClose;
  final ValueChanged<String?> onSelect;
  final ValueChanged<String> onRemove;
  final ValueChanged<Act0AttemptArchiveV1> onOwnHandsChanged;
  final VoidCallback? onPracticeCallPrice;

  @override
  State<Act0AttemptArchiveScreenV1> createState() =>
      _Act0AttemptArchiveScreenV1State();
}

class _Act0AttemptArchiveScreenV1State
    extends State<Act0AttemptArchiveScreenV1> {
  String? _confirmRemovalId;
  bool _showOwnHands = false;
  String _query = '';
  Act0ArchivedAttemptV1? _replayingAttempt;

  Act0ImportedHandV1? _replayingHand;

  Future<void> _enterHand([Act0ImportedHandV1? previous]) async {
    final hand = await Navigator.of(context).push<Act0ImportedHandV1>(
      MaterialPageRoute(
        builder: (_) => Act0ManualHandScreenV1(previous: previous),
      ),
    );
    if (!mounted || hand == null) return;
    widget.onOwnHandsChanged(widget.archive.saveManualHand(hand));
    setState(() => _replayingHand = hand);
  }

  Future<void> _import() async {
    var source = '';
    String? error;
    final updated = await showDialog<Act0AttemptArchiveV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Import own hand'),
          scrollable: true,
          content: TextField(
            minLines: 4,
            maxLines: 8,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'PokerStars hand history',
              helperText:
                  'English USD NLHE cash · one complete single-pot hand',
              helperMaxLines: 2,
              errorText: error,
              errorMaxLines: 3,
            ),
            onChanged: (value) => source = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  final next = widget.archive.importPokerStars(source);
                  if (identical(next, widget.archive)) {
                    setDialogState(() => error = 'This hand is already saved.');
                    return;
                  }
                  Navigator.of(context).pop(next);
                } on Act0HandImportExceptionV1 catch (failure) {
                  setDialogState(
                    () => error = switch (failure.code) {
                      Act0HandImportErrorV1.unsupportedFormat =>
                        'Unsupported format. Paste an English PokerStars USD NLHE cash hand.',
                      Act0HandImportErrorV1.malformedHand =>
                        'Incomplete, invalid or unsupported hand details'
                            '${failure.line == null ? '.' : ' near line ${failure.line}.'}',
                      Act0HandImportErrorV1.conflictingSource =>
                        'A different record for this PokerStars hand is already saved.',
                    },
                  );
                }
              },
              child: const Text('Import hand'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || updated == null) return;
    widget.onOwnHandsChanged(updated);
    setState(() => _replayingHand = updated.importedHands.first);
  }

  Future<void> _removeHand(Act0ImportedHandV1 hand) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this own hand?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove hand'),
          ),
        ],
      ),
    );
    if (!mounted || remove != true) return;
    widget.onOwnHandsChanged(widget.archive.removeImportedHand(hand.sourceKey));
  }

  void _back() {
    if (_replayingAttempt == null && _replayingHand == null) {
      if (_showOwnHands) {
        setState(() => _showOwnHands = false);
      } else {
        widget.onClose();
      }
    } else {
      setState(() {
        _replayingAttempt = null;
        _replayingHand = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attempt = _replayingAttempt;
    final hand = _replayingHand;
    final skill = act0W14LessonSkillsV1[hand?.practiceLessonId]?.first;
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: hand != null
          ? Act0AttemptReplayScreenV1.ownHand(
              hand: hand,
              onClose: _back,
              practice: skill == null
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$skill · Call price',
                          style: Act0ClubNightTokensV1.body,
                        ),
                        const Text(
                          'You faced a price to continue.',
                          style: Act0ClubNightTokensV1.secondary,
                        ),
                        if (widget.onPracticeCallPrice case final onPractice?)
                          TextButton(
                            onPressed: onPractice,
                            child: const Text('Practice call price'),
                          ),
                      ],
                    ),
            )
          : attempt == null
          ? (_showOwnHands ? _ownHandsList(context) : _archiveList(context))
          : Act0AttemptReplayScreenV1(attempt: attempt, onClose: _back),
    );
  }

  Widget _archiveList(BuildContext context) {
    final archive = widget.archive;
    final query = _query.trim().toLowerCase();
    final attempts = query.isEmpty
        ? archive.attempts
        : archive.attempts
              .where((attempt) {
                return [
                  attempt.taskLabel,
                  attempt.choiceLabel,
                  attempt.evidence.taskId,
                  attempt.evidence.choiceId,
                ].whereType<String>().any(
                  (label) => label.toLowerCase().contains(query),
                );
              })
              .toList(growable: false);
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    return ListView.builder(
      key: const PageStorageKey('act0_attempt_archive_list'),
      padding: EdgeInsets.fromLTRB(
        pagePadding,
        Act0ShellTokensV1.gapMd,
        pagePadding,
        Act0ShellTokensV1.gapXl,
      ),
      itemCount: attempts.isEmpty ? 2 : attempts.length + 1,
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
              TextButton(
                onPressed: () => setState(() => _showOwnHands = true),
                child: const Text('Own hands'),
              ),
              if (archive.attempts.isNotEmpty) ...[
                TextFormField(
                  key: const Key('act0_attempt_archive_search'),
                  initialValue: _query,
                  style: Act0AcademyReadingStyleV1.body,
                  decoration: const InputDecoration(
                    labelText: 'Search saved attempts',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() {
                    _query = value;
                    _confirmRemovalId = null;
                  }),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
            ],
          );
        } else if (attempts.isEmpty) {
          child = Text(
            archive.attempts.isEmpty
                ? 'No saved attempts yet.'
                : 'No matching attempts.',
            style: Act0AcademyReadingStyleV1.muted,
          );
        } else {
          child = _attemptRow(context, attempts[index - 1]);
        }
        return Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 860,
          child: child,
        );
      },
    );
  }

  Widget _ownHandsList(BuildContext context) {
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final hands = widget.archive.importedHands;
    return ColoredBox(
      color: Act0ClubNightTokensV1.wall,
      child: ListView.builder(
        key: const PageStorageKey('act0_own_hands_list'),
        padding: EdgeInsets.fromLTRB(
          pagePadding,
          Act0ShellTokensV1.gapMd,
          pagePadding,
          Act0ShellTokensV1.gapXl,
        ),
        itemCount: 1 + hands.length,
        itemBuilder: (context, index) => Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 860,
          child: index == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: _back,
                      child: const Text('Back to attempt archive'),
                    ),
                    const Text('Own hands', style: Act0ClubNightTokensV1.title),
                    Wrap(
                      children: [
                        TextButton(
                          onPressed: _import,
                          child: const Text('Import own hand'),
                        ),
                        TextButton(
                          onPressed: _enterHand,
                          child: const Text('Enter own hand'),
                        ),
                      ],
                    ),
                    if (hands.isEmpty)
                      const Text(
                        'No saved own hands.',
                        style: Act0ClubNightTokensV1.secondary,
                      ),
                  ],
                )
              : _handRow(hands[index - 1]),
        ),
      ),
    );
  }

  Widget _handRow(Act0ImportedHandV1 hand) => Column(
    key: ValueKey(hand.sourceKey),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${hand.isManual ? 'Manual entry' : 'PokerStars · ${hand.timeEt}'} · '
        '${hand.heroCards.join(' ')}',
        style: Act0ClubNightTokensV1.body,
      ),
      Wrap(
        children: [
          TextButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() => _replayingHand = hand);
            },
            child: const Text('Replay hand'),
          ),
          if (hand.isManual)
            TextButton(
              onPressed: () => _enterHand(hand),
              child: const Text('Edit hand'),
            ),
          TextButton(
            onPressed: () => _removeHand(hand),
            child: const Text('Remove own hand'),
          ),
        ],
      ),
      const Divider(),
    ],
  );

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
        Semantics(
          expanded: selected,
          child: ListTile(
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
          if (_confirmRemovalId != attempt.id)
            TextButton(
              key: const Key('act0_attempt_archive_open_replay'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() => _replayingAttempt = attempt);
              },
              child: const Text('Replay attempt'),
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

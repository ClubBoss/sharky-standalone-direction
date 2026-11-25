import 'act0_number_entry_v1.dart';
import 'package:flutter/material.dart';

import 'act0_attempt_archive_v1.dart';
import 'act0_attempt_archive_view_model_v1.dart';
import 'act0_attempt_replay_screen_v1.dart';
import 'act0_completed_decision_contract_v1.dart';

import 'act0_imported_hand_v1.dart';
import 'act0_manual_hand_screen_v1.dart';
import 'act0_w14_skill_state_v1.dart';
import 'skin/act0_skin_components_v1.dart';
import 'skin/act0_skin_tokens_v1.dart';

typedef _T = Act0SkinTokensV1;

class Act0AttemptArchiveScreenV1 extends StatefulWidget {
  const Act0AttemptArchiveScreenV1({
    super.key,
    required this.archive,
    required this.onClose,
    required this.onSelect,
    required this.onRemove,
    required this.onOwnHandsChanged,
    this.onPracticeCallPrice,
    this.practiceSpotForAttempt,
    this.initialReplayAttemptId,
    this.ownHands = false,
  });

  final Act0AttemptArchiveV1 archive;
  final VoidCallback onClose;
  final ValueChanged<String?> onSelect;
  final ValueChanged<String> onRemove;
  final ValueChanged<Act0AttemptArchiveV1> onOwnHandsChanged;
  final VoidCallback? onPracticeCallPrice;
  final VoidCallback? Function(Act0ArchivedAttemptV1)? practiceSpotForAttempt;
  final String? initialReplayAttemptId;
  final bool ownHands;

  @override
  State<Act0AttemptArchiveScreenV1> createState() =>
      _Act0AttemptArchiveScreenV1State();
}

class _Act0AttemptArchiveScreenV1State
    extends State<Act0AttemptArchiveScreenV1> {
  final _search = TextEditingController();
  String? _openFilter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  final _view = Act0AttemptArchiveViewModelV1();

  @override
  void initState() {
    super.initState();
    _view.replayingAttempt = widget.archive.attempts
        .where((attempt) => attempt.id == widget.initialReplayAttemptId)
        .firstOrNull;
  }

  Future<void> _enterHand([Act0ImportedHandV1? previous]) async {
    final hand = await Navigator.of(context).push<Act0ImportedHandV1>(
      MaterialPageRoute(
        builder: (_) => Act0ManualHandScreenV1(previous: previous),
      ),
    );
    if (!mounted || hand == null) return;
    try {
      widget.onOwnHandsChanged(widget.archive.saveManualHand(hand));
    } on Act0HandImportExceptionV1 catch (failure) {
      if (failure.code != Act0HandImportErrorV1.archiveFull) rethrow;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(act0OwnHandArchiveFullMessageV1)),
      );
      return;
    }
    setState(() => _view.replayingHand = hand);
  }

  Future<void> _import() async {
    var source = '';
    String? error;
    final updated = await showDialog<Act0AttemptArchiveV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Act0SkinDarkAreaV1(
          paintBackground: false,
          child: AlertDialog(
            title: const Text('Import own hand'),
            scrollable: true,
            content: TextField(
              minLines: 4,
              maxLines: 8,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'PokerStars hand history',
                helperText: 'English USD NLHE cash. Side pots are unsupported.',
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
                      setDialogState(
                        () => error = 'This hand is already saved.',
                      );
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
                        Act0HandImportErrorV1.archiveFull =>
                          act0OwnHandArchiveFullMessageV1,
                        Act0HandImportErrorV1.sidePot =>
                          act0OwnHandSidePotMessageV1,
                      },
                    );
                  }
                },
                child: const Text('Import hand'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || updated == null) return;
    widget.onOwnHandsChanged(updated);
    setState(() => _view.replayingHand = updated.importedHands.first);
  }

  Future<void> _removeHand(Act0ImportedHandV1 hand) async {
    final remove = await const Act0SkinConfirmSheetV1(
      title: 'Remove this own hand?',
      confirmLabel: 'Remove hand',
    ).show(context);
    if (!mounted || !remove) return;
    widget.onOwnHandsChanged(widget.archive.removeImportedHand(hand.sourceKey));
  }

  void _back() {
    if (_view.atArchiveRoot) {
      widget.onClose();
    } else {
      setState(_view.backToParent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attempt = _view.replayingAttempt;
    final hand = _view.replayingHand;
    final skill = act0W14LessonSkillsV1[hand?.practiceLessonId]?.first;
    return Act0SkinDarkAreaV1(
      maxContentWidth: _T.historyMaxWidth,
      child: PopScope<void>(
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
                          Text('$skill · Call price', style: _T.body),
                          const Text(
                            'You faced a price to continue.',
                            style: _T.secondary,
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
            ? (widget.ownHands ? _ownHandsList(context) : _archiveList(context))
            : Act0AttemptReplayScreenV1(
                attempt: attempt,
                onClose: _back,
                onPracticeSpot: widget.practiceSpotForAttempt?.call(attempt),
              ),
      ),
    );
  }

  static const _padding = EdgeInsets.fromLTRB(
    _T.historyGutter,
    _T.gapMd,
    _T.historyGutter,
    _T.gapXl,
  );

  Widget _archiveList(BuildContext context) {
    final archive = widget.archive;
    final attempts = _view.visibleAttempts(archive);
    final worlds = archive.attempts
        .map((entry) => entry.evidence.worldId)
        .toSet();
    final skills = archive.attempts
        .expand(Act0AttemptArchiveViewModelV1.skillsFor)
        .toSet();
    return ListView(
      key: const PageStorageKey('act0_attempt_archive_list'),
      padding: _padding,
      children: [
        Act0SkinScreenHeaderV1(
          backKey: const Key('act0_attempt_archive_back'),
          onBack: _back,
          title: 'Attempt archive',
        ),
        if (archive.attempts.isNotEmpty) ...[
          TextField(
            key: const Key('act0_attempt_archive_search'),
            controller: _search,
            decoration: const InputDecoration(
              labelText: 'Search saved attempts',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _view.query = value),
          ),
          Wrap(
            spacing: _T.gapSm,
            children: [
              _filter(
                'World',
                _view.world,
                worlds,
                (value) => _view.world = value,
              ),
              _filter(
                'Skill',
                _view.skill,
                skills,
                (value) => _view.skill = value,
              ),
              _filter('Outcome', _view.outcome, const {
                'Correct',
                'Wrong',
                'Repaired',
              }, (value) => _view.outcome = value),
            ],
          ),
        ],
        if (attempts.isEmpty)
          if (archive.attempts.isEmpty)
            Act0SkinEmptyStateV1(
              title: 'No saved attempts yet.',
              description: 'Your decisions will appear here after you answer.',
              action: TextButton(
                onPressed: _back,
                child: const Text('Return to Review'),
              ),
            )
          else
            Act0SkinEmptyStateV1(
              title: 'No matching attempts.',
              description: 'No saved attempts match this search and filters.',
              action: TextButton(
                onPressed: () => setState(() {
                  _search.clear();
                  _view.clearFilters();
                  _openFilter = null;
                }),
                child: const Text('Clear filters'),
              ),
            ),
        for (final attempt in attempts) _attemptRow(context, attempt),
      ],
    );
  }

  Widget _filter(
    String label,
    String? selected,
    Set<String> values,
    ValueChanged<String?> change,
  ) {
    final expanded = _openFilter == label;
    String readableValue(String value) =>
        label == 'World' && value.startsWith('world_')
        ? 'World ${value.substring('world_'.length)}'
        : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Act0SkinChipV1(
          label: selected == null
              ? label
              : '$label: ${readableValue(selected)}',
          tone: selected == null
              ? Act0SkinChipToneV1.neutral
              : Act0SkinChipToneV1.brass,
          selected: selected != null,
          onPressed: () =>
              setState(() => _openFilter = expanded ? null : label),
        ),
        if (expanded)
          Wrap(
            spacing: _T.gapSm,
            children: [
              for (final value in <String?>[null, ...(values.toList()..sort())])
                Act0SkinChipV1(
                  label: value == null
                      ? 'All ${label.toLowerCase()}s'
                      : readableValue(value),
                  selected: value == selected,
                  tone: value == selected
                      ? Act0SkinChipToneV1.brass
                      : Act0SkinChipToneV1.neutral,
                  onPressed: () => setState(() {
                    change(value);
                    _openFilter = null;
                  }),
                ),
            ],
          ),
      ],
    );
  }

  Widget _ownHandsList(BuildContext context) {
    final hands = widget.archive.importedHands;
    return ListView(
      key: const PageStorageKey('act0_own_hands_list'),
      padding: _padding,
      children: [
        Act0SkinScreenHeaderV1(title: 'Own hands', onBack: _back),
        if (hands.isEmpty)
          Act0SkinEmptyStateV1(
            title: 'No saved own hands.',
            description: 'Enter a hand to replay its recorded decisions.',
            action: TextButton(
              onPressed: _enterHand,
              child: const Text('Enter own hand'),
            ),
          )
        else
          TextButton(
            onPressed: _enterHand,
            child: const Text('Enter own hand'),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: _import,
            child: const Text('Import own hand'),
          ),
        ),
        for (final hand in hands) _handRow(hand),
      ],
    );
  }

  Widget _handRow(Act0ImportedHandV1 hand) => Column(
    key: ValueKey(hand.sourceKey),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Act0SkinListRowV1(
        title:
            '${hand.isManual ? 'Manual entry' : 'PokerStars · ${hand.timeEt}'} · '
            '${hand.heroCards.join(' ')}',
        subtitle: 'Replay hand',
        kind: Act0SkinListRowKindV1.hand,
        dark: true,
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _view.replayingHand = hand);
        },
      ),
      Wrap(
        children: [
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
    final usedWorkedMath =
        act0IsNumberEntryChoiceV1(evidence.choiceId) &&
        evidence.assistanceKind == Act0DecisionAssistanceV1.quickHint;
    final result = Act0AttemptArchiveViewModelV1.outcomeFor(attempt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Act0SkinListRowV1(
          controlKey: Key('act0_attempt_archive_entry_${attempt.id}'),
          title: attempt.taskLabel ?? evidence.taskId,
          subtitle: '$date · $clock · $result',
          kind: Act0SkinListRowKindV1.retry,
          dark: true,
          expanded: selected,
          onTap: () => widget.onSelect(selected ? null : attempt.id),
        ),
        if (selected) ...[
          Text(
            'Your choice: ${attempt.choiceLabel ?? evidence.choiceId}',
            style: _T.body,
          ),
          if (attempt.actionReason case final result?)
            Text(
              'Reason: ${result.reason.text} · ${result.reason.tag.label}',
              style: _T.secondary,
            ),
          Text(switch (evidence.assistanceKind) {
            Act0DecisionAssistanceV1.none => 'Help: none',
            Act0DecisionAssistanceV1.quickHint when usedWorkedMath =>
              'Help: worked calculation',
            Act0DecisionAssistanceV1.quickHint => 'Help: quick hint',
            Act0DecisionAssistanceV1.theoryRecall => 'Help: theory recall',
            Act0DecisionAssistanceV1.legacyUnknown => 'Help: unknown',
          }, style: _T.secondary),
          if (attempt.reflection.confidence case final confidence?)
            Text(switch (confidence) {
              Act0DecisionConfidenceV1.unsure => 'Confidence: unsure',
              Act0DecisionConfidenceV1.somewhatSure =>
                'Confidence: somewhat sure',
              Act0DecisionConfidenceV1.verySure => 'Confidence: very sure',
            }, style: _T.secondary),
          if (attempt.reflection.openedClue case final clue?)
            Text('Opened clue: ${clue.text}', style: _T.secondary),
          TextButton(
            key: const Key('act0_attempt_archive_open_replay'),
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() => _view.replayingAttempt = attempt);
            },
            child: const Text('Replay attempt'),
          ),
          Act0SkinListRowV1(
            controlKey: const Key('act0_attempt_archive_remove'),
            title: 'Remove from archive',
            kind: Act0SkinListRowKindV1.destructive,
            dark: true,
            onTap: () async {
              final confirmed = await const Act0SkinConfirmSheetV1(
                title: 'Remove this attempt from the archive?',
                confirmLabel: 'Remove attempt',
                confirmKey: Key('act0_attempt_archive_confirm_remove'),
              ).show(context);
              if (mounted && confirmed) widget.onRemove(attempt.id);
            },
          ),
        ],
        const Divider(),
      ],
    );
  }
}

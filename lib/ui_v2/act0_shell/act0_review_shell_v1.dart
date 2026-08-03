import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

bool _isRuLocaleV1(BuildContext context) => false;

String _reviewCopyV1(
  BuildContext context, {
  String? atomId,
  String? fallback,
  String? en,
  String? ru,
}) {
  if (atomId != null) {
    return act0LocalizedSurfaceAtomV1(
      context,
      atomId,
      fallback: fallback ?? en ?? '',
    );
  }
  return _isRuLocaleV1(context) ? (ru ?? en ?? '') : (en ?? fallback ?? '');
}

class Act0ReviewShellV1 extends StatelessWidget {
  const Act0ReviewShellV1({
    super.key,
    required this.review,
    required this.selected,
    required this.onSelected,
    this.onFixMistake,
    this.onReplayFixedMistake,
    this.sessionDrillRecheckQueueItems =
        const <SessionDrillRecheckLaunchQueueItemV1>[],
    this.onStartSessionDrillRecheck,
    this.mistakeHistoryItems = const <Act0ReviewMistakeHistoryItemV1>[],
    this.dueReviewItems = const <Act0DueReviewItemV1>[],
    this.onStartDueReview,
    this.nextStep,
    this.onOpenRecommendedAction,
    this.onOpenLearn,
  });

  final Act0ReviewStateV1 review;
  final String? selected;
  final ValueChanged<String> onSelected;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;
  final ValueChanged<Act0MistakeCardV1>? onReplayFixedMistake;
  final List<SessionDrillRecheckLaunchQueueItemV1>
  sessionDrillRecheckQueueItems;
  final ValueChanged<SessionDrillRecheckLaunchQueueItemV1>?
  onStartSessionDrillRecheck;
  final List<Act0ReviewMistakeHistoryItemV1> mistakeHistoryItems;
  final List<Act0DueReviewItemV1> dueReviewItems;
  final ValueChanged<Act0DueReviewItemV1>? onStartDueReview;
  final Act0PersonalizedReturnReasonV1? nextStep;
  final VoidCallback? onOpenRecommendedAction;
  final VoidCallback? onOpenLearn;

  @override
  Widget build(BuildContext context) {
    final pagePadding = Act0ShellTokensV1.pageHorizontalPaddingFor(context);
    final localeIsRu = _isRuLocaleV1(context);
    final missCount = review.mistakes.length;
    final showBenchExplainer = missCount <= 1;
    final recovered = <Act0MistakeCardV1>[
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel != 'Quick fix',
      ),
      ...review.fixedMistakes.where(
        (mistake) => mistake.severityLabel == 'Quick fix',
      ),
    ];
    final queueCard = <Widget>[
      if (nextStep != null) ...[
        _ReviewNextStepCardV1(
          nextStep: nextStep!,
          onOpen: _nextStepNeedsDedicatedCtaV1(nextStep!)
              ? onOpenRecommendedAction
              : (nextStep!.recommendedAction == 'spaced_review'
                    ? null
                    : onOpenLearn),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
      ],
      if (sessionDrillRecheckQueueItems.isNotEmpty &&
          onStartSessionDrillRecheck != null) ...[
        _SessionDrillRecheckQueueCardV1(
          item: sessionDrillRecheckQueueItems.first,
          onStart: onStartSessionDrillRecheck!,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
      ],
      if (review.mistakes.isEmpty &&
          dueReviewItems.isNotEmpty &&
          onStartDueReview != null) ...[
        _DueReviewCardV1(
          item:
              _selectedDueItemV1(nextStep, dueReviewItems) ??
              dueReviewItems.first,
          onStart: onStartDueReview!,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
      ],
    ];
    final historyAndRecovered = <Widget>[
      if (mistakeHistoryItems.isNotEmpty) ...[
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        _MistakeHistoryListV1(items: mistakeHistoryItems.take(3).toList()),
      ],
      if (recovered.isNotEmpty) ...[
        const SizedBox(height: Act0ShellTokensV1.gapLg),
        Text(
          _reviewCopyV1(
            context,
            atomId: 'review_recovered_lately_label',
            fallback: 'Worth replaying',
          ),
          style: Act0ShellTokensV1.sectionTitle,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapXs),
        Text(
          localeIsRu
              ? (recovered.length == 1
                    ? 'Один спот уже снова под контролем. Так ошибки перестают казаться вечными.'
                    : '${recovered.length} ${act0RussianPluralV1(recovered.length, 'спот', 'спота', 'спотов')} уже снова под контролем. Так игра начинает ощущаться легче.')
              : (recovered.length == 1
                    ? 'One spot is saved as a light replay note. That keeps the board honest.'
                    : '${recovered.length} spots are saved as light replay notes. That keeps the board honest.'),
          style: Act0ShellTokensV1.muted,
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        Container(
          key: const Key('act0_shell_review_recovered_proof_line'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: Act0ShellTokensV1.surfaceDecoration(
            color: Act0VisualCanonV1.greenTable.withOpacity(0.07),
            borderColor: Act0VisualCanonV1.greenTable.withOpacity(0.18),
            glow: false,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Act0VisualCanonV1.greenTable,
                size: 18,
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  localeIsRu
                      ? 'Заметки для повтора остаются лёгкими повторами, а не техническим отчётом.'
                      : 'Past repair notes stay as light replays, not a debug log.',
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapMd),
        for (final mistake in recovered.take(2)) ...[
          _FixedMistakeCardV1(
            mistake: mistake,
            quick: mistake.severityLabel == 'Quick fix',
            onReplay: onReplayFixedMistake,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
        ],
      ],
    ];

    final header = <Widget>[
      const _ReviewTodayBarV1(),
      const SizedBox(height: Act0ShellTokensV1.gapMd),
      _ReviewCompactHeaderV1(missCount: missCount),
      const SizedBox(height: Act0ShellTokensV1.gapMd),
    ];

    if (!showBenchExplainer) {
      return ListView(
        key: const Key('act0_shell_review_screen'),
        padding: EdgeInsets.fromLTRB(
          pagePadding,
          Act0ShellTokensV1.gapLg,
          pagePadding,
          Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
        ),
        children: [
          ...header,
          Act0ShellTokensV1.centeredContent(
            context,
            tabletMaxWidth: 860,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...queueCard,
                for (final mistake in review.mistakes) ...[
                  _ReviewRepairCoachCardV1(
                    mistake: mistake,
                    onFixMistake: onFixMistake,
                  ),
                  if (mistake != review.mistakes.last)
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                ],
                ...historyAndRecovered,
              ],
            ),
          ),
        ],
      );
    }

    final activeMistake = review.mistakes.isEmpty
        ? null
        : review.mistakes.first;
    final hasPassiveNotes =
        mistakeHistoryItems.isNotEmpty || recovered.isNotEmpty;
    final benchBody = <Widget>[
      ...queueCard,
      if (activeMistake == null && queueCard.isEmpty && !hasPassiveNotes)
        _ReviewEmptyRepairCardV1(onOpenLearn: onOpenLearn)
      else if (activeMistake != null)
        _ReviewRepairCoachCardV1(
          mistake: activeMistake,
          onFixMistake: onFixMistake,
        ),
      ...historyAndRecovered,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final lowContentBench =
            activeMistake == null && queueCard.isEmpty && !hasPassiveNotes;
        final fixedLayout =
            constraints.maxHeight >= 620 &&
            constraints.maxWidth < 700 &&
            (activeMistake != null || lowContentBench);
        const topPadding = Act0ShellTokensV1.gapLg;
        final bottomPadding = fixedLayout
            ? Act0ShellTokensV1.gapLg
            : Act0ShellTokensV1.gapXl;
        final fixedBodyHeight =
            constraints.maxHeight - topPadding - bottomPadding;
        final centeredBench = Act0ShellTokensV1.centeredContent(
          context,
          tabletMaxWidth: 860,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...header, ...benchBody],
          ),
        );
        final content = Padding(
          padding: EdgeInsets.fromLTRB(
            pagePadding,
            topPadding,
            pagePadding,
            bottomPadding,
          ),
          child: fixedLayout
              ? SizedBox(
                  height: fixedBodyHeight < 0 ? 0 : fixedBodyHeight,
                  child: Column(
                    key: const Key('act0_shell_review_screen'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          primary: false,
                          physics: const ClampingScrollPhysics(),
                          child: centeredBench,
                        ),
                      ),
                      const SizedBox(height: Act0ShellTokensV1.gapMd),
                      Act0ShellTokensV1.centeredContent(
                        context,
                        tabletMaxWidth: 860,
                        child: const _ReviewBenchFooterV1(),
                      ),
                    ],
                  ),
                )
              : Column(
                  key: const Key('act0_shell_review_screen'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    centeredBench,
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                    Act0ShellTokensV1.centeredContent(
                      context,
                      tabletMaxWidth: 860,
                      child: const _ReviewBenchFooterV1(),
                    ),
                  ],
                ),
        );
        if (fixedLayout) {
          return content;
        }
        return SingleChildScrollView(child: content);
      },
    );
  }
}

bool _nextStepNeedsDedicatedCtaV1(Act0PersonalizedReturnReasonV1 nextStep) =>
    nextStep.recommendedAction == 'reinforce' ||
    nextStep.recommendedAction == 'resume_focus';

Act0DueReviewItemV1? _selectedDueItemV1(
  Act0PersonalizedReturnReasonV1? nextStep,
  List<Act0DueReviewItemV1> items,
) {
  if (nextStep?.recommendedAction != 'spaced_review') return null;
  for (final item in items) {
    if (item.taskId == nextStep!.sourceTaskId) return item;
  }
  return null;
}

class _ReviewNextStepCardV1 extends StatelessWidget {
  const _ReviewNextStepCardV1({required this.nextStep, this.onOpen});

  final Act0PersonalizedReturnReasonV1 nextStep;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final focus = nextStep.learnerSafeFocusLabel.trim();
    final action = switch (nextStep.recommendedAction) {
      'spaced_review' => 'Review this clue',
      'repair' || 'retry_repair' => 'Practice this repair',
      'reinforce' => 'Reinforce this read',
      'resume_focus' => 'Resume this focus',
      _ => 'Open Learn',
    };
    final line = focus.isNotEmpty
        ? '$action: notice $focus.'
        : switch (nextStep.recommendedAction) {
            'repair' =>
              'Practice this repair: notice the decision that slipped.',
            'retry_repair' => 'Practice this repair: replay the recent repair.',
            'spaced_review' =>
              'Review this clue: recheck the repaired decision.',
            'reinforce' =>
              'Reinforce this read: compare it with the later hand.',
            'resume_focus' =>
              'Resume this focus: return to the latest table-reading focus.',
            _ => 'Continue learning with one useful table read.',
          };
    final whyNow = switch (nextStep.whyNowMessageKey) {
      'unfinished_repair' => 'It is still waiting for one clear retry.',
      'repair_not_landed' => 'The last repair attempt did not land yet.',
      'due_for_review' => 'It is ready for a spaced check now.',
      'transfer_evidence' =>
        'A later hand gave you a real signal to reinforce.',
      'recent_focus' => 'It is the most recent useful focus in your history.',
      _ => 'Start with one useful table read.',
    };
    return Container(
      key: const Key('act0_shell_review_next_step_explanation'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.info.withOpacity(0.08),
        borderColor: Act0ShellTokensV1.info.withOpacity(0.22),
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHY THIS, WHY NOW',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            line,
            style: Act0ShellTokensV1.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(whyNow, style: Act0ShellTokensV1.muted),
          if (onOpen != null) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            FilledButton(
              key: const Key('act0_shell_review_open_recommended_action'),
              onPressed: onOpen,
              child: Text(action),
            ),
          ],
        ],
      ),
    );
  }
}

class _DueReviewCardV1 extends StatelessWidget {
  const _DueReviewCardV1({required this.item, required this.onStart});

  final Act0DueReviewItemV1 item;
  final ValueChanged<Act0DueReviewItemV1> onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_review_due_spaced_item'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0VisualCanonV1.greenTable.withOpacity(0.07),
        borderColor: Act0VisualCanonV1.greenTable.withOpacity(0.18),
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ready to recheck', style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            'A repaired clue is due for a spaced review.',
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: const Key('act0_shell_review_start_due_spaced_item'),
              onPressed: () => onStart(item),
              child: const Text('Review now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTodayBarV1 extends StatelessWidget {
  const _ReviewTodayBarV1();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('act0_shell_review_today_bar'),
      children: [
        Text(
          'Today',
          style: Act0ShellTokensV1.label.copyWith(
            color: Act0ShellTokensV1.textMuted,
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        Expanded(
          child: Container(
            height: 1,
            color: Act0ShellTokensV1.border.withOpacity(0.58),
          ),
        ),
      ],
    );
  }
}

class _ReviewCompactHeaderV1 extends StatelessWidget {
  const _ReviewCompactHeaderV1({required this.missCount});

  final int missCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('act0_shell_review_compact_header'),
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Review',
              style: Act0ShellTokensV1.screenTitle.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 1.08,
              ),
            ),
          ),
          if (missCount > 0) _ReviewMissCountPillV1(missCount: missCount),
        ],
      ),
    );
  }
}

class _ReviewMissCountPillV1 extends StatelessWidget {
  const _ReviewMissCountPillV1({required this.missCount});

  final int missCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_review_miss_count_pill'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: Act0ShellTokensV1.gold.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '●',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
              fontSize: 12,
              letterSpacing: 0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$missCount ${missCount == 1 ? 'miss' : 'misses'} to fix',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.gold,
              fontSize: 12,
              letterSpacing: 0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionDrillRecheckQueueCardV1 extends StatelessWidget {
  const _SessionDrillRecheckQueueCardV1({
    required this.item,
    required this.onStart,
  });

  final SessionDrillRecheckLaunchQueueItemV1 item;
  final ValueChanged<SessionDrillRecheckLaunchQueueItemV1> onStart;

  @override
  Widget build(BuildContext context) {
    final signalLabel = item.missedSignalLabel.trim().isEmpty
        ? 'Range bucket'
        : item.missedSignalLabel;
    final chosen = item.chosenActionId.trim().isEmpty
        ? 'your last choice'
        : item.chosenActionId;
    final expected = item.expectedActionId.trim().isEmpty
        ? 'the better action'
        : item.expectedActionId;
    return Container(
      key: const Key('act0_shell_review_recheck_queue_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.info.withOpacity(0.10),
        borderColor: Act0ShellTokensV1.info.withOpacity(0.28),
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice this spot again',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Text(
            'Review this practice mistake',
            style: Act0ShellTokensV1.sectionTitle,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            '$signalLabel: you chose $chosen; try the $expected line again.',
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Text(
            'This reopens the same drill so you can try the clue again.',
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          FilledButton(
            key: const Key('act0_shell_review_recheck_cta'),
            onPressed: () => onStart(item),
            style: Act0ShellTokensV1.premiumActionButtonStyle(
              height: Act0ShellTokensV1.compactCtaHeight,
            ),
            child: const Text('Practice this spot again'),
          ),
        ],
      ),
    );
  }
}

class _ReviewEmptyRepairCardV1 extends StatelessWidget {
  const _ReviewEmptyRepairCardV1({this.onOpenLearn});

  final VoidCallback? onOpenLearn;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_review_empty_repair_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.info.withValues(alpha: 0.13),
            Act0ShellTokensV1.surface2.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Act0SharkyPresenceBubbleV1(
            line: 'Review is ready',
            detail:
                'Finish a lesson - every miss can become one clean repair rep.',
            mood: Act0SharkyMoodV1.thinking,
            tone: Act0ShellTokensV1.info,
            mascotSize: 44,
            bubblePadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          if (onOpenLearn != null) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            FilledButton.icon(
              key: const Key('act0_shell_review_empty_open_learn_cta'),
              onPressed: onOpenLearn,
              style: Act0ShellTokensV1.premiumActionButtonStyle(),
              icon: const Icon(Icons.play_arrow_rounded, size: 19),
              label: const Text('Open Learn'),
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            'Misses from lessons will appear here after you try a spot.',
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: 3),
          Text(
            'Start on Learn, then come back here for the exact clue.',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRepairCoachCardV1 extends StatelessWidget {
  const _ReviewRepairCoachCardV1({required this.mistake, this.onFixMistake});

  final Act0MistakeCardV1 mistake;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;

  @override
  Widget build(BuildContext context) {
    final guardedLines = act0ReviewRepairCoachCopyGuardLinesV1(
      clueLabel: mistake.title,
    );
    final clueLine = guardedLines.isEmpty
        ? 'This clue is still worth a closer look.'
        : guardedLines.first;
    final actionLine = mistake.repairActionLabel.trim().isEmpty
        ? mistake.reason
        : mistake.repairActionLabel;
    final patternFocus = _reviewPatternFocusLabelV1(mistake);
    final currentClue = _reviewCurrentClueLabelV1(mistake);
    return Container(
      key: const Key('act0_shell_review_repair_coach_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderColor: Act0ShellTokensV1.primary.withOpacity(0.22),
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                ),
                child: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: Act0ShellTokensV1.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  'MISS TO REPAIR',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            clueLine,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Container(
            key: const Key('act0_shell_wave2_review_active_clue_preview'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              border: Border.all(
                color: Act0ShellTokensV1.gold.withOpacity(0.22),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.visibility_rounded,
                  color: Act0ShellTokensV1.gold,
                  size: 16,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Text(
                  'Current clue',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.gold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Text(
                    currentClue,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (patternFocus.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Container(
              key: const Key('act0_shell_review_pattern_coaching'),
              padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                border: Border.all(
                  color: Act0ShellTokensV1.primary.withOpacity(0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pattern to practice',
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
                  Text(
                    'Miss: $patternFocus. Repair: spot it before choosing.',
                    key: const Key('act0_shell_review_pattern_focus_line'),
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapXs),
                  Text(
                    'Next rep: spot the clue before choosing.',
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(actionLine, style: Act0ShellTokensV1.muted),
          const SizedBox(height: 6),
          Text(
            act0SharkyCoachLineForMomentV1(
              Act0SharkyCoachMomentV1.reviewActiveRepair,
            ),
            key: const Key('act0_shell_review_sharky_coach_line'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
          if (onFixMistake != null) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            FilledButton(
              key: const Key('act0_shell_review_practice_cta'),
              onPressed: () => onFixMistake!(mistake),
              style: Act0ShellTokensV1.premiumActionButtonStyle(
                height: Act0ShellTokensV1.compactCtaHeight,
              ),
              child: const Text('Practice this spot'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewHowItWorksStripV1 extends StatelessWidget {
  const _ReviewHowItWorksStripV1({required this.mistake});

  final Act0MistakeCardV1? mistake;

  @override
  Widget build(BuildContext context) {
    final missText = mistake == null
        ? 'exact clue'
        : _reviewMissSlotLabelV1(mistake!);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW REVIEW WORKS',
          style: Act0ShellTokensV1.label.copyWith(
            color: mistake == null
                ? Act0ShellTokensV1.info
                : Act0ShellTokensV1.text.withOpacity(0.50),
            fontSize: 11,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: Act0ShellTokensV1.gapSm),
        Row(
          children: [
            Expanded(
              child: _ReviewBenchSlotV1(
                label: 'MISS',
                value: missText,
                filled: mistake != null,
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              key: Key('act0_shell_review_repair_path_arrow_1'),
              color: Act0ShellTokensV1.textMuted,
              size: 15,
            ),
            const Expanded(
              child: _ReviewBenchSlotV1(
                label: 'REPAIR',
                value: 'focused rep',
                filled: false,
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              key: Key('act0_shell_review_repair_path_arrow_2'),
              color: Act0ShellTokensV1.textMuted,
              size: 15,
            ),
            const Expanded(
              child: _ReviewBenchSlotV1(
                label: 'RESULT',
                value: 'saved read',
                filled: false,
              ),
            ),
          ],
        ),
      ],
    );
    if (mistake != null) {
      return KeyedSubtree(
        key: const Key('act0_shell_review_how_it_works_strip'),
        child: content,
      );
    }
    return const _ReviewEmptyLearningEnginePreviewV1();
  }
}

class _ReviewEmptyLearningEnginePreviewV1 extends StatelessWidget {
  const _ReviewEmptyLearningEnginePreviewV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_review_empty_value_preview'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.info.withValues(alpha: 0.09),
            Act0ShellTokensV1.surface2.withValues(alpha: 0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        key: const Key('act0_shell_review_empty_learning_engine_preview'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW REVIEW WORKS',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'One real lesson miss becomes one focused return path.',
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              _ReviewEmptyLoopTagV1(label: 'focused rep'),
              _ReviewEmptyLoopTagV1(label: 'saved read'),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          const _ReviewEmptyLoopStepV1(
            icon: Icons.visibility_off_rounded,
            label: 'MISS',
            detail: 'Review saves the exact clue after a real lesson miss.',
            tone: Color(0xFF90A4C7),
          ),
          const _ReviewEmptyLoopConnectorV1(),
          const _ReviewEmptyLoopStepV1(
            icon: Icons.build_circle_outlined,
            label: 'REPAIR',
            detail: 'A short rep puts that same clue back in focus.',
            tone: Act0ShellTokensV1.gold,
          ),
          const _ReviewEmptyLoopConnectorV1(),
          const _ReviewEmptyLoopStepV1(
            icon: Icons.verified_outlined,
            label: 'RESULT',
            detail: 'A saved read appears only after a real follow-up read.',
            tone: Act0VisualCanonV1.greenTable,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Container(
            key: const Key('act0_shell_review_empty_sharky_coach_panel'),
            padding: const EdgeInsets.fromLTRB(9, 8, 11, 8),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface3.withValues(alpha: 0.54),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                const Act0SharkyPresenceMascotV1(
                  mood: Act0SharkyMoodV1.thinking,
                  tone: Act0ShellTokensV1.info,
                  size: 42,
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: Text(
                    'After a lesson, Sharky brings back the exact cue you missed.',
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      height: 1.18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewEmptyLoopTagV1 extends StatelessWidget {
  const _ReviewEmptyLoopTagV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Act0ShellTokensV1.muted.copyWith(
            color: Act0ShellTokensV1.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ReviewEmptyLoopStepV1 extends StatelessWidget {
  const _ReviewEmptyLoopStepV1({
    required this.icon,
    required this.label,
    required this.detail,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            border: Border.all(color: tone.withValues(alpha: 0.28)),
          ),
          child: Icon(icon, size: 17, color: tone),
        ),
        const SizedBox(width: Act0ShellTokensV1.gapSm),
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: tone,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.muted.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: 11.2,
              height: 1.12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewEmptyLoopConnectorV1 extends StatelessWidget {
  const _ReviewEmptyLoopConnectorV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 8,
      margin: const EdgeInsets.only(left: 17),
      color: Act0ShellTokensV1.info.withValues(alpha: 0.28),
    );
  }
}

class _ReviewBenchSlotV1 extends StatelessWidget {
  const _ReviewBenchSlotV1({
    required this.label,
    required this.value,
    required this.filled,
  });

  final String label;
  final String value;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: filled
                  ? Act0ShellTokensV1.primary
                  : Act0ShellTokensV1.text.withOpacity(0.55),
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Act0ShellTokensV1.muted.copyWith(
              color: filled
                  ? Act0ShellTokensV1.text
                  : Act0ShellTokensV1.text.withOpacity(0.48),
              fontSize: 12,
              height: 1.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewBenchFooterV1 extends StatelessWidget {
  const _ReviewBenchFooterV1();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('act0_shell_review_bench_footer'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Row(
          key: const Key('act0_shell_review_bench_footer_content'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Act0VisualCanonV1.greenTable,
              size: 19,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                'Nothing else is due. Misses land here the moment they happen.',
                textAlign: TextAlign.left,
                style: Act0ShellTokensV1.muted.copyWith(
                  color: Act0ShellTokensV1.text.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _reviewMissSlotLabelV1(Act0MistakeCardV1 mistake) {
  final title = mistake.title.trim();
  final guardedLines = act0ReviewRepairCoachCopyGuardLinesV1(clueLabel: title);
  for (final line in guardedLines) {
    final match = RegExp(
      r'\bthe\s+([a-z0-9][a-z0-9 -]*?)\s+clue\b',
      caseSensitive: false,
    ).firstMatch(line);
    if (match != null) {
      return _reviewHyphenatedClueLabelV1(match.group(1) ?? '');
    }
  }
  if (title.isEmpty) {
    return 'current clue';
  }
  return _reviewHyphenatedClueLabelV1(title);
}

String _reviewHyphenatedClueLabelV1(String rawLabel) {
  final normalized = rawLabel
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (normalized.isEmpty) {
    return 'current clue';
  }
  return '${normalized[0].toUpperCase()}${normalized.substring(1)} clue';
}

String _reviewPatternFocusLabelV1(Act0MistakeCardV1 mistake) {
  final title = mistake.title.trim();
  if (title.isEmpty) {
    return '';
  }
  const forbiddenTerms = <String>{
    'ai',
    'all-time',
    'cleared',
    'complete',
    'completed',
    'fixed',
    'gto',
    'leak',
    'level',
    'master',
    'mastery',
    'premium',
    'radar',
    'rating',
    'resolved',
    'solver',
  };
  final normalized = title.toLowerCase();
  for (final term in forbiddenTerms) {
    if (normalized.contains(term)) {
      return 'this table clue';
    }
  }
  // Some lesson-node titles read as internal category names ("Legal
  // actions") rather than a natural continuation of "You are working on
  // ...". Swap those specific titles for a phrase that reads naturally in
  // that sentence without renaming the lesson node itself.
  const naturalPhraseOverrides = <String, String>{
    'legal actions': 'nobody has bet yet',
  };
  final override = naturalPhraseOverrides[normalized];
  if (override != null) {
    return override;
  }
  return title;
}

String _reviewCurrentClueLabelV1(Act0MistakeCardV1 mistake) {
  final joined =
      '${mistake.title} ${mistake.reason} ${mistake.repairActionLabel}'
          .toLowerCase();
  if (joined.contains('no bet') ||
      joined.contains('nobody had bet') ||
      joined.contains('nobody has bet')) {
    return 'nobody has bet yet';
  }
  final patternFocus = _reviewPatternFocusLabelV1(mistake).trim();
  if (patternFocus.isNotEmpty) {
    return patternFocus;
  }
  return mistake.title.trim().isEmpty ? 'this table clue' : mistake.title;
}

class _MistakeHistoryListV1 extends StatelessWidget {
  const _MistakeHistoryListV1({required this.items});

  final List<Act0ReviewMistakeHistoryItemV1> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_review_mistake_history_list'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2.withOpacity(0.72),
        borderColor: Act0ShellTokensV1.border,
        glow: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Past spots to review', style: Act0ShellTokensV1.sectionTitle),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            'Read-only notes from completed hands.',
            style: Act0ShellTokensV1.muted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          for (final item in items) ...[
            _MistakeHistoryRowV1(item: item),
            if (item != items.last)
              const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
      ),
    );
  }
}

class _MistakeHistoryRowV1 extends StatelessWidget {
  const _MistakeHistoryRowV1({required this.item});

  final Act0ReviewMistakeHistoryItemV1 item;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('act0_shell_review_mistake_history_row_${item.stableKey}'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: Act0ShellTokensV1.border.withOpacity(0.86)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.gold,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  item.primaryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Text(
                item.orderLabel,
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(item.detailLine, style: Act0ShellTokensV1.muted),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            item.decisionLine,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(
            item.contextLine,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              letterSpacing: 0,
            ),
          ),
          if (item.patternLine != null) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              item.patternLine!,
              key: Key('act0_shell_review_pattern_line_${item.stableKey}'),
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MistakeCardV1 extends StatelessWidget {
  const _MistakeCardV1({
    required this.mistake,
    required this.onFixMistake,
    required this.prominent,
  });

  final Act0MistakeCardV1 mistake;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: prominent
          ? const Key('act0_shell_mistake_card')
          : Key('act0_shell_mistake_card_${mistake.taskId}'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0ShellTokensV1.danger.withOpacity(prominent ? 0.14 : 0.08),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.surface2,
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.danger.withOpacity(prominent ? 0.56 : 0.38),
        ),
        boxShadow: <BoxShadow>[
          if (prominent)
            BoxShadow(
              color: Act0ShellTokensV1.danger.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!prominent) ...[
            Row(
              children: [
                _ReviewBoardMetricPillV1(
                  key: Key('act0_shell_mistake_badge_${mistake.taskId}'),
                  label: mistake.severityLabel,
                  tone: Act0ShellTokensV1.danger,
                  icon: Icons.radio_button_checked_rounded,
                ),
              ],
            ),
            const SizedBox(height: Act0ShellTokensV1.gapMd),
          ],
          Container(
            key: prominent
                ? const Key('act0_shell_mistake_decision_strip')
                : Key('act0_shell_mistake_decision_strip_${mistake.taskId}'),
            padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withOpacity(0.84),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
              border: Border.all(color: Act0ShellTokensV1.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DecisionPanelV1(
                    label: _reviewCopyV1(
                      context,
                      atomId: 'review_you_chose_label',
                      fallback: 'You chose',
                    ),
                    value: mistake.selectedLabel,
                    color: Act0ShellTokensV1.danger,
                  ),
                ),
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Expanded(
                  child: _DecisionPanelV1(
                    label: _reviewCopyV1(
                      context,
                      atomId: 'review_better_label',
                      fallback: 'Better',
                    ),
                    value: mistake.betterLabel,
                    color: Act0ShellTokensV1.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusMd,
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Act0ShellTokensV1.danger,
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mistake.title, style: Act0ShellTokensV1.cardTitle),
                    if (!prominent) ...[
                      const SizedBox(height: Act0ShellTokensV1.gapXs),
                      Text(
                        mistake.weaknessLabel,
                        style: Act0ShellTokensV1.muted,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            mistake.reason,
            key: prominent
                ? const Key('act0_shell_mistake_reason')
                : Key('act0_shell_mistake_reason_${mistake.taskId}'),
            maxLines: 4,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.muted,
          ),
          if (mistake.contextLabels.isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Wrap(
              key: const Key('act0_shell_mistake_context_labels'),
              spacing: 6,
              runSpacing: 5,
              children: [
                for (final label in mistake.contextLabels)
                  _SpotPillV1(label: label, color: Act0ShellTokensV1.gold),
              ],
            ),
          ],
          if (!prominent) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Container(
              key: const Key('act0_shell_mistake_repair_plan'),
              padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
                border: Border.all(
                  color: Act0ShellTokensV1.primary.withOpacity(0.24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    color: Act0ShellTokensV1.primary,
                    size: 19,
                  ),
                  const SizedBox(width: Act0ShellTokensV1.gapSm),
                  Expanded(
                    child: Text(
                      mistake.repairActionLabel,
                      style: Act0ShellTokensV1.body.copyWith(
                        color: Act0ShellTokensV1.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapLg),
          FilledButton(
            key: prominent
                ? const Key('act0_shell_review_fix_next_cta')
                : Key('act0_shell_review_fix_${mistake.taskId}'),
            onPressed: onFixMistake == null
                ? null
                : () => onFixMistake!(mistake),
            style: Act0ShellTokensV1.primaryButtonStyle(
              height: Act0ShellTokensV1.compactCtaHeight,
            ),
            child: Text(
              prominent
                  ? _reviewCopyV1(
                      context,
                      atomId: 'review_repair_this_spot',
                      fallback: 'Repair this clue',
                    )
                  : _reviewCopyV1(
                      context,
                      atomId: 'review_repair_this_spot',
                      fallback: 'Repair this spot',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FixedMistakeCardV1 extends StatelessWidget {
  const _FixedMistakeCardV1({
    required this.mistake,
    this.quick = false,
    this.onReplay,
  });

  final Act0MistakeCardV1 mistake;
  final bool quick;
  final ValueChanged<Act0MistakeCardV1>? onReplay;

  @override
  Widget build(BuildContext context) {
    final detailLine = _recoveredDetailLineV1(context, mistake);
    final replayLabel = mistake.severityLabel == 'Recheck'
        ? _reviewCopyV1(
            context,
            en: 'Replay this spot',
            ru: 'Повторить этот спот',
          )
        : _reviewCopyV1(
            context,
            en: 'Replay for perfect',
            ru: 'Повторить на идеально',
          );
    return Container(
      key: Key('act0_shell_fixed_mistake_${mistake.taskId}'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Act0VisualCanonV1.greenTable.withOpacity(0.055),
            Act0ShellTokensV1.surface,
            Act0ShellTokensV1.surface2,
          ],
        ),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0VisualCanonV1.greenTable.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Act0VisualCanonV1.greenTable.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
              border: Border.all(
                color: Act0VisualCanonV1.greenTable.withOpacity(0.20),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: Act0VisualCanonV1.greenTable,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mistake.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Act0ShellTokensV1.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      key: Key(
                        'act0_shell_fixed_mistake_status_${mistake.taskId}',
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Act0VisualCanonV1.greenTable.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusPill,
                        ),
                        border: Border.all(
                          color: Act0VisualCanonV1.greenTable.withOpacity(0.24),
                        ),
                      ),
                      child: Text(
                        _reviewCopyV1(context, en: 'Replay', ru: 'Повтор'),
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0VisualCanonV1.greenTable,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  mistake.weaknessLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Act0ShellTokensV1.muted,
                ),
                const SizedBox(height: 4),
                Text(
                  detailLine,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          if (onReplay != null) ...[
            const SizedBox(width: Act0ShellTokensV1.gapSm),
            SizedBox(
              width: 92,
              child: OutlinedButton(
                key: quick
                    ? Key('act0_shell_quick_fix_replay_${mistake.taskId}')
                    : Key('act0_shell_fixed_mistake_replay_${mistake.taskId}'),
                onPressed: () => onReplay!(mistake),
                style: Act0ShellTokensV1.quietButtonStyle(height: 38).copyWith(
                  minimumSize: WidgetStateProperty.all(const Size(92, 38)),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  side: WidgetStateProperty.all(
                    BorderSide(
                      color: Act0ShellTokensV1.primary.withOpacity(0.34),
                    ),
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Act0ShellTokensV1.primary,
                  ),
                ),
                child: Text(
                  replayLabel,
                  maxLines: 2,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewBoardMetricPillV1 extends StatelessWidget {
  const _ReviewBoardMetricPillV1({
    super.key,
    required this.label,
    required this.tone,
    required this.icon,
  });

  final String label;
  final Color tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: Act0ShellTokensV1.border.withOpacity(0.86)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: Act0ShellTokensV1.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

String _recoveredDetailLineV1(BuildContext context, Act0MistakeCardV1 mistake) {
  final qualityLine = mistake.qualityLine.trim();
  if (qualityLine == 'Perfect clear complete.' ||
      qualityLine == 'Идеально пройдено.') {
    return _reviewCopyV1(
      context,
      en: 'This clue is ready to replay.',
      ru: 'Эта подсказка готова к повтору.',
    );
  }
  if (qualityLine == 'Clear path still open.' ||
      qualityLine == 'Путь к идеалу открыт.') {
    return _reviewCopyV1(
      context,
      en: 'This clue is worth one more replay.',
      ru: 'Эта подсказка стоит ещё одного повтора.',
    );
  }
  final anxiousRecheckCopy = <String>{
    'Still yours? Run this spot once more.',
    'Ещё твоё? Пройди этот спот ещё раз.',
  };
  if (qualityLine.isNotEmpty && !anxiousRecheckCopy.contains(qualityLine)) {
    return qualityLine;
  }
  return _reviewCopyV1(
    context,
    en: 'Saved from recent review.',
    ru: 'Сохранено после недавнего разбора.',
  );
}

class _SpotPillV1 extends StatelessWidget {
  const _SpotPillV1({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStatV1 extends StatelessWidget {
  const _ReviewStatV1({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: Act0ShellTokensV1.surfaceDecoration(
        color: Act0ShellTokensV1.surface2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(value, style: Act0ShellTokensV1.body),
        ],
      ),
    );
  }
}

class _DecisionPanelV1 extends StatelessWidget {
  const _DecisionPanelV1({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(color: color.withOpacity(0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Act0ShellTokensV1.label.copyWith(color: color)),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(value, style: Act0ShellTokensV1.cardTitle),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_components_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart'
    show Act0DueReviewItemV1;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart'
    show Act0PersonalizedReturnReasonV1;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0MistakeCardV1;

/// Gateway title guard (Draft PR #312 `act0ReviewV4MistakeTitle`). A saved
/// task title can encode its answer; show the neutral weakness label instead.
/// Presentation only: the underlying task and its ids are never changed.
String act0AcademyReviewMistakeTitleV1(Act0MistakeCardV1 mistake) {
  final title = mistake.title.trim();
  if (RegExp(
    r'\b(no bet|nobody (has|had) bet)\b',
    caseSensitive: false,
  ).hasMatch(title)) {
    return 'No bet yet';
  }
  final answer = mistake.betterLabel.trim();
  final answerInTitle =
      answer.isNotEmpty &&
      RegExp(
        '\\b${RegExp.escape(answer)}\\b',
        caseSensitive: false,
      ).hasMatch(title);
  if (title.isEmpty ||
      answerInTitle ||
      RegExp(
        r'\b(fold|check|call|bet|raise)\b',
        caseSensitive: false,
      ).hasMatch(title)) {
    final weakness = mistake.weaknessLabel.trim();
    return weakness.isEmpty ? 'Saved table spot' : weakness;
  }
  return title;
}

/// Local adapter for an existing saved drill recheck. Decouples the leaf from
/// `services/session_drill_recheck_launch_queue_v1.dart` (REUSE-01 R-01); the
/// integration adapter maps `SessionDrillRecheckLaunchQueueItemV1.jobId` here
/// and forwards the original item from its own callback.
class Act0AcademyReviewSavedCheckV1 {
  const Act0AcademyReviewSavedCheckV1({required this.checkId});

  final String checkId;
}

/// Source-owned Review inputs.
/// - [openMistakes]: `Act0ReviewStateV1.mistakes` (open repair debt), in the
///   shell's order. All are listed; none are hidden or merged.
/// - [pastRepairs]: `Act0ReviewStateV1.fixedMistakes`; optional replay only,
///   never counted as open and never celebrated here.
/// - [dueItems]: genuinely due independent reviews from the durable retention
///   contract. Empty means nothing is due; the leaf never invents due work.
/// - [savedChecks]: existing saved drill rechecks.
/// - [nextStep]: the source-selected reinforce/resume focus target. The source
///   owns eligibility and launch; this leaf only forwards its callback.
class Act0AcademyReviewLeafInputV1 {
  const Act0AcademyReviewLeafInputV1({
    this.openMistakes = const <Act0MistakeCardV1>[],
    this.repeatedMistake,
    this.pastRepairs = const <Act0MistakeCardV1>[],
    this.dueItems = const <Act0DueReviewItemV1>[],
    this.savedChecks = const <Act0AcademyReviewSavedCheckV1>[],
    this.hasHistory = false,
    this.onRepairMistake,
    this.onReplayPastRepair,
    this.onStartDueReview,
    this.onStartSavedCheck,
    this.nextStep,
    this.onOpenRecommendedAction,
    this.onOpenLearn,
    this.backdrop,
  });

  final List<Act0MistakeCardV1> openMistakes;
  final Act0MistakeCardV1? repeatedMistake;
  final List<Act0MistakeCardV1> pastRepairs;
  final List<Act0DueReviewItemV1> dueItems;
  final List<Act0AcademyReviewSavedCheckV1> savedChecks;
  final bool hasHistory;
  final ValueChanged<Act0MistakeCardV1>? onRepairMistake;
  final ValueChanged<Act0MistakeCardV1>? onReplayPastRepair;
  final ValueChanged<Act0DueReviewItemV1>? onStartDueReview;
  final ValueChanged<Act0AcademyReviewSavedCheckV1>? onStartSavedCheck;
  final Act0PersonalizedReturnReasonV1? nextStep;
  final VoidCallback? onOpenRecommendedAction;
  final VoidCallback? onOpenLearn;
  final ImageProvider? backdrop;
}

typedef _T = Act0ClubNightTokensV1;

/// Review groups saved mistakes, due reviews and completed repairs.
class Act0AcademyReviewLeafV1 extends StatelessWidget {
  const Act0AcademyReviewLeafV1({super.key, required this.input});

  final Act0AcademyReviewLeafInputV1 input;

  @override
  Widget build(BuildContext context) {
    final repeat = input.onRepairMistake == null ? null : input.repeatedMistake;
    final mistakes = [
      if (repeat != null) repeat,
      ...input.openMistakes.where((mistake) => mistake != repeat),
    ];
    final featured = mistakes.firstOrNull;
    final due = input.dueItems;
    final dueFirst = due.firstOrNull;
    final pastRepair = input.pastRepairs.isNotEmpty;
    final nextStep = input.nextStep;
    final focusAction = nextStep?.recommendedAction;
    final showFocus =
        (focusAction == 'reinforce' || focusAction == 'resume_focus') &&
        nextStep!.sourceTaskId.trim().isNotEmpty &&
        input.onOpenRecommendedAction != null;
    final fresh =
        mistakes.isEmpty &&
        !pastRepair &&
        !input.hasHistory &&
        !showFocus &&
        due.isEmpty &&
        input.savedChecks.isEmpty;
    final emptyTitle = fresh
        ? 'No saved mistakes yet'
        : due.isNotEmpty || input.savedChecks.isNotEmpty || showFocus
        ? '0 open mistakes'
        : pastRepair
        ? 'All caught up'
        : 'No open repairs';
    return ColoredBox(
      key: const Key('act0_academy_review_leaf'),
      color: _T.wall,
      child: Act0ClubTextScaleV1(
        child: ListView(
          key: const Key('act0_academy_review_leaf_scroll'),
          padding: const EdgeInsets.fromLTRB(
            _T.screenGutter,
            _T.gapXl,
            _T.screenGutter,
            _T.gapXl,
          ),
          children: [
            const Act0ClubScreenHeaderV1(
              title: 'Review',
              subtitle: 'Turn missed clues into better decisions.',
            ),
            const SizedBox(height: _T.gapXl),
            Text('YOUR OPEN MISTAKES', style: _T.sectionLabel),
            const SizedBox(height: _T.gapSm),
            if (mistakes.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: _T.gapMd,
                      vertical: _T.gapXs,
                    ),
                    decoration: const BoxDecoration(
                      color: _T.mistakeSoft,
                      borderRadius: BorderRadius.all(
                        Radius.circular(_T.radiusControl),
                      ),
                    ),
                    child: Text(
                      '${mistakes.length}',
                      key: const Key('act0_academy_review_leaf_open_count'),
                      textAlign: TextAlign.center,
                      style: _T.figure.copyWith(color: _T.mistake),
                    ),
                  ),
                  const SizedBox(width: _T.gapMd),
                  Expanded(
                    child: Text(
                      mistakes.length == 1
                          ? 'spot to repair'
                          : 'spots to repair',
                      style: _T.question,
                    ),
                  ),
                ],
              )
            else
              Text(
                emptyTitle,
                key: const Key('act0_academy_review_leaf_empty_title'),
                style: _T.question,
              ),
            const SizedBox(height: _T.gapXs),
            Text(
              mistakes.isNotEmpty
                  ? 'Work through your saved mistakes one by one.'
                  : fresh
                  ? 'Saved mistakes will appear here after a missed '
                        'decision.'
                  : 'You have no saved mistakes to retry.',
              style: _T.secondary,
            ),
            const SizedBox(height: _T.gapLg),
            if (featured != null) _featuredCard(featured),
            if (mistakes.length > 1) ...[
              const SizedBox(height: _T.gapXl),
              Text('OTHER MISTAKES TO REVIEW', style: _T.sectionLabel),
              const SizedBox(height: _T.gapSm),
              _group([
                for (var i = 1; i < mistakes.length; i++)
                  _mistakeRow(mistakes[i], number: i + 1),
              ]),
            ],
            if (showFocus) ...[
              const SizedBox(height: _T.gapLg),
              _cta(
                key: const Key('act0_academy_review_leaf_next_step_cta'),
                label: focusAction == 'reinforce'
                    ? 'Reinforce this read'
                    : 'Resume this focus',
                primary:
                    featured == null &&
                    due.isEmpty &&
                    input.savedChecks.isEmpty,
                onPressed: input.onOpenRecommendedAction,
              ),
            ],
            if (dueFirst != null) ...[
              const SizedBox(height: _T.gapXl),
              Act0ClubCardV1(
                key: const Key('act0_academy_review_leaf_due'),
                emphasized: featured == null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Act0ClubTagV1(label: 'Scheduled review'),
                    const SizedBox(height: _T.gapMd),
                    Text(
                      due.length == 1
                          ? '1 review due'
                          : '${due.length} reviews due',
                      key: const Key('act0_academy_review_leaf_due_count'),
                      style: _T.question,
                    ),
                    const SizedBox(height: _T.gapXs),
                    Text(
                      dueFirst.unseenTaskId == null
                          ? 'Familiar situation'
                          : 'New situation',
                      style: _T.secondary,
                    ),
                    const SizedBox(height: _T.gapLg),
                    _cta(
                      key: const Key('act0_academy_review_leaf_start_due'),
                      label: 'Start review',
                      primary: featured == null,
                      onPressed: input.onStartDueReview == null
                          ? null
                          : () => input.onStartDueReview!(dueFirst),
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: _T.gapLg),
                child: Text(
                  mistakes.isEmpty && input.savedChecks.isEmpty
                      ? 'All caught up. Nothing to review now.'
                      : 'No scheduled reviews right now.',
                  key: const Key('act0_academy_review_leaf_no_due'),
                  style: _T.captionStyle,
                ),
              ),
            for (final check in input.savedChecks) ...[
              const SizedBox(height: _T.gapMd),
              Act0ClubCardV1(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SAVED DRILL CHECK', style: _T.sectionLabel),
                    const SizedBox(height: _T.gapSm),
                    Text('A saved recheck is ready', style: _T.headline),
                    const SizedBox(height: _T.gapLg),
                    _cta(
                      key: Key(
                        'act0_academy_review_leaf_saved_${check.checkId}',
                      ),
                      label: 'Continue saved check',
                      primary: false,
                      onPressed: input.onStartSavedCheck == null
                          ? null
                          : () => input.onStartSavedCheck!(check),
                    ),
                  ],
                ),
              ),
            ],
            if (pastRepair) ...[
              const SizedBox(height: _T.gapLg),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const Key('act0_academy_review_leaf_past_repairs'),
                  tilePadding: EdgeInsets.zero,
                  iconColor: _T.caption,
                  collapsedIconColor: _T.caption,
                  title: Text('Past repair notes', style: _T.headline),
                  children: [
                    _group([
                      for (final mistake in input.pastRepairs)
                        _mistakeRow(mistake, replay: true),
                    ]),
                  ],
                ),
              ),
            ],
            if (featured == null && input.onOpenLearn != null) ...[
              const SizedBox(height: _T.gapLg),
              _cta(
                key: const Key('act0_academy_review_leaf_learn'),
                label: 'Continue learning',
                primary: due.isEmpty && input.savedChecks.isEmpty && !showFocus,
                onPressed: input.onOpenLearn,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _featuredCard(Act0MistakeCardV1 mistake) => Act0ClubCardV1(
    key: const Key('act0_academy_review_leaf_featured'),
    emphasized: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mistake.weaknessLabel.trim().isNotEmpty) ...[
          Act0ClubTagV1(
            label: mistake.weaknessLabel.trim(),
            tone: Act0ClubTagToneV1.mistake,
          ),
          const SizedBox(height: _T.gapMd),
        ],
        Text(
          act0AcademyReviewMistakeTitleV1(mistake),
          key: const Key('act0_academy_review_leaf_featured_title'),
          style: _T.question,
        ),
        const SizedBox(height: _T.gapXs),
        Text(
          mistake == input.repeatedMistake
              ? 'This mistake came up more than once when you answered without help.'
              : 'Saved mistake from an earlier decision.',
          style: _T.captionStyle,
        ),
        const SizedBox(height: _T.gapMd),
        Text(
          mistake.repairActionLabel.trim().isNotEmpty
              ? mistake.repairActionLabel.trim()
              : 'Revisit the clue and try again.',
          style: _T.secondary.copyWith(color: _T.text),
        ),
        const SizedBox(height: _T.gapLg),
        _cta(
          key: const Key('act0_academy_review_leaf_repair_cta'),
          label: 'Review this mistake',
          onPressed: input.onRepairMistake == null
              ? null
              : () => input.onRepairMistake!(mistake),
        ),
      ],
    ),
  );

  Widget _group(List<Widget> rows) => DecoratedBox(
    decoration: BoxDecoration(
      color: _T.surface,
      borderRadius: BorderRadius.circular(_T.radiusCard),
      border: const Border.fromBorderSide(_T.cardBorder),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(_T.radiusCard),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: _T.hairline),
            rows[i],
          ],
        ],
      ),
    ),
  );

  Widget _mistakeRow(
    Act0MistakeCardV1 mistake, {
    int? number,
    bool replay = false,
  }) {
    final callback = replay ? input.onReplayPastRepair : input.onRepairMistake;
    return TextButton(
      key: Key(
        replay
            ? 'act0_academy_review_leaf_past_${mistake.taskId}'
            : 'act0_academy_review_leaf_mistake_${mistake.taskId}',
      ),
      onPressed: callback == null ? null : () => callback(mistake),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 64),
        foregroundColor: _T.text,
        shape: const RoundedRectangleBorder(),
      ),
      child: Row(
        children: [
          if (number != null) ...[
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _T.raised,
              ),
              child: Text(
                number.toString().padLeft(2, '0'),
                style: _T.tag.copyWith(
                  color: _T.text2,
                  fontFeatures: _T.tabular,
                ),
              ),
            ),
            const SizedBox(width: _T.gapMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act0AcademyReviewMistakeTitleV1(mistake),
                  style: _T.headline.copyWith(fontSize: 15, height: 20 / 15),
                ),
                const SizedBox(height: 2),
                Text(
                  replay
                      ? 'Past repair - optional replay'
                      : 'Saved mistake - tap to review',
                  style: _T.captionStyle,
                ),
              ],
            ),
          ),
          const SizedBox(width: _T.gapSm),
          const Icon(Icons.chevron_right_rounded, color: _T.caption, size: 22),
        ],
      ),
    );
  }

  Widget _cta({
    required Key key,
    required String label,
    VoidCallback? onPressed,
    bool primary = true,
  }) => primary
      ? Act0ClubButtonsV1.primary(key: key, label: label, onPressed: onPressed)
      : Act0ClubButtonsV1.secondary(
          key: key,
          label: label,
          onPressed: onPressed,
        );
}

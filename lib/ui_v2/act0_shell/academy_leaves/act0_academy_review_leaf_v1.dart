import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
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
    this.onOpenPersonalHands,
    this.backdrop,
  });

  final List<Act0MistakeCardV1> openMistakes;
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
  final VoidCallback? onOpenPersonalHands;
  final ImageProvider? backdrop;
}

/// Premium Academy Review leaf (Review V4, Draft PR #312).
class Act0AcademyReviewLeafV1 extends StatelessWidget {
  const Act0AcademyReviewLeafV1({super.key, required this.input});

  final Act0AcademyReviewLeafInputV1 input;

  static const _text = Act0AcademyLeafPaletteV1.text;
  static const _muted = Act0AcademyLeafPaletteV1.textMuted;
  static const _aqua = Act0AcademyLeafPaletteV1.aqua;
  static const _rule = Act0AcademyLeafPaletteV1.rule;

  @override
  Widget build(BuildContext context) {
    final mistakes = input.openMistakes;
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
      color: Act0AcademyLeafPaletteV1.ink,
      child: ListView(
        key: const Key('act0_academy_review_leaf_scroll'),
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        children: [
          _ReviewHeroV1(backdrop: input.backdrop),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('YOUR OPEN MISTAKES', color: _muted),
                const SizedBox(height: 6),
                if (mistakes.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        '${mistakes.length}',
                        key: const Key('act0_academy_review_leaf_open_count'),
                        style: const TextStyle(
                          color: _aqua,
                          fontSize: 44,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mistakes.length == 1
                              ? 'spot to repair'
                              : 'spots to repair',
                          style: const TextStyle(
                            color: _text,
                            fontSize: 25,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    emptyTitle,
                    key: const Key('act0_academy_review_leaf_empty_title'),
                    style: const TextStyle(
                      color: _text,
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  mistakes.isNotEmpty
                      ? 'Work through your saved mistakes one by one.'
                      : fresh
                      ? 'Saved mistakes will appear here after a missed '
                            'decision.'
                      : 'Your current repair queue is empty. Independent '
                            'checks stay separate.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (featured != null) _featuredCard(featured),
          if (mistakes.length > 1) ...[
            const SizedBox(height: 12),
            _eyebrow('OTHER MISTAKES TO REVIEW', color: _muted),
            const SizedBox(height: 10),
            for (var i = 1; i < mistakes.length; i++)
              _mistakeRow(mistakes[i], number: i + 1),
          ],
          if (showFocus) ...[
            const SizedBox(height: 16),
            _cta(
              key: const Key('act0_academy_review_leaf_next_step_cta'),
              label: focusAction == 'reinforce'
                  ? 'Reinforce this read'
                  : 'Resume this focus',
              primary:
                  featured == null && due.isEmpty && input.savedChecks.isEmpty,
              onPressed: input.onOpenRecommendedAction,
            ),
          ],
          if (dueFirst != null) ...[
            const SizedBox(height: 20),
            Act0AcademyLeafSurfaceV1(
              key: const Key('act0_academy_review_leaf_due'),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('INDEPENDENT REVIEW'),
                    const SizedBox(height: 8),
                    Text(
                      due.length == 1
                          ? '1 independent review due'
                          : '${due.length} independent reviews due',
                      key: const Key('act0_academy_review_leaf_due_count'),
                      style: const TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check what you remember without guided repair.',
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    _cta(
                      key: const Key('act0_academy_review_leaf_start_due'),
                      label: 'Start independent review',
                      primary: featured == null,
                      onPressed: input.onStartDueReview == null
                          ? null
                          : () => input.onStartDueReview!(dueFirst),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.fromLTRB(6, 18, 6, 0),
              child: Text(
                'No independent reviews are due right now.',
                key: Key('act0_academy_review_leaf_no_due'),
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ),
          for (final check in input.savedChecks) ...[
            const SizedBox(height: 14),
            Act0AcademyLeafSurfaceV1(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('SAVED DRILL CHECK'),
                    const SizedBox(height: 8),
                    const Text(
                      'A saved recheck is ready',
                      style: TextStyle(
                        color: _text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
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
            ),
          ],
          if (pastRepair) ...[
            const SizedBox(height: 18),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const Key('act0_academy_review_leaf_past_repairs'),
                tilePadding: const EdgeInsets.symmetric(horizontal: 6),
                iconColor: _muted,
                collapsedIconColor: _muted,
                title: const Text(
                  'Past repair notes',
                  style: TextStyle(color: _text, fontSize: 15),
                ),
                children: [
                  for (final mistake in input.pastRepairs)
                    _mistakeRow(mistake, replay: true),
                ],
              ),
            ),
          ],
          if (input.onOpenPersonalHands != null) ...[
            const SizedBox(height: 16),
            _cta(
              key: const Key('act0_academy_review_leaf_personal_hands'),
              label: 'My hands - private import',
              primary: false,
              onPressed: input.onOpenPersonalHands,
            ),
            const SizedBox(height: 6),
            const Text(
              'Saved locally in this app. No XP or lesson credit.',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ],
          if (featured == null && input.onOpenLearn != null) ...[
            const SizedBox(height: 16),
            _cta(
              key: const Key('act0_academy_review_leaf_learn'),
              label: 'Continue learning',
              primary: due.isEmpty && input.savedChecks.isEmpty && !showFocus,
              onPressed: input.onOpenLearn,
            ),
          ],
        ],
      ),
    );
  }

  Widget _featuredCard(Act0MistakeCardV1 mistake) => Act0AcademyLeafSurfaceV1(
    key: const Key('act0_academy_review_leaf_featured'),
    emphasized: true,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(mistake.weaknessLabel.toUpperCase()),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  act0AcademyReviewMistakeTitleV1(mistake),
                  key: const Key('act0_academy_review_leaf_featured_title'),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Act0AcademyLeafGlyphV1(
                kind: Act0AcademyLeafGlyphKindV1.learn,
                color: Act0AcademyLeafPaletteV1.aquaSoft,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Saved mistake from an earlier decision.',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _rule),
          const SizedBox(height: 12),
          Text(
            mistake.repairActionLabel.trim().isNotEmpty
                ? mistake.repairActionLabel.trim()
                : 'Revisit the clue and try again.',
            style: const TextStyle(color: _text, fontSize: 14),
          ),
          const SizedBox(height: 14),
          _cta(
            key: const Key('act0_academy_review_leaf_repair_cta'),
            label: 'Review this mistake',
            onPressed: input.onRepairMistake == null
                ? null
                : () => input.onRepairMistake!(mistake),
          ),
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
    return Column(
      children: [
        const Divider(height: 1, color: _rule),
        TextButton(
          key: Key(
            replay
                ? 'act0_academy_review_leaf_past_${mistake.taskId}'
                : 'act0_academy_review_leaf_mistake_${mistake.taskId}',
          ),
          onPressed: callback == null ? null : () => callback(mistake),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            minimumSize: const Size(0, 64),
            foregroundColor: _text,
          ),
          child: Row(
            children: [
              if (number != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF19665F)),
                  ),
                  child: Text(
                    number.toString().padLeft(2, '0'),
                    style: const TextStyle(color: _aqua, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act0AcademyReviewMistakeTitleV1(mistake),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      replay
                          ? 'Past repair - optional replay'
                          : 'Saved mistake - tap to review',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Act0AcademyLeafGlyphV1(
                kind: Act0AcademyLeafGlyphKindV1.forward,
                color: _muted,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eyebrow(String label, {Color color = _aqua}) => Text(
    label,
    style: TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );

  Widget _cta({
    required Key key,
    required String label,
    VoidCallback? onPressed,
    bool primary = true,
  }) => SizedBox(
    width: double.infinity,
    height: 50,
    child: FilledButton(
      key: key,
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: primary ? _aqua : const Color(0xFF0B3439),
        foregroundColor: primary ? Act0AcademyLeafPaletteV1.ink : _text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: primary ? BorderSide.none : const BorderSide(color: _rule),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Act0AcademyLeafGlyphV1(
            kind: Act0AcademyLeafGlyphKindV1.forward,
            color: primary ? Act0AcademyLeafPaletteV1.ink : _text,
            size: 22,
          ),
        ],
      ),
    ),
  );
}

class _ReviewHeroV1 extends StatelessWidget {
  const _ReviewHeroV1({required this.backdrop});

  final ImageProvider? backdrop;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 152),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -18,
            right: -18,
            top: 0,
            bottom: -48,
            child: Act0AcademyLeafBackdropV1(
              image: backdrop,
              alignment: Alignment.centerRight,
            ),
          ),
          const Positioned(
            left: -18,
            right: -18,
            top: 0,
            bottom: -48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x25020E13),
                      Color(0x60020E13),
                      Color(0xFF020E13),
                    ],
                    stops: [0, .55, 1],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 6, top: 20, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHARKY POKER ACADEMY',
                  style: TextStyle(
                    color: Act0AcademyLeafPaletteV1.aqua,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.3,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Review',
                  style: TextStyle(
                    color: Act0AcademyLeafPaletteV1.text,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Turn missed clues into better decisions.',
                  style: TextStyle(
                    color: Act0AcademyLeafPaletteV1.textMuted,
                    fontSize: 14,
                    height: 1.4,
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

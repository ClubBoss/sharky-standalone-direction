import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_iconography_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_north_star_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const kAct0ReviewV4Preview = bool.fromEnvironment('SHARKY_REVIEW_V4_PREVIEW');

/// Task titles can encode an answer ("Check when no bet"). Keep a neutral
/// source clue/category at the gateway, without mutating the underlying task.
String act0ReviewV4MistakeTitle(Act0MistakeCardV1 mistake) {
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
    return mistake.weaknessLabel.trim().isEmpty
        ? 'Saved table spot'
        : mistake.weaknessLabel;
  }
  return title;
}

/// Review presentation only: ordered mistakes, due selection and all launches
/// are supplied by the existing Review owners. No answers enter the gateway UI.
class Act0ReviewV4 extends StatelessWidget {
  const Act0ReviewV4({
    super.key,
    required this.review,
    required this.dueItem,
    required this.dueCount,
    required this.hasHistory,
    this.onFixMistake,
    this.onReplayFixedMistake,
    this.onStartDueReview,
    this.onOpenLearn,
    this.sessionChecks = const [],
    this.onStartSessionCheck,
  });
  final Act0ReviewStateV1 review;
  final Act0DueReviewItemV1? dueItem;
  final int dueCount;
  final bool hasHistory;
  final ValueChanged<Act0MistakeCardV1>? onFixMistake;
  final ValueChanged<Act0MistakeCardV1>? onReplayFixedMistake;
  final ValueChanged<Act0DueReviewItemV1>? onStartDueReview;
  final VoidCallback? onOpenLearn;
  final List<SessionDrillRecheckLaunchQueueItemV1> sessionChecks;
  final ValueChanged<SessionDrillRecheckLaunchQueueItemV1>? onStartSessionCheck;

  static const _text = Act0HomeNorthStarPaletteV1.text;
  static const _muted = Act0HomeNorthStarPaletteV1.textMuted;
  static const _aqua = Act0HomeNorthStarPaletteV1.aqua;
  static const _rule = Act0HomeNorthStarPaletteV1.rule;

  @override
  Widget build(BuildContext context) {
    final mistakes = review.mistakes;
    final featured = mistakes.firstOrNull;
    final pastRepair = review.fixedMistakes.isNotEmpty;
    final fresh =
        mistakes.isEmpty &&
        !pastRepair &&
        !hasHistory &&
        dueCount == 0 &&
        sessionChecks.isEmpty;
    return ColoredBox(
      color: Act0HomeNorthStarPaletteV1.ink,
      child: ListView(
        key: const Key('act0_shell_review_screen'),
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        children: [
          SizedBox(
            height: 168,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  left: -18,
                  right: -18,
                  top: 0,
                  bottom: -48,
                  child: ExcludeSemantics(
                    child: Image(
                      image: AssetImage(
                        'assets/design/sharky/home/poker_lounge_reference_v2.png',
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
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
                  padding: EdgeInsets.only(left: 6, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHARKY POKER ACADEMY',
                        style: TextStyle(
                          color: _aqua,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.3,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Review',
                        style: TextStyle(
                          color: _text,
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
                          color: _muted,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 18),
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
                        key: const Key('act0_review_v4_open_count'),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    fresh
                        ? 'No saved mistakes yet'
                        : dueCount > 0 || sessionChecks.isNotEmpty
                        ? '0 open mistakes'
                        : pastRepair
                        ? 'All caught up'
                        : 'No open repairs',
                    key: const Key('act0_review_v4_empty_title'),
                    style: const TextStyle(
                      color: _text,
                      fontSize: 27,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  mistakes.isNotEmpty
                      ? 'Work through your saved mistakes one by one.'
                      : fresh
                      ? 'Saved mistakes will appear here after a missed decision.'
                      : 'Your current repair queue is empty. Independent checks stay separate.',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (featured != null) _mistakeCard(featured),
          if (mistakes.length > 1) ...[
            const SizedBox(height: 20),
            _eyebrow('OTHER MISTAKES TO REVIEW', color: _muted),
            const SizedBox(height: 10),
            for (var i = 1; i < mistakes.length; i++)
              _mistakeRow(mistakes[i], i + 1),
          ],
          if (dueItem != null) ...[
            const SizedBox(height: 20),
            _material(
              key: const Key('act0_shell_review_due_spaced_item'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('INDEPENDENT REVIEW'),
                    const SizedBox(height: 8),
                    Text(
                      dueCount == 1
                          ? '1 independent review due'
                          : '$dueCount independent reviews due',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check what you remember without guided repair.',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _cta(
                      key: const Key('act0_shell_review_start_due_spaced_item'),
                      label: 'Start independent review',
                      primary: featured == null,
                      onPressed: onStartDueReview == null
                          ? null
                          : () => onStartDueReview!(dueItem!),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 18, 4, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 6, color: _aqua),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No independent reviews are due right now.',
                      key: const Key('act0_review_v4_no_due'),
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          for (final item in sessionChecks) ...[
            const SizedBox(height: 14),
            _material(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _eyebrow('SAVED DRILL CHECK'),
                    const SizedBox(height: 8),
                    const Text(
                      'A saved recheck is ready',
                      style: TextStyle(
                        color: _text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _cta(
                      key: Key('act0_review_v4_session_${item.jobId}'),
                      label: 'Continue saved check',
                      primary: false,
                      onPressed: onStartSessionCheck == null
                          ? null
                          : () => onStartSessionCheck!(item),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (review.fixedMistakes.isNotEmpty) ...[
            const SizedBox(height: 18),
            ExpansionTile(
              key: const Key('act0_review_v4_past_repairs'),
              tilePadding: const EdgeInsets.symmetric(horizontal: 6),
              title: const Text(
                'Past repair notes',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
              iconColor: _muted,
              collapsedIconColor: _muted,
              children: [
                for (final mistake in review.fixedMistakes)
                  _mistakeRow(mistake, null, replay: true),
              ],
            ),
          ],
          if (featured == null && onOpenLearn != null) ...[
            const SizedBox(height: 16),
            _cta(
              key: const Key('act0_review_v4_learn'),
              label: 'Continue learning',
              primary: dueItem == null && sessionChecks.isEmpty,
              onPressed: onOpenLearn,
            ),
          ],
        ],
      ),
    );
  }

  Widget _mistakeCard(Act0MistakeCardV1 mistake) => _material(
    key: const Key('act0_review_v4_featured'),
    emphasized: true,
    child: Padding(
      padding: const EdgeInsets.all(17),
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
                  act0ReviewV4MistakeTitle(mistake),
                  key: const Key('act0_review_v4_featured_title'),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Act0AcademyGlyphV1(
                asset: Act0AcademyIconographyV1.learn,
                color: Act0HomeNorthStarPaletteV1.aquaSoft,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Saved mistake from an earlier decision.',
            style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _rule),
          const SizedBox(height: 12),
          const Text(
            'Revisit the clue and try again.',
            style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          _cta(
            key: const Key('act0_shell_review_practice_cta'),
            label: 'Review this mistake',
            onPressed: onFixMistake == null
                ? null
                : () => onFixMistake!(mistake),
          ),
        ],
      ),
    ),
  );

  Widget _mistakeRow(
    Act0MistakeCardV1 mistake,
    int? number, {
    bool replay = false,
  }) => Column(
    children: [
      const Divider(height: 1, color: _rule),
      TextButton(
        key: Key(
          replay
              ? 'act0_shell_fixed_mistake_${mistake.taskId}'
              : 'act0_review_v4_mistake_${mistake.taskId}',
        ),
        onPressed: replay
            ? onReplayFixedMistake == null
                  ? null
                  : () => onReplayFixedMistake!(mistake)
            : onFixMistake == null
            ? null
            : () => onFixMistake!(mistake),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
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
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    act0ReviewV4MistakeTitle(mistake),
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    replay
                        ? 'Past repair · optional replay'
                        : 'Saved mistake · tap to review',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Act0AcademyGlyphV1(
              asset: Act0AcademyIconographyV1.forward,
              color: _text,
              size: 20,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _eyebrow(String label, {Color color = _aqua}) => Text(
    label,
    style: TextStyle(
      color: color,
      fontSize: 10,
      letterSpacing: 1.6,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _material({
    Key? key,
    required Widget child,
    bool emphasized = false,
  }) => Container(
    key: key,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF08272C), Color(0xFF04171D)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: emphasized ? const Color(0xFF198F84) : _rule),
    ),
    child: child,
  );

  Widget _cta({
    required Key key,
    required String label,
    VoidCallback? onPressed,
    bool primary = true,
  }) => SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton(
      key: key,
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: primary ? _aqua : const Color(0xFF0B3439),
        foregroundColor: primary ? Act0HomeNorthStarPaletteV1.ink : _text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
          Act0AcademyGlyphV1(
            asset: Act0AcademyIconographyV1.forward,
            color: primary ? Act0HomeNorthStarPaletteV1.ink : _text,
            size: 22,
          ),
        ],
      ),
    ),
  );
}

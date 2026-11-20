part of 'act0_lesson_runner_shell_v1.dart';

class Act0BlockCompletionShellV1 extends StatelessWidget {
  const Act0BlockCompletionShellV1({
    super.key,
    required this.summary,
    this.evidenceSummary,
    this.earnedMomentConsumer = const Act0AchievementSeedConsumerV1(),
    this.repairOutcomeConsumer = const Act0RepairOutcomeConsumerV1(),
    this.firstCorrectEarnedThisRun,
    this.nextUsefulHand,
    this.onNextUsefulHand,
    required this.onContinue,
    this.onReplay,
    this.onOpenReview,
    this.onLaunchPracticeRepairQueueTarget,
    required this.onBackToMap,
    this.onBackToHome,
    this.openMissedSpots = 0,
    this.onFirstLessonReminder,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Act0SessionSummaryEvidenceViewModelV1? evidenceSummary;
  final Act0AchievementSeedConsumerV1 earnedMomentConsumer;
  final Act0RepairOutcomeConsumerV1 repairOutcomeConsumer;

  /// Null retains prior leaf-only preview behavior; production root supplies proof.
  final bool? firstCorrectEarnedThisRun;
  final Act0SummaryNextHandoffV1? nextUsefulHand;
  final VoidCallback? onNextUsefulHand;
  final VoidCallback onContinue;
  final VoidCallback? onReplay;
  final VoidCallback? onOpenReview;
  final ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>?
  onLaunchPracticeRepairQueueTarget;
  final VoidCallback onBackToMap;
  final VoidCallback? onBackToHome;
  final int openMissedSpots;
  final ValueChanged<bool>? onFirstLessonReminder;

  VoidCallback? _callbackForCta(Act0MilestoneCtaKindV1 kind) {
    return switch (kind) {
      Act0MilestoneCtaKindV1.continueForward => onContinue,
      Act0MilestoneCtaKindV1.replayForPerfect => onReplay,
      Act0MilestoneCtaKindV1.reviewFirst => onOpenReview,
      Act0MilestoneCtaKindV1.reviewForPerfect => onOpenReview,
      Act0MilestoneCtaKindV1.backToMap => onBackToMap,
    };
  }

  @override
  Widget build(BuildContext context) {
    final celebrateTone = summary.qualifiesForNextLesson
        ? (summary.leveledUp
              ? Act0AcademyDarkReadingStyleV1.gold
              : Act0AcademyDarkReadingStyleV1.primary)
        : Act0AcademyDarkReadingStyleV1.gold;
    final visibleEvidenceSummary =
        evidenceSummary != null && evidenceSummary!.hasEvidence
        ? evidenceSummary
        : null;
    final visibleEarnedMoment = earnedMomentConsumer.moments.isNotEmpty
        ? earnedMomentConsumer.moments.first
        : null;
    final visibleRepairOutcomeReceipt =
        firstCorrectEarnedThisRun == null ||
            (summary.independentProvenanceKnown &&
                summary.quickFixCount > 0 &&
                summary.assistedCount == 0)
        ? repairOutcomeConsumer.sessionReceipt
        : null;
    final localeIsRu = Localizations.localeOf(context).languageCode == 'ru';
    final earnedInThisRun = firstCorrectEarnedThisRun ?? true;
    final currentRunMoments = earnedInThisRun
        ? earnedMomentConsumer.moments
        : const <Act0AchievementMomentViewModelV1>[];
    final currentRunRepairReceipt = firstCorrectEarnedThisRun == null
        ? visibleRepairOutcomeReceipt // Existing isolated renderer contract.
        : summary.independentProvenanceKnown &&
              summary.quickFixCount > 0 &&
              summary.assistedCount == 0
        ? visibleRepairOutcomeReceipt
        : null;
    final payoffHero = _SessionSummaryPayoffHeroV1.fromProof(
      moments: currentRunMoments,
      receipt: currentRunRepairReceipt,
    );
    final hasSourceNext =
        nextUsefulHand?.isActionableRepair == true && onNextUsefulHand != null;
    final summarySharkyLine = localeIsRu
        ? (summary.assistedCount > 0
              ? '\u041f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u0430 \u043f\u043e\u043c\u043e\u0433\u043b\u0430 \u043f\u043e\u043d\u044f\u0442\u044c \u043e\u0448\u0438\u0431\u043a\u0443. \u041f\u0440\u043e\u0432\u0435\u0440\u044c \u044d\u0442\u043e\u0442 \u0441\u0438\u0433\u043d\u0430\u043b \u0441\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u043e.'
              : '\u0417\u0430\u043f\u043e\u043c\u043d\u0438 \u044d\u0442\u0443 \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u0443 \u0441\u0442\u043e\u043b\u0430 \u0438 \u043f\u0440\u043e\u0432\u0435\u0440\u044c \u0435\u0451 \u0432 \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0435\u0439 \u0440\u0430\u0437\u0434\u0430\u0447\u0435.')
        // REP-06/07: a session with help or a miss must not end on an
        // authored growth line; mirror the RU source-truth branches.
        : summary.assistedCount > 0
        ? 'Help showed the clue. Check it on your own next time.'
        : summary.errorCount > 0
        ? 'Keep this table clue and check it in the next hand.'
        : summary.sharkyLine.trim().isNotEmpty
        ? summary.sharkyLine.trim()
        : payoffHero != null
        ? act0SharkyCoachLineForMomentV1(
            Act0SharkyCoachMomentV1.sessionSummaryProof,
          )
        : '';
    final sessionSummaryCompanionState = _act0SessionSummaryCompanionStateV1(
      hasWorldCompletionMoment:
          summary.hasWorldOneCompletionPayoff ||
          summary.hasWorldCompletionPayoff ||
          summary.hasBandTransitionPayoff,
      qualifiesForNextLesson: summary.qualifiesForNextLesson,
      receipt: visibleRepairOutcomeReceipt,
    );
    final sessionSummaryCompanionMood = act0SharkyMoodForCompanionStateV1(
      sessionSummaryCompanionState,
    );
    final sessionSummaryCompanionRinged =
        act0SharkyCompanionStateHasAccentRingV1(sessionSummaryCompanionState);
    final sessionSummaryGrowthStage = act0SharkyGrowthStageForWorldNumberV1(
      summary.worldNumber,
    );
    final foldUnlockIntoMilestonePanel =
        summary.isWorldComplete && summary.unlockedLabel != null;
    final showHabitReward =
        !summary.isWorldComplete || summary.growthLabel.isEmpty;
    final tabletLayout = MediaQuery.sizeOf(context).shortestSide >= 700;
    Widget nextActionCard() {
      return _ProofMotionRevealV1(
        key: const Key('act0_shell_block_summary_next_motion_reveal'),
        child: Container(
          key: const Key('act0_shell_block_summary_next_label'),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
          decoration: BoxDecoration(
            color: Act0AcademyDarkReadingStyleV1.surface2.withValues(
              alpha: 0.86,
            ),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
            border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localeIsRu
                    ? '\u0421\u043B\u0435\u0434\u0443\u044E\u0449\u0438\u0439 \u0448\u0430\u0433'
                    : (payoffHero == null ? 'What next' : 'Next hand'),
                style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                  color: Act0AcademyDarkReadingStyleV1.info,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasSourceNext
                    ? nextUsefulHand!.copyLine
                    : localeIsRu
                    ? (summary.errorCount > 0 || summary.assistedCount > 0
                          ? '\u041F\u043E\u0432\u0442\u043E\u0440\u0438 \u0438\u0441\u0445\u043E\u0434\u043D\u044B\u0439 \u0441\u043F\u043E\u0442 \u0431\u0435\u0437 \u043F\u043E\u0434\u0441\u043A\u0430\u0437\u043A\u0438, \u0447\u0442\u043E\u0431\u044B \u043F\u0440\u043E\u0432\u0435\u0440\u0438\u0442\u044C \u0447\u0442\u0435\u043D\u0438\u0435.'
                          : '\u041F\u0435\u0440\u0435\u0445\u043E\u0434\u0438 \u043A \u0441\u043B\u0435\u0434\u0443\u044E\u0449\u0435\u043C\u0443 \u0443\u0440\u043E\u043A\u0443.')
                    : payoffHero != null &&
                          summary.primaryCtaKind ==
                              Act0MilestoneCtaKindV1.replayForPerfect
                    ? 'Replay the saved read once.'
                    : summary.suggestedNextAction,
                key: const Key('act0_shell_block_summary_suggested_next'),
                maxLines: 4,
                overflow: TextOverflow.fade,
                style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                  color: Act0AcademyDarkReadingStyleV1.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (summary.nextUnlockReasonLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  summary.nextUnlockReasonLabel!,
                  key: const Key('act0_shell_block_summary_next_reason'),
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (summarySharkyLine.isNotEmpty && payoffHero == null) ...[
                const SizedBox(height: 6),
                Act0SharkyPresenceBubbleV1(
                  line: summarySharkyLine,
                  mood: sessionSummaryCompanionMood,
                  ringed: sessionSummaryCompanionRinged,
                  growthStage: sessionSummaryGrowthStage,
                  textKey: const Key('act0_shell_block_summary_sharky_line'),
                  mascotSize: 68,
                  bubblePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget primaryCtaButton() {
      return FilledButton(
        key: const Key('act0_shell_block_summary_continue_cta'),
        onPressed: onBackToHome != null && openMissedSpots > 0
            ? onOpenReview
            : hasSourceNext
            ? onNextUsefulHand
            : _callbackForCta(summary.primaryCtaKind),
        style: Act0AcademyDarkReadingStyleV1.premiumActionButtonStyle(),
        child: Text(
          onBackToHome != null && openMissedSpots > 0
              ? (openMissedSpots == 1
                    ? 'Fix 1 missed spot'
                    : 'Fix $openMissedSpots missed spots')
              : hasSourceNext
              ? (localeIsRu
                    ? '\u0420\u0430\u0437\u043E\u0431\u0440\u0430\u0442\u044C \u044D\u0442\u043E\u0442 \u0441\u043F\u043E\u0442'
                    : 'Practice this clue')
              : localeIsRu
              ? switch (summary.primaryCtaKind) {
                  Act0MilestoneCtaKindV1.continueForward =>
                    '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c \u043e\u0431\u0443\u0447\u0435\u043d\u0438\u0435',
                  Act0MilestoneCtaKindV1.replayForPerfect =>
                    '\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u044c \u0443\u0440\u043e\u043a',
                  Act0MilestoneCtaKindV1.reviewFirst ||
                  Act0MilestoneCtaKindV1.reviewForPerfect =>
                    '\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u0440\u0430\u0437\u0431\u043e\u0440',
                  Act0MilestoneCtaKindV1.backToMap =>
                    '\u041a \u043a\u0430\u0440\u0442\u0435 \u043e\u0431\u0443\u0447\u0435\u043d\u0438\u044f',
                }
              : payoffHero != null &&
                    summary.primaryCtaKind ==
                        Act0MilestoneCtaKindV1.replayForPerfect
              ? 'Replay the saved read'
              : summary.primaryCtaLabel,
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.gapLg,
          Act0ShellTokensV1.bottomNavHeight + Act0ShellTokensV1.gapXl,
        ),
        child: Container(
          key: const Key('act0_shell_block_summary_card'),
          constraints: BoxConstraints(maxWidth: tabletLayout ? 720 : 388),
          padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
          decoration: BoxDecoration(
            color: Act0AcademyDarkReadingStyleV1.surface,
            borderRadius: BorderRadius.circular(
              Act0ShellTokensV1.radiusOverlay,
            ),
            border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
          ),
          child: Column(
            key: const Key('act0_shell_session_summary_victory_lap'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      celebrateTone.withValues(alpha: 0.18),
                      celebrateTone.withValues(alpha: 0.82),
                      Act0AcademyDarkReadingStyleV1.info.withValues(
                        alpha: 0.34,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _ProofMotionRevealV1(
                key: const Key(
                  'act0_shell_session_summary_proof_hero_motion_reveal',
                ),
                child: KeyedSubtree(
                  key: const Key(
                    'act0_shell_block_summary_payoff_motion_reveal',
                  ),
                  child: Container(
                    key: payoffHero == null
                        ? const Key('act0_shell_block_summary_milestone_panel')
                        : const Key('act0_shell_session_summary_hero_payoff'),
                    padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          celebrateTone.withValues(alpha: 0.22),
                          Act0AcademyDarkReadingStyleV1.surface2.withValues(
                            alpha: 0.96,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPanel,
                      ),
                      border: Border.all(
                        color: celebrateTone.withValues(alpha: 0.28),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: celebrateTone.withValues(alpha: 0.12),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: celebrateTone.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.radiusPill,
                                ),
                                border: Border.all(
                                  color: celebrateTone.withValues(alpha: 0.34),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    summary.qualifiesForNextLesson
                                        ? Icons.auto_awesome_rounded
                                        : Icons.refresh_rounded,
                                    size: 14,
                                    color: celebrateTone,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    localeIsRu
                                        ? (summary.qualifiesForNextLesson
                                              ? '\u042d\u0442\u0430\u043f \u0437\u0430\u0432\u0435\u0440\u0448\u0451\u043d'
                                              : '\u041d\u0443\u0436\u0435\u043d \u043f\u043e\u0432\u0442\u043e\u0440')
                                        : payoffHero == null
                                        ? summary.masteryLabel
                                        : payoffHero.kicker,
                                    style: Act0AcademyDarkReadingStyleV1.label
                                        .copyWith(
                                          color: celebrateTone,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (summary.isWorldComplete) ...[
                              const Spacer(),
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 20,
                                color: celebrateTone,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                        Text(
                          localeIsRu
                              ? '\u0418\u0442\u043e\u0433 \u044d\u0442\u043e\u0433\u043e \u043f\u0440\u043e\u0445\u043e\u0434\u0430'
                              : (payoffHero == null
                                    ? 'What finished'
                                    : 'Session complete'),
                          style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                            color: celebrateTone,
                            letterSpacing: 0.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        KeyedSubtree(
                          key: payoffHero == null
                              ? null
                              : const Key(
                                  'act0_shell_session_summary_hero_metric',
                                ),
                          child: Text(
                            localeIsRu
                                ? (payoffHero != null
                                      ? '\u0412\u0435\u0440\u043d\u044b\u0439 \u043e\u0442\u0432\u0435\u0442 \u0441\u043e\u0445\u0440\u0430\u043d\u0451\u043d'
                                      : summary.qualifiesForNextLesson
                                      ? '\u0423\u0440\u043e\u043a \u0437\u0430\u0432\u0435\u0440\u0448\u0451\u043d'
                                      : '\u041f\u043e\u043f\u0440\u043e\u0431\u0443\u0439 \u0441\u043d\u043e\u0432\u0430')
                                : summary.hasWorldOneCompletionPayoff ||
                                      summary.hasWorldCompletionPayoff
                                ? summary.milestoneTitle
                                : payoffHero?.headline ??
                                      summary.milestoneTitle,
                            key: const Key('act0_shell_block_summary_title'),
                            style: Act0AcademyDarkReadingStyleV1.screenTitle
                                .copyWith(
                                  fontSize: payoffHero == null ? 30 : 32,
                                  height: 1.05,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localeIsRu
                              ? summary.milestoneDetailTitle
                              : summary.hasWorldOneCompletionPayoff ||
                                    summary.hasWorldCompletionPayoff
                              ? summary.milestoneDetailTitle
                              : payoffHero?.detail ??
                                    summary.milestoneDetailTitle,
                          key: const Key(
                            'act0_shell_block_summary_detail_title',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                            color: Act0AcademyDarkReadingStyleV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          localeIsRu
                              ? (summary.qualifiesForNextLesson
                                    ? '\u0421\u043b\u0435\u0434\u0443\u044e\u0449\u0438\u0439 \u0443\u0440\u043e\u043a \u0434\u043e\u0441\u0442\u0443\u043f\u0435\u043d. \u041f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u0430 \u043d\u0435 \u0434\u043e\u043a\u0430\u0437\u044b\u0432\u0430\u0435\u0442 \u0441\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u044b\u0439 \u043d\u0430\u0432\u044b\u043a.'
                                    : '\u041f\u043e\u0432\u0442\u043e\u0440\u0438 \u043e\u0446\u0435\u043d\u0451\u043d\u043d\u044b\u0435 \u0437\u0430\u0434\u0430\u043d\u0438\u044f, \u0447\u0442\u043e\u0431\u044b \u0437\u0430\u043a\u0440\u044b\u0442\u044c \u044d\u0442\u043e\u0442 \u044d\u0442\u0430\u043f.')
                              : summary.gateMessage,
                          key: const Key(
                            'act0_shell_block_summary_gate_message',
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.fade,
                          style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                            color: Act0AcademyDarkReadingStyleV1.textMuted,
                          ),
                        ),
                        if (summarySharkyLine.isNotEmpty &&
                            payoffHero != null) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapSm),
                          Act0SharkyPresenceBubbleV1(
                            key: const Key(
                              'act0_shell_session_summary_payoff_sharky',
                            ),
                            line: summarySharkyLine,
                            mood: sessionSummaryCompanionMood,
                            ringed: sessionSummaryCompanionRinged,
                            growthStage: sessionSummaryGrowthStage,
                            textKey: const Key(
                              'act0_shell_block_summary_sharky_line',
                            ),
                            mascotSize: 64,
                            bubblePadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ],
                        if (summary.hasWorldOneCompletionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _WorldOneCompletionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ],
                        if (summary.hasBandTransitionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _BandTransitionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ] else if (summary.hasTerminalCompletionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _TerminalCompletionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ] else if (summary.hasWorldCompletionPayoff) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          _WorldCompletionPayoffV1(
                            summary: summary,
                            tone: celebrateTone,
                            receipt: visibleRepairOutcomeReceipt,
                          ),
                        ],
                        if (foldUnlockIntoMilestonePanel) ...[
                          const SizedBox(height: Act0ShellTokensV1.gapMd),
                          Text(
                            summary.unlockedLabel!,
                            key: const Key(
                              'act0_shell_block_summary_unlock_label',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                              color: Act0AcademyDarkReadingStyleV1.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            summary.progressStatusLabel,
                            key: const Key(
                              'act0_shell_block_summary_progress_status',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                              color: Act0AcademyDarkReadingStyleV1.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXl),
              if (!foldUnlockIntoMilestonePanel &&
                  summary.isWorldComplete &&
                  (summary.unlockedLabel != null ||
                      summary.progressStatusLabel.isNotEmpty)) ...[
                Container(
                  key: const Key('act0_shell_block_summary_unlock_card'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                  decoration: BoxDecoration(
                    color: Act0AcademyDarkReadingStyleV1.surface2.withValues(
                      alpha: 0.86,
                    ),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                    border: Border.all(
                      color: Act0AcademyDarkReadingStyleV1.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (summary.unlockedLabel != null) ...[
                        Text(
                          summary.unlockedLabel!,
                          key: const Key(
                            'act0_shell_block_summary_unlock_label',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                            color: Act0AcademyDarkReadingStyleV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        summary.progressStatusLabel,
                        key: const Key(
                          'act0_shell_block_summary_progress_status',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                          color: Act0AcademyDarkReadingStyleV1.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              nextActionCard(),
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              primaryCtaButton(),
              if (onFirstLessonReminder case final onReminder?) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                Text(
                  'Want one reminder at 6 pm when practice is ready?',
                  style: Act0AcademyDarkReadingStyleV1.body,
                ),
                Wrap(
                  spacing: Act0ShellTokensV1.gapSm,
                  children: [
                    TextButton(
                      key: const Key('act0_first_lesson_reminder_yes'),
                      onPressed: () => onReminder(true),
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      key: const Key('act0_first_lesson_reminder_no'),
                      onPressed: () => onReminder(false),
                      child: const Text('No thanks'),
                    ),
                  ],
                ),
              ],
              if (onBackToHome != null)
                TextButton(
                  key: const Key('act0_shell_block_summary_home_cta'),
                  onPressed: onBackToHome,
                  child: const Text('Back to Home'),
                ),
              if (onBackToHome == null &&
                  summary.secondaryCtaLabel != null) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                OutlinedButton(
                  key: const Key('act0_shell_block_summary_quality_cta'),
                  onPressed: _callbackForCta(summary.secondaryCtaKind!),
                  style: Act0AcademyDarkReadingStyleV1.tonalButtonStyle(
                    tone: Act0AcademyDarkReadingStyleV1.info,
                    fullWidth: true,
                  ),
                  child: Text(
                    localeIsRu
                        ? switch (summary.secondaryCtaKind!) {
                            Act0MilestoneCtaKindV1.replayForPerfect =>
                              '\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u044c \u0431\u0435\u0437 \u043e\u0448\u0438\u0431\u043e\u043a',
                            Act0MilestoneCtaKindV1.reviewFirst ||
                            Act0MilestoneCtaKindV1.reviewForPerfect =>
                              '\u0420\u0430\u0437\u043e\u0431\u0440\u0430\u0442\u044c \u043e\u0448\u0438\u0431\u043a\u0438',
                            Act0MilestoneCtaKindV1.continueForward =>
                              '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c',
                            Act0MilestoneCtaKindV1.backToMap =>
                              '\u041a \u043a\u0430\u0440\u0442\u0435 \u0443\u0440\u043e\u043a\u043e\u0432',
                          }
                        : summary.secondaryCtaLabel!,
                  ),
                ),
              ],
              if (onBackToHome == null &&
                  (summary.hasNextLesson ||
                      (summary.isWorldComplete &&
                          summary.nextWorldTitle != null &&
                          summary.nextWorldTitle!.isNotEmpty))) ...[
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                TextButton(
                  key: const Key('act0_shell_block_summary_map_cta'),
                  onPressed: onBackToMap,
                  child: Text(
                    localeIsRu
                        ? '\u041a \u043a\u0430\u0440\u0442\u0435 \u0443\u0440\u043e\u043a\u043e\u0432'
                        : 'Back to map',
                  ),
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapLg),
              if (showHabitReward) ...[
                Container(
                  key: const Key('act0_shell_block_summary_habit_reward'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
                  decoration: BoxDecoration(
                    color: Act0AcademyDarkReadingStyleV1.surface2.withValues(
                      alpha: 0.82,
                    ),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusCard,
                    ),
                    border: Border.all(
                      color: Act0AcademyDarkReadingStyleV1.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: celebrateTone.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusLg,
                          ),
                        ),
                        child: Icon(
                          summary.deepLeakCount > 0
                              ? Icons.build_circle_rounded
                              : summary.quickFixCount > 0
                              ? Icons.trending_up_rounded
                              : summary.leveledUp
                              ? Icons.auto_awesome_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color: celebrateTone,
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localeIsRu
                                  ? '\u0427\u0442\u043e \u0442\u0440\u0435\u043d\u0438\u0440\u043e\u0432\u0430\u043b\u0438'
                                  : 'What you practiced',
                              key: const Key(
                                'act0_shell_block_summary_habit_reward_label',
                              ),
                              style: Act0AcademyDarkReadingStyleV1.label
                                  .copyWith(
                                    color: Act0AcademyDarkReadingStyleV1.info,
                                    letterSpacing: 0.35,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localeIsRu
                                  ? (summary.assistedCount > 0
                                        ? '\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u043b\u0438 \u0447\u0442\u0435\u043d\u0438\u0435 \u0441\u0442\u043e\u043b\u0430 \u0441 \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u043e\u0439. \u041e\u0448\u0438\u0431\u043a\u0430 \u043e\u0441\u0442\u0430\u0451\u0442\u0441\u044f \u0434\u043b\u044f \u0441\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u043e\u0433\u043e \u0440\u0430\u0437\u0431\u043e\u0440\u0430.'
                                        : '\u0422\u0440\u0435\u043d\u0438\u0440\u043e\u0432\u0430\u043b\u0438 \u0447\u0442\u0435\u043d\u0438\u0435 \u0441\u0442\u043e\u043b\u0430. \u0418\u0442\u043e\u0433 \u043e\u0446\u0435\u043d\u0451\u043d \u043f\u043e \u0441\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u044b\u043c \u043e\u0442\u0432\u0435\u0442\u0430\u043c.')
                                  : summary.habitRewardDetail,
                              key: const Key(
                                'act0_shell_block_summary_habit_reward_detail',
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.fade,
                              style: Act0AcademyDarkReadingStyleV1.body
                                  .copyWith(
                                    color:
                                        Act0AcademyDarkReadingStyleV1.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (localeIsRu) ...[
                Text(
                  summary.independentProvenanceKnown
                      ? (summary.assistedCount > 0
                            ? 'Ответ с подсказкой помогает учиться, но не доказывает самостоятельное решение.'
                            : 'Самостоятельные ответы оценены; исходные ошибки сохранены для разбора.')
                      : 'Самостоятельный итог этого прохождения не подтверждён; помощь не засчитана как независимый успех.',
                  key: const Key('act0_b2_summary_ru_assessed_truth'),
                  style: Act0AcademyDarkReadingStyleV1.body,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (visibleEvidenceSummary != null) ...[
                _SessionSummaryEvidenceCardV1(
                  summary: visibleEvidenceSummary,
                  localeIsRu: localeIsRu,
                  onLaunchPracticeRepairQueueTarget:
                      onLaunchPracticeRepairQueueTarget,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (visibleEarnedMoment != null) ...[
                _SessionSummaryEarnedMomentCardV1(
                  moment: visibleEarnedMoment,
                  tone: celebrateTone,
                  previouslySaved: !earnedInThisRun,
                  localeIsRu: localeIsRu,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (visibleRepairOutcomeReceipt != null) ...[
                _SessionSummaryRepairOutcomeReceiptCardV1(
                  receipt: visibleRepairOutcomeReceipt,
                  tone: celebrateTone,
                ),
                const SizedBox(height: Act0ShellTokensV1.gapMd),
              ],
              if (summary.isWorldComplete &&
                  summary.growthLabel.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _GrowthHighlightV1(
                  key: const Key('act0_shell_block_summary_growth_highlight'),
                  title: 'Practice recap',
                  label: summary.growthLabel,
                  tone: celebrateTone,
                ),
              ],
              if (summary.ownershipHighlights.isNotEmpty) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _BlockSummaryListCardV1(
                  cardKey: const Key('act0_shell_block_summary_ownership_card'),
                  title: 'Practice topics',
                  lines: summary.ownershipHighlights,
                  icon: Icons.workspace_premium_rounded,
                ),
              ],
              if (summary.hasMasteryPack) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _BlockSummaryListCardV1(
                  cardKey: const Key(
                    'act0_shell_block_summary_mastery_pack_card',
                  ),
                  title: 'Keep sharp',
                  lines: summary.masteryPackLines,
                  icon: Icons.track_changes_rounded,
                ),
              ],
              if (summary.hasReturnPlan) ...[
                const SizedBox(height: Act0ShellTokensV1.gapMd),
                _BlockSummaryListCardV1(
                  cardKey: const Key('act0_shell_block_summary_return_card'),
                  title: 'Tomorrow',
                  lines: <String>[summary.returnPlanLabel],
                  icon: Icons.event_repeat_rounded,
                ),
              ],
              const SizedBox(height: Act0ShellTokensV1.gapMd),
              _BlockXpProgressCardV1(summary: summary),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Text(
                localeIsRu
                    ? (summary.independentProvenanceKnown
                          ? '\u041e\u0446\u0435\u043d\u0435\u043d\u043e ${summary.taskCount} \u0437\u0430\u0434\u0430\u043d\u0438\u0439 · \u0432\u0435\u0440\u043d\u043e ${summary.correctCount} · \u043e\u0448\u0438\u0431\u043e\u043a ${summary.errorCount} · \u0441 \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u043e\u0439 ${summary.assistedCount}'
                          : '\u0421\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u044b\u0439 \u0440\u0435\u0437\u0443\u043b\u044c\u0442\u0430\u0442 \u043d\u0435 \u043f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0451\u043d · \u0441 \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u043e\u0439 ${summary.assistedCount}')
                    : !summary.hasVerifiedAssessment
                    ? 'No result without help recorded yet'
                    : summary.assistedCount > 0
                    ? '${summary.correctCount}/${summary.taskCount} correct \u00B7 ${summary.assistedCount} with help \u00B7 ${summary.errorCount} ${summary.errorCount == 1 ? 'error' : 'errors'}'
                    : '${summary.accuracyPercent}% accuracy (assessed) \u00B7 ${summary.correctCount}/${summary.taskCount} correct \u00B7 ${summary.errorCount} ${summary.errorCount == 1 ? 'error' : 'errors'}',
                key: const Key('act0_shell_block_summary_accuracy'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                  color: Act0AcademyDarkReadingStyleV1.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (summary.quickFixCount > 0 || summary.deepLeakCount > 0) ...[
                const SizedBox(height: Act0ShellTokensV1.gapSm),
                Container(
                  key: const Key('act0_shell_block_summary_repair_mix'),
                  padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
                  decoration: BoxDecoration(
                    color: Act0AcademyDarkReadingStyleV1.surface2.withValues(
                      alpha: 0.82,
                    ),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusLg,
                    ),
                    border: Border.all(
                      color: Act0AcademyDarkReadingStyleV1.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localeIsRu
                              ? '\u041f\u043e\u0432\u0442\u043e\u0440\u044b \u043f\u043e\u0441\u043b\u0435 \u043e\u0448\u0438\u0431\u043e\u043a: ${summary.quickFixCount}'
                              : 'Quick fixes: ${summary.quickFixCount}',
                          key: const Key(
                            'act0_shell_block_summary_quick_fixes',
                          ),
                          style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                            color: Act0AcademyDarkReadingStyleV1.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Text(
                          localeIsRu
                              ? '\u041e\u0448\u0438\u0431\u043a\u0438 \u0434\u043b\u044f \u0440\u0430\u0437\u0431\u043e\u0440\u0430: ${summary.deepLeakCount}'
                              : 'Deep leaks: ${summary.deepLeakCount}',
                          key: const Key('act0_shell_block_summary_deep_leaks'),
                          textAlign: TextAlign.right,
                          style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                            color: summary.deepLeakCount == 0
                                ? Act0AcademyDarkReadingStyleV1.textMuted
                                : Act0AcademyDarkReadingStyleV1.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldOneCompletionPayoffV1 extends StatelessWidget {
  const _WorldOneCompletionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_world1_completion',
      tone: tone,
      payoffLabel: summary.worldOneCompletionPayoffLabel,
      learningLabel: summary.worldOneCompletionLearningLabel,
      nextLabel: summary.worldOneCompletionNextLabel,
      previewLine: summary.worldOneCompletionPreviewLine,
      proofFallbackLabel: summary.worldOneCompletionProofFallbackLabel,
      receipt: receipt,
    );
  }
}

/// Ordinary World 2-6 completion payoff. Shares the exact hierarchy/visual
/// grammar accepted for World 1 via [_WorldMilestoneCardV1]; only the
/// deterministic per-world copy differs (`_worldCompletionMetaByNumberV1`).
/// World 4 intentionally receives no special treatment here \u2014 the future
/// W4->W5 band transition PR can key off `summary.worldNumber == 4` to swap
/// in its own stronger variant before this widget is reached.
class _WorldCompletionPayoffV1 extends StatelessWidget {
  const _WorldCompletionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_world_completion',
      tone: tone,
      payoffLabel: summary.worldCompletionPayoffLabel,
      learningLabel: summary.worldCompletionLearningLabel,
      nextLabel: summary.worldCompletionNextLabel,
      previewLine: summary.worldCompletionPreviewLine,
      proofFallbackLabel: summary.worldCompletionProofFallbackLabel,
      receipt: receipt,
    );
  }
}

/// The one W4->W5 Foundation -> Developing Player band-transition milestone.
/// Strictly gated to `worldNumber == 4` with valid World 5 route truth
/// (see [Act0BlockCompletionSummaryV1.hasBandTransitionPayoff]) and checked
/// with higher priority than [_WorldCompletionPayoffV1] at the render site,
/// so World 4 never also renders the ordinary card. Reuses the exact shared
/// [_WorldMilestoneCardV1] hierarchy with band-specific copy and the
/// reserved emphasized milestone seal. Not a general multi-band framework:
/// no other world number reaches this widget.
class _BandTransitionPayoffV1 extends StatelessWidget {
  const _BandTransitionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_band_transition_completion',
      tone: tone,
      payoffLabel: summary.bandTransitionIdentityLabel,
      learningLabel: summary.bandTransitionLearningLabel,
      nextLabel: summary.bandTransitionNextLabel,
      previewLine: summary.bandTransitionPreviewLine,
      proofFallbackLabel: summary.bandTransitionProofFallbackLabel,
      receipt: receipt,
      emphasizeMilestone: true,
    );
  }
}

/// The one World 12 Volume I terminal closure milestone. Strictly gated to
/// `worldNumber == 12` (see
/// [Act0BlockCompletionSummaryV1.hasTerminalCompletionPayoff]) and checked
/// with higher priority than [_WorldCompletionPayoffV1] at the render site,
/// so World 12 never also renders the ordinary card. Reuses the exact
/// shared [_WorldMilestoneCardV1] hierarchy and the emphasized milestone
/// seal already used by [_BandTransitionPayoffV1], with terminal-specific
/// identity copy and the same honest, already-accepted `Volume I review`
/// next-step/preview text. Not a general multi-terminal framework: no other
/// world number reaches this widget, and no W13+ route is implied.
class _TerminalCompletionPayoffV1 extends StatelessWidget {
  const _TerminalCompletionPayoffV1({
    required this.summary,
    required this.tone,
    this.receipt,
  });

  final Act0BlockCompletionSummaryV1 summary;
  final Color tone;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  @override
  Widget build(BuildContext context) {
    return _WorldMilestoneCardV1(
      keyPrefix: 'act0_shell_terminal_completion',
      tone: tone,
      payoffLabel: summary.terminalCompletionIdentityLabel,
      learningLabel: summary.terminalCompletionLearningLabel,
      nextLabel: summary.terminalCompletionNextLabel,
      previewLine: summary.terminalCompletionPreviewLine,
      proofFallbackLabel: summary.terminalCompletionProofFallbackLabel,
      receipt: receipt,
      emphasizeMilestone: true,
    );
  }
}

/// Shared card layout for the accepted world-completion payoff hierarchy:
/// milestone identity, learning takeaway, gated proof row, next-world
/// preview. Used by both the World 1 dedicated copy and the ordinary
/// World 2-6 copy so the visual grammar never forks per world.
class _WorldMilestoneCardV1 extends StatelessWidget {
  const _WorldMilestoneCardV1({
    required this.keyPrefix,
    required this.tone,
    required this.payoffLabel,
    required this.learningLabel,
    required this.nextLabel,
    required this.previewLine,
    required this.proofFallbackLabel,
    this.receipt,
    this.emphasizeMilestone = false,
  });

  final String keyPrefix;
  final Color tone;
  final String payoffLabel;
  final String learningLabel;
  final String nextLabel;
  final String previewLine;
  final String proofFallbackLabel;
  final Act0RepairOutcomeSessionReceiptV1? receipt;

  /// Reserved for the one W4->W5 band-transition consumer. Every ordinary
  /// world-completion wrapper leaves this at its default so the accepted
  /// W1-W6 card renders byte-identically.
  final bool emphasizeMilestone;

  bool get _hasEarnedProof => receipt?.isBankedFixProof == true;

  @override
  Widget build(BuildContext context) {
    final proofIconRole = !_hasEarnedProof
        ? null
        : receipt!.hasReinforcedEvidence
        ? Act0ProofIconRoleV1.reinforced
        : Act0ProofIconRoleV1.repairCompleted;
    return KeyedSubtree(
      key: Key('${keyPrefix}_payoff'),
      child: Padding(
        padding: const EdgeInsets.only(top: Act0ShellTokensV1.gapSm),
        child: _MilestoneMotionRevealV1(
          key: Key('${keyPrefix}_motion_reveal'),
          emphasized: emphasizeMilestone,
          identity: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Act0ProofIconV1(
                key: Key('${keyPrefix}_milestone_icon'),
                role: Act0ProofIconRoleV1.milestone,
                size: Act0ProofIconSizeV1.seal,
                emphasized: emphasizeMilestone,
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  payoffLabel,
                  key: Key('${keyPrefix}_payoff_label'),
                  style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          details: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                learningLabel,
                key: Key('${keyPrefix}_learning_label'),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                  color: Act0AcademyDarkReadingStyleV1.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (proofIconRole != null) ...[
                    Act0ProofIconV1(
                      key: Key('${keyPrefix}_proof_icon'),
                      role: proofIconRole,
                    ),
                    const SizedBox(width: Act0ShellTokensV1.gapXs),
                  ],
                  Expanded(
                    child: Text(
                      _hasEarnedProof
                          ? receipt!.lines.first
                          : proofFallbackLabel,
                      key: Key('${keyPrefix}_proof_line'),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                        color: Act0AcademyDarkReadingStyleV1.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Act0ShellTokensV1.gapXs),
              Text(
                nextLabel,
                key: Key('${keyPrefix}_next_label'),
                style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                previewLine,
                key: Key('${keyPrefix}_preview_line'),
                maxLines: 3,
                overflow: TextOverflow.fade,
                style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                  color: Act0AcademyDarkReadingStyleV1.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared `milestone`-category motion contract for
/// [_WorldCompletionPayoffV1] and [_BandTransitionPayoffV1] (see
/// `docs/_reviews/motion_direction_system_v1.md`). A single, bounded
/// staged reveal: the milestone identity (icon + payoff label) settles in
/// first, then the supporting details (learning line, proof row, next-world
/// preview) follow. `emphasized` (the same flag [_WorldMilestoneCardV1]
/// already uses for the W4->W5 seal) drives a slightly stronger identity
/// settle for the band transition only - no new asset, no new category.
///
/// Runs once per admitted milestone appearance: state lives in this
/// [StatefulWidget]'s [State], so a parent rebuild while this element stays
/// mounted (identical `Key`, same tree position) does not replay it. A real
/// unmount/remount (a new completion actually appearing) starts fresh,
/// which is the correct semantics for "once per admitted appearance".
///
/// Reduced motion ([MediaQuery.disableAnimations]) resolves both stages to
/// their settled state on the very first build, before any post-frame
/// callback runs, so no content is ever hidden while motion is off and no
/// animated frame is produced.
class _MilestoneMotionRevealV1 extends StatefulWidget {
  const _MilestoneMotionRevealV1({
    super.key,
    required this.emphasized,
    required this.identity,
    required this.details,
  });

  final bool emphasized;
  final Widget identity;
  final Widget details;

  @override
  State<_MilestoneMotionRevealV1> createState() =>
      _MilestoneMotionRevealV1State();
}

class _MilestoneMotionRevealV1State extends State<_MilestoneMotionRevealV1> {
  var _identityRevealed = false;
  var _detailsRevealed = false;
  Timer? _detailsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _identityRevealed = true);
      if (MediaQuery.of(context).disableAnimations) {
        setState(() => _detailsRevealed = true);
        return;
      }
      _detailsTimer = Timer(Act0MotionTokensV1.micro, () {
        if (!mounted) return;
        setState(() => _detailsRevealed = true);
      });
    });
  }

  @override
  void dispose() {
    _detailsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [widget.identity, widget.details],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedScale(
          scale: _identityRevealed ? 1.0 : (widget.emphasized ? 0.94 : 0.97),
          duration: widget.emphasized
              ? Act0MotionTokensV1.milestone
              : Act0MotionTokensV1.standard,
          curve: Act0MotionTokensV1.emphasisCurve,
          child: AnimatedOpacity(
            opacity: _identityRevealed ? 1 : 0,
            duration: Act0MotionTokensV1.micro,
            curve: Act0MotionTokensV1.enter,
            child: widget.identity,
          ),
        ),
        AnimatedSlide(
          offset: _detailsRevealed ? Offset.zero : const Offset(0, 0.02),
          duration: Act0MotionTokensV1.standard,
          curve: Act0MotionTokensV1.enter,
          child: AnimatedOpacity(
            opacity: _detailsRevealed ? 1 : 0,
            duration: Act0MotionTokensV1.standard,
            curve: Act0MotionTokensV1.enter,
            child: widget.details,
          ),
        ),
      ],
    );
  }
}

/// Resolves the Session Summary Sharky companion state from the exact same
/// structured evidence already used to decide this screen's copy and proof
/// icons: real world/band completion, a source-backed improvement
/// observation, banked-fix proof, and the ordinary repair-vs-forward gate.
/// Priority is milestone > improve > confirm > repair > neutral, so a
/// genuine completion boundary always wins and `repair` can never coexist
/// with a success/milestone moment. Never parses copy text.
Act0SharkyCompanionStateV1 _act0SessionSummaryCompanionStateV1({
  required bool hasWorldCompletionMoment,
  required bool qualifiesForNextLesson,
  Act0RepairOutcomeSessionReceiptV1? receipt,
}) {
  if (hasWorldCompletionMoment) {
    return Act0SharkyCompanionStateV1.milestone;
  }
  if (receipt?.hasImprovementObservation == true) {
    return Act0SharkyCompanionStateV1.improve;
  }
  if (receipt?.isBankedFixProof == true) {
    return Act0SharkyCompanionStateV1.confirm;
  }
  if (!qualifiesForNextLesson) {
    return Act0SharkyCompanionStateV1.repair;
  }
  return Act0SharkyCompanionStateV1.neutral;
}

class _SessionSummaryPayoffHeroV1 {
  const _SessionSummaryPayoffHeroV1({
    required this.kicker,
    required this.headline,
    required this.detail,
  });

  final String kicker;
  final String headline;
  final String detail;

  static _SessionSummaryPayoffHeroV1? fromProof({
    required List<Act0AchievementMomentViewModelV1> moments,
    required Act0RepairOutcomeSessionReceiptV1? receipt,
  }) {
    final hasCorrectRead = moments.any(
      (moment) => moment.label == 'First correct read',
    );
    final hasGoodFix =
        receipt?.lines.any((line) => line.startsWith('Good fixes:')) ?? false;
    if (!hasCorrectRead && !hasGoodFix) {
      return null;
    }
    return _SessionSummaryPayoffHeroV1(
      kicker: 'Saved read',
      headline: hasCorrectRead && hasGoodFix
          ? 'One clean table read is saved.'
          : hasCorrectRead
          ? 'One clean table read is saved.'
          : 'Repair landed.',
      detail: hasCorrectRead && hasGoodFix
          ? 'Keep this clue: read the table before acting.'
          : hasCorrectRead
          ? 'Keep this clue for the next hand.'
          : 'Keep this repair for the next hand.',
    );
  }
}

class _BlockXpProgressCardV1 extends StatelessWidget {
  const _BlockXpProgressCardV1({required this.summary});

  final Act0BlockCompletionSummaryV1 summary;

  @override
  Widget build(BuildContext context) {
    return _buildCard(context);
  }

  Widget _buildCard(BuildContext context) {
    final tone = summary.leveledUp
        ? Act0AcademyDarkReadingStyleV1.gold
        : Act0AcademyDarkReadingStyleV1.primary;
    // A saved/assisted/wrong run is not automatically an independent clean read.
    // The bar displays assessed correctness, not "all XP equals mastery".
    final cleanIndependentRead =
        summary.hasVerifiedAssessment &&
        summary.errorCount == 0 &&
        summary.assistedCount == 0 &&
        summary.correctCount == summary.taskCount;
    final assessedFraction = summary.hasVerifiedAssessment
        ? (summary.correctCount / summary.taskCount).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      decoration: BoxDecoration(
        color: Act0AcademyDarkReadingStyleV1.surface2.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPanel),
        border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
      ),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                ),
                child: Text(
                  cleanIndependentRead ? 'One clean read' : 'Practice recorded',
                  key: const Key('act0_shell_block_summary_xp_gain'),
                  style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                    color: tone,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: Act0ShellTokensV1.gapSm),
              Expanded(
                child: Text(
                  summary.hasVerifiedAssessment
                      ? 'Assessed accuracy'
                      : 'Assessment not verified',
                  key: const Key('act0_shell_block_summary_xp_total'),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.right,
                  style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (summary.hasVerifiedAssessment) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              child: LinearProgressIndicator(
                key: const Key('act0_shell_block_summary_xp_progress'),
                minHeight: 8,
                value: assessedFraction,
                backgroundColor: Act0AcademyDarkReadingStyleV1.surface3,
                color: tone,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionSummaryEvidenceCardV1 extends StatelessWidget {
  const _SessionSummaryEvidenceCardV1({
    required this.summary,
    this.localeIsRu = false,
    this.onLaunchPracticeRepairQueueTarget,
  });

  final Act0SessionSummaryEvidenceViewModelV1 summary;
  final bool localeIsRu;
  final ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>?
  onLaunchPracticeRepairQueueTarget;

  @override
  Widget build(BuildContext context) {
    final repairFocusLine = summary.repairFocusLine;
    final repairCandidateLine = summary.repairCandidateLine;
    final learningProofLine = summary.learningProofLine;
    final practiceLaunchRequest = summary.practiceLaunchRequest;
    final showPracticeCta =
        practiceLaunchRequest?.isLaunchable == true &&
        onLaunchPracticeRepairQueueTarget != null;
    return Container(
      key: const Key('act0_shell_block_summary_evidence_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0AcademyDarkReadingStyleV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localeIsRu
                ? '\u0422\u0435\u043a\u0443\u0449\u0438\u0439 \u043f\u0440\u043e\u0445\u043e\u0434'
                : summary.title,
            key: const Key('act0_shell_block_summary_evidence_title'),
            style: Act0AcademyDarkReadingStyleV1.label.copyWith(
              color: Act0AcademyDarkReadingStyleV1.info,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localeIsRu
                ? '\u0427\u0438\u0441\u043b\u043e \u0438 \u0440\u0435\u0437\u0443\u043b\u044c\u0442\u0430\u0442 \u043e\u0446\u0435\u043d\u0451\u043d\u043d\u044b\u0445 \u0437\u0430\u0434\u0430\u043d\u0438\u0439 \u043f\u043e\u043a\u0430\u0437\u0430\u043d\u044b \u0432\u044b\u0448\u0435.'
                : summary.spotsLine,
            key: const Key('act0_shell_block_summary_evidence_spots'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0AcademyDarkReadingStyleV1.body.copyWith(
              color: Act0AcademyDarkReadingStyleV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localeIsRu
                ? '\u041f\u043e\u043c\u043e\u0449\u044c \u043d\u0435 \u0441\u0447\u0438\u0442\u0430\u0435\u0442\u0441\u044f \u0441\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u044b\u043c \u0438\u0441\u043f\u0440\u0430\u0432\u043b\u0435\u043d\u0438\u0435\u043c.'
                : summary.resultLine,
            key: const Key('act0_shell_block_summary_evidence_result'),
            maxLines: 2,
            overflow: TextOverflow.fade,
            style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
              color: Act0AcademyDarkReadingStyleV1.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (repairFocusLine != null && repairFocusLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              localeIsRu
                  ? '\u041e\u0431\u0440\u0430\u0442\u0438 \u0432\u043d\u0438\u043c\u0430\u043d\u0438\u0435 \u043d\u0430 \u0441\u043e\u0445\u0440\u0430\u043d\u0451\u043d\u043d\u0443\u044e \u043e\u0448\u0438\u0431\u043a\u0443.'
                  : repairFocusLine,
              key: const Key('act0_shell_block_summary_evidence_repair_focus'),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                color: Act0AcademyDarkReadingStyleV1.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (repairCandidateLine != null &&
              repairCandidateLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              localeIsRu
                  ? '\u0414\u043b\u044f \u044d\u0442\u043e\u0439 \u043e\u0448\u0438\u0431\u043a\u0438 \u0435\u0441\u0442\u044c \u0441\u043b\u0435\u0434\u0443\u044e\u0449\u0438\u0439 \u0442\u0440\u0435\u043d\u0438\u0440\u043e\u0432\u043e\u0447\u043d\u044b\u0439 \u0441\u043f\u043e\u0442.'
                  : repairCandidateLine,
              key: const Key(
                'act0_shell_block_summary_evidence_repair_candidate',
              ),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                color: Act0AcademyDarkReadingStyleV1.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (learningProofLine != null && learningProofLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            _ProofMotionRevealV1(
              key: const Key(
                'act0_shell_block_summary_evidence_learning_proof_reveal',
              ),
              child: Text(
                localeIsRu
                    ? '\u041f\u043e\u0437\u0436\u0435 \u044d\u0442\u0443 \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u0443 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u043f\u0440\u043e\u0447\u0438\u0442\u0430\u0442\u044c \u043f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u043e.'
                    : learningProofLine,
                key: const Key(
                  'act0_shell_block_summary_evidence_learning_proof',
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
                style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                  color: Act0AcademyDarkReadingStyleV1.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (showPracticeCta) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            TextButton(
              key: const Key('act0_shell_session_summary_practice_cta'),
              onPressed: () =>
                  onLaunchPracticeRepairQueueTarget!(practiceLaunchRequest!),
              style: TextButton.styleFrom(
                foregroundColor: Act0AcademyDarkReadingStyleV1.info,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: Act0ShellTokensV1.gapXs,
                  vertical: Act0ShellTokensV1.gapSm,
                ),
              ),
              child: Text(
                localeIsRu
                    ? '\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u044c \u043f\u043e\u0434\u0441\u043a\u0430\u0437\u043a\u0443'
                    : 'Practice this next',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GrowthHighlightV1 extends StatelessWidget {
  const _GrowthHighlightV1({
    super.key,
    required this.label,
    required this.tone,
    this.title = 'Skill gain',
  });

  final String title;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Act0AcademyDarkReadingStyleV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            ),
            child: Icon(Icons.auto_graph_rounded, size: 17, color: tone),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.info,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.text,
                    fontWeight: FontWeight.w800,
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

class _SessionSummaryEarnedMomentCardV1 extends StatelessWidget {
  const _SessionSummaryEarnedMomentCardV1({
    required this.moment,
    required this.tone,
    this.previouslySaved = false,
    this.localeIsRu = false,
  });

  final Act0AchievementMomentViewModelV1 moment;
  final Color tone;
  final bool previouslySaved;
  final bool localeIsRu;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_block_summary_earned_moment'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0AcademyDarkReadingStyleV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('act0_shell_block_summary_earned_moment_mark'),
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            ),
            child: Icon(Icons.check_circle_rounded, color: tone, size: 18),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localeIsRu
                      ? (previouslySaved
                            ? '\u0421\u043E\u0445\u0440\u0430\u043D\u0435\u043D\u043E \u0440\u0430\u043D\u0435\u0435'
                            : '\u0412\u0435\u0440\u043D\u043E \u0432 \u044D\u0442\u043E\u0439 \u0441\u0435\u0441\u0441\u0438\u0438')
                      : (previouslySaved ? 'Saved earlier' : 'Collected read'),
                  key: const Key('act0_shell_block_summary_earned_label'),
                  style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.info,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localeIsRu && moment.label == 'First correct read'
                      ? '\u041f\u0435\u0440\u0432\u043e\u0435 \u043f\u0440\u0430\u0432\u0438\u043b\u044c\u043d\u043e\u0435 \u0447\u0442\u0435\u043d\u0438\u0435 \u0441\u0442\u043e\u043b\u0430'
                      : moment.label,
                  key: const Key('act0_shell_block_summary_earned_seed'),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  act0SharkyCoachLineForMomentV1(
                    Act0SharkyCoachMomentV1.sessionSummaryEarnedMoment,
                  ),
                  key: const Key('act0_shell_block_summary_earned_proof'),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  style: Act0AcademyDarkReadingStyleV1.muted.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.textMuted,
                    fontWeight: FontWeight.w700,
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

class _SessionSummaryRepairOutcomeReceiptCardV1 extends StatelessWidget {
  const _SessionSummaryRepairOutcomeReceiptCardV1({
    required this.receipt,
    required this.tone,
  });

  final Act0RepairOutcomeSessionReceiptV1 receipt;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final proofIconRole = !receipt.isBankedFixProof
        ? null
        : receipt.hasReinforcedEvidence
        ? Act0ProofIconRoleV1.reinforced
        : Act0ProofIconRoleV1.repairCompleted;
    final titleRow = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (proofIconRole != null) ...[
          Act0ProofIconV1(
            key: const Key('act0_shell_session_repair_outcome_proof_icon'),
            role: proofIconRole,
            size: Act0ProofIconSizeV1.tile,
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
        ],
        Expanded(
          child: Text(
            receipt.title,
            key: const Key('act0_shell_session_repair_outcome_title'),
            style: Act0AcademyDarkReadingStyleV1.label.copyWith(
              color: Act0AcademyDarkReadingStyleV1.info,
              letterSpacing: 0.35,
            ),
          ),
        ),
      ],
    );
    return Container(
      key: const Key('act0_shell_session_repair_outcome_receipt'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0AcademyDarkReadingStyleV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          const SizedBox(height: 6),
          for (var index = 0; index < receipt.lines.length; index++) ...[
            if (index > 0) const SizedBox(height: 4),
            Text(
              receipt.lines[index],
              key: Key('act0_shell_session_repair_outcome_line_$index'),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                color: index == 0
                    ? Act0AcademyDarkReadingStyleV1.text
                    : Act0AcademyDarkReadingStyleV1.textMuted,
                fontWeight: index == 0 ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockSummaryListCardV1 extends StatelessWidget {
  const _BlockSummaryListCardV1({
    required this.cardKey,
    required this.title,
    required this.lines,
    required this.icon,
  });

  final Key cardKey;
  final String title;
  final List<String> lines;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: cardKey,
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0AcademyDarkReadingStyleV1.surface2.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusCard),
        border: Border.all(color: Act0AcademyDarkReadingStyleV1.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0AcademyDarkReadingStyleV1.info.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
            ),
            child: Icon(
              icon,
              size: 17,
              color: Act0AcademyDarkReadingStyleV1.info,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Act0AcademyDarkReadingStyleV1.label.copyWith(
                    color: Act0AcademyDarkReadingStyleV1.info,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 4),
                for (final line in lines) ...[
                  Text(
                    line,
                    style: Act0AcademyDarkReadingStyleV1.body.copyWith(
                      color: Act0AcademyDarkReadingStyleV1.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (line != lines.last)
                    const SizedBox(height: Act0ShellTokensV1.gapXs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Act0RunnerCompletionSummaryV1 _blockSummaryProgressAtGain(
  Act0BlockCompletionSummaryV1 summary,
  int gain,
) {
  final xpTarget = summary.xpTarget <= 0 ? 1 : summary.xpTarget;
  final totalXp = summary.startXp + gain;
  return Act0RunnerCompletionSummaryV1(
    xpGain: gain,
    startLevel: summary.startLevel,
    endLevel: summary.startLevel + (totalXp ~/ xpTarget),
    startXp: summary.startXp,
    endXp: totalXp % xpTarget,
    xpTarget: summary.xpTarget,
  );
}

class _CompletionToastV1 extends StatelessWidget {
  const _CompletionToastV1({
    required this.summary,
    this.overlayStyle = _CompletionToastOverlayStyleV1.standard,
  });

  final Act0RunnerCompletionSummaryV1 summary;
  final _CompletionToastOverlayStyleV1 overlayStyle;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return _buildToastCard(context);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final appear = Curves.easeOut.transform((value / 0.18).clamp(0.0, 1.0));
        final disappear = Curves.easeIn.transform(
          ((value - 0.72) / 0.28).clamp(0.0, 1.0),
        );
        final opacity = (appear * (1 - disappear)).clamp(0.0, 1.0);
        final onTableOverlay =
            overlayStyle == _CompletionToastOverlayStyleV1.table;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, (1 - appear) * (onTableOverlay ? 5 : 6)),
            child: _buildToastCard(context),
          ),
        );
      },
    );
  }

  Widget _buildToastCard(BuildContext context) {
    final tone = summary.leveledUp
        ? Act0ShellTokensV1.gold
        : Act0ShellTokensV1.primary;
    final onTableOverlay = overlayStyle == _CompletionToastOverlayStyleV1.table;
    return Container(
      key: const Key('act0_shell_completion_toast'),
      constraints: BoxConstraints(
        minWidth: onTableOverlay ? 164 : 176,
        maxWidth: onTableOverlay ? 204 : 220,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: onTableOverlay ? 11 : 12,
        vertical: onTableOverlay ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: onTableOverlay
            ? Act0ShellTokensV1.surface2.withValues(alpha: 0.88)
            : Act0ShellTokensV1.surface2.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: tone.withValues(alpha: onTableOverlay ? 0.24 : 0.34),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: onTableOverlay ? 0.10 : 0.24),
            blurRadius: onTableOverlay ? 8 : 18,
            offset: Offset(0, onTableOverlay ? 3 : 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Answer checked',
                  key: const Key('act0_shell_completion_toast_reward_label'),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: tone,
                    letterSpacing: onTableOverlay ? 0.16 : 0.25,
                    fontSize: onTableOverlay ? 9.0 : null,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: onTableOverlay ? 2 : 3),
          Text(
            'Keep practicing',
            key: const Key('act0_shell_completion_toast_total'),
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: Act0ShellTokensV1.body.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: onTableOverlay ? 10.8 : 11.5,
            ),
          ),
          SizedBox(height: onTableOverlay ? 5 : 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            child: LinearProgressIndicator(
              key: const Key('act0_shell_completion_toast_progress'),
              minHeight: onTableOverlay ? 5 : 6,
              value: summary.xpGain <= 0 ? 0.0 : 1.0,
              backgroundColor: Act0ShellTokensV1.surface3,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

enum _CompletionToastOverlayStyleV1 { standard, table }

class _PotSweepMomentV1 extends StatelessWidget {
  const _PotSweepMomentV1({required this.potLabel});

  final String potLabel;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const Key('act0_shell_pot_sweep_moment'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1180),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final appear = Curves.easeOut.transform((value / 0.18).clamp(0.0, 1.0));
        final settle = Curves.easeInOut.transform(
          ((value - 0.12) / 0.70).clamp(0.0, 1.0),
        );
        final fade = Curves.easeIn.transform(
          ((value - 0.78) / 0.22).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: (appear * (1 - fade)).clamp(0.0, 1.0),
          child: Align(
            alignment:
                Alignment.lerp(
                  const Alignment(0, -0.04),
                  const Alignment(0, 0.58),
                  settle,
                ) ??
                const Alignment(0, 0.58),
            child: Transform.scale(scale: 0.90 + (0.10 * appear), child: child),
          ),
        );
      },
      child: Container(
        key: const Key('act0_shell_pot_sweep_chip'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
          border: Border.all(
            color: Act0ShellTokensV1.gold.withValues(alpha: 0.38),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Act0ShellTokensV1.gold.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino_rounded, size: 13, color: Act0ShellTokensV1.gold),
            const SizedBox(width: 5),
            Text(
              potLabel,
              key: const Key('act0_shell_pot_sweep_label'),
              maxLines: 3,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
                fontSize: 9.4,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Act0RunnerCompletionSummaryV1 _feedbackProgressAtGain(
  Act0RunnerCompletionSummaryV1 summary,
  int gain,
) {
  final xpTarget = summary.xpTarget <= 0 ? 1 : summary.xpTarget;
  final totalXp = summary.startXp + gain;
  return Act0RunnerCompletionSummaryV1(
    xpGain: gain,
    startLevel: summary.startLevel,
    endLevel: summary.startLevel + (totalXp ~/ xpTarget),
    startXp: summary.startXp,
    endXp: totalXp % xpTarget,
    xpTarget: summary.xpTarget,
  );
}

/// Felt inset. Unchanged from B1 \u2014 widening it pushed the blind chips over the
/// first board card's rank, which is learning-relevant information.
const double _act0SceneRailWidthV1 = 10.0;

/// Downward shift B2 applies to the table so the far-player plane is readable
/// above the far rail. Spends the dead gap between the near rail and the action
/// dock; the table's own height is unchanged, so Wave A table-dominance guards
/// keep their full margin.
const double _act0SceneFarPlaneReserveV1 = 18.0;

/// How far the B2 rail stands proud of the felt inset. The rail gains its
/// volume outward, into the room, rather than by eating the playing surface.
const double _act0SceneRailOverhangV1 = 5.0;

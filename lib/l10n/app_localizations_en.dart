// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get favorites => 'Favorites';

  @override
  String get recommended => 'Recommended';

  @override
  String get starterPacks => 'Starter Packs';

  @override
  String get builtInPacks => 'Built-in Packs';

  @override
  String get yourPacks => 'Your Packs';

  @override
  String get recentPacks => 'Recently Practised';

  @override
  String get popularPacks => '🔥 Popular';

  @override
  String get newPacks => '🆕 New';

  @override
  String get starterBadge => 'Starter';

  @override
  String get newBadge => 'New';

  @override
  String get masteredBadge => '✅ Mastered';

  @override
  String get hands => 'hands';

  @override
  String get packCatalogTitle => 'Pack catalog';

  @override
  String get packCatalogSubtitle => 'Browse curated packs';

  @override
  String get difficultyAdvanced => 'Advanced';

  @override
  String get difficultyIntermediate => 'Intermediate';

  @override
  String get difficultyBeginner => 'Beginner';

  @override
  String get packStatusComingSoon => 'Coming soon';

  @override
  String get packStatusLocked => 'Locked';

  @override
  String get startTraining => 'Start training';

  @override
  String get lastTrained => 'Last trained';

  @override
  String get needsPractice => 'Needs Practice';

  @override
  String get reviewMistakes => 'Review Mistakes';

  @override
  String get reviewMistakesOnly => 'Review Mistakes Only';

  @override
  String percentLabel(Object value) {
    return '$value %';
  }

  @override
  String get starter_packs_title => 'Starter pack';

  @override
  String get starter_packs_subtitle => 'Start training instantly';

  @override
  String get starter_packs_start => 'Start';

  @override
  String get starter_packs_continue => 'Continue';

  @override
  String get starter_packs_choose => 'Choose pack';

  @override
  String accuracySemantics(Object value) {
    return 'Accuracy $value percent';
  }

  @override
  String get sortProgress => 'Progress';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortMostHands => 'Most Hands';

  @override
  String get sortName => 'Name A-Z';

  @override
  String get noMistakesLeft => 'All mistakes already fixed!';

  @override
  String get filterMistakes => 'Mistakes';

  @override
  String get sortInProgress => 'In Progress';

  @override
  String get packPushFold12 => 'Push/Fold 12BB (No Ante)';

  @override
  String get packPushFold15 => 'Push/Fold 15BB (No Ante)';

  @override
  String get packPushFold10 => 'Push/Fold 10BB (No Ante)';

  @override
  String get packPushFold20 => 'Push/Fold 20BB (No Ante)';

  @override
  String get presetBtn10bb => 'BTN 10BB Push/Fold';

  @override
  String get presetBtn11bb => 'BTN 11BB Push/Fold';

  @override
  String get presetBtn12bb => 'BTN 12BB Push/Fold';

  @override
  String get presetBtn13bb => 'BTN 13BB Push/Fold';

  @override
  String get presetBtn14bb => 'BTN 14BB Push/Fold';

  @override
  String get presetBtn15bb => 'BTN 15BB Push/Fold';

  @override
  String get presetBtn16bb => 'BTN 16BB Push/Fold';

  @override
  String get presetBtn17bb => 'BTN 17BB Push/Fold';

  @override
  String get presetBtn18bb => 'BTN 18BB Push/Fold';

  @override
  String get presetBtn19bb => 'BTN 19BB Push/Fold';

  @override
  String get presetBtn20bb => 'BTN 20BB Push/Fold';

  @override
  String get presetSb10bb => 'SB 10BB Push/Fold';

  @override
  String get presetSb11bb => 'SB 11BB Push/Fold';

  @override
  String get presetSb12bb => 'SB 12BB Push/Fold';

  @override
  String get presetSb13bb => 'SB 13BB Push/Fold';

  @override
  String get presetSb14bb => 'SB 14BB Push/Fold';

  @override
  String get presetSb15bb => 'SB 15BB Push/Fold';

  @override
  String get presetSb16bb => 'SB 16BB Push/Fold';

  @override
  String get presetSb17bb => 'SB 17BB Push/Fold';

  @override
  String get presetSb18bb => 'SB 18BB Push/Fold';

  @override
  String get presetSb19bb => 'SB 19BB Push/Fold';

  @override
  String get presetSb20bb => 'SB 20BB Push/Fold';

  @override
  String get generateSpots => 'Generate spots';

  @override
  String get noContent => 'No content';

  @override
  String get unsupportedSpot => 'Unsupported spot';

  @override
  String get startTrainingSessionPrompt => 'Start training session now?';

  @override
  String get trainingSummary => 'Training Summary';

  @override
  String get noMistakes => 'No mistakes';

  @override
  String get repeatMistakes => 'Repeat Mistakes';

  @override
  String get backToLibrary => 'Back to Library';

  @override
  String get recommendedPacks => 'Recommended packs';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get masteredPacks => 'Mastered packs';

  @override
  String get dailyGoals => 'Daily Goals';

  @override
  String get sessions => 'Sessions';

  @override
  String get accuracyPercent => 'Accuracy %';

  @override
  String get ev => 'EV';

  @override
  String get icm => 'ICM';

  @override
  String get spotDetails => 'Spot Details';

  @override
  String heroPosition(Object pos) {
    return 'Hero position: $pos';
  }

  @override
  String heroCards(Object cards) {
    return 'Hero cards: $cards';
  }

  @override
  String boardLabel(Object cards) {
    return 'Board: $cards';
  }

  @override
  String yourAction(Object action) {
    return 'Your action: $action';
  }

  @override
  String evIcm(Object ev, Object icm) {
    return 'EV $ev  ICM $icm';
  }

  @override
  String packCreated(Object name) {
    return 'Pack \"$name\" created';
  }

  @override
  String resetPackPrompt(Object name) {
    return 'Reset progress for \'$name\'?';
  }

  @override
  String resetStagePrompt(Object name) {
    return 'Reset stage \'$name\'?';
  }

  @override
  String get resetStage => 'Reset Stage';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get settingsResetTitle => 'Reset Settings';

  @override
  String get settingsResetConfirmation =>
      'Are you sure you want to reset all settings to defaults?';

  @override
  String get settingsResetSuccess => 'Settings reset to defaults';

  @override
  String get settingsResetButton => 'Reset to Defaults';

  @override
  String get settingsCurrentLanguageLabel => 'Current Language';

  @override
  String languageChangedSnackbar(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get languageSelectorTitle => 'Select Language';

  @override
  String get languageSelectorDescription =>
      'Choose your preferred language. The app will update instantly.';

  @override
  String get settingsLegalEntryTitle => 'Legal & Compliance';

  @override
  String get settingsLegalEntrySubtitle => 'Privacy, terms, and data controls';

  @override
  String get legalScreenTitle => 'Legal & Compliance';

  @override
  String get legalPoliciesSectionTitle => 'Policies';

  @override
  String get legalDataSectionTitle => 'Data';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'View how we handle player data';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get termsOfUseSubtitle => 'Read the governing terms';

  @override
  String get legalDeleteDataTitle => 'Delete Data / Account';

  @override
  String get legalDeleteDataSubtitle =>
      'Wipe local learning progress, snapshots, and session history';

  @override
  String get legalDeleteConfirmationTitle => 'Delete local data?';

  @override
  String get legalDeleteConfirmationBody =>
      'This will remove learning progress, snapshots, and session fingerprints from this device. This cannot be undone.';

  @override
  String get legalDeleteSuccess => 'Local data cleared';

  @override
  String get legalDeleteFailure => 'Failed to clear local data';

  @override
  String get playerType => 'Player Type';

  @override
  String get selectAction => 'Select Action';

  @override
  String get fold => 'Fold';

  @override
  String get call => 'Call';

  @override
  String get raise => 'Raise';

  @override
  String get push => 'Push';

  @override
  String get amount => 'Amount';

  @override
  String get confirm => 'Confirm';

  @override
  String get clear => 'Clear';

  @override
  String get ok => 'OK';

  @override
  String get entrants => 'Entrants';

  @override
  String get gameType => 'Game Type';

  @override
  String get holdemNl => 'Hold\'em NL';

  @override
  String get omahaPl => 'Omaha PL';

  @override
  String get otherGameType => 'Other';

  @override
  String spotsLabel(Object value) {
    return 'Spots: $value';
  }

  @override
  String accuracyLabel(Object value) {
    return 'Accuracy: $value%';
  }

  @override
  String evBb(Object value) {
    return 'EV: $value BB';
  }

  @override
  String icmLabel(Object value) {
    return 'ICM: $value';
  }

  @override
  String get exportWeaknessReport => 'Export Weakness Report';

  @override
  String packsShown(Object count) {
    return 'Shown $count packs';
  }

  @override
  String get noResults => 'No results';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get sortLabel => 'Sorting:';

  @override
  String get sortPopular => 'Popular first';

  @override
  String get sortRating => 'Rating (High → Low)';

  @override
  String get sortCoverage => 'Coverage (High → Low)';

  @override
  String filtersSelected(Object count) {
    return 'Filters: $count selected';
  }

  @override
  String get filtersNone => 'Filters: none';

  @override
  String get progress => 'Progress';

  @override
  String get packsCompleted => 'Packs Completed';

  @override
  String get averageAccuracy => 'Avg Accuracy';

  @override
  String get averageEv => 'Avg EV';

  @override
  String get dailyStreak => 'Streak';

  @override
  String get best => 'Best';

  @override
  String get pinnedPacks => '📌 Pinned Templates';

  @override
  String get weakAreas => 'Weak Areas';

  @override
  String get packOfDay => '🎲 Pack of the Day';

  @override
  String streakChipLabel(Object count) {
    return 'Streak: $count';
  }

  @override
  String dailyHandLabel(Object index) {
    return 'Daily Hand #$index';
  }

  @override
  String get levelGoalTitle => 'Level Goal';

  @override
  String get samplePreviewHint => 'Try a sample first to explore this pack!';

  @override
  String get samplePreviewPrompt =>
      'This pack is large. Preview a quick sample first?';

  @override
  String get previewSample => 'Preview Sample';

  @override
  String get autoSampleToast =>
      'Quick preview launched automatically for faster start.';

  @override
  String plannerBadge(Object count) {
    return '$count left';
  }

  @override
  String get unfinishedSession => 'You have an unfinished session';

  @override
  String get resume => 'Resume';

  @override
  String mistakeBoosterReinforced(Object count) {
    return 'Reinforced: $count tags';
  }

  @override
  String mistakeBoosterRecovered(Object count) {
    return 'Recovered: $count tags';
  }

  @override
  String get quickstartL3 => 'Quickstart L3';

  @override
  String get run => 'Run';

  @override
  String get openReport => 'Open report';

  @override
  String get viewLogs => 'View logs';

  @override
  String get retry => 'Retry';

  @override
  String get presetWillBeUsed => 'Preset will be used';

  @override
  String get reportEmpty => 'Report is empty';

  @override
  String get abDiff => 'A/B diff';

  @override
  String get export => 'Export';

  @override
  String get weightsPreset => 'Weights preset';

  @override
  String get weightsJson => 'Weights JSON';

  @override
  String get invalidJson => 'Invalid JSON';

  @override
  String get desktopOnly => 'Desktop only';

  @override
  String get recentRuns => 'Recent runs';

  @override
  String get open => 'Open';

  @override
  String get logs => 'Logs';

  @override
  String get folder => 'Folder';

  @override
  String get copyPath => 'Copy path';

  @override
  String get reRun => 'Re-run';

  @override
  String get pickTwoRuns => 'Pick two runs';

  @override
  String get compare => 'Compare';

  @override
  String get noSelection => 'No selection';

  @override
  String get rootKeys => 'Root keys';

  @override
  String get arrayLengths => 'Array lengths';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get confirmClear => 'Clear all runs? This action cannot be undone.';

  @override
  String get deleted => 'Deleted';

  @override
  String get copied => 'Copied';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get reveal => 'Reveal';

  @override
  String get csvSaved => 'CSV saved';

  @override
  String get delta => 'Δ';

  @override
  String get args => 'Args';

  @override
  String get shopInsufficientFunds => 'Insufficient coins';

  @override
  String shopPurchased(Object name) {
    return 'Purchased: $name';
  }

  @override
  String shopCoinsBalance(Object balance) {
    return 'Coins: $balance';
  }

  @override
  String shopPrice(Object price) {
    return 'Price: $price';
  }

  @override
  String get shopAvailableItems => 'Available Items';

  @override
  String get shopScreenLabel => 'Shop screen';

  @override
  String shopYourBalance(Object balance) {
    return 'Your balance: $balance coins';
  }

  @override
  String onboardingStepProgress(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingCongratulations => 'Congratulations!';

  @override
  String get onboardingFirstTrainingCompleteWithRepeat =>
      'You completed your first training session!\n\nNow let\'s reinforce what you\'ve learned.';

  @override
  String get onboardingFirstTrainingComplete =>
      'You completed your first training session!';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get onboardingMistakeSystemTitle => 'Mistake Repetition System';

  @override
  String get onboardingHowItWorksTitle => 'How It Works';

  @override
  String get onboardingHowItWorksDescription =>
      'When you make a mistake in a hand, it\'s automatically marked for review. The system tracks all your errors.';

  @override
  String get onboardingWhenRepeatsTitle => 'When Hands Repeat';

  @override
  String get onboardingWhenRepeatsDescription =>
      'You\'ll see this hand again tomorrow. If you make another mistake, it will return in 3 days. If you solve it correctly, it will be removed from reviews.';

  @override
  String get onboardingWhyNeededTitle => 'Why This Matters';

  @override
  String get onboardingWhyNeededDescription =>
      'Repetition is the key to memory. By revisiting challenging hands, you strengthen your understanding and turn weaknesses into strengths.';

  @override
  String get onboardingDontWorry =>
      'Don\'t worry! Mistakes are normal. The important thing is to learn from them.';

  @override
  String get onboardingRepeatMistakes => 'Review Mistakes';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingMistakesReviewed => 'Mistakes Reviewed';

  @override
  String get onboardingCompletedMessage =>
      'You\'ve completed the onboarding!\n\nYou\'re now ready for full training sessions.';

  @override
  String get onboardingStartTraining => 'Start Training';

  @override
  String get onboardingWelcome => 'Welcome to Poker Analyzer!';

  @override
  String get onboardingWelcomeSubtitle =>
      'Learn poker through ready-made hands';

  @override
  String get onboardingStart => 'Start';

  @override
  String get xpTabsTitle => 'Progress';

  @override
  String get xpHistoryTab => 'History';

  @override
  String get xpJournalTab => 'Journal';

  @override
  String get xpEvalTab => 'Self-Eval';

  @override
  String get xpMilestonesTab => 'Milestones';

  @override
  String get xpLeagueTab => 'League';

  @override
  String get xpShareTab => 'Share';

  @override
  String get xpDashboardTitle => 'XP History';

  @override
  String get xpDashboardEmptyTitle => 'No XP activity yet';

  @override
  String get xpDashboardEmptyMessage =>
      'Complete drills, view theory, or finish modules\\nto start earning XP!';

  @override
  String get xpDashboardStreakTitle => 'Activity streak';

  @override
  String get xpDashboardStreakTooltip =>
      'Earn XP every day to keep your streak alive!';

  @override
  String get xpDashboardCurrentStreakLabel => 'Current';

  @override
  String get xpDashboardNoStreak => 'No streak yet';

  @override
  String get xpDashboardBestStreakLabel => 'Best';

  @override
  String get xpDashboardLast30Days => 'Last 30 days';

  @override
  String get xpDashboardTrendsTitle => 'XP trends (last 7 days)';

  @override
  String get xpDashboardTotalXpLabel => 'Total XP';

  @override
  String get xpDashboardDrillsLabel => 'Drills';

  @override
  String get xpDashboardModulesLabel => 'Modules';

  @override
  String get xpDashboardTheoryLabel => 'Theory';

  @override
  String get xpEventDrillCompleted => 'Drill completed';

  @override
  String get xpEventModuleCompleted => 'Module completed';

  @override
  String get xpEventTheoryViewed => 'Theory viewed';

  @override
  String get xpEventGeneric => 'XP earned';

  @override
  String xpRelativeTodayAt(Object time) {
    return 'Today at $time';
  }

  @override
  String xpRelativeYesterdayAt(Object time) {
    return 'Yesterday at $time';
  }

  @override
  String xpRelativeWeekdayAt(Object weekday, Object time) {
    return '$weekday at $time';
  }

  @override
  String xpRelativeDateTime(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String get xpDashboardLauncherTitle => 'Your progress';

  @override
  String get xpDashboardLauncherSubtitle => 'XP, history, self-eval';

  @override
  String get xpJournalTitle => 'XP Journal';

  @override
  String get xpJournalEmptyTitle => 'No XP events yet';

  @override
  String get xpJournalEmptyMessage => 'Complete activities to start journaling';

  @override
  String get xpJournalReflectionLabel => 'Reflection';

  @override
  String get xpJournalReflectionHint =>
      'What did you learn? What could improve?';

  @override
  String get xpSelfEvalTitle => 'Self-evaluation';

  @override
  String get xpSelfEvalResetTooltip => 'Reset all';

  @override
  String get xpSelfEvalResetConfirmation => 'Checklist reset';

  @override
  String get xpSelfEvalProgressHeader => 'Progress';

  @override
  String xpSelfEvalSkillsCompleted(int completed, int total) {
    return '$completed of $total skills complete';
  }

  @override
  String get xpSelfEvalItemPushCall => 'I confidently push/call charts in SRP';

  @override
  String get xpSelfEvalItemBubblePush => 'I understand bubble push ranges';

  @override
  String get xpSelfEvalItemIcmAwareness =>
      'I can tell ICM spots from ChipEV spots';

  @override
  String get xpSelfEvalItemAdjustCharts =>
      'I adjust charts for tournament structures';

  @override
  String get xpSelfEvalItemStackAwareness =>
      'I consider opponent stacks when deciding';

  @override
  String get xpSelfEvalItemReviewMistakes =>
      'I review my mistakes after every session';

  @override
  String get xpSelfEvalItemDeviateCharts =>
      'I know when to deviate from baseline charts';

  @override
  String get xpSelfEvalResetButton => 'Reset checklist';

  @override
  String get xpMilestoneTitle => 'XP milestones';

  @override
  String get xpMilestoneHeaderTitle => 'Your XP progress';

  @override
  String xpMilestoneTotalXp(int xp) {
    return 'Total XP: $xp';
  }

  @override
  String get xpMilestoneUnlockHint =>
      'Unlock milestones by earning XP through drills, modules, and theory!';

  @override
  String xpMilestoneClaimedMessage(int xp) {
    return 'Claimed the $xp XP milestone! 🎉';
  }

  @override
  String get xpMilestoneClaimButton => 'Claim';

  @override
  String get xpMilestoneLockedLabel => 'Locked';

  @override
  String get xpMilestoneUnlockedLabel => 'Tap to claim!';

  @override
  String get xpMilestoneClaimedLabel => 'Claimed';

  @override
  String get xpShareTitle => 'Share your progress';

  @override
  String get xpShareLoadError => 'Couldn\'t load data';

  @override
  String get xpShareSaveSuccess => 'Saved to gallery';

  @override
  String get xpShareSaveError => 'Couldn\'t save image';

  @override
  String get xpShareShareError => 'Couldn\'t share card';

  @override
  String get xpShareCaptionBeast => 'XP Beast! 🔥';

  @override
  String get xpShareCaptionSummit => 'On top! 💪';

  @override
  String get xpShareCaptionGreat => 'Great job! 🎯';

  @override
  String get xpShareCaptionKeepGoing => 'Keep going! 🚀';

  @override
  String get xpShareCaptionLetsGo => 'Let\'s go! ⚡';

  @override
  String get xpShareCaptionGettingStarted => 'Just getting started! 🌟';

  @override
  String get xpShareStreakLabel => 'Streak';

  @override
  String get xpShareMilestonesLabel => 'Milestones';

  @override
  String get xpShareGeneratedFooter => 'Generated in Poker Analyzer';

  @override
  String get xpShareSaveButton => 'Save';

  @override
  String get xpShareShareButton => 'Share';

  @override
  String xpShareShareText(int xp, Object streak, int rank) {
    return 'My Poker Analyzer progress!\\n\\nXP: $xp\\nStreak: $streak\\nLeague position: #$rank';
  }

  @override
  String get xpShareLeagueGold => 'Gold League';

  @override
  String get xpShareLeagueSilver => 'Silver League';

  @override
  String get xpShareLeagueBronze => 'Bronze League';

  @override
  String get xpShareLeagueRookie => 'Rookie League';

  @override
  String get xpLeagueDefaultName => 'Silver League';

  @override
  String xpLeagueWeekSubtitle(int week, Object date) {
    return 'Week $week • Resets: $date';
  }

  @override
  String get xpLeagueYourRank => 'Your rank';

  @override
  String get xpLeagueYourXp => 'Your XP';

  @override
  String get xpLeaguePromotionZone => 'Promotion zone (1-10)';

  @override
  String get xpLeagueSafeZone => 'Safe zone (11-40)';

  @override
  String get xpLeagueDemotionZone => 'Relegation zone (41-50)';

  @override
  String get xpHistoryAchievementsTitle => 'Achievement history';

  @override
  String get xpHistoryEmptyTitle => 'No achievements yet';

  @override
  String get xpHistoryEmptyMessage =>
      'Keep training and earning XP to unlock more achievements!';

  @override
  String get xpHistoryStreaksSection => 'Streaks';

  @override
  String get xpHistoryMilestonesSection => 'XP milestones';

  @override
  String xpHistoryStreakLabel(Object value) {
    return 'Streak $value';
  }

  @override
  String xpProfileStreakSummary(Object current, Object best) {
    return '🔥 Streak: $current (Best: $best)';
  }

  @override
  String get xpProfileNoStreak => 'No current streak';

  @override
  String xpWeeklyProgressLabel(int current, int goal) {
    return 'Weekly progress: $current / $goal XP';
  }

  @override
  String get xpWeeklyGoalComplete => 'Goal completed!';

  @override
  String xpDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get xpRecapTitle => 'XP Overview';

  @override
  String get xpRecapRecentEventsTitle => 'Recent events';

  @override
  String get xpRecapNoRecentEvents => 'No recent events';

  @override
  String get xpRecapWeeklyGoalTitle => 'Weekly goal';

  @override
  String get xpRecapMilestonesTitle => 'Milestones';

  @override
  String xpRecapNextMilestone(int xp) {
    return 'To next milestone: $xp XP';
  }

  @override
  String xpRecapMilestoneAvailable(int xp) {
    return 'Milestone available: $xp XP — tap to claim';
  }

  @override
  String xpRecapNextMilestoneLabel(int xp) {
    return 'Next milestone: $xp XP';
  }

  @override
  String xpRecapRemainingXp(int xp) {
    return 'Remaining: $xp XP';
  }

  @override
  String get xpRecapAllMilestonesAchieved => 'All milestones achieved';

  @override
  String get xpRecapTabSummary => 'Summary';

  @override
  String get xpRecapTabHistory => 'History';

  @override
  String get xpRecapTabGoals => 'Goals';

  @override
  String get xpExportTitle => 'XP Recap Export Settings';

  @override
  String get xpExportMethodSave => 'Save';

  @override
  String get xpExportMethodShare => 'Share';

  @override
  String get xpExportMethodLabel => 'Method';

  @override
  String get xpExportCaptionLabel => 'Caption';

  @override
  String get rewardShopTitle => 'Reward Shop';

  @override
  String get rewardShopBalanceLabel => 'Chip Balance';

  @override
  String rewardShopChipCount(Object count) {
    return '$count chips';
  }

  @override
  String get rewardShopRefresh => 'Refresh';

  @override
  String get rewardShopConfirmTitle => 'Confirm Purchase';

  @override
  String rewardShopConfirmBody(Object cost, Object name) {
    return 'Spend $cost chips for $name?';
  }

  @override
  String get rewardShopCancel => 'Cancel';

  @override
  String get rewardShopPurchase => 'Purchase';

  @override
  String rewardShopUnlocked(Object name) {
    return '$name unlocked!';
  }

  @override
  String rewardShopInsufficient(Object name) {
    return 'Not enough chips for $name.';
  }

  @override
  String get feedbackExportDiagnostics => 'Export diagnostics file';

  @override
  String get feedbackExportSuccess => 'Diagnostics exported';

  @override
  String get feedbackExportFailure => 'Failed to export diagnostics';

  @override
  String get settingsReportProblemTitle => 'Report a problem';

  @override
  String get settingsReportProblemSubtitle => 'Share diagnostics with support';

  @override
  String get feedbackSheetTitle => 'Report a problem';

  @override
  String get feedbackSheetSubtitle => 'Copy diagnostics for support';

  @override
  String get feedbackDiagnosticsHeader => 'Diagnostics payload';

  @override
  String get feedbackCopyDiagnostics => 'Copy diagnostics to clipboard';

  @override
  String get feedbackCopySuccess => 'Diagnostics copied to clipboard';
}

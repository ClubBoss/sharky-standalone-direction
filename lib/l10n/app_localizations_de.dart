// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

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
  String get starter_packs_title => 'Starterpaket';

  @override
  String get starter_packs_subtitle => 'Starte sofort mit dem Training';

  @override
  String get starter_packs_start => 'Starten';

  @override
  String get starter_packs_continue => 'Fortsetzen';

  @override
  String get starter_packs_choose => 'Pack auswählen';

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
  String get unsupportedSpot => 'Nicht unterstützte Hand';

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
  String get cancel => 'Отмена';

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
  String get clear => 'Очистить';

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
  String get sortLabel => 'Sortierung:';

  @override
  String get sortPopular => 'Beliebt zuerst';

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
  String get packOfDay => '🎲 Pack des Tages';

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
    return '$count осталось';
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
  String get quickstartL3 => 'Быстрый старт L3';

  @override
  String get run => 'Запустить';

  @override
  String get openReport => 'Открыть отчет';

  @override
  String get viewLogs => 'Просмотр логов';

  @override
  String get retry => 'Повторить';

  @override
  String get presetWillBeUsed => 'Будет использован пресет';

  @override
  String get reportEmpty => 'Отчет пуст';

  @override
  String get abDiff => 'A/B сравнение';

  @override
  String get export => 'Экспорт';

  @override
  String get weightsPreset => 'Пресет весов';

  @override
  String get weightsJson => 'JSON весов';

  @override
  String get invalidJson => 'Некорректный JSON';

  @override
  String get desktopOnly => 'Nur Desktop';

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
  String get shopInsufficientFunds => 'Недостаточно монет';

  @override
  String shopPurchased(Object name) {
    return 'Куплено: $name';
  }

  @override
  String shopCoinsBalance(Object balance) {
    return 'Монеты: $balance';
  }

  @override
  String shopPrice(Object price) {
    return 'Цена: $price';
  }

  @override
  String get shopAvailableItems => 'Доступные товары';

  @override
  String get shopScreenLabel => 'Экран магазина';

  @override
  String shopYourBalance(Object balance) {
    return 'Ваш баланс: $balance монет';
  }

  @override
  String onboardingStepProgress(Object current, Object total) {
    return 'Шаг $current из $total';
  }

  @override
  String get onboardingCongratulations => 'Поздравляем!';

  @override
  String get onboardingFirstTrainingCompleteWithRepeat =>
      'Вы завершили первую тренировку!\n\nТеперь давайте закрепим материал.';

  @override
  String get onboardingFirstTrainingComplete =>
      'Вы завершили первую тренировку!';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingFinish => 'Завершить';

  @override
  String get onboardingMistakeSystemTitle => 'Система повторения ошибок';

  @override
  String get onboardingHowItWorksTitle => 'Как это работает';

  @override
  String get onboardingHowItWorksDescription =>
      'Когда вы делаете ошибку в раздаче, она автоматически помечается для повторения. Система отслеживает все ваши промахи.';

  @override
  String get onboardingWhenRepeatsTitle => 'Когда повторяются раздачи';

  @override
  String get onboardingWhenRepeatsDescription =>
      'Вы получите эту раздачу снова завтра. Если ошибётесь повторно — через 3 дня. Если решите правильно — она исчезнет из повторений.';

  @override
  String get onboardingWhyNeededTitle => 'Зачем это нужно';

  @override
  String get onboardingWhyNeededDescription =>
      'Повторение — ключ к запоминанию. Возвращаясь к сложным раздачам, вы укрепляете понимание и превращаете слабые места в сильные.';

  @override
  String get onboardingDontWorry =>
      'Не переживайте! Ошибки — это нормально. Главное — учиться на них.';

  @override
  String get onboardingRepeatMistakes => 'Повторить ошибки';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingMistakesReviewed => 'Ошибки проработаны';

  @override
  String get onboardingCompletedMessage =>
      'Вы завершили вводное обучение!\n\nТеперь вы готовы к полноценным тренировкам.';

  @override
  String get onboardingStartTraining => 'Начать тренировки';

  @override
  String get onboardingWelcome => 'Добро пожаловать в Poker Analyzer!';

  @override
  String get onboardingWelcomeSubtitle => 'Изучай покер через готовые раздачи';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get xpTabsTitle => '';

  @override
  String get xpHistoryTab => '';

  @override
  String get xpJournalTab => '';

  @override
  String get xpEvalTab => '';

  @override
  String get xpMilestonesTab => '';

  @override
  String get xpLeagueTab => '';

  @override
  String get xpShareTab => '';

  @override
  String get xpDashboardTitle => '';

  @override
  String get xpDashboardEmptyTitle => '';

  @override
  String get xpDashboardEmptyMessage => '';

  @override
  String get xpDashboardStreakTitle => '';

  @override
  String get xpDashboardStreakTooltip => '';

  @override
  String get xpDashboardCurrentStreakLabel => '';

  @override
  String get xpDashboardNoStreak => '';

  @override
  String get xpDashboardBestStreakLabel => '';

  @override
  String get xpDashboardLast30Days => '';

  @override
  String get xpDashboardTrendsTitle => '';

  @override
  String get xpDashboardTotalXpLabel => '';

  @override
  String get xpDashboardDrillsLabel => '';

  @override
  String get xpDashboardModulesLabel => '';

  @override
  String get xpDashboardTheoryLabel => '';

  @override
  String get xpEventDrillCompleted => '';

  @override
  String get xpEventModuleCompleted => '';

  @override
  String get xpEventTheoryViewed => '';

  @override
  String get xpEventGeneric => '';

  @override
  String xpRelativeTodayAt(Object time) {
    return '';
  }

  @override
  String xpRelativeYesterdayAt(Object time) {
    return '';
  }

  @override
  String xpRelativeWeekdayAt(Object weekday, Object time) {
    return '';
  }

  @override
  String xpRelativeDateTime(Object date, Object time) {
    return '';
  }

  @override
  String get xpDashboardLauncherTitle => '';

  @override
  String get xpDashboardLauncherSubtitle => '';

  @override
  String get xpJournalTitle => '';

  @override
  String get xpJournalEmptyTitle => '';

  @override
  String get xpJournalEmptyMessage => '';

  @override
  String get xpJournalReflectionLabel => '';

  @override
  String get xpJournalReflectionHint => '';

  @override
  String get xpSelfEvalTitle => '';

  @override
  String get xpSelfEvalResetTooltip => '';

  @override
  String get xpSelfEvalResetConfirmation => '';

  @override
  String get xpSelfEvalProgressHeader => '';

  @override
  String xpSelfEvalSkillsCompleted(int completed, int total) {
    return '';
  }

  @override
  String get xpSelfEvalItemPushCall => '';

  @override
  String get xpSelfEvalItemBubblePush => '';

  @override
  String get xpSelfEvalItemIcmAwareness => '';

  @override
  String get xpSelfEvalItemAdjustCharts => '';

  @override
  String get xpSelfEvalItemStackAwareness => '';

  @override
  String get xpSelfEvalItemReviewMistakes => '';

  @override
  String get xpSelfEvalItemDeviateCharts => '';

  @override
  String get xpSelfEvalResetButton => '';

  @override
  String get xpMilestoneTitle => '';

  @override
  String get xpMilestoneHeaderTitle => '';

  @override
  String xpMilestoneTotalXp(int xp) {
    return '';
  }

  @override
  String get xpMilestoneUnlockHint => '';

  @override
  String xpMilestoneClaimedMessage(int xp) {
    return '';
  }

  @override
  String get xpMilestoneClaimButton => '';

  @override
  String get xpMilestoneLockedLabel => '';

  @override
  String get xpMilestoneUnlockedLabel => '';

  @override
  String get xpMilestoneClaimedLabel => '';

  @override
  String get xpShareTitle => '';

  @override
  String get xpShareLoadError => '';

  @override
  String get xpShareSaveSuccess => '';

  @override
  String get xpShareSaveError => '';

  @override
  String get xpShareShareError => '';

  @override
  String get xpShareCaptionBeast => '';

  @override
  String get xpShareCaptionSummit => '';

  @override
  String get xpShareCaptionGreat => '';

  @override
  String get xpShareCaptionKeepGoing => '';

  @override
  String get xpShareCaptionLetsGo => '';

  @override
  String get xpShareCaptionGettingStarted => '';

  @override
  String get xpShareStreakLabel => '';

  @override
  String get xpShareMilestonesLabel => '';

  @override
  String get xpShareGeneratedFooter => '';

  @override
  String get xpShareSaveButton => '';

  @override
  String get xpShareShareButton => '';

  @override
  String xpShareShareText(int xp, Object streak, int rank) {
    return '';
  }

  @override
  String get xpShareLeagueGold => '';

  @override
  String get xpShareLeagueSilver => '';

  @override
  String get xpShareLeagueBronze => '';

  @override
  String get xpShareLeagueRookie => '';

  @override
  String get xpLeagueDefaultName => '';

  @override
  String xpLeagueWeekSubtitle(int week, Object date) {
    return '';
  }

  @override
  String get xpLeagueYourRank => '';

  @override
  String get xpLeagueYourXp => '';

  @override
  String get xpLeaguePromotionZone => '';

  @override
  String get xpLeagueSafeZone => '';

  @override
  String get xpLeagueDemotionZone => '';

  @override
  String get xpHistoryAchievementsTitle => '';

  @override
  String get xpHistoryEmptyTitle => '';

  @override
  String get xpHistoryEmptyMessage => '';

  @override
  String get xpHistoryStreaksSection => '';

  @override
  String get xpHistoryMilestonesSection => '';

  @override
  String xpHistoryStreakLabel(Object value) {
    return '';
  }

  @override
  String xpProfileStreakSummary(Object current, Object best) {
    return '';
  }

  @override
  String get xpProfileNoStreak => '';

  @override
  String xpWeeklyProgressLabel(int current, int goal) {
    return '';
  }

  @override
  String get xpWeeklyGoalComplete => '';

  @override
  String xpDaysCount(int count) {
    return '';
  }

  @override
  String get xpRecapTitle => '';

  @override
  String get xpRecapRecentEventsTitle => '';

  @override
  String get xpRecapNoRecentEvents => '';

  @override
  String get xpRecapWeeklyGoalTitle => '';

  @override
  String get xpRecapMilestonesTitle => '';

  @override
  String xpRecapNextMilestone(int xp) {
    return '';
  }

  @override
  String xpRecapMilestoneAvailable(int xp) {
    return '';
  }

  @override
  String xpRecapNextMilestoneLabel(int xp) {
    return '';
  }

  @override
  String xpRecapRemainingXp(int xp) {
    return '';
  }

  @override
  String get xpRecapAllMilestonesAchieved => '';

  @override
  String get xpRecapTabSummary => 'Сводка';

  @override
  String get xpRecapTabHistory => 'История';

  @override
  String get xpRecapTabGoals => 'Цели';

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
  String get rewardShopTitle => 'Belohnungsshop';

  @override
  String get rewardShopBalanceLabel => 'Chip-Guthaben';

  @override
  String rewardShopChipCount(Object count) {
    return '$count Chips';
  }

  @override
  String get rewardShopRefresh => 'Aktualisieren';

  @override
  String get rewardShopConfirmTitle => 'Kauf bestätigen';

  @override
  String rewardShopConfirmBody(Object cost, Object name) {
    return 'Möchtest du $cost Chips für $name ausgeben?';
  }

  @override
  String get rewardShopCancel => 'Abbrechen';

  @override
  String get rewardShopPurchase => 'Kaufen';

  @override
  String rewardShopUnlocked(Object name) {
    return '$name freigeschaltet!';
  }

  @override
  String rewardShopInsufficient(Object name) {
    return 'Nicht genug Chips für $name.';
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

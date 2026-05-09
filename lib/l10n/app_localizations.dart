import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @favorites.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favorites;

  /// No description provided for @recommended.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендовано'**
  String get recommended;

  /// No description provided for @starterPacks.
  ///
  /// In ru, this message translates to:
  /// **'Стартовые паки'**
  String get starterPacks;

  /// No description provided for @builtInPacks.
  ///
  /// In ru, this message translates to:
  /// **'Встроенные паки'**
  String get builtInPacks;

  /// No description provided for @yourPacks.
  ///
  /// In ru, this message translates to:
  /// **'Ваши паки'**
  String get yourPacks;

  /// No description provided for @recentPacks.
  ///
  /// In ru, this message translates to:
  /// **'Недавняя практика'**
  String get recentPacks;

  /// No description provided for @popularPacks.
  ///
  /// In ru, this message translates to:
  /// **'🔥 Популярное'**
  String get popularPacks;

  /// No description provided for @newPacks.
  ///
  /// In ru, this message translates to:
  /// **'🆕 Новые'**
  String get newPacks;

  /// No description provided for @starterBadge.
  ///
  /// In ru, this message translates to:
  /// **'Стартер'**
  String get starterBadge;

  /// No description provided for @newBadge.
  ///
  /// In ru, this message translates to:
  /// **'Новое'**
  String get newBadge;

  /// No description provided for @masteredBadge.
  ///
  /// In ru, this message translates to:
  /// **'✅ Освоено'**
  String get masteredBadge;

  /// No description provided for @hands.
  ///
  /// In ru, this message translates to:
  /// **'рук'**
  String get hands;

  /// No description provided for @packCatalogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Pack catalog'**
  String get packCatalogTitle;

  /// No description provided for @packCatalogSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Browse curated packs'**
  String get packCatalogSubtitle;

  /// No description provided for @difficultyAdvanced.
  ///
  /// In ru, this message translates to:
  /// **'Advanced'**
  String get difficultyAdvanced;

  /// No description provided for @difficultyIntermediate.
  ///
  /// In ru, this message translates to:
  /// **'Intermediate'**
  String get difficultyIntermediate;

  /// No description provided for @difficultyBeginner.
  ///
  /// In ru, this message translates to:
  /// **'Beginner'**
  String get difficultyBeginner;

  /// No description provided for @packStatusComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Coming soon'**
  String get packStatusComingSoon;

  /// No description provided for @packStatusLocked.
  ///
  /// In ru, this message translates to:
  /// **'Locked'**
  String get packStatusLocked;

  /// No description provided for @startTraining.
  ///
  /// In ru, this message translates to:
  /// **'Начать тренировку'**
  String get startTraining;

  /// No description provided for @lastTrained.
  ///
  /// In ru, this message translates to:
  /// **'Последняя тренировка'**
  String get lastTrained;

  /// No description provided for @needsPractice.
  ///
  /// In ru, this message translates to:
  /// **'Требует практики'**
  String get needsPractice;

  /// No description provided for @reviewMistakes.
  ///
  /// In ru, this message translates to:
  /// **'Разбор ошибок'**
  String get reviewMistakes;

  /// No description provided for @reviewMistakesOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только ошибки'**
  String get reviewMistakesOnly;

  /// No description provided for @percentLabel.
  ///
  /// In ru, this message translates to:
  /// **'{value} %'**
  String percentLabel(Object value);

  /// No description provided for @starter_packs_title.
  ///
  /// In ru, this message translates to:
  /// **'Стартовый пак'**
  String get starter_packs_title;

  /// No description provided for @starter_packs_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Начните тренировку одним нажатием'**
  String get starter_packs_subtitle;

  /// No description provided for @starter_packs_start.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get starter_packs_start;

  /// No description provided for @starter_packs_continue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get starter_packs_continue;

  /// No description provided for @starter_packs_choose.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать пак'**
  String get starter_packs_choose;

  /// No description provided for @accuracySemantics.
  ///
  /// In ru, this message translates to:
  /// **'Точность {value} процентов'**
  String accuracySemantics(Object value);

  /// No description provided for @sortProgress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get sortProgress;

  /// No description provided for @sortNewest.
  ///
  /// In ru, this message translates to:
  /// **'Сначала новые'**
  String get sortNewest;

  /// No description provided for @sortMostHands.
  ///
  /// In ru, this message translates to:
  /// **'Больше всего рук'**
  String get sortMostHands;

  /// No description provided for @sortName.
  ///
  /// In ru, this message translates to:
  /// **'Имя A–Я'**
  String get sortName;

  /// No description provided for @noMistakesLeft.
  ///
  /// In ru, this message translates to:
  /// **'Все ошибки уже исправлены!'**
  String get noMistakesLeft;

  /// No description provided for @filterMistakes.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки'**
  String get filterMistakes;

  /// No description provided for @sortInProgress.
  ///
  /// In ru, this message translates to:
  /// **'В процессе'**
  String get sortInProgress;

  /// No description provided for @packPushFold12.
  ///
  /// In ru, this message translates to:
  /// **'Пуш/Фолд 12ББ (без анте)'**
  String get packPushFold12;

  /// No description provided for @packPushFold15.
  ///
  /// In ru, this message translates to:
  /// **'Пуш/Фолд 15ББ (без анте)'**
  String get packPushFold15;

  /// No description provided for @packPushFold10.
  ///
  /// In ru, this message translates to:
  /// **'Пуш/Фолд 10ББ (без анте)'**
  String get packPushFold10;

  /// No description provided for @packPushFold20.
  ///
  /// In ru, this message translates to:
  /// **'Пуш/Фолд 20ББ (без анте)'**
  String get packPushFold20;

  /// No description provided for @presetBtn10bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 10BB Push/Fold'**
  String get presetBtn10bb;

  /// No description provided for @presetBtn11bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 11BB Push/Fold'**
  String get presetBtn11bb;

  /// No description provided for @presetBtn12bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 12BB Push/Fold'**
  String get presetBtn12bb;

  /// No description provided for @presetBtn13bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 13BB Push/Fold'**
  String get presetBtn13bb;

  /// No description provided for @presetBtn14bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 14BB Push/Fold'**
  String get presetBtn14bb;

  /// No description provided for @presetBtn15bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 15BB Push/Fold'**
  String get presetBtn15bb;

  /// No description provided for @presetBtn16bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 16BB Push/Fold'**
  String get presetBtn16bb;

  /// No description provided for @presetBtn17bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 17BB Push/Fold'**
  String get presetBtn17bb;

  /// No description provided for @presetBtn18bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 18BB Push/Fold'**
  String get presetBtn18bb;

  /// No description provided for @presetBtn19bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 19BB Push/Fold'**
  String get presetBtn19bb;

  /// No description provided for @presetBtn20bb.
  ///
  /// In ru, this message translates to:
  /// **'BTN 20BB Push/Fold'**
  String get presetBtn20bb;

  /// No description provided for @presetSb10bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 10BB Push/Fold'**
  String get presetSb10bb;

  /// No description provided for @presetSb11bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 11BB Push/Fold'**
  String get presetSb11bb;

  /// No description provided for @presetSb12bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 12BB Push/Fold'**
  String get presetSb12bb;

  /// No description provided for @presetSb13bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 13BB Push/Fold'**
  String get presetSb13bb;

  /// No description provided for @presetSb14bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 14BB Push/Fold'**
  String get presetSb14bb;

  /// No description provided for @presetSb15bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 15BB Push/Fold'**
  String get presetSb15bb;

  /// No description provided for @presetSb16bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 16BB Push/Fold'**
  String get presetSb16bb;

  /// No description provided for @presetSb17bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 17BB Push/Fold'**
  String get presetSb17bb;

  /// No description provided for @presetSb18bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 18BB Push/Fold'**
  String get presetSb18bb;

  /// No description provided for @presetSb19bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 19BB Push/Fold'**
  String get presetSb19bb;

  /// No description provided for @presetSb20bb.
  ///
  /// In ru, this message translates to:
  /// **'SB 20BB Push/Fold'**
  String get presetSb20bb;

  /// No description provided for @generateSpots.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать раздачи'**
  String get generateSpots;

  /// No description provided for @noContent.
  ///
  /// In ru, this message translates to:
  /// **'Нет контента'**
  String get noContent;

  /// No description provided for @unsupportedSpot.
  ///
  /// In ru, this message translates to:
  /// **'Неподдерживаемая раздача'**
  String get unsupportedSpot;

  /// No description provided for @startTrainingSessionPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Начать тренировку сейчас?'**
  String get startTrainingSessionPrompt;

  /// No description provided for @trainingSummary.
  ///
  /// In ru, this message translates to:
  /// **'Результаты тренировки'**
  String get trainingSummary;

  /// No description provided for @noMistakes.
  ///
  /// In ru, this message translates to:
  /// **'Ошибок нет'**
  String get noMistakes;

  /// No description provided for @repeatMistakes.
  ///
  /// In ru, this message translates to:
  /// **'Повторить ошибки'**
  String get repeatMistakes;

  /// No description provided for @backToLibrary.
  ///
  /// In ru, this message translates to:
  /// **'Назад в библиотеку'**
  String get backToLibrary;

  /// No description provided for @recommendedPacks.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуемые паки'**
  String get recommendedPacks;

  /// No description provided for @recommendedForYou.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендовано для вас'**
  String get recommendedForYou;

  /// No description provided for @masteredPacks.
  ///
  /// In ru, this message translates to:
  /// **'✅ Вы уже освоили'**
  String get masteredPacks;

  /// No description provided for @dailyGoals.
  ///
  /// In ru, this message translates to:
  /// **'Daily Goals'**
  String get dailyGoals;

  /// No description provided for @sessions.
  ///
  /// In ru, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @accuracyPercent.
  ///
  /// In ru, this message translates to:
  /// **'Accuracy %'**
  String get accuracyPercent;

  /// No description provided for @ev.
  ///
  /// In ru, this message translates to:
  /// **'EV'**
  String get ev;

  /// No description provided for @icm.
  ///
  /// In ru, this message translates to:
  /// **'ICM'**
  String get icm;

  /// No description provided for @spotDetails.
  ///
  /// In ru, this message translates to:
  /// **'Spot Details'**
  String get spotDetails;

  /// No description provided for @heroPosition.
  ///
  /// In ru, this message translates to:
  /// **'Hero position: {pos}'**
  String heroPosition(Object pos);

  /// No description provided for @heroCards.
  ///
  /// In ru, this message translates to:
  /// **'Hero cards: {cards}'**
  String heroCards(Object cards);

  /// No description provided for @boardLabel.
  ///
  /// In ru, this message translates to:
  /// **'Board: {cards}'**
  String boardLabel(Object cards);

  /// No description provided for @yourAction.
  ///
  /// In ru, this message translates to:
  /// **'Your action: {action}'**
  String yourAction(Object action);

  /// No description provided for @evIcm.
  ///
  /// In ru, this message translates to:
  /// **'EV {ev}  ICM {icm}'**
  String evIcm(Object ev, Object icm);

  /// No description provided for @packCreated.
  ///
  /// In ru, this message translates to:
  /// **'Pack \"{name}\" created'**
  String packCreated(Object name);

  /// No description provided for @resetPackPrompt.
  ///
  /// In ru, this message translates to:
  /// **'Reset progress for \'{name}\'?'**
  String resetPackPrompt(Object name);

  /// No description provided for @resetStagePrompt.
  ///
  /// In ru, this message translates to:
  /// **'Reset stage \'{name}\'?'**
  String resetStagePrompt(Object name);

  /// No description provided for @resetStage.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить стадию'**
  String get resetStage;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsResetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Reset Settings'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Are you sure you want to reset all settings to defaults?'**
  String get settingsResetConfirmation;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetSuccess;

  /// No description provided for @settingsResetButton.
  ///
  /// In ru, this message translates to:
  /// **'Reset to Defaults'**
  String get settingsResetButton;

  /// No description provided for @settingsCurrentLanguageLabel.
  ///
  /// In ru, this message translates to:
  /// **'Current Language'**
  String get settingsCurrentLanguageLabel;

  /// No description provided for @languageChangedSnackbar.
  ///
  /// In ru, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedSnackbar(Object language);

  /// No description provided for @languageSelectorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Select Language'**
  String get languageSelectorTitle;

  /// No description provided for @languageSelectorDescription.
  ///
  /// In ru, this message translates to:
  /// **'Choose your preferred language. The app will update instantly.'**
  String get languageSelectorDescription;

  /// No description provided for @settingsLegalEntryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Legal & Compliance'**
  String get settingsLegalEntryTitle;

  /// No description provided for @settingsLegalEntrySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Privacy, terms, and data controls'**
  String get settingsLegalEntrySubtitle;

  /// No description provided for @legalScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Legal & Compliance'**
  String get legalScreenTitle;

  /// No description provided for @legalPoliciesSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Policies'**
  String get legalPoliciesSectionTitle;

  /// No description provided for @legalDataSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Data'**
  String get legalDataSectionTitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'View how we handle player data'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfUse.
  ///
  /// In ru, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @termsOfUseSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Read the governing terms'**
  String get termsOfUseSubtitle;

  /// No description provided for @legalDeleteDataTitle.
  ///
  /// In ru, this message translates to:
  /// **'Delete Data / Account'**
  String get legalDeleteDataTitle;

  /// No description provided for @legalDeleteDataSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Wipe local learning progress, snapshots, and session history'**
  String get legalDeleteDataSubtitle;

  /// No description provided for @legalDeleteConfirmationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Delete local data?'**
  String get legalDeleteConfirmationTitle;

  /// No description provided for @legalDeleteConfirmationBody.
  ///
  /// In ru, this message translates to:
  /// **'This will remove learning progress, snapshots, and session fingerprints from this device. This cannot be undone.'**
  String get legalDeleteConfirmationBody;

  /// No description provided for @legalDeleteSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Local data cleared'**
  String get legalDeleteSuccess;

  /// No description provided for @legalDeleteFailure.
  ///
  /// In ru, this message translates to:
  /// **'Failed to clear local data'**
  String get legalDeleteFailure;

  /// No description provided for @playerType.
  ///
  /// In ru, this message translates to:
  /// **'Player Type'**
  String get playerType;

  /// No description provided for @selectAction.
  ///
  /// In ru, this message translates to:
  /// **'Select Action'**
  String get selectAction;

  /// No description provided for @fold.
  ///
  /// In ru, this message translates to:
  /// **'Fold'**
  String get fold;

  /// No description provided for @call.
  ///
  /// In ru, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @raise.
  ///
  /// In ru, this message translates to:
  /// **'Raise'**
  String get raise;

  /// No description provided for @push.
  ///
  /// In ru, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @amount.
  ///
  /// In ru, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @confirm.
  ///
  /// In ru, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @clear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clear;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @entrants.
  ///
  /// In ru, this message translates to:
  /// **'Entrants'**
  String get entrants;

  /// No description provided for @gameType.
  ///
  /// In ru, this message translates to:
  /// **'Game Type'**
  String get gameType;

  /// No description provided for @holdemNl.
  ///
  /// In ru, this message translates to:
  /// **'Hold\'em NL'**
  String get holdemNl;

  /// No description provided for @omahaPl.
  ///
  /// In ru, this message translates to:
  /// **'Omaha PL'**
  String get omahaPl;

  /// No description provided for @otherGameType.
  ///
  /// In ru, this message translates to:
  /// **'Other'**
  String get otherGameType;

  /// No description provided for @spotsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Spots: {value}'**
  String spotsLabel(Object value);

  /// No description provided for @accuracyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Accuracy: {value}%'**
  String accuracyLabel(Object value);

  /// No description provided for @evBb.
  ///
  /// In ru, this message translates to:
  /// **'EV: {value} BB'**
  String evBb(Object value);

  /// No description provided for @icmLabel.
  ///
  /// In ru, this message translates to:
  /// **'ICM: {value}'**
  String icmLabel(Object value);

  /// No description provided for @exportWeaknessReport.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировать отчёт о слабых местах'**
  String get exportWeaknessReport;

  /// No description provided for @packsShown.
  ///
  /// In ru, this message translates to:
  /// **'Показано {count} паков'**
  String packsShown(Object count);

  /// No description provided for @noResults.
  ///
  /// In ru, this message translates to:
  /// **'Нет результатов'**
  String get noResults;

  /// No description provided for @resetFilters.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get resetFilters;

  /// No description provided for @sortLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка:'**
  String get sortLabel;

  /// No description provided for @sortPopular.
  ///
  /// In ru, this message translates to:
  /// **'Сначала популярные'**
  String get sortPopular;

  /// No description provided for @sortRating.
  ///
  /// In ru, this message translates to:
  /// **'Rating (High → Low)'**
  String get sortRating;

  /// No description provided for @sortCoverage.
  ///
  /// In ru, this message translates to:
  /// **'Coverage (High → Low)'**
  String get sortCoverage;

  /// No description provided for @filtersSelected.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры: {count} выбрано'**
  String filtersSelected(Object count);

  /// No description provided for @filtersNone.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры: нет'**
  String get filtersNone;

  /// No description provided for @progress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get progress;

  /// No description provided for @packsCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Паков завершено'**
  String get packsCompleted;

  /// No description provided for @averageAccuracy.
  ///
  /// In ru, this message translates to:
  /// **'Средняя точность'**
  String get averageAccuracy;

  /// No description provided for @averageEv.
  ///
  /// In ru, this message translates to:
  /// **'Средний EV'**
  String get averageEv;

  /// No description provided for @dailyStreak.
  ///
  /// In ru, this message translates to:
  /// **'Стрик'**
  String get dailyStreak;

  /// No description provided for @best.
  ///
  /// In ru, this message translates to:
  /// **'Рекорд'**
  String get best;

  /// No description provided for @pinnedPacks.
  ///
  /// In ru, this message translates to:
  /// **'📌 Избранные шаблоны'**
  String get pinnedPacks;

  /// No description provided for @weakAreas.
  ///
  /// In ru, this message translates to:
  /// **'Избранные категории'**
  String get weakAreas;

  /// No description provided for @packOfDay.
  ///
  /// In ru, this message translates to:
  /// **'🎲 Пак дня'**
  String get packOfDay;

  /// No description provided for @streakChipLabel.
  ///
  /// In ru, this message translates to:
  /// **'Streak: {count}'**
  String streakChipLabel(Object count);

  /// No description provided for @dailyHandLabel.
  ///
  /// In ru, this message translates to:
  /// **'Daily Hand #{index}'**
  String dailyHandLabel(Object index);

  /// No description provided for @levelGoalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Цель уровня'**
  String get levelGoalTitle;

  /// No description provided for @samplePreviewHint.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте сначала образец пака'**
  String get samplePreviewHint;

  /// No description provided for @samplePreviewPrompt.
  ///
  /// In ru, this message translates to:
  /// **'This pack is large. Preview a quick sample first?'**
  String get samplePreviewPrompt;

  /// No description provided for @previewSample.
  ///
  /// In ru, this message translates to:
  /// **'Preview Sample'**
  String get previewSample;

  /// No description provided for @autoSampleToast.
  ///
  /// In ru, this message translates to:
  /// **'Quick preview launched automatically for faster start.'**
  String get autoSampleToast;

  /// No description provided for @plannerBadge.
  ///
  /// In ru, this message translates to:
  /// **'{count} осталось'**
  String plannerBadge(Object count);

  /// No description provided for @unfinishedSession.
  ///
  /// In ru, this message translates to:
  /// **'У вас есть незавершённая сессия'**
  String get unfinishedSession;

  /// No description provided for @resume.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get resume;

  /// No description provided for @mistakeBoosterReinforced.
  ///
  /// In ru, this message translates to:
  /// **'Укреплено тегов: {count}'**
  String mistakeBoosterReinforced(Object count);

  /// No description provided for @mistakeBoosterRecovered.
  ///
  /// In ru, this message translates to:
  /// **'Исправлено тегов: {count}'**
  String mistakeBoosterRecovered(Object count);

  /// No description provided for @quickstartL3.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый старт L3'**
  String get quickstartL3;

  /// No description provided for @run.
  ///
  /// In ru, this message translates to:
  /// **'Запустить'**
  String get run;

  /// No description provided for @openReport.
  ///
  /// In ru, this message translates to:
  /// **'Открыть отчет'**
  String get openReport;

  /// No description provided for @viewLogs.
  ///
  /// In ru, this message translates to:
  /// **'Просмотр логов'**
  String get viewLogs;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @presetWillBeUsed.
  ///
  /// In ru, this message translates to:
  /// **'Будет использован пресет'**
  String get presetWillBeUsed;

  /// No description provided for @reportEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Отчет пуст'**
  String get reportEmpty;

  /// No description provided for @abDiff.
  ///
  /// In ru, this message translates to:
  /// **'A/B сравнение'**
  String get abDiff;

  /// No description provided for @export.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get export;

  /// No description provided for @weightsPreset.
  ///
  /// In ru, this message translates to:
  /// **'Пресет весов'**
  String get weightsPreset;

  /// No description provided for @weightsJson.
  ///
  /// In ru, this message translates to:
  /// **'JSON весов'**
  String get weightsJson;

  /// No description provided for @invalidJson.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный JSON'**
  String get invalidJson;

  /// No description provided for @desktopOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только на компьютере'**
  String get desktopOnly;

  /// No description provided for @recentRuns.
  ///
  /// In ru, this message translates to:
  /// **'Последние запуски'**
  String get recentRuns;

  /// No description provided for @open.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get open;

  /// No description provided for @logs.
  ///
  /// In ru, this message translates to:
  /// **'Логи'**
  String get logs;

  /// No description provided for @folder.
  ///
  /// In ru, this message translates to:
  /// **'Папка'**
  String get folder;

  /// No description provided for @copyPath.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать путь'**
  String get copyPath;

  /// No description provided for @reRun.
  ///
  /// In ru, this message translates to:
  /// **'Запустить снова'**
  String get reRun;

  /// No description provided for @pickTwoRuns.
  ///
  /// In ru, this message translates to:
  /// **'Выберите два запуска'**
  String get pickTwoRuns;

  /// No description provided for @compare.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить'**
  String get compare;

  /// No description provided for @noSelection.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не выбрано'**
  String get noSelection;

  /// No description provided for @rootKeys.
  ///
  /// In ru, this message translates to:
  /// **'Корневые ключи'**
  String get rootKeys;

  /// No description provided for @arrayLengths.
  ///
  /// In ru, this message translates to:
  /// **'Длины массивов'**
  String get arrayLengths;

  /// No description provided for @clearHistory.
  ///
  /// In ru, this message translates to:
  /// **'Очистить историю'**
  String get clearHistory;

  /// No description provided for @confirmClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить все запуски? Это действие нельзя отменить.'**
  String get confirmClear;

  /// No description provided for @deleted.
  ///
  /// In ru, this message translates to:
  /// **'Удалено'**
  String get deleted;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @exportCsv.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт CSV'**
  String get exportCsv;

  /// No description provided for @reveal.
  ///
  /// In ru, this message translates to:
  /// **'Показать в папке'**
  String get reveal;

  /// No description provided for @csvSaved.
  ///
  /// In ru, this message translates to:
  /// **'CSV сохранён'**
  String get csvSaved;

  /// No description provided for @delta.
  ///
  /// In ru, this message translates to:
  /// **'Δ'**
  String get delta;

  /// No description provided for @args.
  ///
  /// In ru, this message translates to:
  /// **'Аргументы'**
  String get args;

  /// No description provided for @shopInsufficientFunds.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно монет'**
  String get shopInsufficientFunds;

  /// No description provided for @shopPurchased.
  ///
  /// In ru, this message translates to:
  /// **'Куплено: {name}'**
  String shopPurchased(Object name);

  /// No description provided for @shopCoinsBalance.
  ///
  /// In ru, this message translates to:
  /// **'Монеты: {balance}'**
  String shopCoinsBalance(Object balance);

  /// No description provided for @shopPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена: {price}'**
  String shopPrice(Object price);

  /// No description provided for @shopAvailableItems.
  ///
  /// In ru, this message translates to:
  /// **'Доступные товары'**
  String get shopAvailableItems;

  /// No description provided for @shopScreenLabel.
  ///
  /// In ru, this message translates to:
  /// **'Экран магазина'**
  String get shopScreenLabel;

  /// No description provided for @shopYourBalance.
  ///
  /// In ru, this message translates to:
  /// **'Ваш баланс: {balance} монет'**
  String shopYourBalance(Object balance);

  /// No description provided for @onboardingStepProgress.
  ///
  /// In ru, this message translates to:
  /// **'Шаг {current} из {total}'**
  String onboardingStepProgress(Object current, Object total);

  /// No description provided for @onboardingCongratulations.
  ///
  /// In ru, this message translates to:
  /// **'Поздравляем!'**
  String get onboardingCongratulations;

  /// No description provided for @onboardingFirstTrainingCompleteWithRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Вы завершили первую тренировку!\n\nТеперь давайте закрепим материал.'**
  String get onboardingFirstTrainingCompleteWithRepeat;

  /// No description provided for @onboardingFirstTrainingComplete.
  ///
  /// In ru, this message translates to:
  /// **'Вы завершили первую тренировку!'**
  String get onboardingFirstTrainingComplete;

  /// No description provided for @onboardingContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get onboardingContinue;

  /// No description provided for @onboardingFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить'**
  String get onboardingFinish;

  /// No description provided for @onboardingMistakeSystemTitle.
  ///
  /// In ru, this message translates to:
  /// **'Система повторения ошибок'**
  String get onboardingMistakeSystemTitle;

  /// No description provided for @onboardingHowItWorksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как это работает'**
  String get onboardingHowItWorksTitle;

  /// No description provided for @onboardingHowItWorksDescription.
  ///
  /// In ru, this message translates to:
  /// **'Когда вы делаете ошибку в раздаче, она автоматически помечается для повторения. Система отслеживает все ваши промахи.'**
  String get onboardingHowItWorksDescription;

  /// No description provided for @onboardingWhenRepeatsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда повторяются раздачи'**
  String get onboardingWhenRepeatsTitle;

  /// No description provided for @onboardingWhenRepeatsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Вы получите эту раздачу снова завтра. Если ошибётесь повторно — через 3 дня. Если решите правильно — она исчезнет из повторений.'**
  String get onboardingWhenRepeatsDescription;

  /// No description provided for @onboardingWhyNeededTitle.
  ///
  /// In ru, this message translates to:
  /// **'Зачем это нужно'**
  String get onboardingWhyNeededTitle;

  /// No description provided for @onboardingWhyNeededDescription.
  ///
  /// In ru, this message translates to:
  /// **'Повторение — ключ к запоминанию. Возвращаясь к сложным раздачам, вы укрепляете понимание и превращаете слабые места в сильные.'**
  String get onboardingWhyNeededDescription;

  /// No description provided for @onboardingDontWorry.
  ///
  /// In ru, this message translates to:
  /// **'Не переживайте! Ошибки — это нормально. Главное — учиться на них.'**
  String get onboardingDontWorry;

  /// No description provided for @onboardingRepeatMistakes.
  ///
  /// In ru, this message translates to:
  /// **'Повторить ошибки'**
  String get onboardingRepeatMistakes;

  /// No description provided for @onboardingSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get onboardingSkip;

  /// No description provided for @onboardingMistakesReviewed.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки проработаны'**
  String get onboardingMistakesReviewed;

  /// No description provided for @onboardingCompletedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы завершили вводное обучение!\n\nТеперь вы готовы к полноценным тренировкам.'**
  String get onboardingCompletedMessage;

  /// No description provided for @onboardingStartTraining.
  ///
  /// In ru, this message translates to:
  /// **'Начать тренировки'**
  String get onboardingStartTraining;

  /// No description provided for @onboardingWelcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать в Poker Analyzer!'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Изучай покер через готовые раздачи'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get onboardingStart;

  /// No description provided for @xpTabsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get xpTabsTitle;

  /// No description provided for @xpHistoryTab.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get xpHistoryTab;

  /// No description provided for @xpJournalTab.
  ///
  /// In ru, this message translates to:
  /// **'Журнал'**
  String get xpJournalTab;

  /// No description provided for @xpEvalTab.
  ///
  /// In ru, this message translates to:
  /// **'Самооценка'**
  String get xpEvalTab;

  /// No description provided for @xpMilestonesTab.
  ///
  /// In ru, this message translates to:
  /// **'Этапы'**
  String get xpMilestonesTab;

  /// No description provided for @xpLeagueTab.
  ///
  /// In ru, this message translates to:
  /// **'Лига'**
  String get xpLeagueTab;

  /// No description provided for @xpShareTab.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get xpShareTab;

  /// No description provided for @xpDashboardTitle.
  ///
  /// In ru, this message translates to:
  /// **'История XP'**
  String get xpDashboardTitle;

  /// No description provided for @xpDashboardEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет XP'**
  String get xpDashboardEmptyTitle;

  /// No description provided for @xpDashboardEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Выполняйте упражнения, изучайте теорию или завершайте модули\\nчтобы начать зарабатывать XP!'**
  String get xpDashboardEmptyMessage;

  /// No description provided for @xpDashboardStreakTitle.
  ///
  /// In ru, this message translates to:
  /// **'Серия активности'**
  String get xpDashboardStreakTitle;

  /// No description provided for @xpDashboardStreakTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Зарабатывайте XP каждый день, чтобы удерживать серию!'**
  String get xpDashboardStreakTooltip;

  /// No description provided for @xpDashboardCurrentStreakLabel.
  ///
  /// In ru, this message translates to:
  /// **'Текущая'**
  String get xpDashboardCurrentStreakLabel;

  /// No description provided for @xpDashboardNoStreak.
  ///
  /// In ru, this message translates to:
  /// **'Серии пока нет'**
  String get xpDashboardNoStreak;

  /// No description provided for @xpDashboardBestStreakLabel.
  ///
  /// In ru, this message translates to:
  /// **'Лучшая'**
  String get xpDashboardBestStreakLabel;

  /// No description provided for @xpDashboardLast30Days.
  ///
  /// In ru, this message translates to:
  /// **'Последние 30 дней'**
  String get xpDashboardLast30Days;

  /// No description provided for @xpDashboardTrendsTitle.
  ///
  /// In ru, this message translates to:
  /// **'XP-тренды (за 7 дней)'**
  String get xpDashboardTrendsTitle;

  /// No description provided for @xpDashboardTotalXpLabel.
  ///
  /// In ru, this message translates to:
  /// **'Всего XP'**
  String get xpDashboardTotalXpLabel;

  /// No description provided for @xpDashboardDrillsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дриллы'**
  String get xpDashboardDrillsLabel;

  /// No description provided for @xpDashboardModulesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Модули'**
  String get xpDashboardModulesLabel;

  /// No description provided for @xpDashboardTheoryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Теория'**
  String get xpDashboardTheoryLabel;

  /// No description provided for @xpEventDrillCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Дрилл завершён'**
  String get xpEventDrillCompleted;

  /// No description provided for @xpEventModuleCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Модуль завершён'**
  String get xpEventModuleCompleted;

  /// No description provided for @xpEventTheoryViewed.
  ///
  /// In ru, this message translates to:
  /// **'Теория просмотрена'**
  String get xpEventTheoryViewed;

  /// No description provided for @xpEventGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Получено XP'**
  String get xpEventGeneric;

  /// No description provided for @xpRelativeTodayAt.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня в {time}'**
  String xpRelativeTodayAt(Object time);

  /// No description provided for @xpRelativeYesterdayAt.
  ///
  /// In ru, this message translates to:
  /// **'Вчера в {time}'**
  String xpRelativeYesterdayAt(Object time);

  /// No description provided for @xpRelativeWeekdayAt.
  ///
  /// In ru, this message translates to:
  /// **'{weekday} в {time}'**
  String xpRelativeWeekdayAt(Object weekday, Object time);

  /// No description provided for @xpRelativeDateTime.
  ///
  /// In ru, this message translates to:
  /// **'{date} • {time}'**
  String xpRelativeDateTime(Object date, Object time);

  /// No description provided for @xpDashboardLauncherTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш прогресс'**
  String get xpDashboardLauncherTitle;

  /// No description provided for @xpDashboardLauncherSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'XP, история, самооценка'**
  String get xpDashboardLauncherSubtitle;

  /// No description provided for @xpJournalTitle.
  ///
  /// In ru, this message translates to:
  /// **'XP-журнал'**
  String get xpJournalTitle;

  /// No description provided for @xpJournalEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'XP-событий пока нет'**
  String get xpJournalEmptyTitle;

  /// No description provided for @xpJournalEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Выполните активность, чтобы добавить запись'**
  String get xpJournalEmptyMessage;

  /// No description provided for @xpJournalReflectionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Рефлексия'**
  String get xpJournalReflectionLabel;

  /// No description provided for @xpJournalReflectionHint.
  ///
  /// In ru, this message translates to:
  /// **'Что вы узнали? Что можно улучшить?'**
  String get xpJournalReflectionHint;

  /// No description provided for @xpSelfEvalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Самооценка'**
  String get xpSelfEvalTitle;

  /// No description provided for @xpSelfEvalResetTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить всё'**
  String get xpSelfEvalResetTooltip;

  /// No description provided for @xpSelfEvalResetConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Чеклист сброшен'**
  String get xpSelfEvalResetConfirmation;

  /// No description provided for @xpSelfEvalProgressHeader.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get xpSelfEvalProgressHeader;

  /// No description provided for @xpSelfEvalSkillsCompleted.
  ///
  /// In ru, this message translates to:
  /// **'{completed} из {total} навыков освоено'**
  String xpSelfEvalSkillsCompleted(int completed, int total);

  /// No description provided for @xpSelfEvalItemPushCall.
  ///
  /// In ru, this message translates to:
  /// **'Я уверенно пушу и каллирую по чартам в SRP'**
  String get xpSelfEvalItemPushCall;

  /// No description provided for @xpSelfEvalItemBubblePush.
  ///
  /// In ru, this message translates to:
  /// **'Я понимаю диапазоны пуша на бабле'**
  String get xpSelfEvalItemBubblePush;

  /// No description provided for @xpSelfEvalItemIcmAwareness.
  ///
  /// In ru, this message translates to:
  /// **'Я различаю ICM-споты и ChipEV-споты'**
  String get xpSelfEvalItemIcmAwareness;

  /// No description provided for @xpSelfEvalItemAdjustCharts.
  ///
  /// In ru, this message translates to:
  /// **'Я корректно адаптирую чарты под структуру турнира'**
  String get xpSelfEvalItemAdjustCharts;

  /// No description provided for @xpSelfEvalItemStackAwareness.
  ///
  /// In ru, this message translates to:
  /// **'Я учитываю стек оппонентов при принятии решений'**
  String get xpSelfEvalItemStackAwareness;

  /// No description provided for @xpSelfEvalItemReviewMistakes.
  ///
  /// In ru, this message translates to:
  /// **'Я анализирую свои ошибки после каждой сессии'**
  String get xpSelfEvalItemReviewMistakes;

  /// No description provided for @xpSelfEvalItemDeviateCharts.
  ///
  /// In ru, this message translates to:
  /// **'Я понимаю, когда девиировать от базовых чартов'**
  String get xpSelfEvalItemDeviateCharts;

  /// No description provided for @xpSelfEvalResetButton.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить чеклист'**
  String get xpSelfEvalResetButton;

  /// No description provided for @xpMilestoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'XP-этапы'**
  String get xpMilestoneTitle;

  /// No description provided for @xpMilestoneHeaderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш XP-прогресс'**
  String get xpMilestoneHeaderTitle;

  /// No description provided for @xpMilestoneTotalXp.
  ///
  /// In ru, this message translates to:
  /// **'Всего XP: {xp}'**
  String xpMilestoneTotalXp(int xp);

  /// No description provided for @xpMilestoneUnlockHint.
  ///
  /// In ru, this message translates to:
  /// **'Зарабатывайте XP в дриллах, модулях и теории, чтобы открывать этапы!'**
  String get xpMilestoneUnlockHint;

  /// No description provided for @xpMilestoneClaimedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Получен этап {xp} XP! 🎉'**
  String xpMilestoneClaimedMessage(int xp);

  /// No description provided for @xpMilestoneClaimButton.
  ///
  /// In ru, this message translates to:
  /// **'Забрать'**
  String get xpMilestoneClaimButton;

  /// No description provided for @xpMilestoneLockedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Закрыто'**
  String get xpMilestoneLockedLabel;

  /// No description provided for @xpMilestoneUnlockedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите, чтобы забрать'**
  String get xpMilestoneUnlockedLabel;

  /// No description provided for @xpMilestoneClaimedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Забрано'**
  String get xpMilestoneClaimedLabel;

  /// No description provided for @xpShareTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться успехами'**
  String get xpShareTitle;

  /// No description provided for @xpShareLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные'**
  String get xpShareLoadError;

  /// No description provided for @xpShareSaveSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено в галерею'**
  String get xpShareSaveSuccess;

  /// No description provided for @xpShareSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить изображение'**
  String get xpShareSaveError;

  /// No description provided for @xpShareShareError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось поделиться'**
  String get xpShareShareError;

  /// No description provided for @xpShareCaptionBeast.
  ///
  /// In ru, this message translates to:
  /// **'XP-монстр! 🔥'**
  String get xpShareCaptionBeast;

  /// No description provided for @xpShareCaptionSummit.
  ///
  /// In ru, this message translates to:
  /// **'На вершине! 💪'**
  String get xpShareCaptionSummit;

  /// No description provided for @xpShareCaptionGreat.
  ///
  /// In ru, this message translates to:
  /// **'Отлично! 🎯'**
  String get xpShareCaptionGreat;

  /// No description provided for @xpShareCaptionKeepGoing.
  ///
  /// In ru, this message translates to:
  /// **'Продолжай! 🚀'**
  String get xpShareCaptionKeepGoing;

  /// No description provided for @xpShareCaptionLetsGo.
  ///
  /// In ru, this message translates to:
  /// **'Вперёд! ⚡'**
  String get xpShareCaptionLetsGo;

  /// No description provided for @xpShareCaptionGettingStarted.
  ///
  /// In ru, this message translates to:
  /// **'Начало пути! 🌟'**
  String get xpShareCaptionGettingStarted;

  /// No description provided for @xpShareStreakLabel.
  ///
  /// In ru, this message translates to:
  /// **'Серия'**
  String get xpShareStreakLabel;

  /// No description provided for @xpShareMilestonesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Этапы'**
  String get xpShareMilestonesLabel;

  /// No description provided for @xpShareGeneratedFooter.
  ///
  /// In ru, this message translates to:
  /// **'Создано в Poker Analyzer'**
  String get xpShareGeneratedFooter;

  /// No description provided for @xpShareSaveButton.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get xpShareSaveButton;

  /// No description provided for @xpShareShareButton.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get xpShareShareButton;

  /// No description provided for @xpShareShareText.
  ///
  /// In ru, this message translates to:
  /// **'Мой прогресс в Poker Analyzer!\\n\\nXP: {xp}\\nСерия: {streak}\\nПозиция в лиге: #{rank}'**
  String xpShareShareText(int xp, Object streak, int rank);

  /// No description provided for @xpShareLeagueGold.
  ///
  /// In ru, this message translates to:
  /// **'Золотая лига'**
  String get xpShareLeagueGold;

  /// No description provided for @xpShareLeagueSilver.
  ///
  /// In ru, this message translates to:
  /// **'Серебряная лига'**
  String get xpShareLeagueSilver;

  /// No description provided for @xpShareLeagueBronze.
  ///
  /// In ru, this message translates to:
  /// **'Бронзовая лига'**
  String get xpShareLeagueBronze;

  /// No description provided for @xpShareLeagueRookie.
  ///
  /// In ru, this message translates to:
  /// **'Лига новичков'**
  String get xpShareLeagueRookie;

  /// No description provided for @xpLeagueDefaultName.
  ///
  /// In ru, this message translates to:
  /// **'Серебряная лига'**
  String get xpLeagueDefaultName;

  /// No description provided for @xpLeagueWeekSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Неделя {week} • Обновление: {date}'**
  String xpLeagueWeekSubtitle(int week, Object date);

  /// No description provided for @xpLeagueYourRank.
  ///
  /// In ru, this message translates to:
  /// **'Ваша позиция'**
  String get xpLeagueYourRank;

  /// No description provided for @xpLeagueYourXp.
  ///
  /// In ru, this message translates to:
  /// **'Ваш XP'**
  String get xpLeagueYourXp;

  /// No description provided for @xpLeaguePromotionZone.
  ///
  /// In ru, this message translates to:
  /// **'Зона повышения (1-10)'**
  String get xpLeaguePromotionZone;

  /// No description provided for @xpLeagueSafeZone.
  ///
  /// In ru, this message translates to:
  /// **'Безопасная зона (11-40)'**
  String get xpLeagueSafeZone;

  /// No description provided for @xpLeagueDemotionZone.
  ///
  /// In ru, this message translates to:
  /// **'Зона понижения (41-50)'**
  String get xpLeagueDemotionZone;

  /// No description provided for @xpHistoryAchievementsTitle.
  ///
  /// In ru, this message translates to:
  /// **'История достижений'**
  String get xpHistoryAchievementsTitle;

  /// No description provided for @xpHistoryEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет достижений'**
  String get xpHistoryEmptyTitle;

  /// No description provided for @xpHistoryEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Продолжайте тренироваться и зарабатывать XP, чтобы открыть новые достижения!'**
  String get xpHistoryEmptyMessage;

  /// No description provided for @xpHistoryStreaksSection.
  ///
  /// In ru, this message translates to:
  /// **'Серии'**
  String get xpHistoryStreaksSection;

  /// No description provided for @xpHistoryMilestonesSection.
  ///
  /// In ru, this message translates to:
  /// **'XP-этапы'**
  String get xpHistoryMilestonesSection;

  /// No description provided for @xpHistoryStreakLabel.
  ///
  /// In ru, this message translates to:
  /// **'Серия {value}'**
  String xpHistoryStreakLabel(Object value);

  /// No description provided for @xpProfileStreakSummary.
  ///
  /// In ru, this message translates to:
  /// **'🔥 Серия: {current} (Рекорд: {best})'**
  String xpProfileStreakSummary(Object current, Object best);

  /// No description provided for @xpProfileNoStreak.
  ///
  /// In ru, this message translates to:
  /// **'Нет текущей серии'**
  String get xpProfileNoStreak;

  /// No description provided for @xpWeeklyProgressLabel.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс недели: {current} / {goal} XP'**
  String xpWeeklyProgressLabel(int current, int goal);

  /// No description provided for @xpWeeklyGoalComplete.
  ///
  /// In ru, this message translates to:
  /// **'Цель достигнута!'**
  String get xpWeeklyGoalComplete;

  /// No description provided for @xpDaysCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one {{count} день} few {{count} дня} many {{count} дней} other {{count} дня}}'**
  String xpDaysCount(int count);

  /// No description provided for @xpRecapTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обзор XP'**
  String get xpRecapTitle;

  /// No description provided for @xpRecapRecentEventsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Последние события'**
  String get xpRecapRecentEventsTitle;

  /// No description provided for @xpRecapNoRecentEvents.
  ///
  /// In ru, this message translates to:
  /// **'Нет последних событий'**
  String get xpRecapNoRecentEvents;

  /// No description provided for @xpRecapWeeklyGoalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Цель недели'**
  String get xpRecapWeeklyGoalTitle;

  /// No description provided for @xpRecapMilestonesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Этапы'**
  String get xpRecapMilestonesTitle;

  /// No description provided for @xpRecapNextMilestone.
  ///
  /// In ru, this message translates to:
  /// **'До следующего этапа: {xp} XP'**
  String xpRecapNextMilestone(int xp);

  /// No description provided for @xpRecapMilestoneAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступен этап: {xp} XP — можно забрать'**
  String xpRecapMilestoneAvailable(int xp);

  /// No description provided for @xpRecapNextMilestoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Следующий этап: {xp} XP'**
  String xpRecapNextMilestoneLabel(int xp);

  /// No description provided for @xpRecapRemainingXp.
  ///
  /// In ru, this message translates to:
  /// **'Осталось: {xp} XP'**
  String xpRecapRemainingXp(int xp);

  /// No description provided for @xpRecapAllMilestonesAchieved.
  ///
  /// In ru, this message translates to:
  /// **'Все этапы достигнуты'**
  String get xpRecapAllMilestonesAchieved;

  /// No description provided for @xpRecapTabSummary.
  ///
  /// In ru, this message translates to:
  /// **'Сводка'**
  String get xpRecapTabSummary;

  /// No description provided for @xpRecapTabHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get xpRecapTabHistory;

  /// No description provided for @xpRecapTabGoals.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get xpRecapTabGoals;

  /// No description provided for @xpExportTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки экспорта XP'**
  String get xpExportTitle;

  /// No description provided for @xpExportMethodSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get xpExportMethodSave;

  /// No description provided for @xpExportMethodShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get xpExportMethodShare;

  /// No description provided for @xpExportMethodLabel.
  ///
  /// In ru, this message translates to:
  /// **'Метод'**
  String get xpExportMethodLabel;

  /// No description provided for @xpExportCaptionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Подпись'**
  String get xpExportCaptionLabel;

  /// No description provided for @rewardShopTitle.
  ///
  /// In ru, this message translates to:
  /// **'Магазин наград'**
  String get rewardShopTitle;

  /// No description provided for @rewardShopBalanceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Баланс фишек'**
  String get rewardShopBalanceLabel;

  /// No description provided for @rewardShopChipCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} фишек'**
  String rewardShopChipCount(Object count);

  /// No description provided for @rewardShopRefresh.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get rewardShopRefresh;

  /// No description provided for @rewardShopConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение покупки'**
  String get rewardShopConfirmTitle;

  /// No description provided for @rewardShopConfirmBody.
  ///
  /// In ru, this message translates to:
  /// **'Потратить {cost} фишек на {name}?'**
  String rewardShopConfirmBody(Object cost, Object name);

  /// No description provided for @rewardShopCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get rewardShopCancel;

  /// No description provided for @rewardShopPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Купить'**
  String get rewardShopPurchase;

  /// No description provided for @rewardShopUnlocked.
  ///
  /// In ru, this message translates to:
  /// **'{name} разблокирован!'**
  String rewardShopUnlocked(Object name);

  /// No description provided for @rewardShopInsufficient.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно фишек для {name}.'**
  String rewardShopInsufficient(Object name);

  /// No description provided for @feedbackExportDiagnostics.
  ///
  /// In ru, this message translates to:
  /// **'Export diagnostics file'**
  String get feedbackExportDiagnostics;

  /// No description provided for @feedbackExportSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Diagnostics exported'**
  String get feedbackExportSuccess;

  /// No description provided for @feedbackExportFailure.
  ///
  /// In ru, this message translates to:
  /// **'Failed to export diagnostics'**
  String get feedbackExportFailure;

  /// No description provided for @settingsReportProblemTitle.
  ///
  /// In ru, this message translates to:
  /// **'Report a problem'**
  String get settingsReportProblemTitle;

  /// No description provided for @settingsReportProblemSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Share diagnostics with support'**
  String get settingsReportProblemSubtitle;

  /// No description provided for @feedbackSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Report a problem'**
  String get feedbackSheetTitle;

  /// No description provided for @feedbackSheetSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Copy diagnostics for support'**
  String get feedbackSheetSubtitle;

  /// No description provided for @feedbackDiagnosticsHeader.
  ///
  /// In ru, this message translates to:
  /// **'Diagnostics payload'**
  String get feedbackDiagnosticsHeader;

  /// No description provided for @feedbackCopyDiagnostics.
  ///
  /// In ru, this message translates to:
  /// **'Copy diagnostics to clipboard'**
  String get feedbackCopyDiagnostics;

  /// No description provided for @feedbackCopySuccess.
  ///
  /// In ru, this message translates to:
  /// **'Diagnostics copied to clipboard'**
  String get feedbackCopySuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/app_language_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLanguageController', () {
    late AppLanguageController controller;

    setUp(() {
      controller = AppLanguageController();
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with English as default', () async {
      await controller.initialize();
      expect(controller.languageCode, 'en');
      expect(controller.currentLocale.languageCode, 'en');
      expect(controller.isInitialized, true);
    });

    test('should change language and persist preference', () async {
      await controller.initialize();

      final changed = await controller.setLanguage('es');
      expect(changed, true);
      expect(controller.languageCode, 'es');
      expect(controller.currentLocale.languageCode, 'es');

      // Verify it was persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language_code'), 'es');
    });

    test('should not change if language is the same', () async {
      await controller.initialize();

      final changed1 = await controller.setLanguage('ru');
      expect(changed1, true);

      final changed2 = await controller.setLanguage('fr');
      expect(changed2, true);

      final changed3 = await controller.setLanguage('fr');
      expect(changed3, false); // Already French
    });

    test('should reject unsupported language codes', () async {
      await controller.initialize();

      final changed = await controller.setLanguage('invalid');
      expect(changed, false);
      expect(controller.languageCode, 'en'); // Should remain English
    });

    test('should restore saved language on initialization', () async {
      // Set a saved language
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language_code', 'ru');

      await controller.initialize();
      expect(controller.languageCode, 'ru');
      expect(controller.currentLocale.languageCode, 'ru');
    });

    test('should support all required languages', () {
      final languages = AppLanguageController.supportedLanguages.keys.toList();
      expect(languages, contains('en'));
      expect(languages, contains('ru'));
      expect(languages, contains('es'));
      expect(languages, contains('fr'));
      expect(languages, contains('de'));
      expect(languages, contains('zh'));
    });

    test('should provide language names', () {
      expect(AppLanguageController.getLanguageName('en'), 'English');
      expect(AppLanguageController.getLanguageName('ru'), 'Русский');
      expect(AppLanguageController.getLanguageName('es'), 'Español');
      expect(AppLanguageController.getLanguageName('fr'), 'Français');
      expect(AppLanguageController.getLanguageName('de'), 'Deutsch');
      expect(AppLanguageController.getLanguageName('zh'), '中文');
    });

    test('should provide language flags', () {
      expect(AppLanguageController.getLanguageFlag('en'), '🇺🇸');
      expect(AppLanguageController.getLanguageFlag('ru'), '🇷🇺');
      expect(AppLanguageController.getLanguageFlag('es'), '🇪🇸');
      expect(AppLanguageController.getLanguageFlag('fr'), '🇫🇷');
      expect(AppLanguageController.getLanguageFlag('de'), '🇩🇪');
      expect(AppLanguageController.getLanguageFlag('zh'), '🇨🇳');
    });

    test('should notify listeners on language change', () async {
      await controller.initialize();

      var notified = false;
      controller.addListener(() {
        notified = true;
      });

      await controller.setLanguage('de');
      expect(notified, true);
    });
  });
}

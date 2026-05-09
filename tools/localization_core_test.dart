import 'dart:async';

import 'package:poker_analyzer/services/localization_core.dart';

Future<void> main(List<String> args) async {
  final core = LocalizationCore();
  await core.loadGlossary();

  // Seed translation memory with a few demo entries (EN -> RU).
  core.addTranslation(
    source: 'Expected value improves on the turn.',
    languageCode: 'ru',
    translation: 'Ожидаемое значение растет на терне.',
  );
  core.addTranslation(
    source: 'Apply a continuation bet on favorable boards.',
    languageCode: 'ru',
    translation: 'Ставьте конт-бет на подходящих бордах.',
  );
  core.addTranslation(
    source: 'Maintain aggression when stack depth allows.',
    languageCode: 'ru',
    translation: 'Сохраняйте агрессию, когда позволяет стек.',
  );

  final samples = <String>[
    'Expected value improves on the turn.',
    'Apply a continuation bet on favorable boards.',
    'Maintain aggression when stack depth allows.',
    'Raise vs c-bet when EV trend is positive.',
  ];

  for (final source in samples) {
    final translated = core.translate(source, 'ru');
    // Ensure the output passes post-edit cleanup.
    final finalText = core.postEdit(translated);
    print('EN: $source');
    print('RU: $finalText');
    print('');
  }
}

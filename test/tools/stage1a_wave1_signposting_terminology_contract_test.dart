import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Act0 world cards describe W2 and W3 admitted Stage 1A jobs', () {
    final source = _read('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');

    expect(
      source,
      contains(
        "subtitle: 'Choose which hands deserve chips, then use table clues.'",
      ),
    );
    expect(
      source,
      contains(
        "subtitle: 'Use position to choose the preflop open, call, or fold.'",
      ),
    );

    expect(source, contains("title: 'Hand Discipline'"));
    expect(source, contains("title: 'Position Thinking'"));
    expect(source, isNot(contains('content relocation')));
  });

  test('World 3 to World 4 completion bridge preserves W4 novelty', () {
    final source = _read(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    );

    expect(
      source,
      contains("'World 4 starts with a simple question: why did that bet '"),
    );
    expect(source, contains("'happen, and what price did it create?'"));
  });

  test('bounded first-use terminology is clarified in active early sessions', () {
    final w1s01 = _read('content/worlds/world1/v1/sessions/w1.s01/session.md');
    final w1s02 = _read('content/worlds/world1/v1/sessions/w1.s02/session.md');
    final w2s01 = _read('content/worlds/world2/v1/sessions/w2.s01/session.md');
    final w2s03 = _read('content/worlds/world2/v1/sessions/w2.s03/session.md');

    expect(w1s01, contains('Price means what you must pay to continue.'));
    expect(w1s02, contains('The dealer button is the seat marked BTN.'));
    expect(
      w1s02,
      contains(
        'Seat labels stay short: UTG acts first preflop, HJ and CO are middle-to-late seats, BTN is the button, and SB/BB are the blinds.',
      ),
    );
    expect(
      w2s01,
      contains('Price means what calling costs before you continue.'),
    );
    expect(
      w2s03,
      contains(
        'OOP, or out of position, means acting before your opponent on later streets.',
      ),
    );
  });
}

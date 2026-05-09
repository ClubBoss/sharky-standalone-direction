import 'package:poker_analyzer/ui_v2/components/lesson_ai_personalization_v1.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  test('leak tracker threshold and cooldown', () {
    final tracker = LessonLeakTracker(
      windowSize: 24,
      threshold: 3,
      cooldownDecisions: 12,
    );

    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      isNull,
    );
    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      isNull,
    );
    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      equals('sizing'),
    );

    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      isNull,
    );

    for (var i = 0; i < 11; i += 1) {
      tracker.registerDecision(isCorrect: true, errorClass: null);
    }

    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      equals('sizing'),
    );
    expect(tracker.summaryLeakKey(), equals('sizing'));
  });

  test('pattern and summary use en-only text', () {
    const key = 'sizing';
    final enPattern = LessonLeakLabels.patternLine(key, isRu: false);
    final enSummary = LessonLeakLabels.summaryLine(key, isRu: false);
    final ruPattern = LessonLeakLabels.patternLine(key, isRu: true);
    final ruSummary = LessonLeakLabels.summaryLine(key, isRu: true);

    expect(enPattern, equals('Pattern: repeated sizing.'));
    expect(enSummary, equals('Main leak: sizing.'));
    expect(ruPattern, equals(enPattern));
    expect(ruSummary, equals(enSummary));
  });

  test('nudge line appears only when leak triggers', () {
    final tracker = LessonLeakTracker(
      windowSize: 24,
      threshold: 3,
      cooldownDecisions: 12,
    );

    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      isNull,
    );
    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      isNull,
    );
    final leakKey = tracker.registerDecision(
      isCorrect: false,
      errorClass: 'sizing',
    );

    expect(leakKey, equals('sizing'));
    expect(
      LessonLeakLabels.nudgeLine(leakKey!),
      equals('Focus for next hands: sizing.'),
    );

    expect(
      tracker.registerDecision(isCorrect: false, errorClass: 'sizing'),
      isNull,
    );

    final cleanTracker = LessonLeakTracker(
      windowSize: 24,
      threshold: 3,
      cooldownDecisions: 12,
    );
    expect(
      cleanTracker.registerDecision(isCorrect: true, errorClass: null),
      isNull,
    );
  });

  test('v1x close marker present', () {
    final source = File(
      'lib/ui_v2/components/lesson_ai_personalization_v1.dart',
    ).readAsStringSync();
    expect(
      source.contains(
        'AI Personalization v1.x: closed (next changes require new phase decision).',
      ),
      isTrue,
    );
  });

  test('next phase marker present', () {
    final source = File(
      'lib/ui_v2/components/lesson_ai_personalization_v1.dart',
    ).readAsStringSync();
    expect(
      source.contains(
        'Next Phase: started (implementation gated by future prompts).',
      ),
      isTrue,
    );
  });
}

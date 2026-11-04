import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0SharkyMoodV1;

// 1x1 transparent PNG, so the backdrop path is exercised without an asset.
final Uint8List _pixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

Future<void> _pumpHome(
  WidgetTester tester,
  Act0AcademyHomeLeafInputV1 input,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Act0AcademyHomeLeafV1(input: input)),
    ),
  );
  await tester.pump();
}

Act0AcademyHomeLeafInputV1 _input({
  Act0AcademyHomeNextActionV1? nextAction,
  int? earned,
  int? total,
  Act0AcademyHomePhaseV1? phase,
  int streakDays = 0,
  ImageProvider? backdrop,
}) => Act0AcademyHomeLeafInputV1(
  courseTitle: 'Poker Basics',
  streakDays: streakDays,
  mood: Act0SharkyMoodV1.neutral,
  nextAction: nextAction,
  earnedLessonCount: earned,
  courseLessonCount: total,
  phase: phase,
  backdrop: backdrop,
);

void main() {
  testWidgets('renders the source-owned next action and forwards the press', (
    tester,
  ) async {
    var presses = 0;
    await _pumpHome(
      tester,
      _input(
        nextAction: Act0AcademyHomeNextActionV1(
          title: 'Fix the button open',
          subtitle: 'One spot from your last session.',
          ctaLabel: 'Review',
          onPressed: () => presses++,
        ),
      ),
    );

    expect(find.text('Fix the button open'), findsOneWidget);
    expect(find.text('One spot from your last session.'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_academy_home_leaf_cta')));
    expect(presses, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no source next action renders no CTA instead of inventing one', (
    tester,
  ) async {
    await _pumpHome(tester, _input());
    expect(
      find.byKey(const Key('act0_academy_home_leaf_next_card')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_academy_home_leaf_cta')), findsNothing);
    expect(
      find.byKey(const Key('act0_academy_home_leaf_course_progress')),
      findsOneWidget,
    );
  });

  testWidgets('valid earned counts render exact progress', (tester) async {
    await _pumpHome(tester, _input(earned: 3, total: 9));
    expect(find.text('3 of 9 lessons complete'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('act0_academy_home_leaf_progress_bar')),
    );
    expect(bar.value, closeTo(1 / 3, 1e-9));
  });

  for (final counts in const <(int?, int?)>[
    (null, 9),
    (3, null),
    (0, 0),
    (-1, 9),
    (10, 9),
  ]) {
    testWidgets('missing or invalid counts $counts make no progress claim', (
      tester,
    ) async {
      await _pumpHome(tester, _input(earned: counts.$1, total: counts.$2));
      expect(
        find.byKey(const Key('act0_academy_home_leaf_percent')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_academy_home_leaf_progress_label')),
        findsNothing,
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('act0_academy_home_leaf_progress_bar')),
      );
      expect(bar.value, 0);
    });
  }

  testWidgets('no phase marks no learning stage as current', (tester) async {
    await _pumpHome(tester, _input());
    for (final n in [1, 2, 3]) {
      expect(
        find.byKey(Key('act0_academy_home_leaf_active_stage_$n')),
        findsNothing,
      );
    }
    expect(
      find.bySemanticsLabel(RegExp('No step is marked complete')),
      findsOneWidget,
    );
  });

  testWidgets('a supplied phase highlights only that stage', (tester) async {
    await _pumpHome(tester, _input(phase: Act0AcademyHomePhaseV1.recall));
    expect(
      find.byKey(const Key('act0_academy_home_leaf_active_stage_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_academy_home_leaf_active_stage_2')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_academy_home_leaf_active_stage_3')),
      findsNothing,
    );
  });

  testWidgets('streak chip only appears for a real positive streak', (
    tester,
  ) async {
    await _pumpHome(tester, _input());
    expect(
      find.byKey(const Key('act0_academy_home_leaf_streak')),
      findsNothing,
    );
    await _pumpHome(tester, _input(streakDays: 1));
    expect(find.text('1 day'), findsOneWidget);
    await _pumpHome(tester, _input(streakDays: 4));
    expect(find.text('4 days'), findsOneWidget);
  });

  testWidgets('backdrop is optional and never references an undeclared asset', (
    tester,
  ) async {
    await _pumpHome(tester, _input());
    expect(
      find.byKey(const Key('act0_academy_leaf_backdrop_fallback')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_academy_leaf_backdrop_image')),
      findsNothing,
    );

    await _pumpHome(tester, _input(backdrop: MemoryImage(_pixelPng)));
    expect(
      find.byKey(const Key('act0_academy_leaf_backdrop_image')),
      findsOneWidget,
    );
  });

  testWidgets('fits the 393x852 reference viewport without layout errors', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      _input(
        earned: 9,
        total: 9,
        phase: Act0AcademyHomePhaseV1.apply,
        streakDays: 12,
        nextAction: Act0AcademyHomeNextActionV1(
          title: 'A very long next step title that must wrap across two lines',
          subtitle: 'A long subtitle that also has to clamp to two lines here.',
          ctaLabel: 'Continue',
          onPressed: () {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('100%'), findsOneWidget);
  });

  test('locale gate keeps RU on the existing localized surface', () {
    expect(act0AcademyLeafSupportsLocaleV1(const Locale('en')), isTrue);
    expect(act0AcademyLeafSupportsLocaleV1(const Locale('en', 'GB')), isTrue);
    expect(act0AcademyLeafSupportsLocaleV1(const Locale('ru')), isFalse);
  });

  test('inline glyph markup is ASCII and well formed for every kind', () {
    for (final kind in Act0AcademyLeafGlyphKindV1.values) {
      final svg = act0AcademyLeafGlyphSvgV1(kind);
      expect(svg.startsWith('<svg '), isTrue, reason: kind.name);
      expect(svg.endsWith('</svg>'), isTrue, reason: kind.name);
      expect(svg.codeUnits.every((c) => c < 128), isTrue, reason: kind.name);
    }
  });
}

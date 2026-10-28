import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_pw_c3_facade_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'act0_pw_c3_parity_v1_test.dart' as route;

final geometry = <String, Object>{};
void assertPrimary(WidgetTester t, String key) {
  final rect = t.getRect(find.byKey(Key(key)));
  expect(rect.height, greaterThanOrEqualTo(44));
  expect(rect.top, greaterThanOrEqualTo(59));
  expect(rect.bottom, lessThanOrEqualTo(818));
}

void assertIntro(WidgetTester t, String name, String primary) {
  final art = t.getRect(find.byKey(const Key('pw_c4_art')));
  final copy = t.getRect(find.byKey(const Key('pw_c4_intro_copy')));
  final guidance = t.getRect(find.byKey(const Key('pw_c4_intro_guidance')));
  expect(art.width / art.height, closeTo(965 / 1629, 0.00001));
  if (kAct0PwC3RenderPreviewV1) {
    expect(
      copy.bottom,
      lessThan(art.top + art.height * 370 / 1629),
      reason: 'Copy must clear the first baked head/face region',
    );
  }
  expect(guidance.top, greaterThanOrEqualTo(art.bottom));
  assertPrimary(t, primary);
  geometry[name] = {
    'art': [art.left, art.top, art.width, art.height],
    'copy': [copy.left, copy.top, copy.width, copy.height],
    'first_head_top': art.top + art.height * 370 / 1629,
    'guidance_top': guidance.top,
  };
}

void assertTransition(WidgetTester t, String contentKey, String primary) {
  final content = t.getRect(find.byKey(Key(contentKey)));
  final cta = t.getRect(find.byKey(Key(primary)));
  expect(
    cta.top - content.bottom,
    inInclusiveRange(0, 100),
    reason: 'Action must stay connected to transition content',
  );
  assertPrimary(t, primary);
  geometry[contentKey] = {'content_bottom': content.bottom, 'cta_top': cta.top};
}

void main() {
  setUpAll(() async {
    // Ahem's square glyphs do not model production text wrapping. Use Flutter's
    // bundled Roboto for deterministic layout; native iOS type is checked too.
    var directory = File(Platform.resolvedExecutable).parent;
    Directory? fonts;
    while (directory.parent.path != directory.path) {
      final candidate = Directory(
        '${directory.path}/bin/cache/artifacts/material_fonts',
      );
      if (candidate.existsSync()) {
        fonts = candidate;
        break;
      }
      directory = directory.parent;
    }
    expect(fonts, isNotNull, reason: 'Flutter bundled layout font must exist');
    final loader = FontLoader('Roboto');
    for (final weight in ['Regular', 'Bold']) {
      final bytes = File('${fonts!.path}/Roboto-$weight.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });
  tearDownAll(() {
    if (!kAct0PwC4PreviewV1) return;
    final o = Directory('output/pw_c4_20261028')..createSync(recursive: true);
    File(
      '${o.path}/composition_${kAct0PwC3RenderPreviewV1 ? 'owner' : 'current'}_art.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(geometry));
  });
  testWidgets(
    'intro faces stay clear, novice bypass and ungraded handoff stay direct',
    (t) async {
      await route.mount(t);
      assertIntro(t, 'placement', 'act0_shell_placement_intro_cta');
      await route.experience(t, 'new');
      assertIntro(t, 'welcome', 'act0_shell_welcome_primary_cta');
      expect(find.textContaining('ungraded'), findsOneWidget);
      await route.tap(t, 'act0_shell_welcome_primary_cta');
      expect(find.byKey(const Key('pw_c4_art')), findsNothing);
      final r = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      final wrong = r.runner.options.firstWhere((o) => !o.isCorrect);
      await route.tap(t, 'act0_shell_option_${wrong.id}');
      assertTransition(
        t,
        'act0_shell_welcome_next_step_line',
        'act0_shell_welcome_primary_cta',
      );
      expect(find.textContaining('ungraded'), findsOneWidget);
      await route.tap(t, 'act0_shell_welcome_primary_cta');
    },
    skip: !kAct0PwC4PreviewV1,
  );

  testWidgets(
    'questions keep their cards; ready and real unsure result connect to actions',
    (t) async {
      await route.mount(t);
      await route.experience(t, 'friends');
      expect(find.byKey(const Key('pw_c4_art')), findsNothing);
      await route.tap(t, 'act0_shell_placement_option_cards');
      await route.tap(t, 'act0_shell_placement_next_cta');
      assertTransition(
        t,
        'act0_shell_placement_diagnostic_ready',
        'act0_shell_placement_start_diagnostic',
      );
      await route.checks(t, 'uuu');
      expect(find.text('0 of 3 checks read correctly'), findsOneWidget);
      assertTransition(
        t,
        'act0_shell_placement_result',
        'act0_shell_placement_start_recommended',
      );
      expect(
        find.byKey(const Key('act0_shell_placement_start_zero')),
        findsOneWidget,
      );
    },
    skip: !kAct0PwC4PreviewV1,
  );
}

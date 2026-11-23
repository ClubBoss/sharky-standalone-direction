import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_accessibility_semantics_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, int>> _runRoute(
  WidgetTester tester, {
  required double scale,
  required bool reduceMotion,
  required bool inspectLabels,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(
        accessibleNavigation: inspectLabels,
        disableAnimations: reduceMotion,
        reduceMotion: reduceMotion,
      );
  final frames = <String, int>{};
  final effectiveScale = <String, double>{};
  final findings = <String>[];

  Future<void> inspect(String screen) async {
    final error = tester.takeException();
    if (error != null) findings.add('$screen: $error');
    if (inspectLabels) {
      final labels = await labeledTapTargetGuideline.evaluate(tester);
      if (!labels.passed) findings.add('$screen: ${labels.reason}');
    }
  }

  Future<void> open(String screen, Finder control) async {
    expect(control, findsOneWidget, reason: screen);
    if (control.hitTestable().evaluate().isEmpty) {
      await tester.ensureVisible(control);
      await tester.pump();
    }
    expect(control.hitTestable(), findsOneWidget, reason: screen);
    if (inspectLabels) {
      final node = tester.getSemantics(control);
      final data = node.getSemanticsData();
      expect(
        data.label.trim() + data.tooltip.trim(),
        isNotEmpty,
        reason: screen,
      );
      expect(data.hasAction(SemanticsAction.tap), isTrue, reason: screen);
      node.owner!.performAction(node.id, SemanticsAction.tap);
    } else {
      await tester.tap(control);
    }
    frames[screen] = await tester.pumpAndSettle(
      const Duration(milliseconds: 16),
    );
    await inspect(screen);
  }

  Finder key(String value) => find.byKey(Key(value));
  Finder label(String value) => find.text(value);
  Finder tab(String value) =>
      find.descendant(of: key('act0_shell_bottom_nav'), matching: label(value));

  Future<void> openTab(String value) async {
    if (inspectLabels) {
      final entries = tester.widgetList<Act0SemanticActionV1>(
        find.descendant(
          of: key('act0_shell_bottom_nav'),
          matching: find.byType(Act0SemanticActionV1),
        ),
      );
      expect(entries.map((entry) => entry.label), [
        'Home',
        'Learn',
        'Practice',
        'Review',
        'You',
      ]);
      final item = entries.singleWhere((entry) => entry.label == value);
      expect(item.sortKey, isA<OrdinalSortKey>());
      expect(tester.getSemantics(tab(value)).flagsCollection.isButton, isTrue);
    }
    await open(value, tab(value));
    if (inspectLabels) {
      expect(
        tester.getSemantics(tab(value)).flagsCollection.isSelected,
        isTrue,
      );
    }
  }

  void recordScale(String screen, Finder text) {
    effectiveScale[screen] =
        MediaQuery.textScalerOf(tester.element(text)).scale(10) / 10;
  }

  await tester.pumpWidget(const AppRoot());
  await tester.pumpAndSettle();
  await inspect('W1 entry');
  await open('W1 theory', label('Start with the basics'));
  await tester.pump(const Duration(seconds: 1));
  await open('W1 first decision', label('Next'));
  recordScale('W1', label('Which cards belong to you alone?'));
  final wrong = label('The shared cards in the middle');
  if (inspectLabels) {
    expect(tester.getSize(wrong).width, greaterThan(0));
    final paragraph = tester.renderObject<RenderParagraph>(wrong);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.getSemantics(wrong).rect.height, greaterThanOrEqualTo(44));
  }
  await open('W1 feedback', wrong);
  if (inspectLabels) {
    final result = tester.getSemantics(key('act0_accessibility_choice_result'));
    expect(result.flagsCollection.isLiveRegion, isTrue);
    expect(result.label, contains('Selected: The shared cards in the middle'));
    expect(result.value, contains('not selected'));
  }
  await open('W1 repair', label('Try same clue'));
  await open('W1 recheck feedback', label('Board cards'));
  await open('Close lesson', key('act0_shell_runner_back'));
  await openTab('Home');
  await openTab('Learn');
  expect(key('act0_shell_learn_screen'), findsOneWidget);
  if (reduceMotion) {
    for (final rotation in tester.widgetList<AnimatedRotation>(
      find.descendant(
        of: key('act0_shell_learn_screen'),
        matching: find.byType(AnimatedRotation),
      ),
    )) {
      expect(rotation.duration, Duration.zero);
    }
  }
  await openTab('Review');
  recordScale('Review', label('Attempt archive'));
  await open('Attempt archive', label('Attempt archive'));
  final attempt = find.byWidgetPredicate((widget) {
    final key = widget.key;
    return widget is ListTile &&
        key is ValueKey<String> &&
        key.value.startsWith('act0_attempt_archive_entry_');
  }).first;
  if (inspectLabels) {
    final flags = tester.getSemantics(attempt).flagsCollection;
    expect(flags.hasExpandedState, isTrue);
    expect(flags.isExpanded, isFalse);
  }
  await open('Selected attempt', attempt);
  if (inspectLabels) {
    expect(tester.getSemantics(attempt).flagsCollection.isExpanded, isTrue);
  }
  await open('Attempt replay', key('act0_attempt_archive_open_replay'));
  await open('Replay next step', key('act0_attempt_replay_next'));
  await open('Back to archive', key('act0_attempt_replay_back_to_archive'));
  await open('Back to Review', key('act0_attempt_archive_back'));
  await openTab('You');
  recordScale('Profile', key('act0_academy_you_leaf_name'));
  if (inspectLabels) {
    // ignore: avoid_print
    print('A11Y_SCALE requested=$scale effective=$effectiveScale');
  }
  expect(findings, isEmpty, reason: findings.join('\n'));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  return frames;
}

void _configure(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  for (final scale in [1.3, 2.0]) {
    testWidgets('W1, Review and Profile stay operable at system ${scale}x', (
      tester,
    ) async {
      _configure(tester);
      await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp());
      final semantics = tester.ensureSemantics();
      try {
        await _runRoute(
          tester,
          scale: scale,
          reduceMotion: false,
          inspectLabels: true,
        );
      } finally {
        semantics.dispose();
      }
    });
  }

  testWidgets('W1 answer controls can be traversed and activated by keyboard', (
    tester,
  ) async {
    _configure(tester);
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp());
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start with the basics'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final options = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'act0_shell_option_',
          ) &&
          widget is InkWell,
    );
    expect(options.evaluate().length, greaterThan(1));
    final ordered = options
        .evaluate()
        .map((element) => element.widget.key!)
        .toList();
    bool focused(Key key) =>
        tester.getSemantics(find.byKey(key)).flagsCollection.isFocused;
    for (final option in ordered) {
      final finder = find.byKey(option);
      expect(finder.hitTestable(), findsOneWidget);
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(44));
    }
    for (
      var attempts = 0;
      attempts < 24 && !focused(ordered.first);
      attempts++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(focused(ordered.first), isTrue);
    for (var index = 1; index < ordered.length; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(focused(ordered[index]), isTrue);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_accessibility_choice_result')),
      findsOneWidget,
    );
  });

  testWidgets('platform Reduce Motion shortens route animations', (
    tester,
  ) async {
    _configure(tester);
    await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp());
    final standard = await _runRoute(
      tester,
      scale: 1,
      reduceMotion: false,
      inspectLabels: false,
    );
    final reduced = await _runRoute(
      tester,
      scale: 1,
      reduceMotion: true,
      inspectLabels: false,
    );
    expect(reduced.keys, standard.keys);
    for (final (screen, frames) in reduced.entries.map(
      (entry) => (entry.key, entry.value),
    )) {
      expect(frames, lessThanOrEqualTo(standard[screen]!), reason: screen);
    }
    for (final screen in ['W1 feedback', 'Review', 'Replay next step', 'You']) {
      expect(reduced[screen], lessThan(standard[screen]!), reason: screen);
      expect(reduced[screen], lessThanOrEqualTo(3), reason: screen);
    }
    // ignore: avoid_print
    print('A11Y_MOTION standard=$standard reduced=$reduced');
  });
}

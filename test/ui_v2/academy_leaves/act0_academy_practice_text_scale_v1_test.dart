import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0PracticeGroupV1;

const _scrollKey = Key('act0_academy_practice_leaf_scroll');
const _textScale =
    int.fromEnvironment(
      'ACC04_PRACTICE_TEXT_SCALE_PERCENT',
      defaultValue: 160,
    ) /
    100;

Act0PracticeGroupV1 _group(
  String id,
  String title,
  String subtitle, {
  bool enabled = true,
}) => Act0PracticeGroupV1(
  groupId: id,
  title: title,
  subtitle: subtitle,
  ctaLabel: 'Practice',
  categoryLabel: 'Practice',
  isEnabled: enabled,
  targetWorldId: 'w1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_legal_context',
  skipTeaching: true,
);

const _repairRequest = Act0PracticeRepairQueueLaunchRequestV1(
  targetWorldId: 'w1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_legal_context',
  targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
  sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  sourceTaskId: 'actions_legal_context',
  repairTaskId: 'actions_legal_context_repair',
  repairFocusKey: 'legal_action',
  queueItemId: 'active',
);

const _activeRepair = Act0PracticeRepairQueueItemViewModelV1(
  itemId: 'active',
  title: 'Price the call',
  isPinned: true,
  launchTarget: Act0PracticeRepairQueueLaunchTargetV1(
    worldId: 'w1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    source: 'active_repair_v1',
    targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
  ),
  launchRequest: _repairRequest,
  detail: 'Button vs big blind',
  actionLine: 'You chose call - better: fold',
);

Future<void> _pump(
  WidgetTester tester,
  Act0AcademyPracticeLeafInputV1 input,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: ThemeData.dark(
          useMaterial3: true,
        ).textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(393, 852),
          textScaler: TextScaler.linear(_textScale),
        ),
        child: Scaffold(body: Act0AcademyPracticeLeafV1(input: input)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  _expectReadable(tester);
}

void _expectReadable(WidgetTester tester) {
  expect(tester.takeException(), isNull);
  final paragraphs = find.descendant(
    of: find.byType(Act0AcademyPracticeLeafV1),
    matching: find.byType(RichText),
  );
  expect(paragraphs, findsWidgets);
  for (final element in paragraphs.evaluate()) {
    final paragraph = element.renderObject! as RenderParagraph;
    final text = paragraph.text.toPlainText();
    expect(paragraph.textScaler.scale(10), 10 * _textScale, reason: text);
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: 'Truncated at $_textScale (${paragraph.size}): $text',
    );
    for (final box in paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: text.length),
    )) {
      expect(box.left, greaterThanOrEqualTo(-1), reason: text);
      expect(box.top, greaterThanOrEqualTo(-1), reason: text);
      expect(
        box.right,
        lessThanOrEqualTo(paragraph.size.width + 1),
        reason: text,
      );
      expect(
        box.bottom,
        lessThanOrEqualTo(paragraph.size.height + 1),
        reason: text,
      );
    }
  }
}

Future<void> _reach(WidgetTester tester, Key key) async {
  final target = find.byKey(key);
  await tester.scrollUntilVisible(
    target,
    160,
    scrollable: find.descendant(
      of: find.byKey(_scrollKey),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
  _expectReadable(tester);
  expect(target.hitTestable(), findsOneWidget);
  final rect = tester.getRect(target);
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.bottom, lessThanOrEqualTo(852));
  expect(rect.width, greaterThanOrEqualTo(44));
  expect(rect.height, greaterThanOrEqualTo(44));
}

Future<void> _tap(WidgetTester tester, Key key) async {
  await _reach(tester, key);
  expect(
    tester
        .getSemantics(find.byKey(key))
        .getSemanticsData()
        .hasAction(SemanticsAction.tap),
    isTrue,
  );
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
  _expectReadable(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Use Flutter's real Material font metrics, not Ahem's square glyphs.
    final configFile = File('.dart_tool/package_config.json').absolute;
    final config = jsonDecode(await configFile.readAsString()) as Map;
    final flutter = (config['packages'] as List).cast<Map>().singleWhere(
      (package) => package['name'] == 'flutter',
    );
    final sdk = Directory.fromUri(
      configFile.uri.resolve(flutter['rootUri'] as String),
    ).parent.parent;
    final loader = FontLoader('Roboto');
    for (final weight in ['Regular', 'Medium', 'Bold']) {
      final bytes = await File(
        '${sdk.path}/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
      ).readAsBytes();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  });

  for (final empty in [true, false]) {
    testWidgets(
      '${_textScale}x ${empty ? 'empty' : 'locked'} Practice keeps Learn reachable',
      (tester) async {
        var learn = 0;
        final started = <Act0PracticeGroupV1>[];
        await _pump(
          tester,
          Act0AcademyPracticeLeafInputV1(
            groups: empty
                ? []
                : [
                    _group(
                      'daily',
                      'Daily practice',
                      'Unlock after one route rep.',
                      enabled: false,
                    ),
                    _group(
                      'weak_spots',
                      'Review one quick fix',
                      'Quick fixes unlock after you repair one spot in Review.',
                      enabled: false,
                    ),
                  ],
            recommendedGroupId: 'daily',
            recommendedTitle: 'Daily practice',
            recommendedSubtitle: 'Unlock after one route rep.',
            onStartGroup: started.add,
            onOpenLearn: () => learn++,
          ),
        );
        expect(find.text('Start practice'), findsNothing);
        await _tap(
          tester,
          Key(
            empty
                ? 'act0_academy_practice_leaf_empty_learn'
                : 'act0_academy_practice_leaf_start',
          ),
        );
        expect(learn, 1);
        expect(started, isEmpty);
      },
    );
  }

  testWidgets(
    '${_textScale}x daily, quick reps, Review and expanded topics remain operable',
    (tester) async {
      final daily = _group(
        'daily',
        'Start a short rep',
        'Finish three short spots for today.',
      );
      final weak = _group(
        'weak_spots',
        'Review one quick fix',
        'One light review keeps this quick fix stable.',
      );
      final actions = _group(
        'actions',
        'Actions',
        'Read the price and choose the legal action fast.',
      );
      final blinds = _group(
        'blinds',
        'Blinds',
        'Track the blinds and who acts first preflop.',
      );
      final locked = _group(
        'positions',
        'Positions',
        'Clear it on the route first.',
        enabled: false,
      );
      final started = <Act0PracticeGroupV1>[];
      var review = 0;
      await _pump(
        tester,
        Act0AcademyPracticeLeafInputV1(
          groups: [daily, weak, actions, blinds, locked],
          recommendedGroupId: 'daily',
          recommendedTitle: daily.title,
          recommendedSubtitle: daily.subtitle,
          onStartGroup: started.add,
          onOpenReview: () => review++,
        ),
      );
      await _tap(tester, const Key('act0_academy_practice_leaf_start'));
      await _tap(
        tester,
        const Key('act0_academy_practice_leaf_topic_weak_spots'),
      );
      await _tap(tester, const Key('act0_academy_practice_leaf_review'));
      await _tap(tester, const Key('act0_academy_practice_leaf_expand'));
      expect(find.text('Show less'), findsOneWidget);
      await _tap(tester, const Key('act0_academy_practice_leaf_topic_actions'));
      await _tap(tester, const Key('act0_academy_practice_leaf_topic_blinds'));
      await _reach(
        tester,
        const Key('act0_academy_practice_leaf_topic_positions'),
      );
      expect(
        tester
            .getSemantics(
              find.byKey(
                const Key('act0_academy_practice_leaf_topic_positions'),
              ),
            )
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      expect(started, orderedEquals([daily, weak, actions, blinds]));
      expect(started.first, same(daily));
      expect(review, 1);
    },
  );

  testWidgets(
    '${_textScale}x active repair preserves readable source context and exact launch',
    (tester) async {
      final launched = <Act0PracticeRepairQueueLaunchRequestV1>[];
      final started = <Act0PracticeGroupV1>[];
      final daily = _group(
        'daily',
        'Start a short rep',
        'Finish three short spots for today.',
      );
      await _pump(
        tester,
        Act0AcademyPracticeLeafInputV1(
          groups: [daily],
          recommendedGroupId: 'daily',
          recommendedTitle: daily.title,
          recommendedSubtitle: daily.subtitle,
          onStartGroup: started.add,
          repairQueue: const Act0PracticeRepairQueueConsumerV1(
            items: [_activeRepair],
          ),
          onLaunchRepair: launched.add,
        ),
      );
      await _tap(
        tester,
        const Key('act0_academy_practice_leaf_repair_cta_active'),
      );
      expect(launched.single, same(_repairRequest));
      await _tap(tester, const Key('act0_academy_practice_leaf_start'));
      expect(started.single, same(daily));
      expect(
        find.textContaining(
          RegExp('fixed|mastered|earned', caseSensitive: false),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    '${_textScale}x completed daily and non-launchable repair do not invent actions',
    (tester) async {
      final daily = _group(
        'daily',
        'Daily short reps complete',
        'Table read improved. Come back tomorrow for the next useful hand, or practice extra reps.',
      );
      final started = <Act0PracticeGroupV1>[];
      await _pump(
        tester,
        Act0AcademyPracticeLeafInputV1(
          groups: [daily],
          recommendedGroupId: 'daily',
          recommendedTitle: daily.title,
          recommendedSubtitle: daily.subtitle,
          onStartGroup: started.add,
          completionTitle: 'Session complete',
          completionBody: 'Extra reps are optional.',
          repairQueue: const Act0PracticeRepairQueueConsumerV1(
            items: [
              Act0PracticeRepairQueueItemViewModelV1(
                itemId: 'history',
                title: 'Price the call',
                isPinned: false,
                detail: 'Button vs big blind',
                actionLine: 'You chose call - better: fold',
              ),
            ],
          ),
        ),
      );
      await _tap(tester, const Key('act0_academy_practice_leaf_start'));
      expect(started.single, same(daily));
      final scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(_scrollKey),
          matching: find.byType(Scrollable),
        ),
      );
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      _expectReadable(tester);
      expect(
        find.byKey(const Key('act0_academy_practice_leaf_repair_cta_history')),
        findsNothing,
      );
      expect(
        find.text('Session complete\nExtra reps are optional.'),
        findsOneWidget,
      );
    },
  );
}

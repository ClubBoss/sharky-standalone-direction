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
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart'
    show Act0PracticeGroupV1;

const _scrollKey = Key('act0_academy_practice_leaf_scroll');
const _textScale = 1.4;

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

const _intent = Act0RepairIntentV1(
  sourceWorldId: 'world_1',
  sourceLessonId: 'fold_check_call_raise',
  sourceTaskId: 'actions_legal_context',
  choiceId: 'fold',
  result: 'incorrect',
  errorType: 'missed_action_read',
  missedSignalId: 'no_bet_yet',
  missedSignalLabel: 'No bet yet',
  skillAtomId: 'action_read',
  skillLabel: 'Action read',
  targetWorldId: 'world_1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_check_drill',
  mappingType: 'repair',
  reasonCode: 'same_signal_action_read_no_bet_yet',
);

const _history = Act0ReviewMistakeRecordV1(
  recordId: 'review_mistake_v1|history',
  sourceDecisionId: 'decision_v1|1',
  createdOrder: 1,
  updatedOrder: 1,
  worldId: 'world_1',
  lessonId: 'fold_check_call_raise',
  decisionTaskId: 'previous_decision',
  sourceTaskId: 'previous_action',
  decisionKind: 'actionList',
  selectedId: 'call',
  expectedId: 'fold',
  resultKind: 'incorrect',
  errorType: 'missed_action_read',
  skillAtomId: 'action_read',
  repairFocusId: 'facing_bet',
  runId: 'run_v1|world_1|fold_check_call_raise|1',
  runKind: 'lesson',
  runOrdinal: 1,
  attemptRecordIds: ['decision_v1|1'],
  dedupUsesFallback: false,
);

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

  testWidgets('1.4x source-shaped repairs preserve text and launch identity', (
    tester,
  ) async {
    final projection = Act0PracticeRepairQueueProjectionV1.fromSources(
      activeRepairIntents: const [_intent],
      reviewMistakeHistory: const Act0ReviewMistakeHistoryV1(
        records: [_history],
      ),
    );
    final queue = Act0PracticeRepairQueueConsumerV1.fromProjection(projection);
    expect(queue.items, hasLength(2));
    final active = queue.items[0];
    final history = queue.items[1];
    expect(active.isPinned, isTrue);
    expect(active.isLaunchable, isTrue);
    expect(active.actionLine, isNull);
    expect(history.isPinned, isFalse);
    expect(history.isLaunchable, isFalse);
    expect(history.actionLine, 'You chose call - better: fold');

    final launched = <Act0PracticeRepairQueueLaunchRequestV1>[];
    final daily = _group('daily', 'Start a short rep', 'Short lesson practice.');
    final started = <Act0PracticeGroupV1>[];
    await _pump(
      tester,
      Act0AcademyPracticeLeafInputV1(
        groups: [daily],
        recommendedGroupId: 'daily',
        recommendedTitle: daily.title,
        recommendedSubtitle: daily.subtitle,
        onStartGroup: started.add,
        repairQueue: queue,
        onLaunchRepair: launched.add,
      ),
    );
    expect(find.text('No bet yet'), findsOneWidget);
    expect(find.text('You chose call - better: fold'), findsOneWidget);
    expect(
      find.byKey(Key('act0_academy_practice_leaf_repair_cta_${history.itemId}')),
      findsNothing,
    );
    final semantics = tester.ensureSemantics();
    await _tap(
      tester,
      Key('act0_academy_practice_leaf_repair_cta_${active.itemId}'),
    );
    expect(launched.single, same(active.launchRequest));
    expect(launched.single.targetTaskId, 'actions_check_drill');
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
    semantics.dispose();
  });
}

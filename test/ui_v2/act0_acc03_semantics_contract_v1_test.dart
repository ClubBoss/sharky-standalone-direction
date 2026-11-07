import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_accessibility_semantics_v1.dart';

void main() {
  for (final entry in <(String, String, String)>[
    ('A', 'h', 'Ace of hearts'),
    ('K', 's', 'King of spades'),
    ('Q', 'd', 'Queen of diamonds'),
    ('J', 'c', 'Jack of clubs'),
    ('T', '♥', '10 of hearts'),
    ('10', '♠', '10 of spades'),
    ('2', '♣', '2 of clubs'),
    ('9', '♦', '9 of diamonds'),
    ('7', 'hearts', '7 of hearts'),
    ('3', 'spades', '3 of spades'),
    ('4', 'diamonds', '4 of diamonds'),
    ('5', 'clubs', '5 of clubs'),
    (' A ', ' H ', 'Ace of hearts'),
    ('?', '', '?'),
  ]) {
    test(
      'ACC-03: visible card ${entry.$1}${entry.$2} has one unambiguous name',
      () {
        expect(act0SpokenCardV1(entry.$1, entry.$2), entry.$3);
      },
    );
  }

  testWidgets('ACC-03: disabled action has a name, disabled state and no tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Act0SemanticActionV1(
          label: 'Previous theory page',
          onTap: null,
          child: TextButton(onPressed: null, child: Icon(Icons.arrow_back)),
        ),
      ),
    );
    final node = tester.getSemantics(
      find.bySemanticsLabel('Previous theory page'),
    );
    final data = node.getSemanticsData();
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
    expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
  });

  testWidgets(
    'ACC-03: card action replaces decorative child labels without leaking correctness',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Act0CardSemanticsV1(
            rank: 'A',
            suit: 'h',
            position: 'Board card 1',
            onTap: () => calls++,
            child: const Row(children: [Text('A'), Text('♥'), Text('gold')]),
          ),
        ),
      );
      final node = tester.getSemantics(
        find.bySemanticsLabel('Board card 1, Ace of hearts'),
      );
      expect(node.getSemanticsData().hasFlag(SemanticsFlag.isButton), isTrue);
      expect(
        node.debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder),
        isEmpty,
      );
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      expect(calls, 1);
    },
  );

  testWidgets(
    'ACC-03: changed result updates a stable live node and preserves Continue',
    (tester) async {
      var continued = 0;
      Widget result(String title, String choice, bool assisted) => MaterialApp(
        home: Act0ChoiceResultSemanticsV1(
          title: title,
          selectedLabel: choice,
          reason: 'Read the current bet.',
          assisted: assisted,
          child: TextButton(
            onPressed: () => continued++,
            child: const Text('Continue'),
          ),
        ),
      );
      await tester.pumpWidget(result('Try again', 'Check', true));
      final finder = find.byKey(const Key('act0_accessibility_choice_result'));
      final first = tester.getSemantics(finder);
      expect(first.getSemanticsData().label, contains('With help'));
      final id = first.id;
      await tester.pumpWidget(result('Correct read', 'Call', false));
      final updated = tester.getSemantics(finder);
      expect(updated.id, id);
      expect(
        updated.getSemanticsData().hasFlag(SemanticsFlag.isLiveRegion),
        isTrue,
      );
      expect(
        updated.getSemanticsData().label,
        'Correct read. Selected: Call. Read the current bet.',
      );
      final action = tester.getSemantics(find.bySemanticsLabel('Continue'));
      action.owner!.performAction(action.id, SemanticsAction.tap);
      await tester.pump();
      expect(continued, 1);
      await tester.pumpWidget(result('Correct read', 'Call', false));
      expect(tester.getSemantics(finder).id, id);
      expect(tester.takeException(), isNull);
    },
  );
}

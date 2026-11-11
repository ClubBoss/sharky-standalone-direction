import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_reference_v1.dart';

// Asset I/O must run outside the widget test's fake clock. This loads the
// real registered production asset through its parser; no fake catalog or
// replacement bundle is injected. UI assertions still require the real panel.
Future<void> _loadRealReferenceAsset(WidgetTester tester) async {
  await tester.runAsync(() async {
    // Do not await a cached Future created by a previous FakeAsync zone.
    // Start this real asset I/O and its continuations in the same real zone.
    rootBundle.evict(Act0Hlp02ReferenceCatalogV1.assetPath);
    final catalog = await Act0Hlp02ReferenceCatalogV1.load(rootBundle);
    expect(catalog.rankings, hasLength(9));
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final rawData = File(
    'content/_meta/hlp02_reference_en_v1.json',
  ).readAsStringSync();

  test('exact asset schema, ordered rankings and owned lesson contexts', () {
    final catalog = Act0Hlp02ReferenceCatalogV1.fromJson(rawData);
    expect(catalog.rankings, hasLength(9));
    expect(catalog.rankings.first['id'], 'rank.high_card');
    expect(catalog.rankings.last['id'], 'rank.straight_flush');
    expect(catalog.namedVariant['parent_rank_id'], 'rank.straight_flush');
    expect(catalog.terms['term.equity']!['definition_en'],
        contains('Ties contribute'));

    expect(catalog.contextByLesson.keys.toSet(),
        Act0Hlp02ReferencePolicyV1.theoryTaskByLesson.keys.toSet());
    for (final entry in Act0Hlp02ReferencePolicyV1.theoryTaskByLesson.entries) {
      final context = catalog.contextFor(entry.key, entry.value);
      expect(context, isNotNull, reason: 'missing ${entry.key}/${entry.value}');
      expect(context!['task_id'], entry.value);
      expect(catalog.definitionsFor(entry.key, entry.value), isNotEmpty);
    }
    // Original source copy of EQUITY has a narrower meaning. Reference
    // retains its corrected definition but must NOT surface it automatically.
    for (final context in catalog.contextByLesson.values) {
      final ids = (context['term_ids'] as List<dynamic>).cast<String>();
      expect(ids, isNot(contains('term.equity')));
      expect(ids, isNot(contains('term.icm')));
      expect(ids, isNot(contains('term.oop')));
    }
  });

  test('asset can load through the already-registered rootBundle path', () async {
    final catalog = await Act0Hlp02ReferenceCatalogV1.load(rootBundle);
    expect(catalog.rankings, hasLength(9));
  });

  test('rejects schema drift and duplicate ranks', () {
    expect(
      () => Act0Hlp02ReferenceCatalogV1.fromJson('{}'),
      throwsFormatException,
    );
    final decoded = jsonDecode(rawData) as Map<String, dynamic>;
    final ranks = decoded['rankings'] as List<dynamic>;
    (ranks[1] as Map<String, dynamic>)['id'] =
        (ranks[0] as Map<String, dynamic>)['id'];
    expect(
      () => Act0Hlp02ReferenceCatalogV1.fromJson(jsonEncode(decoded)),
      throwsFormatException,
    );
  });

  test('assessment, recheck, inaccessible lesson and wrong locale are blocked', () {
    bool allowed({
      String lesson = 'hand_rankings_table',
      String task = 'hand_rankings_theory',
      bool theory = true,
      bool learn = true,
      bool selectable = true,
      bool english = true,
      bool scored = false,
    }) => Act0Hlp02ReferencePolicyV1.canOpen(
          lessonId: lesson,
          taskId: task,
          isTheory: theory,
          isLearnStep: learn,
          isSelectable: selectable,
          isEnglish: english,
          hasActiveScoredChoice: scored,
        );

    expect(allowed(), isTrue);
    expect(allowed(task: 'hand_rankings_pair_drill'), isFalse);
    expect(allowed(task: 'hand_rankings_review'), isFalse);
    expect(allowed(task: 'showdown_kicker_drill'), isFalse);
    expect(allowed(theory: false), isFalse);
    expect(allowed(learn: false), isFalse);
    expect(allowed(selectable: false), isFalse);
    expect(allowed(english: false), isFalse);
    expect(allowed(scored: true), isFalse);
    expect(allowed(lesson: 'unknown'), isFalse);
  });


  testWidgets('button cannot be invoked inside an assessment', (tester) async {
    await _loadRealReferenceAsset(tester);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Act0Hlp02ReferenceButtonV1(
          lessonId: 'hand_rankings_table',
          taskId: 'hand_rankings_theory',
          isTheory: true,
          isLearnStep: true,
          isSelectable: true,
          isEnglish: true,
          hasActiveScoredChoice: true,
        ),
      ),
    ));
    expect(find.byKey(const Key('act0_hlp02_open_theory_reference')),
        findsNothing);
  });

  testWidgets('cold production asset opens the reference without a fixture bundle',
      (tester) async {
    rootBundle.evict(Act0Hlp02ReferenceCatalogV1.assetPath);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Act0Hlp02ReferenceButtonV1(
          lessonId: 'hand_rankings_table',
          taskId: 'hand_rankings_theory',
          isTheory: true,
          isLearnStep: true,
          isSelectable: true,
          isEnglish: true,
          hasActiveScoredChoice: false,
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('act0_hlp02_open_theory_reference')));
    await tester.runAsync(() async {
      // Build the panel in the real async zone: its initState starts the cold
      // rootBundle request here. Awaiting a Future first created in FakeAsync
      // would deadlock because runAsync cannot flush that zone's continuations.
      await tester.pump();
      // Await the same production request in the zone that initiated it.
      final catalog = await Act0Hlp02ReferenceCatalogV1.load(rootBundle);
      expect(catalog.rankings, hasLength(9));
    });
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_hlp02_theory_reference_panel')),
        findsOneWidget);
    expect(find.text('Hand rankings - lowest to highest'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Reference unavailable'), findsNothing);
  });

  testWidgets('rank theory reference opens inline and exposes card-name semantics',
      (tester) async {
    await _loadRealReferenceAsset(tester);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Act0Hlp02ReferenceButtonV1(
          lessonId: 'hand_rankings_table',
          taskId: 'hand_rankings_theory',
          isTheory: true,
          isLearnStep: true,
          isSelectable: true,
          isEnglish: true,
          hasActiveScoredChoice: false,
        ),
      ),
    ));
    expect(find.byKey(const Key('act0_hlp02_open_theory_reference')),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_hlp02_open_theory_reference')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_hlp02_theory_reference_panel')),
        findsOneWidget);
    expect(find.text('Hand rankings - lowest to highest'), findsOneWidget);
    final semanticsHandle = tester.ensureSemantics();
    addTearDown(semanticsHandle.dispose);
    const highCard = Key('act0_hlp02_rank_rank.high_card');
    await tester.ensureVisible(find.byKey(highCard));
    await tester.tap(find.byKey(highCard));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'Example: .* of .*')),
      findsWidgets,
    );

    // There is no Equity term in this lesson's source-owned allowlist.
    final catalog = Act0Hlp02ReferenceCatalogV1.fromJson(rawData);
    expect(catalog.definitionsFor('hand_rankings_table', 'hand_rankings_theory')
        .any((term) => term['id'] == 'term.equity'), isFalse);
  });

  testWidgets('showdown theory shows contextual definitions without ranks',
      (tester) async {
    await _loadRealReferenceAsset(tester);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Act0Hlp02ReferenceButtonV1(
          lessonId: 'showdown_winning',
          taskId: 'showdown_theory',
          isTheory: true,
          isLearnStep: true,
          isSelectable: true,
          isEnglish: true,
          hasActiveScoredChoice: false,
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('act0_hlp02_open_theory_reference')));
    await tester.pumpAndSettle();
    expect(find.text('Terms in this lesson'), findsOneWidget);
    expect(find.text('Hand rankings - lowest to highest'), findsNothing);
  });
  testWidgets('an opened panel closes when its source task/lesson changes',
      (tester) async {
    await _loadRealReferenceAsset(tester);
    String lesson = 'hand_rankings_table';
    String task = 'hand_rankings_theory';
    bool english = true;
    late StateSetter update;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, setState) {
        update = setState;
        return Scaffold(
          body: Act0Hlp02ReferenceButtonV1(
            lessonId: lesson,
            taskId: task,
            isTheory: true,
            isLearnStep: true,
            isSelectable: true,
            isEnglish: english,
            hasActiveScoredChoice: false,
          ),
        );
      }),
    ));
    const openKey = Key('act0_hlp02_open_theory_reference');
    const panelKey = Key('act0_hlp02_theory_reference_panel');
    await tester.tap(find.byKey(openKey));
    await tester.pumpAndSettle();
    expect(find.byKey(panelKey), findsOneWidget);

    // Source task switches while panel is open. The exact allowlist closes it.
    update(() => task = 'hand_rankings_pair_drill');
    await tester.pumpAndSettle();
    expect(find.byKey(openKey), findsNothing);
    expect(find.byKey(panelKey), findsNothing);

    // Back/re-entry to the same theory does not resurrect the old panel.
    update(() => task = 'hand_rankings_theory');
    await tester.pumpAndSettle();
    expect(find.byKey(openKey), findsOneWidget);
    expect(find.byKey(panelKey), findsNothing);

    await tester.tap(find.byKey(openKey));
    await tester.pumpAndSettle();
    update(() {
      lesson = 'showdown_winning';
      task = 'showdown_theory';
    });
    await tester.pumpAndSettle();
    expect(find.byKey(openKey), findsOneWidget);
    expect(find.byKey(panelKey), findsNothing);

    update(() => english = false);
    await tester.pumpAndSettle();
    expect(find.byKey(openKey), findsNothing);
    expect(find.byKey(panelKey), findsNothing);
  });

}

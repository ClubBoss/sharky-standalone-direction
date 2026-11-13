// JRN08 scoped negative proof: You leaf, not whole-journey/native acceptance.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';

void main() {
  testWidgets('unknown completion and empty moments preserve truth and exits', (
    tester,
  ) async {
    // Synthetic unreadable unrelated record: leaf must not repair/reset storage.
    SharedPreferences.setMockInitialValues({
      'jrn08_synthetic_corrupt_progress': '{broken',
    });
    var recovery = 0;
    var learn = 0;
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0AcademyYouLeafV1(
            input: Act0AcademyYouLeafInputV1(
              completedTaskCount: null,
              onRecoveryOptions: () {
                recovery++;
              },
              onOpenLearn: () {
                learn++;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start learning'), findsNothing);
    expect(find.text('0 tasks completed'), findsNothing);
    expect(find.text('0 task completed'), findsNothing);
    expect(find.byKey(const Key('act0_academy_you_leaf_banked')), findsNothing);
    expect(
      find.byKey(const Key('act0_academy_you_leaf_reinforced')),
      findsNothing,
    );
    final recover = find.byKey(const Key('act0_profile_recovery_options'));
    await tester.scrollUntilVisible(
      recover,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(recover.hitTestable(), findsOneWidget);
    await tester.tap(recover);
    await tester.pumpAndSettle();
    expect(recovery, 1);
    expect(learn, 0);
    final next = find.byKey(const Key('act0_academy_you_leaf_learn'));
    await tester.scrollUntilVisible(
      next,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final unknownRecord = find.text('Your learning, saved');
    expect(unknownRecord, findsOneWidget);
    await tester.ensureVisible(unknownRecord);
    await tester.pumpAndSettle();
    expect(unknownRecord.hitTestable(), findsOneWidget);
    // Recheck at the mounted record section, not only above the lazy viewport.
    expect(find.text('0 tasks completed'), findsNothing);
    expect(find.text('0 task completed'), findsNothing);
    expect(find.byKey(const Key('act0_academy_you_leaf_banked')), findsNothing);
    expect(
      find.byKey(const Key('act0_academy_you_leaf_reinforced')),
      findsNothing,
    );
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    expect(find.text('Open Learn'), findsOneWidget);
    expect(next.hitTestable(), findsOneWidget);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(learn, 1);
    expect(recovery, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {'jrn08_synthetic_corrupt_progress'});
    expect(prefs.getString('jrn08_synthetic_corrupt_progress'), '{broken');
    expect(tester.takeException(), isNull);
  });
}

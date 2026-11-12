import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_screen_v1.dart';
import 'package:poker_analyzer/features/hst06/pokerstars_text_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'hst06_review_route_proposal_test.dart' as fixture;

const repair = Act0MistakeCardV1(
  taskId: 'synthetic-authored-repair',
  lessonId: 'synthetic-lesson',
  worldId: 'synthetic-world',
  title: 'Synthetic existing learning repair',
  weaknessLabel: '',
  selectedOptionId: 'a',
  selectedLabel: '',
  betterLabel: '',
  reason: '',
  attempts: 1,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final mode in ['choose', 'cancel', 'stale', 'empty']) {
    testWidgets('private hand learning link: $mode', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final saved = await Hst06PersonalStore().confirm(
        Hst06PokerStarsPreview().parse(fixture.synthetic).single,
      );
      final before = await fixture.snapshot();
      final rebuild = ValueNotifier<int>(0);
      addTearDown(rebuild.dispose);
      final launched = <Act0MistakeCardV1>[];
      var closedBeforeLaunch = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<int>(
              valueListenable: rebuild,
              builder: (context, value, _) => act0AcademyReviewRuntimeV1(
                context,
                legacy: Act0ReviewShellV1(
                  review: Act0ReviewStateV1(
                    title: 'Review',
                    subtitle: '',
                    weaknessLabel: '',
                    reason: '',
                    stats: [],
                    chosenLabel: '',
                    betterLabel: '',
                    mistakes: mode == 'empty' ? [] : [repair],
                  ),
                  selected: null,
                  onSelected: (_) {},
                  onFixMistake: (target) {
                    closedBeforeLaunch = !Navigator.of(context).canPop();
                    launched.add(target);
                  },
                ),
                isCurrent: () => true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      fixture.callback(tester)();
      await tester.pumpAndSettle();
      if (mode == 'empty') {
        expect(find.text('No learning repair available'), findsOneWidget);
      } else {
        final choose = find.byKey(
          Key('hst06-learning-' + saved.stored!.localId),
        );
        await tester.ensureVisible(choose);
        await tester.pumpAndSettle();
        await tester.tap(choose);
        await tester.pumpAndSettle();
        expect(find.textContaining('not an assessment'), findsOneWidget);
        if (mode == 'stale') {
          rebuild.value++;
          await tester.pumpAndSettle();
        }
        await tester.tap(
          find.text(mode == 'cancel' ? 'Cancel' : repair.title).last,
        );
        await tester.pumpAndSettle();
      }
      if (mode == 'choose') {
        expect(launched, [same(repair)]);
        expect(closedBeforeLaunch, isTrue);
        expect(find.byType(Hst06PersonalHandScreen), findsNothing);
      } else {
        expect(launched, isEmpty);
        if (mode == 'stale')
          expect(
            find.textContaining('Learning repairs changed'),
            findsOneWidget,
          );
      }
      expect(
        await fixture.snapshot(),
        before,
        reason:
            'Choosing/navigation cannot change personal or learning storage.',
      );
      expect(tester.takeException(), isNull);
    });
  }
}

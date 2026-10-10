import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// S08 Wave A follow-up: Learn/Worlds must render its surrounding chrome
// (page background, current-World strip, current-mission card, ordered
// Up next journey) through the same approved V3 Editorial Tide light
// Academy tokens already lifted on Welcome (#262) and Home (#263). The
// protected Modern Table and the shared premium CTA button style stay
// untouched; this lift only recolors the Learn/Worlds surrounding surfaces.
void main() {
  Future<void> pumpLearnV1(
    WidgetTester tester, {
    required Size size,
    Locale locale = const Locale('en'),
    double textScale = 1.0,
  }) async {
    final state = Act0ShellStateV1.sample;
    final world = state.selectedWorld;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ru')],
          home: Scaffold(
            body: Act0LearnPathShellV1(
              moduleTitle: state.courseTitle,
              moduleProgressLabel: state.pathProgressLabel,
              worlds: state.worlds,
              selectedWorldId: world.worldId,
              showWorldMenu: false,
              worldDetailId: null,
              lessons: world.lessons,
              selectedLessonId: state.currentLesson.lessonId,
              selectedTaskId: state.currentLesson.taskList.first.taskId,
              activePopupTaskId: null,
              completedTaskIds: const <String>{},
              perfectTaskIds: const <String>{},
              skippedTaskIds: const <String>{},
              pathClosedTaskIds: const <String>{},
              detailLessonId: null,
              lessonOutcomeLabels: const <String, String>{},
              onSelectWorld: (_) {},
              onOpenWorldMenu: () {},
              onCloseWorldMenu: () {},
              onDismissWorldDetail: () {},
              onPreviewPremiumWorld: (_) {},
              onSelectLesson: (_) => true,
              onOpenLessonAfterScroll: (_) {},
              onDismissDetail: () {},
              onSelectTask: (_, _) {},
              onDismissTaskPopup: () {},
              onStartTask: (_, _) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(320, 760), const Size(375, 812)]) {
    testWidgets(
      'Learn uses the Academy light page/card tokens at '
      '${size.width.toInt()}px',
      (tester) async {
        await pumpLearnV1(tester, size: size);

        final pageBackground = tester.widget<ColoredBox>(
          find.byKey(const Key('act0_shell_learn_page_background')),
        );
        expect(pageBackground.color, Act0AcademyDesignTokensV1.pageSurface);

        final worldStrip = tester.widget<Ink>(
          find.byKey(const Key('act0_shell_learn_v5_world_context')),
        );
        final worldStripDecoration = worldStrip.decoration as BoxDecoration;
        expect(
          worldStripDecoration.color,
          Act0AcademyDesignTokensV1.cardSurface,
        );
        expect(worldStripDecoration.borderRadius, BorderRadius.circular(6));

        final missionCard = tester.widget<Container>(
          find.byKey(const Key('act0_shell_current_mission_card')),
        );
        final missionDecoration = missionCard.decoration as BoxDecoration;
        expect(
          missionDecoration.color,
          Act0AcademyDesignTokensV1.cardSurface,
        );
        expect(missionDecoration.borderRadius, BorderRadius.circular(6));

        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Learn keeps the current World, the dominant mission CTA and the '
    'ordered Up next journey under RU locale and 1.4x text scale at 320px',
    (tester) async {
      await pumpLearnV1(
        tester,
        size: const Size(320, 760),
        locale: const Locale('ru'),
        textScale: 1.4,
      );

      // One clear dominant first-next action.
      expect(
        find.byKey(const Key('act0_shell_current_mission_cta')),
        findsOneWidget,
      );

      // Truthful current World + ordered journey stay reachable.
      expect(
        find.byKey(const Key('act0_shell_learn_v5_world_context')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_journey_path_header')),
        findsOneWidget,
      );
      expect(find.text('Дальше'), findsWidgets);

      // No RenderFlex/overflow exception at compact width under RU + 1.4x.
      expect(tester.takeException(), isNull);
    },
  );
}

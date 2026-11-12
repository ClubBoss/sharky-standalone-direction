import 'dart:ui' as ui;
// Test-only paragraph/card geometry and tappable control proof at EN393x852.
// 1x/2x are scenarios, not OS matrix; not arbitrary ancestor occlusion proof.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Learn world nodes text scale $scale keeps text and controls within bounds',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final worlds = Act0ShellStateV1.sample.worlds;
        final world = worlds.first;
        final selectedIds = <String>[];
        var closeCalls = 0;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: Act0LearnPathShellV1(
                    moduleTitle: 'Learn',
                    moduleProgressLabel: 'Sample',
                    worlds: worlds,
                    selectedWorldId: world.worldId,
                    showWorldMenu: true,
                    worldDetailId: null,
                    lessons: world.lessons,
                    selectedLessonId: world.lessons.first.lessonId,
                    selectedTaskId: world.lessons.first.taskList.first.taskId,
                    activePopupTaskId: null,
                    completedTaskIds: const {},
                    perfectTaskIds: const {},
                    skippedTaskIds: const {},
                    pathClosedTaskIds: const {},
                    detailLessonId: null,
                    lessonOutcomeLabels: const {},
                    onSelectWorld: (id) {
                      selectedIds.add(id);
                    },
                    onOpenWorldMenu: () {},
                    onCloseWorldMenu: () {
                      closeCalls++;
                    },
                    onDismissWorldDetail: () {},
                    onPreviewPremiumWorld: (_) {},
                    onSelectLesson: (_) => true,
                    onOpenLessonAfterScroll: (_) {},
                    onDismissDetail: () {},
                    onSelectTask: (_, __) {},
                    onDismissTaskPopup: () {},
                    onStartTask: (_, __) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final number in [1, 10]) {
          final targetWorld = worlds.singleWhere(
            (w) => w.worldNumber == number,
          );
          final node = find.byKey(Key('act0_shell_world_$number'));
          final scrollable = find
              .descendant(
                of: find.byKey(const Key('act0_shell_levels_menu')),
                matching: find.byType(Scrollable),
              )
              .first;
          await tester.scrollUntilVisible(
            node,
            180,
            scrollable: scrollable,
            maxScrolls: 30,
          );
          expect(node, findsOneWidget);
          await Scrollable.ensureVisible(tester.element(node), alignment: 0.5);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(node.hitTestable(), findsOneWidget);
          final card = tester.getRect(node);
          expect(card.top, greaterThanOrEqualTo(0));
          expect(card.bottom, lessThanOrEqualTo(852));
          final texts = find.descendant(of: node, matching: find.byType(Text));
          expect(texts.evaluate().length, greaterThanOrEqualTo(4));
          final numberText = find.descendant(
            of: node,
            matching: find.text('$number'),
          );
          final labelText = find.descendant(
            of: node,
            matching: find.text('World $number'),
          );
          expect(numberText, findsOneWidget);
          expect(labelText, findsOneWidget);
          expect(
            tester.getRect(numberText).overlaps(tester.getRect(labelText)),
            isFalse,
          );
          final paragraphs = find.descendant(
            of: node,
            matching: find.byType(RichText),
          );
          for (final element in paragraphs.evaluate()) {
            final paragraph = element.renderObject! as RenderParagraph;
            expect(paragraph.didExceedMaxLines, isFalse);
            final value = paragraph.text.toPlainText();
            expect(value.trim(), isNotEmpty);
            // Select non-whitespace codepoints with correct UTF-16 offsets.
            final boxes = <({int offset, ui.TextBox box})>[];
            var offset = 0;
            for (final rune in value.runes) {
              final end = offset + (rune > 0xffff ? 2 : 1);
              if (String.fromCharCode(rune).trim().isNotEmpty) {
                for (final box in paragraph.getBoxesForSelection(
                  TextSelection(baseOffset: offset, extentOffset: end),
                )) {
                  boxes.add((offset: offset, box: box));
                }
              }
              offset = end;
            }
            expect(boxes, isNotEmpty);
            for (final entry in boxes) {
              final box = entry.box;
              final reason = '$value; UTF16 offset ${entry.offset}; box=$box';
              final topLeft = paragraph.localToGlobal(
                Offset(box.left, box.top),
              );
              final bottomRight = paragraph.localToGlobal(
                Offset(box.right, box.bottom),
              );
              expect(
                card.inflate(0.5).contains(topLeft),
                isTrue,
                reason: reason,
              );
              expect(
                card.inflate(0.5).contains(bottomRight),
                isTrue,
                reason: reason,
              );
              expect(box.left, greaterThanOrEqualTo(-0.5), reason: reason);
              expect(
                box.right,
                lessThanOrEqualTo(paragraph.size.width + 0.5),
                reason: reason,
              );
              expect(box.top, greaterThanOrEqualTo(-0.5), reason: reason);
              expect(
                box.bottom,
                lessThanOrEqualTo(paragraph.size.height + 0.5),
                reason: reason,
              );
            }
          }
          await tester.tap(node);
          expect(selectedIds.last, targetWorld.worldId);
        }
        expect(selectedIds.length, 2);
        final close = find.byKey(const Key('act0_shell_levels_menu_close'));
        expect(close.hitTestable(), findsOneWidget);
        await tester.tap(close);
        expect(closeCalls, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

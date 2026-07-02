import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_cross_session_profile_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_proof_icon_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  group('cross-session Profile proof projection', () {
    test('no proof produces an empty safe projection', () {
      final profileProof = Act0CrossSessionProfileProofV1.fromFixProof(
        const Act0FixProofProjectionV1(),
      );

      expect(profileProof.hasProof, isFalse);
      expect(profileProof.totalBankedFixCount, 0);
      expect(profileProof.recentProofItems, isEmpty);
      expect(profileProof.latestProofSessionId, isEmpty);
    });

    test('lifetime counts do not decrease when the recent window moves', () {
      final profileProof = Act0CrossSessionProfileProofV1.fromFixProof(
        Act0FixProofProjectionV1(
          recentSessionLimit: 2,
          proofs: <Act0FixProofItemV1>[
            for (var index = 1; index <= 8; index += 1)
              _proof(
                id: 'proof_$index',
                sessionId: 'session_$index',
                order: index,
                familyId: index.isEven ? 'position_read' : 'action_read',
              ),
          ],
        ),
      );

      expect(profileProof.totalBankedFixCount, 8);
      expect(profileProof.distinctConceptFamilyCount, 2);
      expect(profileProof.recentProofItems, hasLength(2));
      expect(
        profileProof.recentProofItems.map((item) => item.proofId),
        <String>['proof_8', 'proof_7'],
      );
    });

    test('duplicate exact proof counts once and reinforcement upgrades it', () {
      final profileProof = Act0CrossSessionProfileProofV1.fromFixProof(
        Act0FixProofProjectionV1(
          proofs: <Act0FixProofItemV1>[
            _proof(id: 'proof_a', sessionId: 'session_1', order: 1),
            _proof(
              id: 'proof_a',
              sessionId: 'session_1',
              order: 1,
              reinforced: true,
            ),
          ],
        ),
      );

      expect(profileProof.totalBankedFixCount, 1);
      expect(profileProof.reinforcedFixCount, 1);
      expect(profileProof.recentProofItems.single.isReinforced, isTrue);
    });

    test('multiple exact fixes in one family count separately', () {
      final profileProof = Act0CrossSessionProfileProofV1.fromFixProof(
        Act0FixProofProjectionV1(
          proofs: <Act0FixProofItemV1>[
            _proof(id: 'proof_a', sessionId: 'session_1', order: 1),
            _proof(id: 'proof_b', sessionId: 'session_2', order: 2),
          ],
        ),
      );

      expect(profileProof.totalBankedFixCount, 2);
      expect(profileProof.distinctConceptFamilyCount, 1);
    });

    test('recent items cap at three with deterministic proof ordering', () {
      final profileProof = Act0CrossSessionProfileProofV1.fromFixProof(
        Act0FixProofProjectionV1(
          proofs: <Act0FixProofItemV1>[
            _proof(id: 'proof_a', sessionId: 'session_1', order: 8),
            _proof(
              id: 'proof_b',
              sessionId: 'session_2',
              order: 2,
              reinforced: true,
            ),
            _proof(id: 'proof_c', sessionId: 'session_3', order: 7),
            _proof(id: 'proof_d', sessionId: 'session_4', order: 6),
          ],
        ),
      );

      expect(profileProof.recentProofItems, hasLength(3));
      expect(
        profileProof.recentProofItems.map((item) => item.proofId),
        <String>['proof_b', 'proof_a', 'proof_c'],
      );
      expect(profileProof.latestProofOrder, 8);
      expect(profileProof.latestProofSessionId, 'session_1');
    });

    test('malformed source payload fails closed', () {
      final source = Act0FixProofProjectionV1.tryParse(<String, Object?>{
        'schemaVersion': 1,
        'recentSessionLimit': 7,
        'proofs': <Map<String, Object?>>[
          <String, Object?>{'fixProofId': 'missing_source_fields'},
        ],
      });

      final profileProof = Act0CrossSessionProfileProofV1.fromFixProof(source);

      expect(profileProof.hasProof, isFalse);
    });

    test('source reload reconstructs the same Profile proof', () {
      final source = Act0FixProofProjectionV1(
        proofs: <Act0FixProofItemV1>[
          _proof(
            id: 'proof_a',
            sessionId: 'session_1',
            order: 4,
            reinforced: true,
          ),
        ],
      );

      final before = Act0CrossSessionProfileProofV1.fromFixProof(source);
      final after = Act0CrossSessionProfileProofV1.fromFixProof(
        Act0FixProofProjectionV1.tryParse(source.toPayload()),
      );

      expect(after.toPayload(), before.toPayload());
    });

    test('projection owns no persistence telemetry dashboard or score', () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_cross_session_profile_proof_v1.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('SharedPreferences')));
      expect(source, isNot(contains('Telemetry')));
      expect(source, isNot(contains('dashboard')));
      expect(source, isNot(contains('percentage')));
      expect(source, isNot(contains('mastery')));
    });
  });

  group('bounded existing Profile consumer', () {
    testWidgets('no proof preserves the existing Profile fallback', (
      tester,
    ) async {
      await _pumpProfile(tester);

      expect(find.text('Lessons'), findsOneWidget);
      expect(find.text('Rhythm'), findsWidgets);
      expect(
        find.byKey(const Key('act0_shell_profile_recent_proof')),
        findsNothing,
      );
    });

    testWidgets(
      'proof enriches the existing progress card with lifetime data',
      (tester) async {
        await _pumpProfile(tester, proof: _visibleProfileProof());

        expect(
          find.byKey(const Key('act0_shell_profile_progress_proof')),
          findsOneWidget,
        );
        expect(find.text('Fixes'), findsOneWidget);
        expect(find.text('4 banked'), findsOneWidget);
        expect(find.text('Reinforced'), findsOneWidget);
        expect(find.text('1 on a later hand'), findsOneWidget);
        expect(find.text('Concepts'), findsOneWidget);
        expect(find.text('2 worked on'), findsOneWidget);
      },
    );

    testWidgets('Profile renders capped claim-safe recent proof lines', (
      tester,
    ) async {
      await _pumpProfile(tester, proof: _visibleProfileProof());
      await tester.scrollUntilVisible(
        find.byKey(const Key('act0_shell_profile_recent_proof')),
        160,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text('Across your recent sessions'), findsOneWidget);
      expect(find.text('Later evidence supported this repair'), findsOneWidget);
      expect(
        find.text('You repaired this table-reading clue'),
        findsNWidgets(2),
      );
      expect(
        find.byKey(const Key('act0_shell_profile_recent_proof_item_proof_a')),
        findsNothing,
      );

      final text = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(const Key('act0_shell_profile_progress_proof')),
              matching: find.byType(Text),
            ),
          )
          .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
          .join(' ')
          .toLowerCase();
      for (final forbidden in <String>[
        'mastered',
        'score',
        'percentage',
        'level',
        'rating',
        'weakest',
        'ai verified',
        'this week',
      ]) {
        expect(text, isNot(contains(forbidden)));
      }
    });

    testWidgets('proof keeps Profile callback behavior unchanged', (
      tester,
    ) async {
      var homeTapCount = 0;
      await _pumpProfile(
        tester,
        proof: _visibleProfileProof(),
        onGoToHome: () => homeTapCount += 1,
      );

      await tester.tap(
        find.byKey(const Key('act0_shell_profile_next_milestone')),
      );
      await tester.pump();

      expect(homeTapCount, 1);
    });

    testWidgets(
      'banked fix maps to repairCompleted and reinforced proof icons',
      (tester) async {
        await _pumpProfile(tester, proof: _visibleProfileProof());

        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_profile_progress_proof')),
            matching: find.byKey(
              const Key('act0_proof_icon_v1_repairCompleted'),
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_profile_progress_proof')),
            matching: find.byKey(const Key('act0_proof_icon_v1_reinforced')),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('missing proof yields no earned proof icon', (tester) async {
      await _pumpProfile(tester);

      expect(find.byType(Act0ProofIconV1), findsNothing);
    });

    testWidgets(
      'banked fix without reinforcement does not show a reinforced icon',
      (tester) async {
        final proof = Act0CrossSessionProfileProofV1.fromFixProof(
          Act0FixProofProjectionV1(
            proofs: <Act0FixProofItemV1>[
              _proof(id: 'proof_a', sessionId: 'session_1', order: 1),
            ],
          ),
        );
        await _pumpProfile(tester, proof: proof);

        expect(
          find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('act0_proof_icon_v1_reinforced')),
          findsNothing,
        );
      },
    );

    testWidgets('ordinary fix proof never maps to a milestone icon', (
      tester,
    ) async {
      await _pumpProfile(tester, proof: _visibleProfileProof());

      expect(
        find.byKey(const Key('act0_proof_icon_v1_milestone')),
        findsNothing,
      );
    });

    testWidgets('proof icon rendering does not mutate proof state', (
      tester,
    ) async {
      final proof = _visibleProfileProof();
      final before = proof.toPayload();

      await _pumpProfile(tester, proof: proof);
      await tester.pump();

      expect(proof.toPayload(), before);
    });

    testWidgets('compact Profile proof has no overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpProfile(tester, proof: _visibleProfileProof());
      await tester.drag(
        find.byKey(const Key('act0_shell_profile_screen')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  Act0CrossSessionProfileProofV1? proof,
  VoidCallback? onGoToHome,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0ProfileShellV1(
          profile: Act0ShellStateV1.sample.profile,
          crossSessionProof: proof,
          onRetakePlacement: () {},
          onGoToHome: onGoToHome,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0CrossSessionProfileProofV1 _visibleProfileProof() {
  return Act0CrossSessionProfileProofV1.fromFixProof(
    Act0FixProofProjectionV1(
      proofs: <Act0FixProofItemV1>[
        _proof(
          id: 'proof_a',
          sessionId: 'session_1',
          order: 1,
          familyId: 'action_read',
        ),
        _proof(
          id: 'proof_b',
          sessionId: 'session_2',
          order: 2,
          familyId: 'position_read',
          reinforced: true,
        ),
        _proof(
          id: 'proof_c',
          sessionId: 'session_3',
          order: 3,
          familyId: 'action_read',
        ),
        _proof(
          id: 'proof_d',
          sessionId: 'session_4',
          order: 4,
          familyId: 'position_read',
        ),
      ],
    ),
  );
}

Act0FixProofItemV1 _proof({
  required String id,
  required String sessionId,
  required int order,
  String familyId = 'action_read',
  bool reinforced = false,
}) {
  return Act0FixProofItemV1(
    fixProofId: id,
    queueItemId: 'queue_$id',
    conceptFamilyId: familyId,
    repairFocusId: familyId,
    sourceTaskId: 'source_$id',
    repairSessionId: sessionId,
    repairOutcomeRef: 'repair_outcome_v1|$order|queue_$id',
    proofState: reinforced
        ? act0FixProofStateReinforcedByLaterEvidenceV1
        : act0FixProofStateRepairCompletedV1,
    laterEvidenceSessionId: reinforced ? 'later_$sessionId' : '',
    laterEvidenceTaskId: reinforced ? 'later_task_$id' : '',
    transferVerdict: reinforced ? 'improved_v1' : '',
    bankedAtOrder: order,
    messageKey: reinforced
        ? 'fix_proof_reinforced_v1'
        : 'fix_proof_repair_completed_v1',
  );
}

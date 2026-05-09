import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tools/validate_training_content.dart' as validator;

void _expectBoundaryPassesForFile(String path) {
  final content = File(path).readAsStringSync();
  expect(
    validator.validateSharedCoreFormatBoundaryTextV1(
      filePath: path,
      content: content,
    ),
    isEmpty,
    reason: 'Expected boundary validator to allow $path as-is.',
  );
}

void main() {
  test(
    'shared-core format boundary validator blocks premature context drift and universal policy wording',
    () {
      final earlyWorldContextErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world3/v1/sessions/w3.s01/notes.md',
            content:
                'In 6-max cash this is always the right play, even before later tracks.',
          );
      expect(earlyWorldContextErrors, isNotEmpty);
      expect(
        earlyWorldContextErrors.join('\n'),
        contains('must not introduce explicit format-context token "6-max"'),
      );
      expect(
        earlyWorldContextErrors.join('\n'),
        contains(
          'must not frame context-dependent strategy as universal policy',
        ),
      );

      final world8ContextErrors = validator.validateSharedCoreFormatBoundaryTextV1(
        filePath: 'content/worlds/world8/v1/sessions/w8.s01/notes.md',
        content:
            'ICM pressure changes value and survival tradeoffs in later tournament decisions.',
      );
      expect(world8ContextErrors, isEmpty);

      final earlyWorldUniversalErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world5/v1/sessions/w5.s02/notes.md',
            content:
                'This heuristic is the final answer across cash, MTT, and mixed play.',
          );
      expect(earlyWorldUniversalErrors, isNotEmpty);
      expect(earlyWorldUniversalErrors.join('\n'), contains('"final answer"'));

      final prematureTrackRoutingErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world6/v1/sessions/w6.s01/notes.md',
            content:
                'After this lesson, choose cash track if you want the final answer for deeper stacks.',
          );
      expect(prematureTrackRoutingErrors, isNotEmpty);
      expect(
        prematureTrackRoutingErrors.join('\n'),
        contains('must not introduce post-core track-routing wording'),
      );
      expect(prematureTrackRoutingErrors.join('\n'), contains('"choose cash"'));

      final collapsedContextErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world9/v1/sessions/w9.s02/notes.md',
            content:
                'This is the one correct play regardless of stack depth or ICM.',
          );
      expect(collapsedContextErrors, isNotEmpty);
      expect(collapsedContextErrors.join('\n'), contains('"one correct play"'));
      expect(
        collapsedContextErrors.join('\n'),
        contains('"regardless of stack depth"'),
      );
    },
  );

  test(
    'shared-core format boundary validator covers admitted file-backed World 9 residues and preserves allowed World 8 wording',
    () {
      final world9TrackNotesPath =
          'content/worlds/world9/v1/sessions/w9.s10/notes.md';
      final world9TrackNotes = File(world9TrackNotesPath).readAsStringSync();
      expect(
        validator.validateSharedCoreFormatBoundaryTextV1(
          filePath: world9TrackNotesPath,
          content: world9TrackNotes,
        ),
        isEmpty,
      );
      final world9TrackLeakErrors = validator.validateSharedCoreFormatBoundaryTextV1(
        filePath: world9TrackNotesPath,
        content:
            'Keep real-player reads, then choose one track that fits your game. '
            'Next practice: apply one consistent adjustment inside cash, tournament, or mixed play.',
      );
      expect(world9TrackLeakErrors, isNotEmpty);
      expect(
        world9TrackLeakErrors.join('\n'),
        contains('indirect post-core track-choice wording'),
      );

      final world9PlaceholderNotesPath =
          'content/worlds/world9/v1/sessions/w9.s02/notes.md';
      final world9PlaceholderNotes = File(
        world9PlaceholderNotesPath,
      ).readAsStringSync();
      expect(
        validator.validateSharedCoreFormatBoundaryTextV1(
          filePath: world9PlaceholderNotesPath,
          content: world9PlaceholderNotes,
        ),
        isEmpty,
      );
      final world9PlaceholderErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: world9PlaceholderNotesPath,
            content: '# Notes\n- TODO\n',
          );
      expect(world9PlaceholderErrors, isNotEmpty);
      expect(
        world9PlaceholderErrors.join('\n'),
        contains('learner-facing TODO placeholder residue'),
      );

      final world8AllowedPath =
          'content/worlds/world8/v1/sessions/w8.s01/session.md';
      final world8Allowed = File(world8AllowedPath).readAsStringSync();
      expect(
        validator.validateSharedCoreFormatBoundaryTextV1(
          filePath: world8AllowedPath,
          content: world8Allowed,
        ),
        isEmpty,
      );
    },
  );

  test(
    'shared-core format boundary validator allows admitted World 5, 7, and 8 file-backed late-core phrasing',
    () {
      const admittedPaths = <String>[
        'content/worlds/world5/v1/sessions/w5.s01/session.md',
        'content/worlds/world5/v1/sessions/w5.s02/session.md',
        'content/worlds/world5/v1/sessions/w5.s03/session.md',
        'content/worlds/world5/v1/sessions/w5.s04/session.md',
        'content/worlds/world5/v1/sessions/w5.s05/session.md',
        'content/worlds/world5/v1/sessions/w5.s06/session.md',
        'content/worlds/world5/v1/sessions/w5.s07/session.md',
        'content/worlds/world5/v1/sessions/w5.s08/session.md',
        'content/worlds/world5/v1/sessions/w5.s09/session.md',
        'content/worlds/world5/v1/sessions/w5.s10/session.md',
        'content/worlds/world7/v1/sessions/w7.s10/notes.md',
        'content/worlds/world8/v1/sessions/w8.s10/notes.md',
      ];

      for (final path in admittedPaths) {
        _expectBoundaryPassesForFile(path);
      }
    },
  );

  test(
    'shared-core format boundary validator allows cleaned World 6 to 9 notes metadata replacements',
    () {
      const cleanedNotesPaths = <String>[
        'content/worlds/world6/v1/sessions/w6.s02/notes.md',
        'content/worlds/world6/v1/sessions/w6.s03/notes.md',
        'content/worlds/world7/v1/sessions/w7.s02/notes.md',
        'content/worlds/world7/v1/sessions/w7.s04/notes.md',
        'content/worlds/world7/v1/sessions/w7.s05/notes.md',
        'content/worlds/world7/v1/sessions/w7.s06/notes.md',
        'content/worlds/world7/v1/sessions/w7.s07/notes.md',
        'content/worlds/world7/v1/sessions/w7.s08/notes.md',
        'content/worlds/world7/v1/sessions/w7.s09/notes.md',
        'content/worlds/world7/v1/sessions/w7.s03/notes.md',
        'content/worlds/world8/v1/sessions/w8.s02/notes.md',
        'content/worlds/world8/v1/sessions/w8.s03/notes.md',
        'content/worlds/world8/v1/sessions/w8.s04/notes.md',
        'content/worlds/world8/v1/sessions/w8.s05/notes.md',
        'content/worlds/world8/v1/sessions/w8.s06/notes.md',
        'content/worlds/world8/v1/sessions/w8.s07/notes.md',
        'content/worlds/world8/v1/sessions/w8.s08/notes.md',
        'content/worlds/world8/v1/sessions/w8.s09/notes.md',
        'content/worlds/world9/v1/sessions/w9.s03/notes.md',
        'content/worlds/world9/v1/sessions/w9.s04/notes.md',
        'content/worlds/world9/v1/sessions/w9.s05/notes.md',
        'content/worlds/world9/v1/sessions/w9.s06/notes.md',
        'content/worlds/world9/v1/sessions/w9.s07/notes.md',
        'content/worlds/world9/v1/sessions/w9.s08/notes.md',
        'content/worlds/world9/v1/sessions/w9.s09/notes.md',
      ];

      for (final path in cleanedNotesPaths) {
        _expectBoundaryPassesForFile(path);
      }
    },
  );

  test(
    'shared-core format boundary validator allows admitted file-backed World 0 and World 4 session wording',
    () {
      const admittedSessionPaths = <String>[
        'content/worlds/world0/v1/sessions/w0.s01/session.md',
        'content/worlds/world0/v1/sessions/w0.s05/session.md',
        'content/worlds/world0/v1/sessions/w0.s10/session.md',
        'content/worlds/world4/v1/sessions/w4.s05/session.md',
        'content/worlds/world4/v1/sessions/w4.s10/session.md',
      ];

      for (final path in admittedSessionPaths) {
        _expectBoundaryPassesForFile(path);
      }
    },
  );

  test(
    'shared-core format boundary validator allows admitted file-backed World 1 late-discipline and World 2 bridge session wording',
    () {
      const admittedSessionPaths = <String>[
        'content/worlds/world1/v1/sessions/w1.s09/session.md',
        'content/worlds/world1/v1/sessions/w1.s10/session.md',
        'content/worlds/world2/v1/sessions/w2.s02/session.md',
        'content/worlds/world2/v1/sessions/w2.s03/session.md',
      ];

      for (final path in admittedSessionPaths) {
        _expectBoundaryPassesForFile(path);
      }
    },
  );

  test(
    'shared-core format boundary validator blocks added track-choice and universal-policy drift on session surfaces',
    () {
      final earlySessionTrackErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world0/v1/sessions/w0.s01/session.md',
            content:
                'After this first-run lesson, choose one track that fits your game.',
          );
      expect(earlySessionTrackErrors, isNotEmpty);
      expect(
        earlySessionTrackErrors.join('\n'),
        contains('indirect post-core track-choice wording'),
      );

      final mainlineUniversalErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world4/v1/sessions/w4.s05/session.md',
            content:
                'This size is the final answer across cash, tournament, and mixed play.',
          );
      expect(mainlineUniversalErrors, isNotEmpty);
      expect(
        mainlineUniversalErrors.join('\n'),
        contains(
          'must not frame context-dependent strategy as universal policy',
        ),
      );

      final lateSessionTrackErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world9/v1/sessions/w9.s10/session.md',
            content:
                'Keep the read, then choose one track that fits your game for the next step.',
          );
      expect(lateSessionTrackErrors, isNotEmpty);
      expect(
        lateSessionTrackErrors.join('\n'),
        contains('indirect post-core track-choice wording'),
      );
    },
  );

  test(
    'shared-core format boundary validator allows admitted file-backed World 6 to 9 bridge session wording',
    () {
      const admittedBridgeSessionPaths = <String>[
        'content/worlds/world6/v1/sessions/w6.s01/session.md',
        'content/worlds/world7/v1/sessions/w7.s01/session.md',
        'content/worlds/world8/v1/sessions/w8.s01/session.md',
        'content/worlds/world9/v1/sessions/w9.s01/session.md',
      ];

      for (final path in admittedBridgeSessionPaths) {
        _expectBoundaryPassesForFile(path);
      }
    },
  );

  test(
    'shared-core format boundary validator blocks explicit stack-band and format-context drift on bridge session surfaces',
    () {
      final earlyBridgeContextErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world6/v1/sessions/w6.s01/session.md',
            content: 'In 6-max cash at 20bb, this is always the right play.',
          );
      expect(earlyBridgeContextErrors, isNotEmpty);
      expect(
        earlyBridgeContextErrors.join('\n'),
        contains('must not introduce explicit format-context token "6-max"'),
      );
      expect(
        earlyBridgeContextErrors.join('\n'),
        contains(
          'must not introduce explicit stack-band policy wording before later specialization layers',
        ),
      );
      expect(
        earlyBridgeContextErrors.join('\n'),
        contains(
          'must not frame context-dependent strategy as universal policy',
        ),
      );
    },
  );

  test(
    'shared-core format boundary validator blocks track-choice and universal-policy drift on World 1 and World 2 decision-session surfaces',
    () {
      final world1UniversalErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world1/v1/sessions/w1.s10/session.md',
            content:
                'From a friendly seat, this is the final answer across cash, tournament, and mixed play.',
          );
      expect(world1UniversalErrors, isNotEmpty);
      expect(world1UniversalErrors.join('\n'), contains('"final answer"'));
      expect(
        world1UniversalErrors.join('\n'),
        contains(
          'must not frame context-dependent strategy as universal policy',
        ),
      );

      final world2TrackChoiceErrors = validator
          .validateSharedCoreFormatBoundaryTextV1(
            filePath: 'content/worlds/world2/v1/sessions/w2.s03/session.md',
            content:
                'After this initiative lesson, choose one track that fits your game for deeper stack spots.',
          );
      expect(world2TrackChoiceErrors, isNotEmpty);
      expect(
        world2TrackChoiceErrors.join('\n'),
        contains('indirect post-core track-choice wording'),
      );
    },
  );
}

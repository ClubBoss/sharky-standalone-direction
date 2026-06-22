import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'term scanner rejects learner content that uses a term before its introduction',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'term_introduction_glossary_safety_',
      );
      addTearDown(() => root.delete(recursive: true));

      final meta = Directory('${root.path}/content/_meta')
        ..createSync(recursive: true);
      final session = Directory(
        '${root.path}/content/worlds/world2/v1/sessions/w2.s02',
      )..createSync(recursive: true);
      final earlierDrills = Directory(
        '${root.path}/content/worlds/world2/v1/sessions/w2.s01/drills',
      )..createSync(recursive: true);

      File('${meta.path}/term_introduction_contract_v1.json').writeAsStringSync(
        jsonEncode(<String, Object>{
          'active_learner_content_root': 'content/worlds',
          'reference_only_tokens': <Object>[],
          'priority_terms': <Object>[
            <String, Object>{
              'term': 'EQUITY',
              'introduction_path':
                  'content/worlds/world2/v1/sessions/w2.s02/session.md',
              'definition': 'Equity is your chance to win the pot.',
            },
          ],
        }),
      );
      File('${session.path}/session.md').writeAsStringSync(
        '# Session\n\nEquity is your chance to win the pot.\n',
      );
      File(
        '${earlierDrills.path}/d.pre_intro.json',
      ).writeAsStringSync('{"prompt":"Use equity before the introduction."}');

      final result = await Process.run('dart', <String>[
        'run',
        'tools/term_coverage_scanner.dart',
        '--root',
        root.path,
      ]);

      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('pre-introduction'));
    },
  );

  test(
    'term scanner accepts a declared introduction and ignores reference-only content',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'term_introduction_glossary_safety_',
      );
      addTearDown(() => root.delete(recursive: true));

      final meta = Directory('${root.path}/content/_meta')
        ..createSync(recursive: true);
      final introduction = Directory(
        '${root.path}/content/worlds/world2/v1/sessions/w2.s01',
      )..createSync(recursive: true);
      final laterDrills = Directory(
        '${root.path}/content/worlds/world2/v1/sessions/w2.s02/drills',
      )..createSync(recursive: true);
      final reference = Directory('${root.path}/content/_reference')
        ..createSync(recursive: true);

      File('${meta.path}/term_introduction_contract_v1.json').writeAsStringSync(
        jsonEncode(<String, Object>{
          'active_learner_content_root': 'content/worlds',
          'reference_only_tokens': <Object>[
            <String, Object>{'term': 'PFA', 'reason': 'reference only'},
          ],
          'priority_terms': <Object>[
            <String, Object>{
              'term': 'EQUITY',
              'introduction_path':
                  'content/worlds/world2/v1/sessions/w2.s01/session.md',
              'definition': 'Equity is your chance to win the pot.',
            },
          ],
        }),
      );
      File('${introduction.path}/session.md').writeAsStringSync(
        '# Session\n\nEquity is your chance to win the pot.\n',
      );
      File(
        '${laterDrills.path}/d.after_intro.json',
      ).writeAsStringSync('{"prompt":"Use equity after the introduction."}');
      File(
        '${reference.path}/notes.md',
      ).writeAsStringSync('PFA remains reference only.');

      final result = await Process.run('dart', <String>[
        'run',
        'tools/term_coverage_scanner.dart',
        '--root',
        root.path,
      ]);

      expect(result.exitCode, 0);
      expect(
        result.stdout.toString(),
        contains('reference-only tokens excluded: PFA'),
      );
    },
  );

  test(
    'term scanner rejects a use that appears before its definition in the introduction source',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'term_introduction_glossary_safety_',
      );
      addTearDown(() => root.delete(recursive: true));

      final meta = Directory('${root.path}/content/_meta')
        ..createSync(recursive: true);
      final introduction = Directory(
        '${root.path}/content/worlds/world2/v1/sessions/w2.s01',
      )..createSync(recursive: true);

      File('${meta.path}/term_introduction_contract_v1.json').writeAsStringSync(
        jsonEncode(<String, Object>{
          'active_learner_content_root': 'content/worlds',
          'reference_only_tokens': <Object>[],
          'priority_terms': <Object>[
            <String, Object>{
              'term': 'EQUITY',
              'introduction_path':
                  'content/worlds/world2/v1/sessions/w2.s01/session.md',
              'definition': 'Equity is your chance to win the pot.',
            },
          ],
        }),
      );
      File('${introduction.path}/session.md').writeAsStringSync(
        'Use equity to assess the spot.\n\n'
        'Equity is your chance to win the pot.\n',
      );

      final result = await Process.run('dart', <String>[
        'run',
        'tools/term_coverage_scanner.dart',
        '--root',
        root.path,
      ]);

      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('before its definition'));
    },
  );
}

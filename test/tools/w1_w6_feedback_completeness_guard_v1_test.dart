import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'production W1-W6 feedback guard scans 453 active decision rows',
    () async {
      final result = await Process.run('dart', <String>[
        'run',
        'tools/w1_w6_feedback_completeness_guard.dart',
        '--root',
        Directory.current.path,
        '--json',
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      final report =
          jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      expect(report['active_decision_rows_scanned'], 453);
      expect(report['missing_correct_incorrect_count'], 0);
      expect(report['missing_acceptable_feedback_count'], 0);
      expect(report['missing_why_count'], 0);
      expect(report['violations'], isEmpty);
    },
  );

  test(
    'guard reports actionable missing feedback by world session id and file',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'w1_w6_feedback_guard_',
      );
      addTearDown(() => root.delete(recursive: true));

      final meta = Directory('${root.path}/content/_meta')
        ..createSync(recursive: true);
      final drills = Directory(
        '${root.path}/content/worlds/world1/v1/sessions/w1.s01/drills',
      )..createSync(recursive: true);
      final drillPath =
          'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_call.json';

      File('${meta.path}/world_drills_manifest_v1.json').writeAsStringSync(
        jsonEncode(<String, Object>{
          'version': 1,
          'generated_from': 'test',
          'worlds': <Object>[
            <String, Object>{
              'world': 1,
              'sessions': <Object>[
                <String, Object>{
                  'id': 'w1.s01',
                  'path': 'content/worlds/world1/v1/sessions/w1.s01/',
                  'drills': <Object>[
                    <String, Object>{'id': 'choose_call', 'path': drillPath},
                  ],
                },
              ],
            },
          ],
        }),
      );
      File('${root.path}/$drillPath').writeAsStringSync(
        jsonEncode(<String, Object>{
          'id': 'choose_call',
          'kind': 'action_choice',
          'prompt': 'Choose call.',
          'expected': <String, String>{'actionId': 'call'},
          'acceptable_actions': <String>['fold'],
          'error_class': 'action_selection',
        }),
      );

      final result = await Process.run('dart', <String>[
        'run',
        'tools/w1_w6_feedback_completeness_guard.dart',
        '--root',
        root.path,
        '--json',
      ]);

      expect(result.exitCode, isNot(0));
      final report =
          jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      expect(report['active_decision_rows_scanned'], 1);
      final violations = (report['violations'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(violations, hasLength(4));
      expect(violations.first, containsPair('file', drillPath));
      expect(violations.first, containsPair('world', 1));
      expect(violations.first, containsPair('session', 'w1.s01'));
      expect(violations.first, containsPair('id', 'choose_call'));
      expect(
        violations.map((violation) => violation['field']).toSet(),
        <String>{
          'feedback_correct_v1',
          'feedback_incorrect_v1',
          'feedback_acceptable_v1',
          'why_v1',
        },
      );
    },
  );
}

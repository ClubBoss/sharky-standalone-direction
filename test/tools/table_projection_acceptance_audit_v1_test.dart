import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/table_projection_acceptance_audit_v1.dart';

void main() {
  test(
    'synthetic repo catches table-required host mismatch and missing scene fields',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'table_projection_acceptance_audit_v1_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      final manifestDir = Directory('${tempRoot.path}/content/_meta')
        ..createSync(recursive: true);
      File(
        '${manifestDir.path}/world_drills_manifest_v1.json',
      ).writeAsStringSync(
        jsonEncode(<String, Object?>{
          'version': 1,
          'worlds': <Object?>[
            <String, Object?>{
              'world': 4,
              'sessions': <Object?>[
                <String, Object?>{
                  'id': 'w4.s04',
                  'path': 'content/worlds/world4/v1/sessions/w4.s04/',
                  'drills': <Object?>[
                    <String, Object?>{
                      'id': 'find_btn_repeat',
                      'path':
                          'content/worlds/world4/v1/sessions/w4.s04/drills/d.find_btn_repeat.json',
                    },
                    <String, Object?>{
                      'id': 'tap_flop_left_repeat',
                      'path':
                          'content/worlds/world4/v1/sessions/w4.s04/drills/d.tap_flop_left_repeat.json',
                    },
                  ],
                },
              ],
            },
          ],
        }),
      );

      final drillsDir = Directory(
        '${tempRoot.path}/content/worlds/world4/v1/sessions/w4.s04/drills',
      )..createSync(recursive: true);
      File(
        '${tempRoot.path}/content/worlds/world4/v1/sessions/w4.s04/session.md',
      ).writeAsStringSync('session');
      File('${drillsDir.path}/index.md').writeAsStringSync(
        '- find_btn_repeat: seat\n- tap_flop_left_repeat: board\n',
      );
      File('${drillsDir.path}/d.find_btn_repeat.json').writeAsStringSync(
        '{"id":"find_btn_repeat","kind":"seat_tap","prompt":"Tap BTN.","expected":{"role":"btn"},"error_class":"mismatch"}',
      );
      File('${drillsDir.path}/d.tap_flop_left_repeat.json').writeAsStringSync(
        '{"id":"tap_flop_left_repeat","kind":"board_tap","prompt":"Tap flop left.","expected":{"boardSlot":"flop_left"},"error_class":"mismatch"}',
      );

      final report = buildTableProjectionAcceptanceAuditReportV1(
        rootPath: tempRoot.path,
        options: const TableProjectionAuditOptionsV1(world: 4),
      );

      expect(report.summary.errorCount, equals(4));
      expect(
        report.summary.reasonCounts['table_required_but_host_not_projected'],
        equals(2),
      );
      expect(
        report.summary.reasonCounts['missing_required_scene_fields'],
        equals(2),
      );
    },
  );

  test(
    'current repo world4 audit is clean after spatial and hand-chain closeout',
    () {
      final report = buildTableProjectionAcceptanceAuditReportV1(
        options: const TableProjectionAuditOptionsV1(world: 4),
      );

      expect(report.summary.totalIssues, equals(0));
      expect(report.issues, isEmpty);
    },
  );

  test(
    'current repo worlds 6 to 8 audits are clean after hand-chain closeout',
    () {
      for (final world in <int>[6, 7, 8]) {
        final report = buildTableProjectionAcceptanceAuditReportV1(
          options: TableProjectionAuditOptionsV1(world: world),
        );

        expect(report.summary.totalIssues, equals(0), reason: 'world $world');
        expect(report.issues, isEmpty, reason: 'world $world');
      }
    },
  );

  test('current repo world9 audit is clean after hand-chain closeout', () {
    final report = buildTableProjectionAcceptanceAuditReportV1(
      options: const TableProjectionAuditOptionsV1(world: 9),
    );

    expect(report.summary.totalIssues, equals(0));
    expect(report.issues, isEmpty);
  });

  test(
    'current repo world10 audit is clean after canonical table migration batch',
    () {
      final report = buildTableProjectionAcceptanceAuditReportV1(
        options: const TableProjectionAuditOptionsV1(world: 10),
      );

      expect(report.summary.totalIssues, equals(0));
      expect(report.issues, isEmpty);
    },
  );

  test(
    'world2 single-step projected subset is clean after canonical seam admission',
    () {
      final report = buildTableProjectionAcceptanceAuditReportV1(
        options: const TableProjectionAuditOptionsV1(world: 2),
      );
      const cleanSubset = <String>{
        'w2.s01',
        'w2.s02',
        'w2.s03',
        'w2.s04',
        'w2.s06',
      };

      expect(
        report.issues.where((issue) => cleanSubset.contains(issue.sessionId)),
        isEmpty,
      );
    },
  );

  test(
    'world2 mixed hand-chain subset is clean after canonical seam admission',
    () {
      final report = buildTableProjectionAcceptanceAuditReportV1(
        options: const TableProjectionAuditOptionsV1(world: 2),
      );
      const cleanSubset = <String>{'w2.s07', 'w2.s08', 'w2.s09', 'w2.s10'};

      expect(
        report.issues.where((issue) => cleanSubset.contains(issue.sessionId)),
        isEmpty,
      );
    },
  );

  test('world2 review connector is clean on the learner-facing drill set', () {
    final report = buildTableProjectionAcceptanceAuditReportV1(
      options: const TableProjectionAuditOptionsV1(world: 2),
    );

    expect(
      report.issues.where((issue) => issue.sessionId == 'w2.s05'),
      isEmpty,
    );
  });

  test(
    'current repo world5 audit is clean after late texture canonical migration',
    () {
      final report = buildTableProjectionAcceptanceAuditReportV1(
        options: const TableProjectionAuditOptionsV1(world: 5),
      );

      expect(report.summary.totalIssues, equals(0));
      expect(report.issues, isEmpty);
    },
  );

  test('json output stays stable for representative world filtering', () {
    final report = buildTableProjectionAcceptanceAuditReportV1(
      options: const TableProjectionAuditOptionsV1(world: 4),
    );
    final decoded =
        jsonDecode(jsonEncode(report.toJson())) as Map<String, Object?>;
    final summary = decoded['summary'] as Map<String, Object?>;

    expect(decoded['version'], 'v1');
    expect(summary['total_issues'], isNotNull);
    expect(summary['reason_counts'], isNotNull);
    expect(decoded['issues'], isA<List<Object?>>());
  });
}

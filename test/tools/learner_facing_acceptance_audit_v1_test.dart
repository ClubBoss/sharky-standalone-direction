import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/learner_facing_acceptance_audit_v1.dart';

void main() {
  test('report is deterministic on current repo after world1 closeout', () {
    final first = renderLearnerFacingAcceptanceAuditReportV1(
      buildLearnerFacingAcceptanceAuditReportV1(),
    );
    final second = renderLearnerFacingAcceptanceAuditReportV1(
      buildLearnerFacingAcceptanceAuditReportV1(),
    );

    expect(second, equals(first));
    expect(first, contains('issues='));
    expect(first, contains('presentation'));

    final report = buildLearnerFacingAcceptanceAuditReportV1();
    expect(report.summary.presentationIssueCount, equals(0));
    expect(report.summary.reasonCounts.keys, isEmpty);
    expect(report.issues.where((issue) => issue.world == 1), isEmpty);
    expect(
      report.issues.where(
        (issue) => issue.itemId == 'world10_spine_campaign_v1',
      ),
      isEmpty,
    );
  });

  test('synthetic repo catches missing and empty learner-facing drill assets', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'learner_acceptance_audit_v1_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final metaDir = Directory('${tempRoot.path}/content/_meta')
      ..createSync(recursive: true);
    File('${metaDir.path}/world_drills_manifest_v1.json').writeAsStringSync(
      jsonEncode(<String, Object?>{
        'version': 1,
        'worlds': <Object?>[
          <String, Object?>{
            'world': 4,
            'sessions': <Object?>[
              <String, Object?>{
                'id': 'w4.s03',
                'path': 'content/worlds/world4/v1/sessions/w4.s03',
                'drills': <Object?>[
                  <String, Object?>{
                    'id': 'chain_world4_purpose_checkpoint_v1',
                    'path':
                        'content/worlds/world4/v1/sessions/w4.s03/drills/d.chain_world4_purpose_checkpoint_v1.json',
                  },
                  <String, Object?>{
                    'id': 'choose_raise_value',
                    'path':
                        'content/worlds/world4/v1/sessions/w4.s03/drills/d.choose_raise_value.json',
                  },
                ],
              },
            ],
          },
        ],
      }),
    );

    final drillDir = Directory(
      '${tempRoot.path}/content/worlds/world4/v1/sessions/w4.s03/drills',
    )..createSync(recursive: true);
    File('${drillDir.path}/index.md').writeAsStringSync(
      '- chain_world4_purpose_checkpoint_v1: checkpoint\n'
      '- choose_raise_value: continue\n',
    );
    File('${drillDir.path}/d.choose_raise_value.json').writeAsStringSync('   ');

    final report = buildLearnerFacingAcceptanceAuditReportV1(
      rootPath: tempRoot.path,
      options: const LearnerFacingAcceptanceAuditOptionsV1(
        world: 4,
        includePresentationIssues: false,
      ),
    );

    expect(report.summary.assetIssueCount, equals(2));
    expect(report.summary.presentationIssueCount, equals(0));
    expect(report.summary.errorCount, equals(2));
    expect(
      report.issues.map((issue) => issue.reasonCode).toSet(),
      containsAll(<String>['broken_drill_reference', 'empty_drill_file']),
    );
  });

  test('json output stays stable for representative world filtering', () {
    final report = buildLearnerFacingAcceptanceAuditReportV1(
      options: const LearnerFacingAcceptanceAuditOptionsV1(world: 10),
    );
    final encoded = encodeLearnerFacingAcceptanceAuditReportJsonV1(report);
    final decoded = jsonDecode(encoded) as Map<String, Object?>;
    final summary = decoded['summary'] as Map<String, Object?>;

    expect(decoded['version'], 'v1');
    expect(summary['total_issues'], isNotNull);
    expect(summary['presentation_issue_count'], isNotNull);
    expect(summary['asset_issue_count'], isNotNull);
  });
}

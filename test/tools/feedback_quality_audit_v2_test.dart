import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/feedback_quality_audit_v2.dart';

void main() {
  test('v2 preserves release-blocking and adds medium-debt signals', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'feedback_quality_audit_v2_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeFileV2(
      tempRoot,
      'content/worlds/world1/v1/sessions/w1.s07/drills/d.raise.json',
      jsonEncode(<String, Object?>{
        'id': 'raise',
        'kind': 'action_choice',
        'feedback_incorrect_v1': 'Incorrect.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world2/v1/sessions/w2.s05/drills/d.curriculum.json',
      jsonEncode(<String, Object?>{
        'id': 'curriculum',
        'kind': 'action_choice',
        'feedback_incorrect_v1':
            'Incorrect. This checkpoint answer still expects call.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world6/v1/sessions/w6.s01/drills/d.generic.json',
      jsonEncode(<String, Object?>{
        'id': 'generic',
        'kind': 'action_choice',
        'feedback_incorrect_v1':
            'Incorrect. This spot expects a different action.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world6/v1/sessions/w6.s02/drills/d.anchor.json',
      jsonEncode(<String, Object?>{
        'id': 'anchor',
        'kind': 'action_choice',
        'feedback_correct_v1': 'Correct. Seat anchor is confirmed.',
        'feedback_incorrect_v1': 'Incorrect. Tap the target seat anchor first.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s07/drills/d.short.json',
      jsonEncode(<String, Object?>{
        'id': 'short',
        'kind': 'action_choice',
        'feedback_incorrect_v1': 'Incorrect. Too loose here.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s08/drills/d.chain.json',
      jsonEncode(<String, Object?>{
        'id': 'chain',
        'kind': 'hand_chain_v1',
        'steps': <Object?>[
          <String, Object?>{
            'feedback_incorrect_v1':
                'Incorrect. This checkpoint answer still expects call.',
          },
        ],
      }),
    );

    final report = buildFeedbackQualityAuditReportV2(rootPath: tempRoot.path);
    final rendered = renderFeedbackQualityAuditReportV2(report);

    expect(report.filesChecked, 6);
    expect(
      report.findings.where(
        (item) => item.issueType == 'bare_incorrect_feedback',
      ),
      hasLength(1),
    );
    expect(
      report.findings.where(
        (item) => item.issueType == 'internal_curriculum_label_feedback',
      ),
      hasLength(2),
    );
    expect(
      report.findings.where(
        (item) => item.issueType == 'generic_template_feedback',
      ),
      hasLength(1),
    );
    expect(
      report.findings.where(
        (item) => item.issueType == 'generic_anchor_feedback',
      ),
      hasLength(1),
    );
    expect(
      report.findings.where(
        (item) => item.issueType == 'suspiciously_short_feedback',
      ),
      hasLength(1),
    );
    expect(
      report.findings.where(
        (item) => item.issueType == 'shallow_positive_feedback',
      ),
      hasLength(1),
    );
    expect(report.clones, hasLength(1));
    expect(
      report.families.first.highestSeverity,
      FeedbackAuditSeverityV2.releaseBlocking,
    );
    final mediumDebtFamilies = report.families
        .where(
          (item) => item.highestSeverity == FeedbackAuditSeverityV2.mediumDebt,
        )
        .toList(growable: false);
    expect(
      mediumDebtFamilies.first.familyPath,
      'content/worlds/world2/v1/sessions/w2.s05',
    );
    expect(rendered, contains('FEEDBACK_QUALITY_AUDIT_V2'));
    expect(rendered, contains('ISSUE_TOTALS'));
    expect(rendered, contains('internal_curriculum_label_feedback'));
    expect(rendered, contains('generic_anchor_feedback'));
    expect(rendered, contains('shallow_positive_feedback'));
  });
}

void _writeFileV2(Directory root, String relativePath, String contents) {
  final file = File('${root.path}/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}

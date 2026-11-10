import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import '../../tools/cnt01_role_inventory_v1.dart';

Map<String, Object?> _row({
  String id = 'task_a',
  String role = 'UNKNOWN',
  String basis = 'UNKNOWN',
  String? sourcePath,
  String? mainSha,
  String? revision,
}) => <String, Object?>{
  'worldId': 'world_1',
  'lessonId': 'lesson_1',
  'taskId': id,
  'sourceRole': role,
  'roleBasis': basis,
  'catalogSourcePath': sourcePath ?? cnt01CatalogSourceV1,
  'catalogSourceMainSha': mainSha ?? List<String>.filled(40, 'a').join(),
  'semanticRevision': revision ?? List<String>.filled(64, 'b').join(),
  'authoredSourcePath': 'UNKNOWN',
  'authoredRevision': 'UNKNOWN',
  'responsibleAuthor': 'UNKNOWN',
  'choiceIds': <String>['choice_a', 'choice_b'],
  'authoredCorrectChoiceIds': <String>['choice_a'],
  'authoredRationaleByChoiceId': <String, String>{
    'choice_a': 'Source-authored explanation',
  },
};

Set<String> _codes(List<Map<String, Object?>> rows, {
  Set<String> seen = const <String>{},
  Set<String> assisted = const <String>{},
}) => Cnt01RoleInventoryV1.validateRows(
  rows,
  previouslyPresentedTaskIds: seen,
  assistanceExposedTaskIds: assisted,
).map((finding) => finding['code']!).toSet();

void main() {
  test('CNT-01 export', () async {
    final env = Platform.environment;
    final output = env['CNT01_OUTPUT'];
    if (output == null || !output.startsWith('/')) {
      throw StateError('CNT01_OUTPUT must be an absolute new output file.');
    }
    final file = File(output);
    if (file.existsSync()) throw StateError('Refusing to replace existing output.');
    final result = await cnt01ExportV1(
      repositoryRoot: env['CNT01_ROOT'] ?? '',
      attestationPath: env['CNT01_ATTESTATION'] ?? '',
    );
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
    expect(result['count'], greaterThan(0));
    expect(result['errors'], isEmpty,
        reason: 'Inventory saved with errors intact; this is not acceptance.');
  }, skip: Platform.environment.keys.any((key) => key.startsWith('CNT01_'))
      ? false : 'Opt-in export: see tools/cnt01_role_inventory_v1.dart');
  group('CNT-01 source-only inventory', () {
    test('reuses existing Act0 source fingerprint and does not infer unseen', () {
      final rows = Cnt01RoleInventoryV1.fromAct0(
        baselineMainSha: List<String>.filled(40, 'a').join(),
      );
      expect(rows, isNotEmpty);
      expect(
        rows.where((row) => row['taskId'] == 'what_poker_is_theory')
            .single['sourceRole'],
        'TEACHING',
      );
      for (final id in <String>[
        'what_poker_is_table_read_transfer',
        'what_poker_is_table_read_recheck',
      ]) {
        final row = rows.where((candidate) => candidate['taskId'] == id).single;
        expect(row['sourceRole'], 'UNKNOWN', reason: id);
        expect(row['semanticRevision'], isNot('UNKNOWN'), reason: id);
      }
      expect(rows.where((row) => row['sourceRole'] == 'UNSEEN'), isEmpty);
      expect(rows.where((row) => row['sourceRole'] == 'ELAPSED'), isEmpty);
    });

    List<Map<String, Object?>> sourceRows() => Cnt01RoleInventoryV1.fromAct0(
      baselineMainSha: List<String>.filled(40, 'a').join(),
    );

    Map<String, Object?> teachingRow() => Map<String, Object?>.from(
      sourceRows().singleWhere((r) => r['taskId'] == 'what_poker_is_theory'),
    );

    test('unaltered source has no classification mismatch', () {
      final codes = _codes(sourceRows());
      expect(codes, isNot(contains('SOURCE_CLASSIFICATION_MISMATCH')));
      expect(codes, isNot(contains('SOURCE_INPUT_MISMATCH')));
      expect(codes, isNot(contains('SOURCE_TASK_NOT_UNIQUE')));
    });

    test('complete JSON round trip preserves source validation', () {
      final decoded = (jsonDecode(jsonEncode(sourceRows())) as List)
          .map((row) => Map<String, Object?>.from(row as Map)).toList();
      final findings = Cnt01RoleInventoryV1.validateRows(decoded);
      expect(findings, equals(Cnt01RoleInventoryV1.validateRows(sourceRows())));
      expect(findings.where((finding) =>
          finding['code']!.startsWith('SOURCE_FIELD_MISMATCH_') ||
          finding['code'] == 'SOURCE_TASK_MISSING'), isEmpty);
    });

    test('empty or truncated inventory cannot claim full source coverage', () {
      expect(_codes([]), contains('SOURCE_TASK_MISSING'));
      expect(_codes(sourceRows().skip(1).toList()),
          contains('SOURCE_TASK_MISSING'));
    });

    test('copied fingerprint cannot validate fabricated content or provenance', () {
      final mutations = <String, Object?>{
        'taskIdentity': 'FORGED',
        'choiceIds': <String>['invented_choice'],
        'authoredCorrectChoiceIds': <String>['invented_choice'],
        'authoredRationaleByChoiceId': <String, String>{'invented_choice': 'fake'},
        'hasAssessmentChoices': 'not_a_boolean',
        'authoredSourcePath': 'invented/source',
        'authoredRevision': 'invented_revision',
        'responsibleAuthor': 'invented_author',
      };
      for (final mutation in mutations.entries) {
        final row = teachingRow()..[mutation.key] = mutation.value;
        expect(_codes([row]), contains('SOURCE_FIELD_MISMATCH_${mutation.key}'),
            reason: mutation.key);
      }
    });

    test('coherent forged role and basis cannot override source', () {
      final row = teachingRow()
        ..['sourceRole'] = 'REPAIR'
        ..['roleBasis'] = 'stepKind.fixMistakes';
      expect(_codes([row]), contains('SOURCE_CLASSIFICATION_MISMATCH'));
    });

    test('forged basis and each source input are independently rejected', () {
      final basis = teachingRow()..['roleBasis'] = 'taskFamily.learn';
      expect(_codes([basis]), contains('SOURCE_CLASSIFICATION_MISMATCH'));
      for (final field in ['sourcePhase', 'sourceStepKind', 'sourceFamily']) {
        final row = teachingRow()..[field] = 'forged';
        expect(_codes([row]), contains('SOURCE_INPUT_MISMATCH'), reason: field);
      }
      final coherent = teachingRow()
        ..['sourcePhase'] = 'drill'
        ..['sourceStepKind'] = 'fixMistakes'
        ..['sourceFamily'] = 'repair'
        ..['sourceRole'] = 'REPAIR'
        ..['roleBasis'] = 'stepKind.fixMistakes';
      expect(_codes([coherent]), containsAll([
        'SOURCE_INPUT_MISMATCH', 'SOURCE_CLASSIFICATION_MISMATCH',
      ]));
    });

    test('unknown identity cannot borrow another task classification', () {
      final row = teachingRow()..['taskId'] = 'not_an_authored_task';
      expect(_codes([row]), contains('SOURCE_TASK_NOT_UNIQUE'));
    });

    test('missing authored answer remains a gap', () {
      final row = _row()..['authoredCorrectChoiceIds'] = <String>[];
      expect(_codes([row]), contains('AUTHORED_ANSWER_UNKNOWN'));
    });

    test('missing blank unknown and non-string rationale remain gaps', () {
      for (final text in <Object?>[null, '', '  ', 'UNKNOWN', 42]) {
        final row = _row()
          ..['authoredRationaleByChoiceId'] = <String, Object?>{'choice_a': text};
        expect(_codes([row]), contains('AUTHORED_RATIONALE_UNKNOWN'));
      }
    });

    test('Flutter host serializes the full source and preserves errors', () {
      final rows = sourceRows();
      final decoded = jsonDecode(jsonEncode(rows)) as List;
      expect(decoded, hasLength(rows.length));
      expect(decoded, isNotEmpty);
      final broken = teachingRow()..['semanticRevision'] = '';
      final findings = Cnt01RoleInventoryV1.validateRows([broken]);
      expect(findings, contains(containsPair('code', 'MISSING_SEMANTIC_REVISION')));
    });

    test('export rejects relative root and a different package root', () async {
      await expectLater(cnt01ExportV1(repositoryRoot: '.', attestationPath: '.'),
          throwsArgumentError);
      final dir = Directory.systemTemp.createTempSync('cnt01-root-');
      try {
        await expectLater(cnt01ExportV1(repositoryRoot: dir.path,
            attestationPath: '${dir.path}/missing.json'), throwsStateError);
      } finally {
        dir.deleteSync(recursive: true);
      }
    });

    test('export rejects absent receipt revision and incomplete manifest', () async {
      // flutter_tester has no Isolate.resolvePackageUri implementation.
      // Export independently validates this host root against package_config.
      final root = Directory.current.resolveSymbolicLinksSync();
      final dir = Directory.systemTemp.createTempSync('cnt01-receipt-');
      final receipt = File('${dir.path}/receipt.json');
      try {
        await expectLater(cnt01ExportV1(repositoryRoot: root,
            attestationPath: receipt.path), throwsA(isA<FileSystemException>()));
        final metadata = <String, Object?>{
          'schemaVersion': 'cnt01_source_attestation_v1',
          'verifiedBy': 'TEST_FIXTURE_NOT_EXTERNAL_PROVENANCE',
          'baselineMainSha': List<String>.filled(40, 'a').join(),
          'files': <String, String>{},
        };
        receipt.writeAsStringSync(jsonEncode(metadata));
        await expectLater(cnt01ExportV1(repositoryRoot: root,
            attestationPath: receipt.path), throwsStateError);
        metadata['sourceRevision'] = List<String>.filled(40, 'b').join();
        receipt.writeAsStringSync(jsonEncode(metadata));
        await expectLater(cnt01ExportV1(repositoryRoot: root,
            attestationPath: receipt.path), throwsStateError);
        // Correct path set and plausible digests still cannot attest wrong bytes.
        final files = <String, String>{
          for (final path in <String>[
            'pubspec.yaml', 'pubspec.lock',
            'tools/cnt01_role_inventory_v1.dart',
            'test/ui_v2/cnt01_role_inventory_v1_test.dart',
          ]) path: List<String>.filled(64, '0').join(),
        };
        for (final entry in Directory('$root/lib').listSync(
            recursive: true, followLinks: false)) {
          if (entry is File && entry.path.endsWith('.dart')) {
            files[entry.path.substring(root.length + 1)] =
                List<String>.filled(64, '0').join();
          }
        }
        metadata['files'] = files;
        receipt.writeAsStringSync(jsonEncode(metadata));
        await expectLater(cnt01ExportV1(repositoryRoot: root,
            attestationPath: receipt.path), throwsA(isA<StateError>().having(
              (error) => error.message, 'message',
              startsWith('Source attestation mismatch:'),
            )));
        // Positive host-path test only: self-hashed fixture is NOT external
        // provenance and cannot establish accepted revision or editorial owner.
        for (final path in files.keys.toList()) {
          files[path] = sha256.convert(File('$root/$path').readAsBytesSync())
              .toString();
        }
        receipt.writeAsStringSync(jsonEncode(metadata));
        final exported = await cnt01ExportV1(
          repositoryRoot: root, attestationPath: receipt.path,
        );
        expect(exported['status'], 'TECHNICAL_INVENTORY_ONLY_NOT_CNT01_ACCEPTANCE');
        final rows = (exported['rows'] as List).cast<Map<String, Object?>>();
        expect(rows, hasLength(sourceRows().length));
        expect(rows.every((row) => row['responsibleAuthor'] == 'UNKNOWN'), isTrue);
        expect(exported['errors'], equals(
          Cnt01RoleInventoryV1.validateRows(sourceRows())
              .where((finding) => finding['level'] == 'ERROR').toList(),
        ));
      } finally {
        dir.deleteSync(recursive: true);
      }
    });

    test('global duplicate source task ID is an error', () {
      expect(_codes(<Map<String, Object?>>[
        _row(),
        _row(),
      ]), contains('DUPLICATE_TASK_ID'));
    });

    test('missing origin and missing semantic revision fail closed', () {
      final invalid = _row(sourcePath: '', mainSha: '', revision: '');
      final findings = _codes(<Map<String, Object?>>[invalid]);
      expect(findings, contains('MISSING_ORIGIN'));
      expect(findings, contains('MISSING_SEMANTIC_REVISION'));
    });

    test('a seen item cannot be claimed as unseen', () {
      expect(
        _codes(<Map<String, Object?>>[
          _row(role: 'UNSEEN'),
        ], seen: <String>{'task_a'}),
        contains('UNSEEN_ALREADY_PRESENTED'),
      );
    });

    test('an assistance-exposed item cannot be claimed as unseen', () {
      expect(
        _codes(<Map<String, Object?>>[
          _row(role: 'UNSEEN'),
        ], assisted: <String>{'task_a'}),
        contains('UNSEEN_ASSISTANCE_EXPOSED'),
      );
    });

    test('a new ID alone cannot establish unseen eligibility', () {
      expect(
        _codes(<Map<String, Object?>>[_row(role: 'UNSEEN')]),
        contains('UNSEEN_NEEDS_SOURCE_AND_LEARNER_PROOF'),
      );
    });

    test('a review label alone cannot establish elapsed retention', () {
      expect(
        _codes(<Map<String, Object?>>[_row(role: 'ELAPSED')]),
        contains('ELAPSED_NEEDS_REAL_TIME_INDEPENDENT_PROOF'),
      );
    });

    test('source role conflicts are detected', () {
      expect(
        _codes(<Map<String, Object?>>[
          _row(role: 'TEACHING', basis: 'stepKind.fixMistakes'),
        ]),
        contains('ROLE_COLLISION'),
      );
    });

    test('missing author revision and responsible origin remain gaps', () {
      final findings =
          Cnt01RoleInventoryV1.validateRows(<Map<String, Object?>>[_row()]);
      expect(
        findings.where((item) =>
            item['code'] == 'AUTHOR_REVISION_UNKNOWN' &&
            item['level'] == 'GAP'),
        hasLength(1),
      );
      expect(_codes(<Map<String, Object?>>[_row()]),
          contains('RESPONSIBLE_UNKNOWN'));
    });

    test('duplicated choice IDs and answers outside choices are rejected', () {
      final invalid = _row();
      invalid['choiceIds'] = <String>['choice_a', 'choice_a'];
      invalid['authoredCorrectChoiceIds'] = <String>['missing'];
      final codes = _codes(<Map<String, Object?>>[invalid]);
      expect(codes, contains('DUPLICATE_CHOICE_ID'));
      expect(codes, contains('ANSWER_NOT_IN_CHOICES'));
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/runtime_asset_resolution_audit_v1.dart';

void main() {
  test('synthetic repo catches runtime bundle omission and empty bundled asset', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'runtime_asset_resolution_audit_v1_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final manifestDir = Directory('${tempRoot.path}/content/_meta')
      ..createSync(recursive: true);
    File('${manifestDir.path}/world_drills_manifest_v1.json').writeAsStringSync(
      jsonEncode(<String, Object?>{
        'version': 1,
        'worlds': <Object?>[
          <String, Object?>{
            'world': 4,
            'sessions': <Object?>[
              <String, Object?>{
                'id': 'w4.s03',
                'path': 'content/worlds/world4/v1/sessions/w4.s03/',
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

    final sourceSessionDir = Directory(
      '${tempRoot.path}/content/worlds/world4/v1/sessions/w4.s03/drills',
    )..createSync(recursive: true);
    File(
      '${tempRoot.path}/content/worlds/world4/v1/sessions/w4.s03/session.md',
    ).writeAsStringSync('session');
    File('${sourceSessionDir.path}/index.md').writeAsStringSync(
      '- chain_world4_purpose_checkpoint_v1: checkpoint\n'
      '- choose_raise_value: action\n',
    );
    File(
      '${sourceSessionDir.path}/d.chain_world4_purpose_checkpoint_v1.json',
    ).writeAsStringSync('{"id":"chain_world4_purpose_checkpoint_v1"}');
    File(
      '${sourceSessionDir.path}/d.choose_raise_value.json',
    ).writeAsStringSync('{"id":"choose_raise_value"}');

    final runtimeRoot = Directory('${tempRoot.path}/build/flutter_assets')
      ..createSync(recursive: true);
    final runtimeSessionDir = Directory(
      '${runtimeRoot.path}/content/worlds/world4/v1/sessions/w4.s03/drills',
    )..createSync(recursive: true);
    File(
      '${runtimeRoot.path}/content/worlds/world4/v1/sessions/w4.s03/session.md',
    ).writeAsStringSync('session');
    File('${runtimeSessionDir.path}/index.md').writeAsStringSync('index');
    File(
      '${runtimeSessionDir.path}/d.choose_raise_value.json',
    ).writeAsStringSync('   ');

    final report = buildRuntimeAssetResolutionAuditReportV1(
      rootPath: tempRoot.path,
      options: RuntimeAssetResolutionAuditOptionsV1(
        world: 4,
        runtimeRoot: runtimeRoot.path,
      ),
    );

    expect(report.summary.errorCount, equals(2));
    expect(report.summary.reasonCounts['runtime_bundle_omission'], equals(1));
    expect(
      report.summary.reasonCounts['runtime_bundle_empty_asset'],
      equals(1),
    );
  });

  test('json output stays stable for representative world filtering', () {
    final report = buildRuntimeAssetResolutionAuditReportV1(
      options: const RuntimeAssetResolutionAuditOptionsV1(world: 4),
    );
    final decoded =
        jsonDecode(encodeRuntimeAssetResolutionAuditReportJsonV1(report))
            as Map<String, Object?>;
    final summary = decoded['summary'] as Map<String, Object?>;

    expect(decoded['version'], 'v1');
    expect(summary['total_issues'], isNotNull);
    expect(summary['runtime_roots_scanned'], isNotNull);
    expect(summary['reason_counts'], isNotNull);
  });
}

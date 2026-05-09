import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

import '../tools/modern_table_audit_pack_hint_v1.dart' as tool;

void main() {
  test('prints run command when zip is missing', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'modern_table_audit_pack_missing_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    String? output;
    await runZoned(
      () async {
        tool.main([tempDir.path]);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          output = line;
        },
      ),
    );

    expect(
      output,
      'RUN: dart run tools/modern_table_screenshot_v1.dart && '
      'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh',
    );
  });

  test('prints pack env var when zip exists', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'modern_table_audit_pack_present_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final outDir = Directory('${tempDir.path}${Platform.pathSeparator}out');
    await outDir.create();
    final zipFile = File(
      '${outDir.path}${Platform.pathSeparator}modern_table_screenshots_v1.zip',
    );
    await zipFile.writeAsString('ok');

    String? output;
    await runZoned(
      () async {
        tool.main([tempDir.path]);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          output = line;
        },
      ),
    );

    expect(
      output,
      'MODERN_TABLE_AUDIT_PACK=out/modern_table_screenshots_v1.zip',
    );
  });
}

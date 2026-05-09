import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

import '../tools/modern_table_audit_hub_v1.dart' as hub;

void main() {
  Future<String?> _captureOutput(List<String> args) async {
    String? output;
    await runZoned(
      () async {
        hub.main(args);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          output = line;
        },
      ),
    );
    return output;
  }

  test('audit hub prints sections in order with single blank lines', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'modern_table_audit_hub_present_',
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

    final output = await _captureOutput(['--root', tempDir.path]);
    expect(output, isNotNull);

    final rendered = output!;
    expect(
      rendered.startsWith(
        'MODERN_TABLE_AUDIT_PACK=out/modern_table_screenshots_v1.zip',
      ),
      isTrue,
    );
    expect(rendered.contains('- [ ] Felt spotlight/vignette'), isTrue);
    expect(rendered.contains('Modern Table Visual Cohesion'), isTrue);
    expect(rendered.contains('Commands'), isTrue);
    expect(
      rendered.contains('dart run tools/modern_table_screenshot_v1.dart'),
      isTrue,
    );
    expect(
      rendered.contains(
        'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh',
      ),
      isTrue,
    );
    expect(
      rendered.contains('bash tools/modern_table_audit_run_v1.sh'),
      isTrue,
    );
  });
}

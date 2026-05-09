import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('store package docs include guard guidance', () {
    final ssot = File('docs/release/store_package_v1.md');
    final readme = File('assets/store/README.md');
    final metadataTruth = File('docs/release/submission_metadata_truth_v1.md');
    final missing = <String>[];
    if (!ssot.existsSync()) missing.add('docs/release/store_package_v1.md');
    if (!readme.existsSync()) missing.add('assets/store/README.md');
    if (!metadataTruth.existsSync()) {
      missing.add('docs/release/submission_metadata_truth_v1.md');
    }
    if (missing.isNotEmpty) {
      fail('Missing store package docs: ${missing.join(', ')}');
    }

    final ssotContent = ssot.readAsStringSync();
    final readmeContent = readme.readAsStringSync();
    final metadataTruthContent = metadataTruth.readAsStringSync();

    final checks = <String, bool>{
      'STORE_PACKAGE_GUARD=1': ssotContent.contains('STORE_PACKAGE_GUARD=1'),
      'canonical proof artifact path': ssotContent.contains(
        'out/modern_table_screenshots_v1.zip',
      ),
      'default skip if proof artifact missing': ssotContent.contains(
        'guard **skips** if `out/modern_table_screenshots_v1.zip` is missing',
      ),
      'enforce during Store Package preparation': ssotContent.contains(
        'Store Package preparation / release checklist',
      ),
      'optional assets/store import layout': ssotContent.contains(
        'assets/store/` remains an optional import layout',
      ),
      '"<platform>-<set>-<index>.png" in README': readmeContent.contains(
        '<platform>-<set>-<index>.png',
      ),
      'platform markers ios/android':
          readmeContent.contains('ios') && readmeContent.contains('android'),
      'Required Files section': readmeContent.contains('## Required Files'),
      'Telemetry guard section': ssotContent.contains('Telemetry guard'),
      'Telemetry guard command': ssotContent.contains(
        'dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m',
      ),
      'support contact uses runtime truth': ssotContent.contains(
        'support@sharky.app',
      ),
      'example.com placeholders removed':
          !ssotContent.contains('www.example.com') &&
          !ssotContent.contains('example.com/support') &&
          !ssotContent.contains('example.com/poker'),
      'submission urls explicitly unresolved':
          ssotContent.contains(
            'Support URL / Marketing URL for store submission',
          ) &&
          ssotContent.contains('unresolved on current main'),
      'legal entity placeholder removed':
          !ssotContent.contains('Sharky Labs') &&
          ssotContent.contains('Legal entity / Copyright for store submission'),
      'runtime legal source documented': ssotContent.contains(
        'lib/ui_v2/settings/legal_screen_v1.dart',
      ),
      'canonical metadata owner referenced in ssot': ssotContent.contains(
        'docs/release/submission_metadata_truth_v1.md',
      ),
      'readme references metadata truth owner': readmeContent.contains(
        'docs/release/submission_metadata_truth_v1.md',
      ),
      'metadata truth defines unresolved support url': metadataTruthContent
          .contains('Support URL: unresolved on current `main`'),
      'metadata truth defines unresolved marketing url': metadataTruthContent
          .contains('Marketing URL: unresolved on current `main`'),
      'metadata truth defines unresolved legal entity': metadataTruthContent
          .contains('Legal entity display name: unresolved on current `main`'),
      'metadata truth forbids placeholder urls':
          !metadataTruthContent.contains('https://www.example.com') &&
          !metadataTruthContent.contains('http://www.example.com') &&
          metadataTruthContent.contains(
            'Do not use `example.com`, sample domains, or fake production URLs.',
          ),
      'metadata truth declares canonical owner': metadataTruthContent.contains(
        'is the canonical owner for',
      ),
    };

    final failed = checks.entries.where((entry) => !entry.value).toList();
    if (failed.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('Store package docs sync contract failed:')
        ..writeln('Missing expectations:')
        ..writeln(failed.map((e) => '- ${e.key}').join('\n'));
      fail(buffer.toString());
    }
  });
}

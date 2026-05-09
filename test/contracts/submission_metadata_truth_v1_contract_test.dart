import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'submission metadata truth stays bounded, unresolved, and placeholder-free',
    () {
      final metadataOwner = File(
        'docs/release/submission_metadata_truth_v1.md',
      );
      final storePackage = File('docs/release/store_package_v1.md');

      expect(metadataOwner.existsSync(), isTrue);
      expect(storePackage.existsSync(), isTrue);

      final metadataContent = metadataOwner.readAsStringSync();
      final storePackageContent = storePackage.readAsStringSync();

      expect(metadataContent, contains('support@sharky.app'));
      expect(
        metadataContent,
        contains('Support URL: unresolved on current `main`'),
      );
      expect(
        metadataContent,
        contains('Marketing URL: unresolved on current `main`'),
      );
      expect(
        metadataContent,
        contains('Legal entity display name: unresolved on current `main`'),
      );
      expect(
        metadataContent,
        contains(
          'Copyright line for store submission: unresolved on current `main`',
        ),
      );
      expect(
        metadataContent,
        contains(
          'Do not use `example.com`, sample domains, or fake production URLs.',
        ),
      );
      expect(metadataContent, isNot(contains('https://www.example.com')));
      expect(metadataContent, isNot(contains('http://www.example.com')));
      expect(metadataContent, isNot(contains('Sharky Labs')));
      expect(
        metadataContent,
        contains('lib/ui_v2/settings/legal_screen_v1.dart'),
      );
      expect(metadataContent, contains('lib/ui/settings/privacy_terms.dart'));
      expect(metadataContent, contains('Current Bounded Proof On Main'));
      expect(
        metadataContent,
        contains(
          'This owner records unresolved submission-only metadata truth on current',
        ),
      );
      expect(
        metadataContent,
        contains('This owner does not claim store submission readiness.'),
      );
      expect(
        metadataContent,
        contains('This owner does not claim final release completion.'),
      );
      expect(
        metadataContent,
        contains('surface is overstating repo truth and must be corrected'),
      );

      expect(
        storePackageContent,
        contains('docs/release/submission_metadata_truth_v1.md'),
      );
    },
  );
}

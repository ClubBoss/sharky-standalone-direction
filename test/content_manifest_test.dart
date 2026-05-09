import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:poker_analyzer/content/manifest.dart';

void main() {
  test('manifest loading', () {
    expect(File(ContentManifest.path).existsSync(), isTrue);

    final m = ContentManifest.loadSync();
    expect(m.modules, isA<Set<String>>());
    expect(m.isReady('cash:l3:v1'), isTrue);
    expect(isReady('cash:l3:v1'), isTrue);
  });
}

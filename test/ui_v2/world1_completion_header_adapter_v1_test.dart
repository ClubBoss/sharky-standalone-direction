import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_completion_header_adapter_v1.dart';

void main() {
  test('world1 completion header adapter uses shared section vocabulary', () {
    final adapter = buildWorld1CompletionHeaderAdapterV1();

    expect(adapter.sections.showIntro, isFalse);
    expect(adapter.sections.showSourceMeta, isFalse);
    expect(adapter.sections.showRecap, isFalse);
    expect(adapter.sections.showCompletionInHeader, isTrue);
    expect(adapter.sections.showEmbeddedFeedbackBelowTable, isFalse);
    expect(adapter.shouldShowOutcomeStatus(outcomeVisible: true), isTrue);
    expect(adapter.shouldShowOutcomeStatus(outcomeVisible: false), isFalse);
  });
}

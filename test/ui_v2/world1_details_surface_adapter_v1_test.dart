import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_details_surface_adapter_v1.dart';

void main() {
  test('world1 details surface adapter uses shared section vocabulary', () {
    final adapter = buildWorld1DetailsSurfaceAdapterV1(
      sourceId: 'world1_spine_campaign_v1#step2',
      canonicalPrompt: 'Take the best action.',
      detailsPromptOverride: 'Choose the best action.',
    );

    expect(adapter.presentation.shortPrompt, 'Take the best action.');
    expect(adapter.presentation.detailsPrompt, 'Choose the best action.');
    expect(adapter.canOpenDetailsSheet, isTrue);
    expect(adapter.sections.showIntro, isFalse);
    expect(adapter.sections.showSourceMeta, isFalse);
    expect(adapter.sections.showRecap, isTrue);
    expect(adapter.sections.showCompletionInHeader, isFalse);
    expect(adapter.sections.showEmbeddedFeedbackBelowTable, isFalse);
    expect(adapter.sourceMeta.entries, isEmpty);
  });
}

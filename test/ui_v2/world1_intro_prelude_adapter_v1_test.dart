import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_intro_prelude_adapter_v1.dart';

void main() {
  test('world1 intro prelude adapter uses shared section vocabulary', () {
    final adapter = buildWorld1IntroPreludeAdapterV1();

    expect(adapter.sections.showIntro, isTrue);
    expect(adapter.sections.showSourceMeta, isFalse);
    expect(adapter.sections.showRecap, isFalse);
    expect(adapter.sections.showCompletionInHeader, isFalse);
    expect(adapter.sections.showEmbeddedFeedbackBelowTable, isFalse);
    expect(
      adapter.shouldShowIntroSurface(
        preludeVisible: true,
        introVisible: false,
      ),
      isTrue,
    );
    expect(
      adapter.shouldShowIntroSurface(
        preludeVisible: false,
        introVisible: true,
      ),
      isTrue,
    );
    expect(
      adapter.shouldShowIntroSurface(
        preludeVisible: false,
        introVisible: false,
      ),
      isFalse,
    );
  });
}

/// Passive fake hand preview map V1 (Phi-57.10).
class FakeHandPreviewV1 {
  const FakeHandPreviewV1(this.previewBridgeMap);

  final Object previewBridgeMap;

  Map<String, Object> asReadOnlyMap() {
    final Object previewCandidate = previewBridgeMap;
    final bool hasPreview =
        previewCandidate is Map && previewCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasPreview) missing.add('preview_bridge');

    Map<String, Object> _card() {
      final Map preview = hasPreview
          ? (previewCandidate as Map)['preview_bridge'] as Map? ??
                <String, Object>{}
          : <String, Object>{};
      return <String, Object>{
        'face': preview['face'] ?? <Object>{},
        'back': preview['back'] ?? <Object>{},
        'layout_rect': preview['layout_rect'] ?? <Object>{},
      };
    }

    final Map<String, Object> fakeHandPreview = <String, Object>{
      'card_1': _card(),
      'card_2': _card(),
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'fake_hand_preview': fakeHandPreview,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

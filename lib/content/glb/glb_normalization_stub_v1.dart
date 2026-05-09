import '../content_root.dart';

class GLBNormalizationStubV1 {
  final Map<String, Object> normalized;

  const GLBNormalizationStubV1(this.normalized);

  Map<String, Object> asMap() => <String, Object>{'normalized': normalized};

  static Map<String, Object> buildStub() {
    final Map<String, Object> master = const ContentRoot()
        .buildGLBMasterExportV1();
    return <String, Object>{
      'normalized': <String, Object>{
        'source_master': master,
        'normalization': 'placeholder_glb_normalization_v1',
        'status': 'stub_ready',
      },
    };
  }
}

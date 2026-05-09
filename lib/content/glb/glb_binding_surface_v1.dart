import '../content_root.dart';

class GLBBindingSurfaceV1 {
  final Map<String, Object> binding;

  const GLBBindingSurfaceV1(this.binding);

  Map<String, Object> asMap() => <String, Object>{'binding': binding};

  static Map<String, Object> buildStub() {
    final Map<String, Object> normalized = const ContentRoot()
        .buildGLBNormalizationStubV1();
    return <String, Object>{
      'binding': <String, Object>{
        'normalized': normalized,
        'binding_metadata': 'placeholder_glb_binding_v1',
        'status': 'stub_ready',
      },
    };
  }
}

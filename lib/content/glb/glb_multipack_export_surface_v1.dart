import '../content_root.dart';

class GLBMultipackExportSurfaceV1 {
  final Map<String, Object> exportData;

  const GLBMultipackExportSurfaceV1(this.exportData);

  Map<String, Object> asMap() => <String, Object>{'export': exportData};

  static Map<String, Object> buildStub() {
    final Map<String, Object> loader = const ContentRoot()
        .buildGLBMultipackLoaderV1();
    return <String, Object>{
      'export': <String, Object>{
        'multipack': loader,
        'metadata': 'placeholder_glb_export_surface_v1',
      },
    };
  }
}

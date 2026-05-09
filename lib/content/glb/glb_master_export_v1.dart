import '../content_root.dart';

class GLBMasterExportV1 {
  final Map<String, Object> master;

  const GLBMasterExportV1(this.master);

  Map<String, Object> asMap() => <String, Object>{'master': master};

  static Map<String, Object> buildStub() {
    const ContentRoot root = ContentRoot();
    final Map<String, Object> registry = root.buildGLBPackRegistryV1();
    final Map<String, Object> descriptor = root.buildGLBPackDescriptorV1();
    final Map<String, Object> multipack = root.buildGLBMultipackLoaderV1();
    final Map<String, Object> exportSurface = root
        .buildGLBMultipackExportSurfaceV1();
    final Map<String, Object> cashL3Pack = root.exportCashL3PackV1();
    final Map<String, Object> cashL3QA = root.buildCashL3PackQASurfaceV1();

    return <String, Object>{
      'master': <String, Object>{
        'registry': registry,
        'descriptor': descriptor,
        'multipack': multipack,
        'export_surface': exportSurface,
        'cash_l3_pack': cashL3Pack,
        'cash_l3_qa': cashL3QA,
        'metadata': 'placeholder_glb_master_export_v1',
      },
    };
  }
}

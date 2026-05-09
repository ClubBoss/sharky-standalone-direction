import 'glb_pack_descriptor_v1.dart';

class GLBPackRegistryV1 {
  final Map<String, Object> registry;

  const GLBPackRegistryV1(this.registry);

  Map<String, Object> asMap() => <String, Object>{'registry': registry};

  static Map<String, Object> buildStubRegistry() => <String, Object>{
    'cash_l3_v1': <String, Object>{
      'descriptor': const GLBPackDescriptorV1(
        id: 'glb_pack_descriptor_stub_v1',
        version: 'v1',
        family: 'placeholder_family',
        moduleCount: 0,
        metadata: 'placeholder_metadata',
      ).asMap(),
      'notes': 'placeholder_glb_registry_entry',
    },
  };
}

import '../content_root.dart';
import 'glb_pack_descriptor_v1.dart';

class GLBCashL3RegistrationBridgeV1 {
  final Map<String, Object> descriptor;
  final Map<String, Object> pack;
  final Map<String, Object> qaSurface;
  final Map<String, Object> registryEntry;

  const GLBCashL3RegistrationBridgeV1(
    this.descriptor,
    this.pack,
    this.qaSurface,
    this.registryEntry,
  );

  Map<String, Object> asMap() => <String, Object>{
    'descriptor': descriptor,
    'pack': pack,
    'qa_surface': qaSurface,
    'registry_entry': registryEntry,
  };

  static Map<String, Object> buildStub() {
    final Map<String, Object> descriptor = GLBPackDescriptorV1(
      id: 'cash_l3_v1',
      version: 'v1',
      family: 'cash',
      moduleCount: 1,
      metadata: 'placeholder_cash_l3_descriptor',
    ).asMap();

    final Map<String, Object> pack = ContentRoot().exportCashL3PackV1();
    final Map<String, Object> qaSurface = ContentRoot()
        .buildCashL3PackQASurfaceV1();

    final Map<String, Object> registryEntry = <String, Object>{
      'descriptor': descriptor,
      'notes': 'placeholder_registry_cash_l3',
    };

    return GLBCashL3RegistrationBridgeV1(
      descriptor,
      pack,
      qaSurface,
      registryEntry,
    ).asMap();
  }
}

import '../content_root.dart';

class GLBMultipackLoaderV1 {
  final Map<String, Object> packs;

  const GLBMultipackLoaderV1(this.packs);

  Map<String, Object> asMap() => <String, Object>{'packs': packs};

  static Map<String, Object> buildStub() {
    final Map<String, Object> cashL3 = const ContentRoot()
        .buildGLBCashL3RegistrationBridgeV1();
    return <String, Object>{
      'packs': <String, Object>{'cash_l3_v1': cashL3},
      'metadata': 'placeholder_multipack_loader_v1',
    };
  }
}

import 'cash_l3_generation_core_v1.dart';
import 'cash_l3_real_generation_bridge_v1.dart';

class CashL3ComposePipelineV1 {
  const CashL3ComposePipelineV1(this.core, this.realBridge);

  final CashL3GenerationCoreV1 core;
  final CashL3RealGenerationBridgeV1 realBridge;

  Map<String, Object?> composeOnce() {
    final coreRun = core.runOnce();
    final moduleId = coreRun['selected'];
    final realModule = realBridge.buildRealModule(moduleId as String);
    return <String, Object?>{
      'core': coreRun,
      'real': realModule,
      'status': 'compose_stub',
    };
  }
}

import 'cash_l3_real_generation_v1.dart';

class CashL3RealGenerationBridgeV1 {
  const CashL3RealGenerationBridgeV1(this.realGen);

  final CashL3RealGenerationV1 realGen;

  Map<String, Object?> buildRealModule(String moduleId) => <String, Object?>{
    'id': moduleId,
    'theory': realGen.generateTheory(moduleId),
    'drills': realGen.generateDrills(moduleId),
    'recap': realGen.generateRecap(moduleId),
    'quiz': realGen.generateQuiz(moduleId),
  };
}

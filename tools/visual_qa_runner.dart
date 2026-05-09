import 'package:poker_analyzer/ui_v2/theme_v3/visual_qa_orchestrator_v3.dart';

void main(List<String> args) {
  final orchestrator = VisualQAOrchestratorV3();
  orchestrator.initialize();
  orchestrator.runFullVisualAudit();
}

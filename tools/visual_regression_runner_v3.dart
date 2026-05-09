import 'package:poker_analyzer/ui_v2/theme_v3/visual_regression_orchestrator_v3.dart';

void main(List<String> args) {
  final orchestrator = VisualRegressionOrchestratorV3();
  orchestrator.initialize();
  orchestrator.runFullRegression();
}

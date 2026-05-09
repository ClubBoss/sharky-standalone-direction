import 'personalization_context.dart';

class DifficultyAssistRouter {
  DifficultyAssistRouter(this.ctx);

  final PersonalizationContext ctx;

  double get difficultyTrend {
    // TODO(Φ-AI): derive from ctx.accuracyTrend later.
    return 0.0;
  }

  double get reinforcementBias {
    // TODO(Φ-AI): derive from ctx.errorBurstFlag later.
    return 0.0;
  }

  int get decisionAssistLevel {
    // TODO(Φ-AI): derive from ctx.decisionSpeed later.
    return 0;
  }
}

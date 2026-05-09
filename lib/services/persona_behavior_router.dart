import 'personalization_context.dart';

class PersonaBehaviorRouter {
  PersonaBehaviorRouter(this.ctx);

  final PersonalizationContext ctx;

  double get expressionLevel {
    final base = 1.0;
    // TODO(Φ-AI): derive expression intensity from ctx in the future.
    return base;
  }

  String get tone {
    // TODO(Φ-AI): derive persona tone from ctx in the future.
    return 'neutral';
  }

  bool get shouldSoftenHints {
    // TODO(Φ-AI): use ctx.errorBurstFlag when adaptive hints are available.
    return false;
  }

  // TODO(Φ-AI): plug adaptive behavioral logic here later.
}

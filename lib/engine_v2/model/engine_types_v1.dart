enum EngineStateKindV1 { setup, streetActive, evaluation, outcome }

enum StreetPhaseV1 { acting, resolving }

class EngineViolationV1 {
  const EngineViolationV1({required this.code, required this.message});

  final String code;
  final String message;

  @override
  bool operator ==(Object other) {
    if (other is! EngineViolationV1) {
      return false;
    }
    return code == other.code && message == other.message;
  }

  @override
  int get hashCode => Object.hash(code, message);
}

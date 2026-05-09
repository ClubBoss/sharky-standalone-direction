enum DecisionVerdictV1 { correct, incorrect }

enum ErrorTypeV1 { sizing, range, timing, logic }

class ErrorDetailV1 {
  const ErrorDetailV1({
    required this.type,
    required this.code,
    required this.message,
    this.expected,
    this.actual,
  });

  final ErrorTypeV1 type;
  final String code;
  final String message;
  final String? expected;
  final String? actual;

  @override
  bool operator ==(Object other) {
    if (other is! ErrorDetailV1) {
      return false;
    }
    return type == other.type &&
        code == other.code &&
        message == other.message &&
        expected == other.expected &&
        actual == other.actual;
  }

  @override
  int get hashCode => Object.hash(type, code, message, expected, actual);
}

class ErrorClassificationV1 {
  const ErrorClassificationV1();

  ErrorDetailV1 fromViolation({
    required String code,
    required String message,
    String? expected,
    String? actual,
  }) {
    final normalized = code.toLowerCase();

    if (_isTimingCode(normalized)) {
      return ErrorDetailV1(
        type: ErrorTypeV1.timing,
        code: code,
        message: message,
        expected: expected,
        actual: actual,
      );
    }

    if (_isSizingCode(normalized)) {
      return ErrorDetailV1(
        type: ErrorTypeV1.sizing,
        code: code,
        message: message,
        expected: expected,
        actual: actual,
      );
    }

    return ErrorDetailV1(
      type: ErrorTypeV1.logic,
      code: code,
      message: message,
      expected: expected,
      actual: actual,
    );
  }

  ErrorDetailV1 fromRangeMismatch({
    required String expected,
    required String actual,
  }) {
    return ErrorDetailV1(
      type: ErrorTypeV1.range,
      code: 'range_expectation_mismatch',
      message: 'Action is valid but does not match expected strategy action',
      expected: expected,
      actual: actual,
    );
  }

  bool _isTimingCode(String code) {
    return code.contains('check_requires_zero_to_call') ||
        code.contains('call_requires_positive_to_call') ||
        code.contains('invalid_advance_transition') ||
        code.contains('invalid_finish_transition') ||
        code.contains('action_outside_acting_phase');
  }

  bool _isSizingCode(String code) {
    return code.contains('bet_exceeds_stack') ||
        code.contains('invalid_bet_amount') ||
        code.contains('raise_to_not_above_current_bet') ||
        code.contains('raise_exceeds_stack') ||
        code.contains('invalid_raise_delta') ||
        code.contains('missing_raise_to_amount');
  }
}

// lib/services/payment_gateway_service.dart
// Stage 25: Payments Integration (Mock)
//
// Pure Dart mock payment gateway for sandbox testing.
// No real Stripe/Apple/Google keys or network calls.
// ASCII-only, deterministic success for CI stability.

/// Mock payment gateway for premium purchases.
class PaymentGatewayService {
  static final PaymentGatewayService _instance =
      PaymentGatewayService._internal();
  factory PaymentGatewayService() => _instance;
  PaymentGatewayService._internal();

  bool _initialized = false;
  String? _lastReceipt;

  /// Initialize the mock gateway (sandbox).
  Future<void> initGateway() async {
    // Simulate lightweight setup
    _initialized = true;
  }

  /// Purchase premium and return a mock ASCII receipt string.
  ///
  /// This does not trigger platform channels or network calls.
  Future<String> purchasePremium() async {
    if (!_initialized) {
      await initGateway();
    }
    final now = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    _lastReceipt = 'MOCK-RECEIPT-$now-0001';
    return _lastReceipt!;
  }

  /// Validate the provided receipt.
  ///
  /// Simulates successful validation with a deterministic score within 80–100%.
  Future<Map<String, dynamic>> validateReceipt(String receipt) async {
    // Deterministic success score for CI (95%)
    const score = 0.95;
    final success = receipt.isNotEmpty && score >= 0.8;
    return {'success': success, 'score': score, 'receipt': receipt};
  }

  /// Returns current gateway status for health dashboard.
  Map<String, Object> getStatus() {
    return {'initialized': _initialized, 'hasReceipt': _lastReceipt != null};
  }
}
